FROM python:3.10-slim

RUN apt-get update -y && apt-get install git -y

# Clone repository into /app
WORKDIR /app
RUN git clone https://github.com/Sonntd271/mura-app.git

# Change working directory to mura-app
WORKDIR /app/mura-app

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose Flask application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]