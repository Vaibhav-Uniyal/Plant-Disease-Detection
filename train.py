"""
Plant Disease Detection Model Training Script
This script trains a CNN model for detecting potato diseases using DVC pipeline
"""

import os
import json
import yaml
import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Activation, Flatten, Dropout, Dense
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.utils import to_categorical, img_to_array
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt

# Set random seeds for reproducibility
np.random.seed(42)
tf.random.set_seed(42)

def load_params(params_file='params.yaml'):
    """Load parameters from YAML file"""
    with open(params_file, 'r') as f:
        params = yaml.safe_load(f)
    return params

def convert_image_to_array(image_path, image_size):
    """Convert image to numpy array"""
    try:
        image = cv2.imread(image_path)
        if image is not None:
            image = cv2.resize(image, (image_size, image_size))
            return img_to_array(image)
        else:
            return np.array([])
    except Exception as e:
        print(f"Error loading {image_path}: {e}")
        return None

def load_dataset(params):
    """Load and preprocess the dataset"""
    dataset_path = params['data']['dataset_path']
    classes = params['data']['classes']
    image_size = params['data']['image_size']
    
    print(f"Loading dataset from: {dataset_path}")
    print(f"Classes: {classes}")
    
    image_list = []
    label_list = []
    
    for class_idx, class_name in enumerate(classes):
        class_path = os.path.join(dataset_path, class_name)
        print(f"Loading {class_name}...")
        
        if not os.path.exists(class_path):
            raise ValueError(f"Class directory not found: {class_path}")
        
        images = os.listdir(class_path)
        for image_name in images:
            image_path = os.path.join(class_path, image_name)
            image_array = convert_image_to_array(image_path, image_size)
            
            if image_array is not None and image_array.size > 0:
                image_list.append(image_array)
                label_list.append(class_idx)
    
    print(f"Total images loaded: {len(image_list)}")
    
    # Convert to numpy arrays and normalize
    image_data = np.array(image_list, dtype=np.float32) / 255.0
    labels = np.array(label_list)
    
    return image_data, labels, classes

def build_model(params, num_classes):
    """Build CNN model"""
    input_shape = tuple(params['model']['input_shape'])
    conv_filters = params['model']['conv_filters']
    dense_units = params['model']['dense_units']
    dropout_rate = params['model']['dropout_rate']
    
    model = Sequential()
    
    # First Convolutional Block
    model.add(Conv2D(conv_filters[0], (3, 3), padding='same', input_shape=input_shape))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(3, 3)))
    model.add(Dropout(0.25))
    
    # Second Convolutional Block
    model.add(Conv2D(conv_filters[1], (3, 3), padding='same'))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))
    
    # Third Convolutional Block
    model.add(Conv2D(conv_filters[2], (3, 3), padding='same'))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))
    
    # Flatten and Dense layers
    model.add(Flatten())
    model.add(Dense(dense_units))
    model.add(Activation('relu'))
    model.add(Dropout(dropout_rate))
    
    # Output layer
    model.add(Dense(num_classes))
    model.add(Activation('softmax'))
    
    return model

def train_model(params):
    """Main training function"""
    print("=" * 60)
    print("Plant Disease Detection - Model Training")
    print("=" * 60)
    
    # Load dataset
    image_data, labels, class_names = load_dataset(params)
    num_classes = len(class_names)
    
    # One-hot encode labels
    labels = to_categorical(labels, num_classes)
    
    # Split data
    test_split = params['data']['test_split']
    val_split = params['data']['validation_split']
    random_seed = params['data']['random_seed']
    
    # Train-test split
    x_train_full, x_test, y_train_full, y_test = train_test_split(
        image_data, labels, test_size=test_split, random_state=random_seed
    )
    
    # Train-validation split
    x_train, x_val, y_train, y_val = train_test_split(
        x_train_full, y_train_full, test_size=val_split, random_state=random_seed
    )
    
    print(f"\nDataset split:")
    print(f"  Training: {len(x_train)} images")
    print(f"  Validation: {len(x_val)} images")
    print(f"  Test: {len(x_test)} images")
    
    # Build model
    print("\nBuilding model...")
    model = build_model(params, num_classes)
    
    # Compile model
    learning_rate = params['training']['learning_rate']
    optimizer = Adam(learning_rate=learning_rate)
    
    model.compile(
        loss=params['training']['loss'],
        optimizer=optimizer,
        metrics=params['training']['metrics']
    )
    
    print("\nModel Summary:")
    model.summary()
    
    # Train model
    print("\nTraining model...")
    epochs = params['training']['epochs']
    batch_size = params['training']['batch_size']
    
    history = model.fit(
        x_train, y_train,
        validation_data=(x_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        verbose=1
    )
    
    # Evaluate on test set
    print("\nEvaluating on test set...")
    test_loss, test_accuracy = model.evaluate(x_test, y_test, verbose=0)
    
    print(f"\nTest Results:")
    print(f"  Loss: {test_loss:.4f}")
    print(f"  Accuracy: {test_accuracy:.4f} ({test_accuracy * 100:.2f}%)")
    
    # Save model
    model_path = params['paths']['model_output']
    print(f"\nSaving model to {model_path}...")
    # Save with compatible format
    model.save(model_path, save_format='h5', include_optimizer=False)
    
    # Save metrics
    metrics = {
        'test_loss': float(test_loss),
        'test_accuracy': float(test_accuracy),
        'train_accuracy': float(history.history['accuracy'][-1]),
        'val_accuracy': float(history.history['val_accuracy'][-1]),
        'epochs': epochs,
        'batch_size': batch_size,
        'learning_rate': learning_rate,
        'num_classes': num_classes,
        'total_images': len(image_data),
        'class_names': class_names
    }
    
    metrics_path = params['paths']['metrics_output']
    with open(metrics_path, 'w') as f:
        json.dump(metrics, f, indent=4)
    
    print(f"Metrics saved to {metrics_path}")
    
    # Save training plots
    plot_dir = params['paths']['plots_output']
    os.makedirs(plot_dir, exist_ok=True)
    
    # Plot accuracy
    plt.figure(figsize=(12, 5))
    
    plt.subplot(1, 2, 1)
    plt.plot(history.history['accuracy'], label='Train Accuracy')
    plt.plot(history.history['val_accuracy'], label='Val Accuracy')
    plt.title('Model Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.legend()
    plt.grid(True)
    
    # Plot loss
    plt.subplot(1, 2, 2)
    plt.plot(history.history['loss'], label='Train Loss')
    plt.plot(history.history['val_loss'], label='Val Loss')
    plt.title('Model Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.legend()
    plt.grid(True)
    
    plt.tight_layout()
    plt.savefig(os.path.join(plot_dir, 'training_history.png'), dpi=150)
    print(f"Training plots saved to {plot_dir}")
    
    print("\n" + "=" * 60)
    print("Training completed successfully!")
    print("=" * 60)
    
    return metrics

if __name__ == "__main__":
    # Load parameters
    params = load_params('params.yaml')
    
    # Train model
    metrics = train_model(params)
    
    print("\nFinal Metrics:")
    for key, value in metrics.items():
        if isinstance(value, float):
            print(f"  {key}: {value:.4f}")
        else:
            print(f"  {key}: {value}")

