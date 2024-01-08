FROM python:3.10-slim

RUN apt-get update -y

# Clone repository into /app
WORKDIR /app

# Copy the local copy of the project to the Docker image
COPY . /app

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose Flask application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]