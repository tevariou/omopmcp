FROM clickhouse/clickhouse-server:25.5

# Create directory for OMOP data in user_files
RUN mkdir -p /var/lib/clickhouse/user_files/omop_data_csv

# Copy OMOP data files with proper permissions
COPY --chown=clickhouse:clickhouse omop_data_csv/ /var/lib/clickhouse/user_files/omop_data_csv/
