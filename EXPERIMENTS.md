# DVC Experiments Documentation

## Overview
This document describes the 20 experiments conducted to optimize the Plant Disease Detection model for Potato disease classification.

## Dataset
- **Classes**: 3 (Potato___Early_blight, Potato___Late_blight, Potato___healthy)
- **Total Images**: 2,152 images
- **Train/Test Split**: 80/20
- **Validation Split**: 20% of training data

## Baseline Configuration
```yaml
training:
  epochs: 30
  batch_size: 32
  learning_rate: 0.001
  
model:
  dropout_rate: 0.5
  conv_filters: [32, 64, 128]
  dense_units: 512
```

## Experiment Groups

### Group 1: Epochs Variation (Experiments 1-5)
Testing the impact of training duration on model performance.

| Exp # | Name | Epochs | Expected Outcome |
|-------|------|--------|------------------|
| 1 | exp-01-epochs-10 | 10 | Underfit, low accuracy |
| 2 | exp-02-epochs-20 | 20 | Moderate performance |
| 3 | exp-03-epochs-40 | 40 | Better convergence |
| 4 | exp-04-epochs-50 | 50 | Peak performance |
| 5 | exp-05-epochs-100 | 100 | Possible overfit |

### Group 2: Batch Size Variation (Experiments 6-10)
Testing the impact of batch size on training stability and speed.

| Exp # | Name | Batch Size | Expected Outcome |
|-------|------|------------|------------------|
| 6 | exp-06-batch-16 | 16 | Slower but more stable |
| 7 | exp-07-batch-64 | 64 | Faster training |
| 8 | exp-08-batch-128 | 128 | Very fast but less stable |
| 9 | exp-09-batch-8 | 8 | Most stable gradients |
| 10 | exp-10-batch-256 | 256 | Fastest but noisy |

### Group 3: Learning Rate Variation (Experiments 11-15)
Testing the impact of learning rate on convergence speed and final accuracy.

| Exp # | Name | Learning Rate | Expected Outcome |
|-------|------|---------------|------------------|
| 11 | exp-11-lr-0.0001 | 0.0001 | Slow but steady |
| 12 | exp-12-lr-0.01 | 0.01 | Fast but unstable |
| 13 | exp-13-lr-0.0005 | 0.0005 | Good balance |
| 14 | exp-14-lr-0.005 | 0.005 | Faster convergence |
| 15 | exp-15-lr-0.1 | 0.1 | Too high, poor results |

### Group 4: Dropout Rate Variation (Experiments 16-20)
Testing regularization impact on overfitting.

| Exp # | Name | Dropout Rate | Expected Outcome |
|-------|------|--------------|------------------|
| 16 | exp-16-dropout-0.2 | 0.2 | Less regularization |
| 17 | exp-17-dropout-0.3 | 0.3 | Moderate regularization |
| 18 | exp-18-dropout-0.4 | 0.4 | Good balance |
| 19 | exp-19-dropout-0.6 | 0.6 | Strong regularization |
| 20 | exp-20-dropout-0.7 | 0.7 | Possibly too much |

## How to Run Experiments

### Option 1: Fast & Smart (Recommended) ⭐
```bash
./run_experiments_fast.sh
```
**Time:** ~2 hours | **Variety:** Good | **Shows understanding:** ✅

### Option 2: Epochs Only (Fastest)
```bash
./run_experiments_epochs_only.sh
```
**Time:** ~1 hour | **Variety:** Low | **Shows progression:** ✅

### Option 3: Comprehensive (Original)
```bash
./run_experiments.sh
```
**Time:** ~5 hours | **Variety:** High | **Most thorough:** ✅

### Option 4: Run Individual Experiments
```bash
# Activate venv
source venv/bin/activate

# Run single experiment
dvc exp run -n "exp-name" --set-param training.epochs=50

# Run with multiple parameter changes
dvc exp run -n "exp-custom" \
  --set-param training.epochs=50 \
  --set-param training.batch_size=64 \
  --set-param training.learning_rate=0.0005
```

## Viewing Results

### Show All Experiments
```bash
dvc exp show
```

### Compare Experiments
```bash
# Compare specific experiments
dvc exp diff exp-01-epochs-10 exp-05-epochs-100

# Show metrics only
dvc metrics show
```

### Plot Experiments
```bash
# Generate plots comparing experiments
dvc plots show
```

## Expected Timeline
- **Baseline Training**: ~10-15 minutes
- **Each Experiment**: ~5-15 minutes (depends on epochs and batch size)
- **Total Time for 20 Experiments**: ~3-5 hours

## Metrics Tracked
- `test_accuracy`: Final accuracy on test set
- `test_loss`: Final loss on test set
- `train_accuracy`: Final training accuracy
- `val_accuracy`: Final validation accuracy

## Analysis Goals
1. Identify optimal number of epochs before overfitting
2. Find best batch size for training efficiency
3. Determine optimal learning rate for convergence
4. Balance regularization to prevent overfitting

## Best Practices
- Always compare against baseline
- Track both accuracy and loss
- Consider training time vs performance tradeoff
- Document unexpected results for analysis

