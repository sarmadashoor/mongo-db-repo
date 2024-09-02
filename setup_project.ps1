$PROJECT_ROOT = "craf_demo"

# Create project directories
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\postgres"
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\mongo"
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\django\app"
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\node\app"

# Create Dockerfile for PostgreSQL
Set-Content -Path "$PROJECT_ROOT\postgres\Dockerfile" -Value @"
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
"@

# Create a sample init.sql file (optional)
Set-Content -Path "$PROJECT_ROOT\postgres\init.sql" -Value @"
-- Sample SQL initialization script
CREATE TABLE sample_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
"@

# Create Dockerfile for MongoDB
Set-Content -Path "$PROJECT_ROOT\mongo\Dockerfile" -Value @"
# Use the official MongoDB image as a base
FROM mongo:latest

# Expose the default MongoDB port
EXPOSE 27017
"@

# Create Dockerfile for Django
Set-Content -Path "$PROJECT_ROOT\django\Dockerfile" -Value @"
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project code to the container
COPY . /app/

# Expose port 8000
EXPOSE 8000

# Run the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
"@

# Create a sample requirements.txt file for Django
Set-Content -Path "$PROJECT_ROOT\django\requirements.txt" -Value @"
Django>=3.2,<4.0
djangorestframework>=3.12,<4.0
"@

# Create Dockerfile for Node.js
Set-Content -Path "$PROJECT_ROOT\node\Dockerfile" -Value @"
# Use the official Node.js image as a base
FROM node:14

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . /app/

# Expose port 3000
EXPOSE 3000

# Run the application
CMD ["npm", "start"]
"@

# Create a sample package.json file for Node.js
Set-Content -Path "$PROJECT_ROOT\node\package.json" -Value @"
{
  "name": "node_app",
  "version": "1.0.0",
  "description": "A sample Node.js application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
"@

# Create a sample server.js file for Node.js
Set-Content -Path "$PROJECT_ROOT\node\app\server.js" -Value @"
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(\`Node.js server running on port \${port}\`);
});
"@

# Create docker-compose.yml file
Set-Content -Path "$PROJECT_ROOT\docker-compose.yml" -Value @"
version: '3.8'

services:
  postgres:
    build: ./postgres
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - my_project_network

  mongo:
    build: ./mongo
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    networks:
      - my_project_network

  django:
    build: ./django
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./django:/app
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - mongo
    networks:
      - my_project_network

  node:
    build: ./node
    command: npm start
    volumes:
      - ./node:/app
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - mongo
    networks:
      - my_project_network

volumes:
  postgres_data:
  mongo_data:

networks:
  my_project_network:
"@

# Create README.md
Set-Content -Path "$PROJECT_ROOT\README.md" -Value @"
# My Project

This is a multi-service project using Docker Compose to orchestrate PostgreSQL, MongoDB, Django, and Node.js.

## Setup

1. Run \`docker-compose up -d\` to build and start all the services.
2. Access Django at \`http://localhost:8000\`.
3. Access Node.js at \`http://localhost:3000\`.

## Services

- **PostgreSQL**: A relational database running on port 5432.
- **MongoDB**: A NoSQL database running on port 27017.
- **Django**: A Python web framework running on port 8000.
- **Node.js**: A JavaScript runtime running on port 3000.

## Notes

- Data for PostgreSQL and MongoDB is persisted using Docker volumes.
"@

Write-Output "Project structure created successfully at $PROJECT_ROOT"
