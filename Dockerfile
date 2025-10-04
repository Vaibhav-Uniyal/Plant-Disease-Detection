FROM python:3.9-slim

WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl git && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for caching)
COPY requirements.txt .

# Install Python deps
RUN pip install --no-cache-dir --prefer-binary -r requirements.txt
RUN pip install dvc[s3] --no-cache-dir

# Copy the rest of the code
COPY . /app

# Pull model from DVC remote (S3)
RUN dvc pull plant_disease_model.h5

# Expose Streamlit port
EXPOSE 8501

# Run app
CMD ["streamlit", "run", "main_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
