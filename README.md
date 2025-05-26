# OMOP MCP Project

## Overview
This project implements a Model Context Protocol (MCP) server that provides context, tools, and prompts to AI clients, specifically designed to work with Observational Medical Outcomes Partnership (OMOP) Common Data Model databases. The server is built to work with ClickHouse as the database provider.

## Part I: Data Migration Pipeline

### References
- [MIMIC-IV Demo OMOP Dataset](https://physionet.org/content/mimic-iv-demo-omop/0.9/)

### Architecture
- **Target Database**: ClickHouse
- **Data Source**: OMOP CSV/TSV files

The pipeline facilitates the migration of OMOP-formatted CSV files from the `./omop_data_csv` directory into a ClickHouse database.

## Part II: OMOP MCP Server

The server provides the following core functionality:
- Patient data extraction for specified time periods by ID
- OMOP CDM query interface
- Data source reference tracking

## Getting Started
[Installation and setup instructions to be added]

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
