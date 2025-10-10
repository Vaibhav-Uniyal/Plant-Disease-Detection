# Library imports
import numpy as np
import streamlit as st
import cv2
import tensorflow as tf
import os
import sys

# Suppress TensorFlow warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

# Loading the Model with backward compatibility for both Keras 2 and Keras 3
@st.cache_resource
def load_plant_model():
    """Load model with support for both Keras 2.x and Keras 3.x formats"""
    try:
        # Load model - TF 2.15+ supports both Keras 2 and 3 formats
        model = tf.keras.models.load_model('plant_disease_model.h5', compile=False)
        
        # Verify model loaded correctly
        if model is not None:
            st.success("✅ Model loaded successfully!")
            return model
        else:
            raise ValueError("Model loaded but returned None")
            
    except Exception as e:
        st.error(f"❌ Error loading model: {str(e)}")
        st.error("Please ensure the model file exists and is in the correct format")
        st.info("Run `dvc pull` to download the model from S3")
        return None

# Load model at startup
model = load_plant_model()

# Check if model loaded successfully
if model is None:
    st.warning("Model failed to load. Please check the error messages above.")
    st.stop()
                    
# Name of Classes (Updated for Potato Disease Model)
CLASS_NAMES = ('Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy')

# Setting Title of App
st.title("Plant Disease Detection")
st.markdown("Upload an image of the plant leaf")

# Uploading the dog image
plant_image = st.file_uploader("Choose an image...", type = "jpg")
submit = st.button('predict Disease')

# On predict button click
if submit:
    if plant_image is not None:
        try:
            # Convert the file to an opencv image
            file_bytes = np.asarray(bytearray(plant_image.read()), dtype=np.uint8)
            opencv_image = cv2.imdecode(file_bytes, 1)
            
            if opencv_image is None:
                st.error("Failed to decode image. Please upload a valid JPG image.")
                st.stop()
            
            # Displaying the image
            st.image(opencv_image, channels="BGR")
            st.write(f"Image shape: {opencv_image.shape}")
            
            # Resizing the image to model input size
            opencv_image = cv2.resize(opencv_image, (256, 256))
            
            # Normalize and add batch dimension
            opencv_image = opencv_image.astype(np.float32) / 255.0
            opencv_image = np.expand_dims(opencv_image, axis=0)
            
            # Make Prediction
            with st.spinner('Analyzing the image...'):
                Y_pred = model.predict(opencv_image, verbose=0)
            
            # Get prediction result
            predicted_class_idx = np.argmax(Y_pred)
            confidence = Y_pred[0][predicted_class_idx] * 100
            result = CLASS_NAMES[predicted_class_idx]
            
            # Display result with confidence
            st.success("Prediction complete!")
            
            # Split by three underscores and format the output
            parts = result.split('___')
            if len(parts) == 2:
                plant_type = parts[0]
                disease_status = parts[1].replace('_', ' ')
                st.title(f"🌿 This is a {plant_type} leaf with {disease_status}")
                st.metric("Confidence", f"{confidence:.2f}%")
            else:
                st.title(f"🌿 Prediction: {result}")
                st.metric("Confidence", f"{confidence:.2f}%")
            
            # Show all class probabilities
            with st.expander("View detailed probabilities"):
                for idx, class_name in enumerate(CLASS_NAMES):
                    prob = Y_pred[0][idx] * 100
                    st.write(f"{class_name}: {prob:.2f}%")
                    
        except Exception as e:
            st.error(f"Error during prediction: {str(e)}")
            import traceback
            st.code(traceback.format_exc())
    else:
        st.warning("Please upload an image first before clicking predict!")
