# Use the official PostgreSQL image as a base
FROM postgres:latest

# Optional: Copy any initialization scripts (like init.sql) into the Docker image
COPY init.sql /docker-entrypoint-initdb.d/

# Expose the default PostgreSQL port
EXPOSE 5432
