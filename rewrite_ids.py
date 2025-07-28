#!/usr/bin/env python3
"""
Script to rewrite IDs in OMOP CSV files to use smaller sequential integers
while maintaining referential integrity. Excludes concept_id and vocabulary-related columns.
"""

import os
import gzip
import pandas as pd
import tempfile
from collections import defaultdict
import shutil

# Define which columns contain IDs that need to be rewritten
# Format: {table_name: [list_of_id_columns]}
ID_COLUMNS = {
    'person': ['person_id'],
    'visit_occurrence': ['visit_occurrence_id', 'person_id', 'provider_id', 'care_site_id'],
    'condition_occurrence': ['condition_occurrence_id', 'person_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id'],
    'drug_exposure': ['drug_exposure_id', 'person_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id'],
    'measurement': ['measurement_id', 'person_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id'],
    'observation': ['observation_id', 'person_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id'],
    'procedure_occurrence': ['procedure_occurrence_id', 'person_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id'],
    'device_exposure': ['device_exposure_id', 'person_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id'],
    'death': ['person_id'],
    'note': ['note_id', 'person_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id'],
    'note_nlp': ['note_nlp_id', 'note_id'],
    'observation_period': ['observation_period_id', 'person_id'],
    'specimen': ['specimen_id', 'person_id'],
    'visit_detail': ['visit_detail_id', 'person_id', 'provider_id', 'care_site_id', 'visit_occurrence_id'],
    'cost': ['cost_id', 'person_id', 'cost_event_id', 'payer_plan_period_id'],
    'drug_era': ['drug_era_id', 'person_id'],
    'dose_era': ['dose_era_id', 'person_id'],
    'condition_era': ['condition_era_id', 'person_id'],
    'location': ['location_id'],
    'care_site': ['care_site_id', 'location_id'],
    'provider': ['provider_id', 'care_site_id'],
    'payer_plan_period': ['payer_plan_period_id', 'person_id'],
    'cohort': ['subject_id'],
    'cohort_attribute': ['subject_id'],
    'fact_relationship': ['fact_id_1', 'fact_id_2']
}

# Define cross-table ID relationships for referential integrity
# Format: {table_name: {column_name: (referenced_table, referenced_column)}}
CROSS_TABLE_IDS = {
    'visit_occurrence': {
        'preceding_visit_occurrence_id': ('visit_occurrence', 'visit_occurrence_id')
    },
    'visit_detail': {
        'preceding_visit_detail_id': ('visit_detail', 'visit_detail_id'),
        'visit_detail_parent_id': ('visit_detail', 'visit_detail_id')
    }
}

# Columns to exclude from ID rewriting (concept and vocabulary related)
EXCLUDED_COLUMNS = {
    'concept_id', 'gender_concept_id', 'race_concept_id', 'ethnicity_concept_id',
    'visit_concept_id', 'visit_type_concept_id', 'visit_source_concept_id',
    'admitted_from_concept_id', 'discharged_to_concept_id',
    'condition_concept_id', 'condition_type_concept_id', 'condition_status_concept_id',
    'condition_source_concept_id',
    'drug_concept_id', 'drug_type_concept_id', 'drug_source_concept_id',
    'route_concept_id',
    'measurement_concept_id', 'measurement_type_concept_id', 'operator_concept_id',
    'value_as_concept_id', 'unit_concept_id', 'measurement_source_concept_id',
    'observation_concept_id', 'observation_type_concept_id', 'value_as_concept_id',
    'qualifier_concept_id', 'unit_concept_id', 'observation_source_concept_id',
    'procedure_concept_id', 'procedure_type_concept_id', 'modifier_concept_id',
    'procedure_source_concept_id',
    'device_concept_id', 'device_type_concept_id', 'device_source_concept_id',
    'death_type_concept_id', 'cause_concept_id', 'cause_source_concept_id',
    'note_type_concept_id', 'note_class_concept_id', 'encoding_concept_id',
    'language_concept_id',
    'section_concept_id', 'note_nlp_concept_id', 'note_nlp_source_concept_id',
    'period_type_concept_id',
    'specimen_concept_id', 'specimen_type_concept_id', 'unit_concept_id',
    'anatomic_site_concept_id', 'disease_status_concept_id',
    'visit_detail_concept_id', 'visit_detail_type_concept_id',
    'visit_detail_source_concept_id', 'admitted_from_concept_id',
    'discharged_to_concept_id',
    'cost_type_concept_id', 'currency_concept_id', 'revenue_code_concept_id',
    'drg_concept_id',
    'drug_concept_id',  # in drug_era and dose_era
    'unit_concept_id',  # in dose_era
    'condition_concept_id',  # in condition_era
    'country_concept_id',
    'place_of_service_concept_id',
    'specialty_concept_id', 'gender_concept_id', 'specialty_source_concept_id',
    'gender_source_concept_id',
    'payer_concept_id', 'payer_source_concept_id', 'plan_concept_id',
    'plan_source_concept_id', 'sponsor_concept_id', 'sponsor_source_concept_id',
    'stop_reason_concept_id', 'stop_reason_source_concept_id',
    'cohort_definition_id', 'attribute_definition_id', 'value_as_concept_id',
    'domain_concept_id_1', 'domain_concept_id_2', 'relationship_concept_id',
    'metadata_concept_id', 'metadata_type_concept_id', 'value_as_concept_id',
    'relationship_concept_id',
    'ingredient_concept_id', 'amount_unit_concept_id', 'numerator_unit_concept_id',
    'denominator_unit_concept_id',
    'domain_concept_id',
    'concept_class_concept_id',
    'language_concept_id'
}

def get_csv_files():
    """Get all CSV files in the omop_data_csv directory"""
    csv_dir = "omop_data_csv"
    if not os.path.exists(csv_dir):
        print(f"Directory {csv_dir} not found!")
        return []
    
    csv_files = []
    for file in os.listdir(csv_dir):
        if file.endswith('.csv.gz'):
            table_name = file.replace('.csv.gz', '')
            csv_files.append((table_name, os.path.join(csv_dir, file)))
    
    return csv_files

def ensure_output_dir():
    """Create output directory if it doesn't exist"""
    output_dir = "omop_data_csv_rewritten"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created output directory: {output_dir}")
    return output_dir

def read_csv_file(file_path):
    """Read a gzipped CSV file"""
    try:
        # Try CSVWithNames first
        df = pd.read_csv(file_path, compression='gzip', low_memory=False)
        return df
    except Exception as e:
        try:
            # Try TabSeparatedWithNames if CSV fails
            df = pd.read_csv(file_path, compression='gzip', sep='\t', low_memory=False)
            return df
        except Exception as e2:
            print(f"Error reading {file_path}: {e2}")
            return None

def create_id_mappings(df, id_columns):
    """Create mappings from old IDs to new sequential IDs"""
    mappings = {}
    
    for col in id_columns:
        if col in df.columns:
            # Get unique non-null values
            unique_values = df[col].dropna().unique()
            if len(unique_values) > 0:
                # Create mapping from old to new sequential IDs
                new_ids = range(1, len(unique_values) + 1)
                mappings[col] = dict(zip(unique_values, new_ids))
                print(f"  {col}: {len(unique_values)} unique values mapped to 1-{len(unique_values)}")
    
    return mappings

def apply_id_mappings(df, mappings):
    """Apply ID mappings to the dataframe"""
    df_copy = df.copy()
    
    for col, mapping in mappings.items():
        if col in df_copy.columns:
            df_copy[col] = df_copy[col].map(mapping)
            # Ensure the column is integer type, not float
            df_copy[col] = pd.to_numeric(df_copy[col], errors='coerce').astype('Int64')
    
    return df_copy

def save_csv_file(df, file_path, output_dir):
    """Save dataframe to gzipped CSV file in output directory"""
    # Get filename from original path
    filename = os.path.basename(file_path)
    output_path = os.path.join(output_dir, filename)
    
    # Save new file
    df.to_csv(output_path, index=False, compression='gzip')
    print(f"  Saved: {output_path}")

def main():
    print("Starting ID rewriting process...")
    print("This will maintain referential integrity while using smaller sequential IDs.")
    print()
    
    # Create output directory
    output_dir = ensure_output_dir()
    
    csv_files = get_csv_files()
    if not csv_files:
        print("No CSV files found!")
        return
    
    print(f"Found {len(csv_files)} CSV files to process:")
    for table_name, file_path in csv_files:
        print(f"  - {table_name}: {file_path}")
    print()
    
    # First pass: collect all ID mappings
    all_mappings = {}
    
    print("Phase 1: Collecting ID mappings...")
    for table_name, file_path in csv_files:
        print(f"\nProcessing {table_name}...")
        
        df = read_csv_file(file_path)
        if df is None:
            continue
        
        # Get ID columns for this table
        id_cols = ID_COLUMNS.get(table_name, [])
        if not id_cols:
            print(f"  No ID columns defined for {table_name}, skipping...")
            continue
        
        # Filter out excluded columns
        id_cols = [col for col in id_cols if col not in EXCLUDED_COLUMNS]
        if not id_cols:
            print(f"  All ID columns for {table_name} are excluded, skipping...")
            continue
        
        print(f"  ID columns to rewrite: {id_cols}")
        
        # Create mappings for this table
        mappings = create_id_mappings(df, id_cols)
        all_mappings[table_name] = mappings
    
    print(f"\nPhase 2: Applying ID mappings...")
    
    # Second pass: apply mappings
    for table_name, file_path in csv_files:
        print(f"\nProcessing {table_name}...")
        
        df = read_csv_file(file_path)
        if df is None:
            continue
        
        mappings = all_mappings.get(table_name, {})
        if not mappings:
            print(f"  No mappings for {table_name}, skipping...")
            continue
        
        # Apply mappings for regular ID columns
        df_new = apply_id_mappings(df, mappings)
        
        # Apply cross-table ID mappings
        cross_table_ids = CROSS_TABLE_IDS.get(table_name, {})
        for col, (ref_table, ref_col) in cross_table_ids.items():
            if col in df_new.columns and ref_table in all_mappings and ref_col in all_mappings[ref_table]:
                ref_mapping = all_mappings[ref_table][ref_col]
                df_new[col] = df_new[col].map(ref_mapping)
                # Ensure the column is integer type, not float
                df_new[col] = pd.to_numeric(df_new[col], errors='coerce').astype('Int64')
                print(f"  Applied cross-table mapping: {col} -> {ref_table}.{ref_col}")
        
        # Save the file
        save_csv_file(df_new, file_path, output_dir)
    
    print(f"\nID rewriting completed!")
    print(f"Rewritten files saved to: {output_dir}")
    print("You can now load these files into ClickHouse with the updated clickhouse-init.xml.")

if __name__ == "__main__":
    main() 