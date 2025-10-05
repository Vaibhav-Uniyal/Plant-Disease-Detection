# Plant Disease Detection - MLOps Project 🌱

A machine learning project for detecting plant diseases using CNN with complete MLOps pipeline implementation.

## What We Built

- **ML Model**: CNN model to detect plant diseases (Tomato Bacterial Spot, Potato Early Blight, Corn Common Rust)
- **Web App**: Streamlit interface for image upload and prediction
- **Docker Container**: Fully containerized application
- **CI/CD Pipeline**: Automated build and deployment using GitHub Actions
- **Model Versioning**: DVC integration for model tracking

## Quick Start - Run with Docker

### Pull and Run the Container
```bash
# Pull the image from Docker Hub
docker pull venom1510/plant-disease-detector:latest

# Run the container
docker run -p 8501:8501 venom1510/plant-disease-detector:latest

# Open browser: http://localhost:8501
```

### Run in Background
```bash
docker run -d -p 8501:8501 --name plant-disease-app venom1510/plant-disease-detector:latest
```

## Local Development

```bash
# Clone repo
git clone <your-repo-url>
cd mlops_project

# Install dependencies
pip install -r requirements.txt

# Run locally
streamlit run main_app.py
```

## Project Structure
