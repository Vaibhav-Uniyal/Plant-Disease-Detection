# 🌱 Plant Disease Detection - MLOps Project

A production-ready machine learning project for detecting potato plant diseases using CNN with complete MLOps pipeline implementation including CI/CD, Docker, DVC, and AWS S3 integration.

![Python](https://img.shields.io/badge/Python-3.9-blue)
![TensorFlow](https://img.shields.io/badge/TensorFlow-2.15.0-orange)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-green)

## 🎯 Project Overview

This project implements an end-to-end MLOps pipeline for plant disease detection with:
- **Deep Learning Model**: CNN trained on PlantVillage dataset (95%+ accuracy)
- **Web Application**: Interactive Streamlit UI for real-time predictions
- **Containerization**: Fully Dockerized application
- **CI/CD Pipeline**: Automated build and deployment using GitHub Actions
- **Model Versioning**: DVC integration with AWS S3 for model tracking
- **Experiment Tracking**: 20+ hyperparameter experiments documented

---

## 🚀 Quick Start - Run with Docker

### Option 1: Pull from Docker Hub (Recommended)

```bash
# Pull the latest image
docker pull venom1510/plant-disease-detector:latest

# Run the container
docker run -d -p 8501:8501 --name plant-disease-app venom1510/plant-disease-detector:latest

# Open browser at http://localhost:8501
```

### Option 2: Build Locally

```bash
git clone https://github.com/Vaibhav-Uniyal/Plant-Disease-Detection.git
cd Plant-Disease-Detection
docker build -t plant-disease-detector .
docker run -p 8501:8501 plant-disease-detector
```

---

## 💻 Local Development Setup

### Prerequisites
- Python 3.9+
- Git
- DVC (for model versioning)
- AWS credentials (for DVC S3 remote)

### Installation Steps

```bash
# Clone the repository
git clone https://github.com/Vaibhav-Uniyal/Plant-Disease-Detection.git
cd Plant-Disease-Detection

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Pull model from S3 (using DVC)
dvc pull

# Run the Streamlit app
streamlit run main_app.py
```

Access the app at **http://localhost:8501**

---

## 📁 Project Structure

```
mlops_project/
├── main_app.py                    # Streamlit web application
├── train.py                       # Model training script
├── test_model.py                  # Model testing utilities
├── params.yaml                    # Hyperparameters configuration
├── dvc.yaml                       # DVC pipeline definition
├── dvc.lock                       # DVC lock file
├── plant_disease_model.h5         # Trained CNN model (tracked by DVC)
├── metrics.json                   # Training metrics
├── requirements.txt               # Python dependencies
├── Dockerfile                     # Docker configuration
├── .dockerignore                  # Docker ignore patterns
├── .dvc/                          # DVC configuration
│   └── config                     # S3 remote configuration
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── PlantVillage/                  # Dataset (tracked by DVC)
│   ├── Potato___Early_blight/
│   ├── Potato___Late_blight/
│   └── Potato___healthy/
├── plots/                         # Training visualizations
├── Test Image/                    # Sample test images
├── EXPERIMENTS.md                 # Experiment documentation
├── QUICK_START.md                 # Quick start guide
└── README.md                      # This file
```

---

## 🧠 Model Information

### Architecture
- **Type**: Convolutional Neural Network (CNN)
- **Input**: 256×256×3 RGB images
- **Layers**: 
  - 3 Convolutional blocks (32, 64, 128 filters)
  - MaxPooling and Dropout layers
  - Dense layer (512 units)
  - Output layer (3 classes with softmax)
- **Model Size**: 111 MB
- **Format**: Keras 3 compatible HDF5

### Performance
- **Test Accuracy**: 95.82%
- **Classes**: 
  - Potato___Early_blight
  - Potato___Late_blight
  - Potato___healthy
- **Training Dataset**: 2,152 images from PlantVillage
- **Inference Time**: ~1-3 seconds per image

---

## 🔧 Technology Stack

### Machine Learning
- **TensorFlow**: 2.15.0
- **NumPy**: 1.24.3
- **OpenCV**: 4.8.1.78
- **Scikit-learn**: 1.3.2

### Web Framework
- **Streamlit**: 1.28.1

### MLOps Tools
- **DVC**: 3.51.0 (Data & model versioning)
- **Docker**: Containerization
- **GitHub Actions**: CI/CD pipeline
- **AWS S3**: Model storage

### Development
- **Python**: 3.9.18
- **Pandas**: 2.0.3
- **Matplotlib**: 3.8.2

---

## 🔄 CI/CD Pipeline

### Automated Workflow

Every push to `main` branch triggers:

1. **Code Checkout**: Repository cloned
2. **Docker Authentication**: Login to Docker Hub
3. **AWS Configuration**: Setup AWS credentials
4. **Model Pull**: Download model from S3 via DVC
5. **Docker Build**: Build optimized image
6. **Docker Push**: Push to Docker Hub
7. **Deployment Ready**: Image available at `venom1510/plant-disease-detector:latest`

### Pipeline Configuration

File: `.github/workflows/ci-cd.yml`

**Required GitHub Secrets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `S3_BUCKET`
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

---

## 📊 DVC Pipeline & Experiments

### Pipeline Overview

DVC manages:
- ✅ Dataset versioning (PlantVillage - 2,152 images)
- ✅ Reproducible training pipeline
- ✅ Model versioning with S3 storage
- ✅ Experiment tracking (20+ runs)
- ✅ Metrics comparison

### Running the Pipeline

```bash
# Reproduce the entire pipeline
dvc repro

# View pipeline status
dvc status

# Push artifacts to S3
dvc push

# Pull artifacts from S3
dvc pull
```

### Experiment Tracking

```bash
# Run a single experiment
dvc exp run -n "exp-01-epochs-25" --set-param training.epochs=25

# Run all experiments (automated)
./run_experiments.sh

# View experiment results
dvc exp show

# Compare experiments
dvc exp diff exp-01-epochs-25 exp-02-epochs-50

# Apply best experiment
dvc exp apply exp-18-epochs-25
git add params.yaml dvc.lock
git commit -m "Apply best experiment"
```

### Hyperparameter Experiments

20+ experiments conducted varying:
- **Epochs**: 1-100
- **Batch Size**: 8-256
- **Learning Rate**: 0.0001-0.01
- **Dropout Rate**: 0.2-0.7

See `EXPERIMENTS.md` for detailed results.

---

## 🎨 Features

### For Users
- 📤 **Image Upload**: Upload potato leaf images (JPG format)
- 🔍 **Instant Predictions**: Real-time disease detection
- 📊 **Confidence Scores**: See prediction confidence percentages
- 📈 **Probability Breakdown**: View all class probabilities
- 🎯 **User-Friendly UI**: Clean, intuitive interface

### For Developers
- 🐳 **Docker Support**: One-command deployment
- 🔄 **CI/CD Pipeline**: Automated builds on every commit
- 📦 **Model Versioning**: Track models with DVC + S3
- 📝 **Experiment Tracking**: Compare 20+ training runs
- 🧪 **Reproducible Pipeline**: Automated training with DVC
- ⚡ **Optimized Inference**: Fast predictions with TensorFlow

---

## 🌐 Deployment

### Docker Hub
**Image**: `venom1510/plant-disease-detector:latest`

```bash
# Pull
docker pull venom1510/plant-disease-detector:latest

# Run
docker run -d -p 8501:8501 --name plant-disease-detector-app venom1510/pl
ant-disease-detector:latest

# Stop
docker stop plant-disease-detector-app && docker rm plant-disease-detecto
r-app
```

### Environment Variables

```bash
# For TensorFlow optimization
TF_CPP_MIN_LOG_LEVEL=2  # Suppress TF warnings

# For custom port
docker run -p 8502:8501 venom1510/plant-disease-detector:latest
```

---

## 📖 Usage

### Web Interface

1. Open the app in your browser
2. Click "Choose an image..." to upload a potato leaf image
3. Click "predict Disease" button
4. View results:
   - Disease classification
   - Confidence percentage
   - Detailed probability breakdown

### Supported Image Formats
- **Format**: JPG/JPEG
- **Recommended Size**: Any (auto-resized to 256×256)
- **Quality**: Higher quality images give better results

---

## 🔍 How It Works

### Prediction Pipeline

```
Input Image (JPG)
    ↓
Decode with OpenCV
    ↓
Resize to 256×256
    ↓
Normalize (0-1 range)
    ↓
CNN Model Inference
    ↓
Softmax Classification
    ↓
Display Results
```

### Training Pipeline (DVC)

```
PlantVillage Dataset
    ↓
train.py (with params.yaml)
    ↓
Model Training (CNN)
    ↓
Save Artifacts
    ├── plant_disease_model.h5
    ├── metrics.json
    └── plots/training_history.png
    ↓
Push to S3 (DVC)
```

---

## 🛠️ Troubleshooting

### Docker Issues

```bash
# Port already in use
docker run -d -p 8501:8501 --name plant-disease-detector-app venom1510/pl
ant-disease-detector:latest

# Container not starting
docker logs plant-disease-app

# Clean up old containers
docker system prune -a
```

### Model Loading Issues

```bash
# Model file missing
dvc pull

# DVC connection issues
dvc remote list
dvc status
```

### Local Development Issues

```bash
# Dependencies fail
pip install --upgrade pip
pip install -r requirements.txt --no-cache-dir

# TensorFlow issues
pip install tensorflow==2.15.0 --no-cache-dir
```

---

## 📈 Performance Metrics

### Latest Model (95.82% Accuracy)

```json
{
  "test_accuracy": 0.9582,
  "test_loss": 0.1243,
  "train_accuracy": 0.9876,
  "val_accuracy": 0.9634,
  "epochs": 25,
  "batch_size": 32,
  "learning_rate": 0.001
}
```

### Dataset Statistics
- **Total Images**: 2,152
- **Training Set**: 1,377 images (64%)
- **Validation Set**: 344 images (16%)
- **Test Set**: 431 images (20%)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is created for educational and portfolio purposes.

---

## 👥 Author

**Vaibhav Uniyal**
- GitHub: [@Vaibhav-Uniyal](https://github.com/Vaibhav-Uniyal)
- Docker Hub: [venom1510](https://hub.docker.com/u/venom1510)

---

## 🙏 Acknowledgments

- **PlantVillage Dataset**: For providing the training data
- **TensorFlow/Keras**: For the deep learning framework
- **Streamlit**: For the web application framework
- **DVC**: For data and model versioning
- **Docker**: For containerization

---

## 🔗 Links

- **Docker Image**: [venom1510/plant-disease-detector](https://hub.docker.com/r/venom1510/plant-disease-detector)
- **GitHub Repository**: [Plant-Disease-Detection](https://github.com/Vaibhav-Uniyal/Plant-Disease-Detection)
- **CI/CD Pipeline**: GitHub Actions (automated)

---

## 📚 Additional Documentation

- `EXPERIMENTS.md` - Detailed experiment results and analysis
- `QUICK_START.md` - Step-by-step setup guide
- `SETUP_SUMMARY.md` - Project setup summary

---

**🌱 Ready to detect plant diseases with MLOps! 🚀**


