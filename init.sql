-- PostgreSQL OMOP CDM Initialization Script
-- This script creates the tables for the OMOP Common Data Model
-- Schema matches the ClickHouse schema exactly

-- Create schema
CREATE SCHEMA IF NOT EXISTS omop;

-- Set search path
SET search_path TO omop, public;

-- Person table
CREATE TABLE IF NOT EXISTS person (
    person_id BIGINT,
    gender_concept_id INTEGER,
    year_of_birth SMALLINT,
    month_of_birth SMALLINT,
    day_of_birth SMALLINT,
    birth_datetime TIMESTAMP,
    race_concept_id INTEGER,
    ethnicity_concept_id INTEGER,
    location_id BIGINT,
    provider_id BIGINT,
    care_site_id BIGINT,
    person_source_value TEXT,
    gender_source_value TEXT,
    gender_source_concept_id INTEGER,
    race_source_value TEXT,
    race_source_concept_id INTEGER,
    ethnicity_source_value TEXT,
    ethnicity_source_concept_id INTEGER
);

-- Visit occurrence table
CREATE TABLE IF NOT EXISTS visit_occurrence (
    visit_occurrence_id BIGINT,
    person_id BIGINT,
    visit_concept_id INTEGER,
    visit_start_date DATE,
    visit_start_datetime TIMESTAMP,
    visit_end_date DATE,
    visit_end_datetime TIMESTAMP,
    visit_type_concept_id INTEGER,
    provider_id BIGINT,
    care_site_id BIGINT,
    visit_source_value TEXT,
    visit_source_concept_id INTEGER,
    admitted_from_concept_id INTEGER,
    admitted_from_source_value TEXT,
    discharged_to_concept_id INTEGER,
    discharged_to_source_value TEXT,
    preceding_visit_occurrence_id BIGINT
);

-- Condition occurrence table
CREATE TABLE IF NOT EXISTS condition_occurrence (
    condition_occurrence_id BIGINT,
    person_id BIGINT,
    condition_concept_id INTEGER,
    condition_start_date DATE,
    condition_start_datetime TIMESTAMP,
    condition_end_date DATE,
    condition_end_datetime TIMESTAMP,
    condition_type_concept_id INTEGER,
    condition_status_concept_id INTEGER,
    stop_reason TEXT,
    provider_id BIGINT,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    condition_source_value TEXT,
    condition_source_concept_id INTEGER,
    condition_status_source_value TEXT
);

-- Drug exposure table
CREATE TABLE IF NOT EXISTS drug_exposure (
    drug_exposure_id BIGINT,
    person_id BIGINT,
    drug_concept_id INTEGER,
    drug_exposure_start_date DATE,
    drug_exposure_start_datetime TIMESTAMP,
    drug_exposure_end_date DATE,
    drug_exposure_end_datetime TIMESTAMP,
    verbatim_end_date DATE,
    drug_type_concept_id INTEGER,
    stop_reason TEXT,
    refills INTEGER,
    quantity NUMERIC,
    days_supply INTEGER,
    sig TEXT,
    route_concept_id INTEGER,
    lot_number TEXT,
    provider_id BIGINT,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    drug_source_value TEXT,
    drug_source_concept_id INTEGER,
    route_source_value TEXT,
    dose_unit_source_value TEXT
);

-- Measurement table
CREATE TABLE IF NOT EXISTS measurement (
    measurement_id BIGINT,
    person_id BIGINT,
    measurement_concept_id INTEGER,
    measurement_date DATE,
    measurement_datetime TIMESTAMP,
    measurement_time TEXT,
    measurement_type_concept_id INTEGER,
    operator_concept_id INTEGER,
    value_as_number NUMERIC,
    value_as_concept_id INTEGER,
    unit_concept_id INTEGER,
    range_low NUMERIC,
    range_high NUMERIC,
    provider_id BIGINT,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    measurement_source_value TEXT,
    measurement_source_concept_id INTEGER,
    unit_source_value TEXT,
    value_source_value TEXT
);

-- Observation table
CREATE TABLE IF NOT EXISTS observation (
    observation_id BIGINT,
    person_id BIGINT,
    observation_concept_id INTEGER,
    observation_date DATE,
    observation_datetime TIMESTAMP,
    observation_type_concept_id INTEGER,
    value_as_number NUMERIC,
    value_as_string TEXT,
    value_as_concept_id INTEGER,
    qualifier_concept_id INTEGER,
    unit_concept_id INTEGER,
    provider_id BIGINT,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    observation_source_value TEXT,
    observation_source_concept_id INTEGER,
    unit_source_value TEXT,
    qualifier_source_value TEXT
);

-- Procedure occurrence table
CREATE TABLE IF NOT EXISTS procedure_occurrence (
    procedure_occurrence_id BIGINT,
    person_id BIGINT,
    procedure_concept_id INTEGER,
    procedure_date DATE,
    procedure_datetime TIMESTAMP,
    procedure_type_concept_id INTEGER,
    modifier_concept_id INTEGER,
    quantity INTEGER,
    provider_id BIGINT,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    procedure_source_value TEXT,
    procedure_source_concept_id INTEGER,
    modifier_source_value TEXT
);

-- Device exposure table
CREATE TABLE IF NOT EXISTS device_exposure (
    device_exposure_id BIGINT,
    person_id BIGINT,
    device_concept_id INTEGER,
    device_exposure_start_date DATE,
    device_exposure_start_datetime TIMESTAMP,
    device_exposure_end_date DATE,
    device_exposure_end_datetime TIMESTAMP,
    device_type_concept_id INTEGER,
    unique_device_id TEXT,
    quantity INTEGER,
    provider_id BIGINT,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    device_source_value TEXT,
    device_source_concept_id INTEGER
);

-- Death table
CREATE TABLE IF NOT EXISTS death (
    person_id BIGINT,
    death_date DATE,
    death_datetime TIMESTAMP,
    death_type_concept_id INTEGER,
    cause_concept_id INTEGER,
    cause_source_value TEXT,
    cause_source_concept_id INTEGER
);

-- Note table
CREATE TABLE IF NOT EXISTS note (
    note_id BIGINT,
    person_id BIGINT,
    note_date DATE,
    note_datetime TIMESTAMP,
    note_type_concept_id INTEGER,
    note_class_concept_id INTEGER,
    note_title TEXT,
    note_text TEXT,
    encoding_concept_id INTEGER,
    language_concept_id INTEGER,
    provider_id BIGINT,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    note_source_value TEXT
);

-- Note NLP table
CREATE TABLE IF NOT EXISTS note_nlp (
    note_nlp_id BIGINT,
    note_id BIGINT,
    section_concept_id INTEGER,
    snippet TEXT,
    "offset" TEXT,
    lexical_variant TEXT,
    note_nlp_concept_id INTEGER,
    note_nlp_source_concept_id INTEGER,
    nlp_system TEXT,
    nlp_date DATE,
    nlp_datetime TIMESTAMP,
    term_exists TEXT,
    term_temporal TEXT,
    term_modifiers TEXT
);

-- Observation period table
CREATE TABLE IF NOT EXISTS observation_period (
    observation_period_id BIGINT,
    person_id BIGINT,
    observation_period_start_date DATE,
    observation_period_end_date DATE,
    period_type_concept_id INTEGER
);

-- Specimen table
CREATE TABLE IF NOT EXISTS specimen (
    specimen_id BIGINT,
    person_id BIGINT,
    specimen_concept_id INTEGER,
    specimen_type_concept_id INTEGER,
    specimen_date DATE,
    specimen_datetime TIMESTAMP,
    quantity NUMERIC,
    unit_concept_id INTEGER,
    anatomic_site_concept_id INTEGER,
    disease_status_concept_id INTEGER,
    specimen_source_id TEXT,
    specimen_source_value TEXT,
    unit_source_value TEXT,
    anatomic_site_source_value TEXT,
    disease_status_source_value TEXT
);

-- Visit detail table
CREATE TABLE IF NOT EXISTS visit_detail (
    visit_detail_id BIGINT,
    person_id BIGINT,
    visit_detail_concept_id INTEGER,
    visit_detail_start_date DATE,
    visit_detail_start_datetime TIMESTAMP,
    visit_detail_end_date DATE,
    visit_detail_end_datetime TIMESTAMP,
    visit_detail_type_concept_id INTEGER,
    provider_id BIGINT,
    care_site_id BIGINT,
    visit_detail_source_value TEXT,
    visit_detail_source_concept_id INTEGER,
    admitted_from_concept_id INTEGER,
    admitted_from_source_value TEXT,
    discharged_to_source_value TEXT,
    discharged_to_concept_id INTEGER,
    preceding_visit_detail_id BIGINT,
    visit_detail_parent_id BIGINT,
    visit_occurrence_id BIGINT
);

-- Cost table
CREATE TABLE IF NOT EXISTS cost (
    cost_id BIGINT,
    person_id BIGINT,
    cost_event_id BIGINT,
    cost_domain_id TEXT,
    cost_type_concept_id INTEGER,
    currency_concept_id INTEGER,
    total_charge NUMERIC,
    total_cost NUMERIC,
    total_paid NUMERIC,
    paid_by_payer NUMERIC,
    paid_by_patient NUMERIC,
    paid_patient_copay NUMERIC,
    paid_patient_coinsurance NUMERIC,
    paid_patient_deductible NUMERIC,
    paid_by_primary NUMERIC,
    paid_ingredient_cost NUMERIC,
    paid_dispensing_fee NUMERIC,
    payer_plan_period_id BIGINT,
    amount_allowed NUMERIC,
    revenue_code_concept_id INTEGER,
    revenue_code_source_value TEXT,
    drg_concept_id INTEGER,
    drg_source_value TEXT
);

-- Drug era table
CREATE TABLE IF NOT EXISTS drug_era (
    drug_era_id BIGINT,
    person_id BIGINT,
    drug_concept_id INTEGER,
    drug_era_start_date DATE,
    drug_era_end_date DATE,
    drug_exposure_count INTEGER,
    gap_days INTEGER
);

-- Dose era table
CREATE TABLE IF NOT EXISTS dose_era (
    dose_era_id BIGINT,
    person_id BIGINT,
    drug_concept_id INTEGER,
    unit_concept_id INTEGER,
    dose_value NUMERIC,
    dose_era_start_date DATE,
    dose_era_end_date DATE
);

-- Condition era table
CREATE TABLE IF NOT EXISTS condition_era (
    condition_era_id BIGINT,
    person_id BIGINT,
    condition_concept_id INTEGER,
    condition_era_start_date DATE,
    condition_era_end_date DATE,
    condition_occurrence_count INTEGER
);

-- Location table
CREATE TABLE IF NOT EXISTS location (
    location_id BIGINT,
    address_1 TEXT,
    address_2 TEXT,
    city TEXT,
    state TEXT,
    zip TEXT,
    county TEXT,
    location_source_value TEXT,
    country_concept_id INTEGER,
    country_source_value TEXT,
    latitude NUMERIC,
    longitude NUMERIC
);

-- Care site table
CREATE TABLE IF NOT EXISTS care_site (
    care_site_id BIGINT,
    care_site_name TEXT,
    place_of_service_concept_id INTEGER,
    location_id BIGINT,
    care_site_source_value TEXT,
    place_of_service_source_value TEXT
);

-- Provider table
CREATE TABLE IF NOT EXISTS provider (
    provider_id BIGINT,
    provider_name TEXT,
    npi TEXT,
    dea TEXT,
    specialty_concept_id INTEGER,
    care_site_id BIGINT,
    year_of_birth SMALLINT,
    gender_concept_id INTEGER,
    provider_source_value TEXT,
    specialty_source_value TEXT,
    specialty_source_concept_id INTEGER,
    gender_source_value TEXT,
    gender_source_concept_id INTEGER
);

-- Payer plan period table
CREATE TABLE IF NOT EXISTS payer_plan_period (
    payer_plan_period_id BIGINT,
    person_id BIGINT,
    payer_plan_period_start_date DATE,
    payer_plan_period_end_date DATE,
    payer_concept_id INTEGER,
    payer_source_value TEXT,
    payer_source_concept_id INTEGER,
    plan_concept_id INTEGER,
    plan_source_value TEXT,
    plan_source_concept_id INTEGER,
    sponsor_concept_id INTEGER,
    sponsor_source_value TEXT,
    sponsor_source_concept_id INTEGER,
    family_source_value TEXT,
    stop_reason_concept_id INTEGER,
    stop_reason_source_value TEXT,
    stop_reason_source_concept_id INTEGER
);

-- CDM source table
CREATE TABLE IF NOT EXISTS cdm_source (
    cdm_source_name TEXT,
    cdm_source_abbreviation TEXT,
    cdm_holder TEXT,
    source_description TEXT,
    source_documentation_reference TEXT,
    cdm_etl_reference TEXT,
    source_release_date DATE,
    cdm_release_date DATE,
    cdm_version TEXT,
    vocabulary_version TEXT
);

-- Concept table
CREATE TABLE IF NOT EXISTS concept (
    concept_id INTEGER,
    concept_name TEXT,
    domain_id TEXT,
    vocabulary_id TEXT,
    concept_class_id TEXT,
    standard_concept TEXT,
    concept_code TEXT,
    valid_start_date DATE,
    valid_end_date DATE,
    invalid_reason TEXT
);

-- Concept relationship table
CREATE TABLE IF NOT EXISTS concept_relationship (
    concept_id_1 INTEGER,
    concept_id_2 INTEGER,
    relationship_id TEXT,
    valid_start_date DATE,
    valid_end_date DATE,
    invalid_reason TEXT
);

-- Concept ancestor table
CREATE TABLE IF NOT EXISTS concept_ancestor (
    ancestor_concept_id INTEGER,
    descendant_concept_id INTEGER,
    min_levels_of_separation INTEGER,
    max_levels_of_separation INTEGER
);

-- Vocabulary table
CREATE TABLE IF NOT EXISTS vocabulary (
    vocabulary_id TEXT,
    vocabulary_name TEXT,
    vocabulary_reference TEXT,
    vocabulary_version TEXT,
    vocabulary_concept_id INTEGER
);

-- Cohort table
CREATE TABLE IF NOT EXISTS cohort (
    cohort_definition_id INTEGER,
    subject_id BIGINT,
    cohort_start_date DATE,
    cohort_end_date DATE
);

-- Cohort definition table
CREATE TABLE IF NOT EXISTS cohort_definition (
    cohort_definition_id INTEGER,
    cohort_definition_name TEXT,
    cohort_definition_description TEXT,
    definition_type_concept_id INTEGER,
    cohort_definition_syntax TEXT,
    subject_concept_id INTEGER,
    cohort_initiation_date DATE
);

-- Cohort attribute table
CREATE TABLE IF NOT EXISTS cohort_attribute (
    cohort_definition_id INTEGER,
    subject_id BIGINT,
    cohort_start_date DATE,
    cohort_end_date DATE,
    attribute_definition_id INTEGER,
    value_as_number NUMERIC,
    value_as_concept_id INTEGER
);

-- Attribute definition table
CREATE TABLE IF NOT EXISTS attribute_definition (
    attribute_definition_id INTEGER,
    attribute_name TEXT,
    attribute_description TEXT,
    attribute_type_concept_id INTEGER,
    attribute_syntax TEXT
);

-- Fact relationship table
CREATE TABLE IF NOT EXISTS fact_relationship (
    domain_concept_id_1 INTEGER,
    fact_id_1 BIGINT,
    domain_concept_id_2 INTEGER,
    fact_id_2 BIGINT,
    relationship_concept_id INTEGER
);

-- Metadata table
CREATE TABLE IF NOT EXISTS metadata (
    metadata_concept_id INTEGER,
    metadata_type_concept_id INTEGER,
    name TEXT,
    value_as_string TEXT,
    value_as_concept_id INTEGER,
    metadata_date DATE,
    metadata_datetime TIMESTAMP
);

-- Relationship table
CREATE TABLE IF NOT EXISTS relationship (
    relationship_id TEXT,
    relationship_name TEXT,
    is_hierarchical TEXT,
    defines_ancestry TEXT,
    reverse_relationship_id TEXT,
    relationship_concept_id INTEGER
);

-- Drug strength table
CREATE TABLE IF NOT EXISTS drug_strength (
    drug_concept_id INTEGER,
    ingredient_concept_id INTEGER,
    amount_value NUMERIC,
    amount_unit_concept_id INTEGER,
    numerator_value NUMERIC,
    numerator_unit_concept_id INTEGER,
    denominator_value NUMERIC,
    denominator_unit_concept_id INTEGER,
    box_size INTEGER,
    valid_start_date DATE,
    valid_end_date DATE,
    invalid_reason TEXT
);

-- Domain table
CREATE TABLE IF NOT EXISTS domain (
    domain_id TEXT,
    domain_name TEXT,
    domain_concept_id INTEGER
);

-- Concept class table
CREATE TABLE IF NOT EXISTS concept_class (
    concept_class_id TEXT,
    concept_class_name TEXT,
    concept_class_concept_id INTEGER
);

-- Concept synonym table
CREATE TABLE IF NOT EXISTS concept_synonym (
    concept_id INTEGER,
    concept_synonym_name TEXT,
    language_concept_id INTEGER
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_person_person_id ON person(person_id);
CREATE INDEX IF NOT EXISTS idx_visit_occurrence_person_id ON visit_occurrence(person_id);
CREATE INDEX IF NOT EXISTS idx_visit_occurrence_visit_occurrence_id ON visit_occurrence(visit_occurrence_id);
CREATE INDEX IF NOT EXISTS idx_condition_occurrence_person_id ON condition_occurrence(person_id);
CREATE INDEX IF NOT EXISTS idx_drug_exposure_person_id ON drug_exposure(person_id);
CREATE INDEX IF NOT EXISTS idx_measurement_person_id ON measurement(person_id);
CREATE INDEX IF NOT EXISTS idx_observation_person_id ON observation(person_id);
CREATE INDEX IF NOT EXISTS idx_procedure_occurrence_person_id ON procedure_occurrence(person_id);
CREATE INDEX IF NOT EXISTS idx_device_exposure_person_id ON device_exposure(person_id);
CREATE INDEX IF NOT EXISTS idx_death_person_id ON death(person_id);
CREATE INDEX IF NOT EXISTS idx_note_person_id ON note(person_id);
CREATE INDEX IF NOT EXISTS idx_note_nlp_note_id ON note_nlp(note_id);
CREATE INDEX IF NOT EXISTS idx_observation_period_person_id ON observation_period(person_id);
CREATE INDEX IF NOT EXISTS idx_specimen_person_id ON specimen(person_id);
CREATE INDEX IF NOT EXISTS idx_cost_person_id ON cost(person_id);
CREATE INDEX IF NOT EXISTS idx_drug_era_person_id ON drug_era(person_id);
CREATE INDEX IF NOT EXISTS idx_dose_era_person_id ON dose_era(person_id);
CREATE INDEX IF NOT EXISTS idx_condition_era_person_id ON condition_era(person_id);
CREATE INDEX IF NOT EXISTS idx_payer_plan_period_person_id ON payer_plan_period(person_id);
CREATE INDEX IF NOT EXISTS idx_cohort_subject_id ON cohort(subject_id);
CREATE INDEX IF NOT EXISTS idx_cohort_attribute_subject_id ON cohort_attribute(subject_id);

-- Vocabulary table indexes
CREATE INDEX IF NOT EXISTS idx_concept_concept_id ON concept(concept_id);
CREATE INDEX IF NOT EXISTS idx_concept_vocabulary_id ON concept(vocabulary_id);
CREATE INDEX IF NOT EXISTS idx_concept_domain_id ON concept(domain_id);
CREATE INDEX IF NOT EXISTS idx_concept_standard_concept ON concept(standard_concept);
CREATE INDEX IF NOT EXISTS idx_concept_relationship_concept_id_1 ON concept_relationship(concept_id_1);
CREATE INDEX IF NOT EXISTS idx_concept_relationship_concept_id_2 ON concept_relationship(concept_id_2);
CREATE INDEX IF NOT EXISTS idx_concept_ancestor_ancestor_concept_id ON concept_ancestor(ancestor_concept_id);
CREATE INDEX IF NOT EXISTS idx_concept_ancestor_descendant_concept_id ON concept_ancestor(descendant_concept_id);
CREATE INDEX IF NOT EXISTS idx_concept_synonym_concept_id ON concept_synonym(concept_id);
CREATE INDEX IF NOT EXISTS idx_drug_strength_drug_concept_id ON drug_strength(drug_concept_id);
CREATE INDEX IF NOT EXISTS idx_drug_strength_ingredient_concept_id ON drug_strength(ingredient_concept_id);

-- Load data from CSV files
-- Note: PostgreSQL cannot directly read gzipped files, so we'll use COPY with program to unzip

-- Load person data
\copy person FROM PROGRAM 'gunzip -c /omop_data_csv/person.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load location data
\copy location FROM PROGRAM 'gunzip -c /omop_data_csv/location.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load care_site data
\copy care_site FROM PROGRAM 'gunzip -c /omop_data_csv/care_site.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load provider data
\copy provider FROM PROGRAM 'gunzip -c /omop_data_csv/provider.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load visit_occurrence data
\copy visit_occurrence FROM PROGRAM 'gunzip -c /omop_data_csv/visit_occurrence.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load visit_detail data
\copy visit_detail FROM PROGRAM 'gunzip -c /omop_data_csv/visit_detail.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load condition_occurrence data
\copy condition_occurrence FROM PROGRAM 'gunzip -c /omop_data_csv/condition_occurrence.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load drug_exposure data
\copy drug_exposure FROM PROGRAM 'gunzip -c /omop_data_csv/drug_exposure.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load procedure_occurrence data
\copy procedure_occurrence FROM PROGRAM 'gunzip -c /omop_data_csv/procedure_occurrence.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load measurement data
\copy measurement FROM PROGRAM 'gunzip -c /omop_data_csv/measurement.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load observation data
\copy observation FROM PROGRAM 'gunzip -c /omop_data_csv/observation.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load device_exposure data
\copy device_exposure FROM PROGRAM 'gunzip -c /omop_data_csv/device_exposure.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load death data
\copy death FROM PROGRAM 'gunzip -c /omop_data_csv/death.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load note data
\copy note FROM PROGRAM 'gunzip -c /omop_data_csv/note.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load note_nlp data
\copy note_nlp FROM PROGRAM 'gunzip -c /omop_data_csv/note_nlp.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load observation_period data
\copy observation_period FROM PROGRAM 'gunzip -c /omop_data_csv/observation_period.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load specimen data
\copy specimen FROM PROGRAM 'gunzip -c /omop_data_csv/specimen.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load cost data
\copy cost FROM PROGRAM 'gunzip -c /omop_data_csv/cost.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load drug_era data
\copy drug_era FROM PROGRAM 'gunzip -c /omop_data_csv/drug_era.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load dose_era data
\copy dose_era FROM PROGRAM 'gunzip -c /omop_data_csv/dose_era.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load condition_era data
\copy condition_era FROM PROGRAM 'gunzip -c /omop_data_csv/condition_era.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load payer_plan_period data
\copy payer_plan_period FROM PROGRAM 'gunzip -c /omop_data_csv/payer_plan_period.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load cohort data
\copy cohort FROM PROGRAM 'gunzip -c /omop_data_csv/cohort.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load cohort_attribute data
\copy cohort_attribute FROM PROGRAM 'gunzip -c /omop_data_csv/cohort_attribute.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load fact_relationship data
\copy fact_relationship FROM PROGRAM 'gunzip -c /omop_data_csv/fact_relationship.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load additional tables if they exist
-- These are optional tables that might not be present in all OMOP datasets

-- Load concept data (if exists)
\copy concept FROM PROGRAM 'gunzip -c /omop_data_csv/concept.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

-- Load vocabulary data (if exists)
\copy vocabulary FROM PROGRAM 'gunzip -c /omop_data_csv/vocabulary.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

-- Load domain data (if exists)
\copy domain FROM PROGRAM 'gunzip -c /omop_data_csv/domain.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

-- Load concept_class data (if exists)
\copy concept_class FROM PROGRAM 'gunzip -c /omop_data_csv/concept_class.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

-- Load concept_relationship data (if exists)
\copy concept_relationship FROM PROGRAM 'gunzip -c /omop_data_csv/concept_relationship.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

-- Load concept_ancestor data (if exists)
\copy concept_ancestor FROM PROGRAM 'gunzip -c /omop_data_csv/concept_ancestor.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load concept_synonym data (if exists)
\copy concept_synonym FROM PROGRAM 'gunzip -c /omop_data_csv/concept_synonym.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER E'\t');

-- Load relationship data (if exists)
\copy relationship FROM PROGRAM 'gunzip -c /omop_data_csv/relationship.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load drug_strength data (if exists)
\copy drug_strength FROM PROGRAM 'gunzip -c /omop_data_csv/drug_strength.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load cohort_definition data (if exists)
\copy cohort_definition FROM PROGRAM 'gunzip -c /omop_data_csv/cohort_definition.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load attribute_definition data (if exists)
\copy attribute_definition FROM PROGRAM 'gunzip -c /omop_data_csv/attribute_definition.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load cdm_source data (if exists)
\copy cdm_source FROM PROGRAM 'gunzip -c /omop_data_csv/cdm_source.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Load metadata data (if exists)
\copy metadata FROM PROGRAM 'gunzip -c /omop_data_csv/metadata.csv.gz' WITH (FORMAT csv, HEADER true, DELIMITER ',');

ANALYZE;
