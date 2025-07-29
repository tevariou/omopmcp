# OMOP MCP Project

This project provides a setup for loading OMOP CDM data into both ClickHouse and PostgreSQL databases.

## Prerequisites

- Docker and Docker Compose
- Python 3.8+ (for running the ID rewriting script)

## Quick Start

### 1. Start the Databases

```bash
# Start both ClickHouse and PostgreSQL
docker-compose up -d

# Check if services are running
docker-compose ps
```

### 2. Load Data

The data loading process is automatic when the containers start:

- **ClickHouse**: Data is loaded automatically via the `clickhouse-init.xml` configuration
- **PostgreSQL**: Data is loaded automatically via the `init.sql` initialization script

### 3. Connect to Databases

#### ClickHouse
```bash
# Connect to ClickHouse
docker exec -it omop_clickhouse clickhouse-client --database=omop

# Or connect from host
clickhouse-client --host=localhost --port=9000 --database=omop
```

#### PostgreSQL
```bash
# Connect to PostgreSQL
docker exec -it omop_postgres psql -U omop_user -d omop

# Or connect from host
psql -h localhost -p 5432 -U omop_user -d omop
```

## Data Processing

### Rewrite IDs (Optional)

If you want to rewrite IDs to use smaller sequential integers while maintaining referential integrity:

```bash
python3 rewrite_ids.py
```

This will create a new directory `omop_data_csv_rewritten/` with the processed files.

### Shift Dates (Optional)

If you need to shift dates in the OMOP data:

```bash
python3 shift_omop_dates.py
```

## Database Schemas

Both databases use the standard OMOP CDM schema with the following main tables:

- `person` - Patient demographics
- `visit_occurrence` - Healthcare visits
- `condition_occurrence` - Diagnoses
- `drug_exposure` - Medications
- `procedure_occurrence` - Procedures
- `measurement` - Lab results and measurements
- `observation` - Clinical observations
- `death` - Mortality data
- And many more...

## Configuration

### ClickHouse
- Port: 8123 (HTTP), 9000 (Native)
- Database: `omop`
- User: `default`
- Password: `default`

### PostgreSQL
- Port: 5432
- Database: `omop`
- User: `omop_user`
- Password: `omop_password`

## Troubleshooting

### Check Container Logs
```bash
# Check ClickHouse logs
docker-compose logs clickhouse

# Check PostgreSQL logs
docker-compose logs postgres
```

### Restart Services
```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart postgres
```

### Rebuild Containers
```bash
# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Data Sources

The OMOP data should be placed in the `omop_data_csv/` directory as gzipped CSV files with the following naming convention:
- `person.csv.gz`
- `visit_occurrence.csv.gz`
- `condition_occurrence.csv.gz`
- etc.

## License

See LICENSE file for details.
