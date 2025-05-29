import os
import gzip
import pandas as pd
from datetime import datetime

# Directory paths
INPUT_DIR = 'omop_data_csv_bak'
OUTPUT_DIR = 'omop_data_csv_shifted'

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

# OMOP date/datetime columns by table (from your schema)
DATE_COLUMNS = {
    'visit_occurrence': ['visit_start_date', 'visit_start_datetime', 'visit_end_date', 'visit_end_datetime'],
    'condition_occurrence': ['condition_start_date', 'condition_start_datetime', 'condition_end_date', 'condition_end_datetime'],
    'drug_exposure': ['drug_exposure_start_date', 'drug_exposure_start_datetime', 'drug_exposure_end_date', 'drug_exposure_end_datetime'],
    'measurement': ['measurement_date', 'measurement_datetime'],
    'observation': ['observation_date', 'observation_datetime'],
    'procedure_occurrence': ['procedure_date', 'procedure_datetime'],
    'device_exposure': ['device_exposure_start_date', 'device_exposure_start_datetime', 'device_exposure_end_date', 'device_exposure_end_datetime'],
    'death': ['death_date', 'death_datetime'],
    'note': [],
    'note_nlp': [],
    'observation_period': ['observation_period_start_date', 'observation_period_end_date'],
    'specimen': ['specimen_date', 'specimen_datetime'],
    'visit_detail': ['visit_detail_start_date', 'visit_detail_start_datetime', 'visit_detail_end_date', 'visit_detail_end_datetime'],
    'cost': [],
    'drug_era': ['drug_era_start_date', 'drug_era_end_date'],
    'dose_era': ['dose_era_start_date', 'dose_era_end_date'],
    'condition_era': ['condition_era_start_date', 'condition_era_end_date'],
    'provider': [],
    'payer_plan_period': ['payer_plan_period_start_date', 'payer_plan_period_end_date'],
    'cdm_source': [],
    'cohort': [],
    'cohort_definition': [],
    'cohort_attribute': [],
    'attribute_definition': [],
    'fact_relationship': [],
    'metadata': [],
    'relationship': [],
    'drug_strength': [],
    'domain': [],
    'concept_class': [],
    'concept_synonym': [],
    'concept': [],
    'concept_relationship': [],
    'concept_ancestor': [],
    'vocabulary': [],
    'location': [],
    'care_site': [],
}

# Helper: get table name from file name
def get_table_name(filename):
    base = filename.split('.')[0]
    return base

def get_delimiter(filename):
    tsv_tables = [
        'concept', 'concept_relationship', 'vocabulary', 'domain', 'concept_class', 'concept_synonym'
    ]
    for t in tsv_tables:
        if filename.startswith(t):
            return '\t'
    return ','

# Step 1: Load person table and get birth dates
person_file = 'person.csv.gz'
person_path = os.path.join(INPUT_DIR, person_file)
person_out_path = os.path.join(OUTPUT_DIR, person_file)
person_id_birth = {}
person_id_rowidx = {}

if os.path.exists(person_path):
    with gzip.open(person_path, 'rt') as f:
        df_person = pd.read_csv(f)
    for idx, row in df_person.iterrows():
        pid = row['person_id']
        y = int(row['year_of_birth'])
        birth = datetime(y, 1, 1)
        person_id_birth[pid] = birth
        person_id_rowidx[pid] = idx
else:
    raise FileNotFoundError(f"person.csv.gz not found in {INPUT_DIR}")

# Step 2: Load death table and map person_id to death date
death_file = 'death.csv.gz'
death_path = os.path.join(INPUT_DIR, death_file)
person_id_death = {}
if os.path.exists(death_path):
    with gzip.open(death_path, 'rt') as f:
        df_death = pd.read_csv(f, low_memory=False)
    if 'death_date' in df_death.columns:
        df_death['death_date'] = pd.to_datetime(df_death['death_date'], errors='coerce')
        for idx, row in df_death.iterrows():
            pid = row['person_id']
            if pd.notnull(row['death_date']):
                person_id_death[pid] = row['death_date']

# Step 3: For each person, find last event date (last visit)
visit_file = 'visit_occurrence.csv.gz'
visit_path = os.path.join(INPUT_DIR, visit_file)
person_id_last_event = {}
if os.path.exists(visit_path):
    with gzip.open(visit_path, 'rt') as f:
        df_visit = pd.read_csv(f, low_memory=False)
    if 'visit_end_date' in df_visit.columns:
        df_visit['visit_end_date'] = pd.to_datetime(df_visit['visit_end_date'], errors='coerce')
    for pid, birth in person_id_birth.items():
        visits = df_visit[df_visit['person_id'] == pid]
        if not visits.empty:
            last_visit = visits['visit_end_date'].dropna().max()
            if pd.notnull(last_visit):
                person_id_last_event[pid] = last_visit

# Step 4: For each person, determine interval, max_shift, and random shift
SHIFT_END = 2024
SHIFT_START = SHIFT_END - 100
person_id_shift_years = {}
for pid, birth in person_id_birth.items():
    # Determine end of interval
    if pid in person_id_death:
        end = person_id_death[pid]
    elif pid in person_id_last_event:
        end = person_id_last_event[pid]
    else:
        end = birth  # No events, no shift
    interval_years = max(0, (end.year - birth.year))
    print("Interval years", interval_years)
    max_shift = (SHIFT_END - SHIFT_START) - interval_years
    shift = SHIFT_START - birth.year
    # Deterministic random: use person_id as seed
    rnd = abs(hash(pid))
    shift += rnd % (max_shift)
    if shift < 0:
        shift = 0
    person_id_shift_years[pid] = shift

# Step 5: Shift all dates for each person in all tables
def shift_date(dt, shift_years, col):
    if pd.isnull(dt):
        return dt
    try:
        dt = pd.to_datetime(dt, errors='coerce')
        if pd.isnull(dt):
            return dt
        dt = dt + pd.DateOffset(years=shift_years)
        # Cap at 2024-12-31 or 2024-12-31 23:59:59
        if 'datetime' in col:
            cap = pd.Timestamp('2024-12-31 23:59:59')
        else:
            cap = pd.Timestamp('2024-12-31')
        if dt > cap:
            print("Capping date", dt, "at", cap)
            dt = cap
        return dt.strftime('%Y-%m-%d %H:%M:%S') if 'datetime' in col else dt.strftime('%Y-%m-%d')
    except Exception:
        return dt

def convert_id_columns_to_int(df):
    for col in df.columns:
        if col.endswith('_id') or col == 'id':
            try:
                df[col] = df[col].astype('Int64')
            except Exception:
                pass
        if col == 'amount_value' or col == 'numerator_value' or col == 'denominator_value':
            try:
                df[col] = df[col].astype('Float64')
            except Exception:
                pass

def convert_quantity_column(df, table):
    # Only for procedure_occurrence and device_exposure
    if table in ['procedure_occurrence', 'device_exposure'] and 'quantity' in df.columns:
        try:
            df['quantity'] = df['quantity'].astype('Int64')
        except Exception:
            pass

# Shift year_of_birth in person table and write output
for pid, shift in person_id_shift_years.items():
    idx = person_id_rowidx[pid]
    print("Shifting year_of_birth for person_id", pid, "by", shift, "years", df_person.at[idx, 'year_of_birth'])
    df_person.at[idx, 'year_of_birth'] = int(df_person.at[idx, 'year_of_birth']) + shift
    print(df_person.at[idx, 'year_of_birth'])

# Convert id columns to int
convert_id_columns_to_int(df_person)

with gzip.open(person_out_path, 'wt', newline='') as f:
    df_person.to_csv(f, index=False, na_rep='')



for fname in os.listdir(INPUT_DIR):
    if not fname.endswith('.csv.gz'):
        continue
    table = get_table_name(fname)
    date_cols = DATE_COLUMNS.get(table, [])
    in_path = os.path.join(INPUT_DIR, fname)
    out_path = os.path.join(OUTPUT_DIR, fname)
    if out_path == person_out_path:
        continue
    delimiter = get_delimiter(fname)
    with gzip.open(in_path, 'rt') as f:
        df = pd.read_csv(f, delimiter=delimiter, low_memory=False)
    # If no person_id or no date columns, just copy
    if 'person_id' not in df.columns or not date_cols:
        continue
    # Shift dates for each row according to person_id
    def shift_row(row):
        shift = person_id_shift_years.get(row['person_id'], 0)
        for col in date_cols:
            if col in row and pd.notnull(row[col]):
                row[col] = shift_date(row[col], shift, col)
        return row
    df = df.apply(shift_row, axis=1)

    # Convert id columns to int before writing
    convert_id_columns_to_int(df)
    convert_quantity_column(df, table)
    # Write out
    with gzip.open(out_path, 'wt', newline='') as f:
        df.to_csv(f, index=False, sep=delimiter, na_rep='')

print('Date shifting complete. Output written to', OUTPUT_DIR) 
