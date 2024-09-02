# Use the official PostgreSQL image as a base
FROM postgres:latest

# Optional: Copy any initialization scripts (like init.sql) into the Docker image
COPY init.sql /docker-entrypoint-initdb.d/

# Set environment variables (these can also be set in the docker-compose.yml)
ENV POSTGRES_DB=mydb
ENV POSTGRES_USER=user
ENV POSTGRES_PASSWORD=password

# Expose the default PostgreSQL port
EXPOSE 5432
