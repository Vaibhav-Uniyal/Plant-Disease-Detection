You're right! Let me provide the complete README content that you can directly apply:

```markdown:README.md
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

# To stop later
docker stop plant-disease-app
docker rm plant-disease-app
```

## Local Development

```bash
# Clone repo
git clone https://github.com/venom1510/mlops_project.git
cd mlops_project

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run locally
streamlit run main_app.py
```

## Project Structure
```
mlops_project/
├── main_app.py                    # Streamlit web app
├── Plant_Disease_Detection.ipynb  # Model training notebook
├── plant_disease_model.h5         # Trained model weights
├── plant_disease_model.h5.dvc     # DVC tracking file
├── requirements.txt               # Python dependencies
├── Dockerfile                     # Docker configuration
├── .dockerignore                  # Docker ignore patterns
├── .github/workflows/ci-cd.yml    # GitHub Actions pipeline
├── Test Image/                    # Sample test images
└── README.md                      # This file
```

## What We Implemented

### 1. Docker Containerization
- Optimized Dockerfile with Python 3.9 slim base
- System dependencies for TensorFlow and OpenCV
- Proper layer caching for faster builds
- Health checks and proper port exposure

### 2. CI/CD Pipeline
- GitHub Actions workflow for automated builds
- Docker Hub integration for image publishing
- AWS S3 integration for model artifacts via DVC
- Automated testing and deployment on push to main

### 3. MLOps Practices
- Model versioning with DVC
- Containerized ML application
- Automated model deployment
- Cloud storage for model artifacts

## Key Files

- **`main_app.py`**: Streamlit web interface for disease prediction
- **`Plant_Disease_Detection.ipynb`**: Jupyter notebook with model training code
- **`plant_disease_model.h5`**: Pre-trained CNN model weights
- **`Dockerfile`**: Container configuration with optimized builds
- **`.github/workflows/ci-cd.yml`**: Automated CI/CD pipeline
- **`requirements.txt`**: Python dependencies with specific versions

## Dependencies
```
# Core ML Libraries
tensorflow==2.12.0
keras==2.12.0
numpy==1.23.5
opencv-python-headless==4.7.0.72
pillow==9.5.0

# Web UI
streamlit==1.25.0

# Utility libraries
pandas==1.5.3

# Additional dependencies for stability
protobuf==3.20.3
grpcio==1.54.2
```

## How It Works

1. **Upload**: User uploads plant leaf image (JPG format)
2. **Preprocess**: Image resized to 256x256 pixels using OpenCV
3. **Predict**: CNN model classifies the disease type
4. **Display**: Results shown with plant type and disease name

## MLOps Pipeline Flow

1. **Development**: Code changes pushed to GitHub
2. **CI/CD Trigger**: GitHub Actions workflow starts automatically
3. **Build**: Docker image built with optimized layers
4. **Test**: Automated testing (if configured)
5. **Deploy**: Image pushed to Docker Hub
6. **Model Sync**: DVC pulls latest model from S3

## Team Notes

- Docker image is automatically built and pushed to Docker Hub on every commit to main
- Model artifacts are stored in AWS S3 and tracked with DVC
- The app is production-ready and can be deployed anywhere Docker runs
- CI/CD pipeline handles all the build complexity automatically
- Image is available at: `venom1510/plant-disease-detector:latest`

## DVC Pipeline & Experiments

### Pipeline Overview

This project uses DVC (Data Version Control) for:
- **Dataset tracking**: Versioning the PlantVillage dataset
- **Pipeline automation**: Reproducible training workflow
- **Experiment tracking**: Managing 20+ hyperparameter experiments
- **Model versioning**: Tracking model files with Git + S3

### Project Structure
```
mlops_project/
├── params.yaml              # Hyperparameters configuration
├── train.py                 # Training script
├── dvc.yaml                 # Pipeline definition
├── PlantVillage/            # Dataset (tracked by DVC)
│   ├── Potato___Early_blight/
│   ├── Potato___Late_blight/
│   └── Potato___healthy/
├── plant_disease_model.h5   # Trained model (pipeline output)
├── metrics.json             # Training metrics
└── plots/                   # Training visualizations
```

### Running the Pipeline

#### 1. Initial Training
```bash
# Activate virtual environment (WSL)
source venv/bin/activate

# Run the complete pipeline
dvc repro

# View results
cat metrics.json
ls plots/
```

#### 2. Modify Parameters
Edit `params.yaml` to change hyperparameters:
```yaml
training:
  epochs: 50          # Change this
  batch_size: 64      # Or this
  learning_rate: 0.001
```

Then rerun:
```bash
dvc repro
```

### Running 20 Experiments

#### Quick Method (Automated)
```bash
# Run all 20 experiments
./run_experiments.sh
```

#### Manual Method (Step by Step)
```bash
# Experiment 1: Different epochs
dvc exp run -n "exp-01-epochs-10" --set-param training.epochs=10

# Experiment 2: Different batch size
dvc exp run -n "exp-02-batch-64" --set-param training.batch_size=64

# Experiment 3: Different learning rate
dvc exp run -n "exp-03-lr-0.0001" --set-param training.learning_rate=0.0001

# Continue for 20 experiments...
```

#### Experiment Groups
1. **Epochs Variation** (Experiments 1-5): 10, 20, 40, 50, 100
2. **Batch Size Variation** (Experiments 6-10): 8, 16, 64, 128, 256
3. **Learning Rate Variation** (Experiments 11-15): 0.0001, 0.0005, 0.001, 0.005, 0.01
4. **Dropout Rate Variation** (Experiments 16-20): 0.2, 0.3, 0.4, 0.6, 0.7

See `EXPERIMENTS.md` for detailed experiment documentation.

### Viewing Experiment Results

```bash
# Show all experiments in a table
dvc exp show

# Compare two experiments
dvc exp diff exp-01-epochs-10 exp-05-epochs-100

# Show only changed parameters
dvc exp show --only-changed

# Export to CSV for analysis
dvc exp show --csv > experiments_results.csv
```

### Applying Best Experiment

```bash
# After identifying the best experiment
dvc exp apply exp-04-epochs-50

# This updates your workspace with:
# - Best hyperparameters in params.yaml
# - Best model in plant_disease_model.h5
# - Best metrics in metrics.json

# Commit the changes
git add params.yaml dvc.lock
git commit -m "Apply best experiment results"
dvc push
```

### Key DVC Commands

```bash
# Track dataset
dvc add PlantVillage

# Run pipeline
dvc repro

# Check pipeline status
dvc status

# Push model to S3
dvc push

# Pull model from S3
dvc pull

# List experiments
dvc exp list

# Show metrics
dvc metrics show
```

### Dataset Information

- **Classes**: 3 Potato disease categories
  - Potato___Early_blight (1,000 images)
  - Potato___Late_blight (1,000 images)  
  - Potato___healthy (152 images)
- **Total Images**: 2,152
- **Train/Val/Test Split**: 64% / 16% / 20%
- **Image Size**: 256x256 pixels
- **Source**: PlantVillage Dataset

### Baseline Model Configuration

```yaml
Model Architecture:
  - Conv2D layers: [32, 64, 128] filters
  - Dense layer: 512 units
  - Dropout: 0.5
  - Optimizer: Adam
  
Training:
  - Epochs: 30
  - Batch size: 32
  - Learning rate: 0.001
  - Loss: categorical_crossentropy
```

### Expected Performance

- **Training Time**: ~10-15 minutes per run (CPU)
- **Expected Accuracy**: 85-95% on test set
- **Model Size**: ~2.7 MB
- **Inference Time**: ~100ms per image

### Quick Start Guides

- `QUICK_START.md` - Step-by-step guide for running experiments
- `EXPERIMENTS.md` - Detailed experiment documentation
- `run_experiments.sh` - Automated script for 20 experiments

## Troubleshooting

### Docker Issues
```bash
# If Docker pull fails - login first
docker login

# If port 8501 is busy - use different port
docker run -p 8502:8501 venom1510/plant-disease-detector:latest

# Check if container is running
docker ps
```

### Local Development Issues
```bash
# If model file is missing
dvc pull plant_disease_model.h5

# If dependencies fail to install
pip install --upgrade pip
pip install -r requirements.txt --no-cache-dir
```

### CI/CD Issues
- Check GitHub secrets are properly configured
- Verify Docker Hub Personal Access Token has correct permissions
- Ensure AWS credentials are valid for DVC integration

---

**Ready to detect plant diseases! 🌱🔍**
```