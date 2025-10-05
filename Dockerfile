# Use Python 3.9 slim with specific version for stability
FROM python:3.9.18-slim

# Set working directory
WORKDIR /app

# Install system dependencies in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgfortran5 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies with specific optimizations
RUN pip install --upgrade pip==23.3.1 setuptools==68.2.2 wheel==0.41.2 \
    && pip install --no-cache-dir --prefer-binary \
       --timeout 300 \
       --retries 3 \
       -r requirements.txt

# Install DVC and boto3 separately to avoid conflicts
RUN pip install --no-cache-dir --prefer-binary \
    "dvc[s3]==3.51.0" \
    "boto3==1.34.69" \
    "botocore==1.34.69"

# Copy application code
COPY . .

# Set environment variables for TensorFlow
ENV TF_CPP_MIN_LOG_LEVEL=2
ENV PYTHONPATH=/app

# Expose Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Run the application
CMD ["streamlit", "run", "main_app.py", "--server.port=8501", "--server.address=0.0.0.0", "--server.headless=true"]
