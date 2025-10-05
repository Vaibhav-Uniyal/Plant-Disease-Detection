# ✅ Use slim base with pinned versions for faster dependency resolution
FROM python:3.9-slim

# ✅ Set working directory
WORKDIR /app

# ✅ Preinstall system dependencies only once
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# ✅ Copy requirements first for layer caching
COPY requirements.txt .

# ✅ Install dependencies with no backtracking
# Use constrained resolver + wheel-only installs for speed
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --prefer-binary \
       --timeout 1000 \
       -r requirements.txt \
    && pip install --no-cache-dir --prefer-binary "dvc[s3]==3.51.0" boto3==1.34.69

# ✅ Copy only app code
COPY . .

# ✅ Pull model (optional safeguard)
RUN dvc pull plant_disease_model.h5 || echo "Skipping DVC pull in build stage."

# ✅ Expose Streamlit default port
EXPOSE 8501

# ✅ Default command
CMD ["streamlit", "run", "main_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
