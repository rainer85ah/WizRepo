FROM python:3.11-slim

WORKDIR /app

# Install curl and dependencies
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r ./requirements.txt

# Create wizexercise.txt inside the image
RUN echo "This is content of wizexercise.txt" > wizexercise.txt

COPY . .
EXPOSE 8080
CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app"]