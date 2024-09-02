# Define project structure
$PROJECT_ROOT = "."

# Create project directories
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\config"
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\apps\example_app"
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\static"
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\templates"
New-Item -ItemType Directory -Force -Path "$PROJECT_ROOT\.github\workflows"

# Create Dockerfile
@"
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project code to the container
COPY . /app/

# Expose port 8000
EXPOSE 8000

# Run the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
"@ > $PROJECT_ROOT\Dockerfile

# Create requirements.txt
@"
Django>=3.2,<4.0
djangorestframework>=3.12,<4.0
djongo==1.3.6         # For MongoDB integration
psycopg2-binary>=2.9  # For PostgreSQL integration
"@ > $PROJECT_ROOT\requirements.txt

# Create .env.example
@"
SECRET_KEY=your-secret-key
DEBUG=True
ALLOWED_HOSTS=localhost 127.0.0.1 [::1]

# Database configurations
POSTGRES_DB=mydb
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

MONGO_HOST=mongo
MONGO_PORT=27017
"@ > $PROJECT_ROOT\.env.example

# Create manage.py (basic structure)
@"
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
"@ > $PROJECT_ROOT\manage.py

# Create config/__init__.py
New-Item -ItemType File -Force -Path "$PROJECT_ROOT\config\__init__.py" | Out-Null

# Create config/asgi.py
@"
"""
ASGI config for the project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/3.2/howto/deployment/asgi/
"""

import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

application = get_asgi_application()
"@ > $PROJECT_ROOT\config\asgi.py

# Create config/settings.py
@"
import os
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv('SECRET_KEY', 'your-default-secret-key')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.getenv('DEBUG', 'True') -eq 'True'

ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', 'localhost 127.0.0.1 [::1]').Split()

# Application definition
INSTALLED_APPS = @(
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'apps.example_app'
)

MIDDLEWARE = @(
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware'
)

ROOT_URLCONF = 'config.urls'

TEMPLATES = @(
    @{
        'BACKEND' = 'django.template.backends.django.DjangoTemplates'
        'DIRS' = @("$BASE_DIR/templates")
        'APP_DIRS' = $true
        'OPTIONS' = @{
            'context_processors' = @(
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages'
            )
        }
    }
)

WSGI_APPLICATION = 'config.wsgi.application'

# Database
DATABASES = @{
    'default' = @{
        'ENGINE' = 'django.db.backends.postgresql'
        'NAME' = (os.getenv('POSTGRES_DB'))
        'USER' = (os.getenv('POSTGRES_USER'))
        'PASSWORD' = (os.getenv('POSTGRES_PASSWORD'))
        'HOST' = (os.getenv('POSTGRES_HOST'))
        'PORT' = (os.getenv('POSTGRES_PORT'))
    }
    'mongo' = @{
        'ENGINE' = 'djongo'
        'NAME' = 'my_mongo_db'
        'ENFORCE_SCHEMA' = $false
        'CLIENT' = @{
            'host' = (os.getenv('MONGO_HOST'))
            'port' = [int](os.getenv('MONGO_PORT'))
        }
    }
}

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
"@ > $PROJECT_ROOT\config\settings.py

# Create config/urls.py
@"
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('apps.example_app.urls')),
]
"@ > $PROJECT_ROOT\config\urls.py

# Create config/wsgi.py
@"
"""
WSGI config for the project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/3.2/howto/deployment/wsgi/
"""

import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

application = get_wsgi_application()
"@ > $PROJECT_ROOT\config\wsgi.py

# Create apps/example_app/__init__.py
New-Item -ItemType File -Force -Path "$PROJECT_ROOT\apps\example_app\__init__.py" | Out-Null

# Create apps/example_app/admin.py
@"
from django.contrib import admin
from .models import ExampleModel

admin.site.register(ExampleModel)
"@ > $PROJECT_ROOT\apps\example_app\admin.py

# Create apps/example_app/apps.py
@"
from django.apps import AppConfig

class ExampleAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.example_app'
"@ > $PROJECT_ROOT\apps\example_app\apps.py

# Create apps/example_app/models.py
@"
from django.db import models

class ExampleModel(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name
"@ > $PROJECT_ROOT\apps\example_app\models.py

# Create apps/example_app/views.py
@"
from django.http import JsonResponse

def example_view(request):
    return JsonResponse({'message': 'Hello, world!'})
"@ > $PROJECT_ROOT\apps\example_app\views.py

# Create apps/example_app/urls.py
@"
from django.urls import path
from .views import example_view

urlpatterns = [
    path('example/', example_view),
]
"@ > $PROJECT_ROOT\apps\example_app\urls.py

# Create .github/workflows/python-ci.yml
@"
name: Django CI

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt

    - name: Run tests
      run: |
        python manage.py test
"@ > $PROJECT_ROOT\.github\workflows\python-ci.yml

Write-Output "Django skeleton project structure created successfully."
