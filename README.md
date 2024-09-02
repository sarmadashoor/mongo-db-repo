# My Project

This is a multi-service project using Docker Compose to orchestrate PostgreSQL, MongoDB, Django, and Node.js.

## Setup

1. Run \docker-compose up -d\ to build and start all the services.
2. Access Django at \http://localhost:8000\.
3. Access Node.js at \http://localhost:3000\.

## Services

- **PostgreSQL**: A relational database running on port 5432.
- **MongoDB**: A NoSQL database running on port 27017.
- **Django**: A Python web framework running on port 8000.
- **Node.js**: A JavaScript runtime running on port 3000.

## Notes

- Data for PostgreSQL and MongoDB is persisted using Docker volumes.
