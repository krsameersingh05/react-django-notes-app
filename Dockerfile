# Stage 1: Build React frontend
FROM node:16-alpine as frontend

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build

# Stage 2: Django backend setup
FROM python:3.11-slim as backend

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Create Python virtual environment
RUN python -m venv env

# Set environment PATH to use venv
ENV PATH="/app/env/bin:$PATH"

# Install Python dependencies inside venv
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy Django backend code
COPY . .

# Copy React build output
COPY --from=frontend /app/frontend/build /app/frontend/build/

# Expose Django port
EXPOSE 8000

# Run server using virtual environment python
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

