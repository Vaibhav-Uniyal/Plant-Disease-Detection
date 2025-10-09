#!/usr/bin/env python3
"""
Resave the model in compatible format
"""
import tensorflow as tf
from tensorflow.keras.models import load_model

print("Loading existing model...")
model = load_model('plant_disease_model.h5', compile=True)

print("Model loaded successfully!")
print(f"Input shape: {model.input_shape}")
print(f"Output shape: {model.output_shape}")

print("\nResaving model in compatible format...")
model.save('plant_disease_model.h5', save_format='h5', include_optimizer=False)

print("✅ Model resaved successfully!")
print("Now push to S3 with: dvc push")

