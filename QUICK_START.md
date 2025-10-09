# Quick Start Guide - DVC Experiments

## 🚀 After First Training Completes

### 1. Check Training Results
```bash
# View metrics
cat metrics.json

# View training plots
ls -la plots/

# Check DVC pipeline status
dvc status
```

### 2. Commit the Baseline
```bash
# Add DVC files
git add dvc.yaml dvc.lock params.yaml train.py
git add PlantVillage.dvc .gitignore
git add metrics.json plots/

# Commit
git commit -m "Add DVC pipeline and baseline training"

# Push model to S3 (if configured)
dvc push
```

### 3. Run Your 20 Experiments

**Option A: Run all at once (3-5 hours)**
```bash
source venv/bin/activate
./run_experiments.sh
```

**Option B: Run in batches**
```bash
source venv/bin/activate

# Run first 5 experiments (epochs variation)
dvc exp run -n "exp-01-epochs-10" --set-param training.epochs=10
dvc exp run -n "exp-02-epochs-20" --set-param training.epochs=20
dvc exp run -n "exp-03-epochs-40" --set-param training.epochs=40
dvc exp run -n "exp-04-epochs-50" --set-param training.epochs=50
dvc exp run -n "exp-05-epochs-100" --set-param training.epochs=100

# View results so far
dvc exp show
```

### 4. Analyze Experiments
```bash
# Show all experiments in a table
dvc exp show

# Compare two specific experiments
dvc exp diff exp-01-epochs-10 exp-05-epochs-100

# Show only metrics
dvc metrics show

# Export results to CSV
dvc exp show --csv > experiments.csv
```

### 5. Select Best Model
```bash
# Apply the best experiment to your workspace
dvc exp apply exp-04-epochs-50

# This will update:
# - params.yaml (with best hyperparameters)
# - plant_disease_model.h5 (with best model)
# - metrics.json (with best metrics)
```

### 6. Push Best Model to Production
```bash
# Commit the best configuration
git add params.yaml dvc.lock
git commit -m "Apply best experiment: exp-04-epochs-50"

# Push model to S3
dvc push

# Push to GitHub
git push
```

## 📊 Understanding DVC Experiments

### What Happens During an Experiment?
1. DVC creates a copy of your workspace
2. Modifies params.yaml with new values
3. Runs `dvc repro` to train model
4. Stores results without affecting your main workspace
5. You can compare all experiments side-by-side

### Key Commands
```bash
# List all experiments
dvc exp list

# Show experiments table
dvc exp show

# Show specific columns
dvc exp show --only-changed

# Remove an experiment
dvc exp remove exp-name

# Push experiments to remote
dvc exp push origin exp-name
```

## 🎯 Experiment Strategy

### Quick Experiments (10-20 epochs)
Best for rapid iteration and testing parameters:
```bash
dvc exp run -n "quick-test" --set-param training.epochs=10
```

### Full Experiments (30-50 epochs)
Best for final comparison:
```bash
dvc exp run -n "full-test" --set-param training.epochs=50
```

### Multi-Parameter Experiments
```bash
dvc exp run -n "optimized" \
  --set-param training.epochs=50 \
  --set-param training.batch_size=64 \
  --set-param training.learning_rate=0.0005 \
  --set-param model.dropout_rate=0.4
```

## 📈 Expected Results

### Good Results to Look For:
- **Test Accuracy**: > 85%
- **Train-Val Gap**: < 5% (indicates no overfitting)
- **Training Time**: 5-15 minutes per experiment

### Red Flags:
- Test accuracy << Train accuracy (overfitting)
- Very low accuracy (< 60%) - check learning rate
- Training time > 30 min - consider smaller epochs for experiments

## 🔧 Troubleshooting

### Experiment Failed?
```bash
# Check error logs
dvc exp show --show-failed

# Remove failed experiment
dvc exp remove failed-exp-name
```

### Out of Memory?
```bash
# Reduce batch size
dvc exp run -n "smaller-batch" --set-param training.batch_size=16
```

### Taking Too Long?
```bash
# Reduce epochs for testing
dvc exp run -n "quick-test" --set-param training.epochs=10
```

## 📝 For Your Assignment Report

### Document These:
1. **Baseline Performance**: First training results
2. **Best Experiment**: Which hyperparameters worked best
3. **Interesting Findings**: Unexpected results
4. **Comparison Table**: Use `dvc exp show` output
5. **Plots**: Include training history plots

### Generate Report Data:
```bash
# Export experiments to CSV
dvc exp show --csv > experiments_report.csv

# Show only changed parameters and metrics
dvc exp show --only-changed

# Compare best vs worst
dvc exp diff worst-exp-name best-exp-name
```

## ⏱️ Time Management

- **Baseline Training**: 10-15 min ✅ (Running now)
- **20 Experiments**: 3-5 hours total
- **Analysis & Selection**: 30 min
- **Documentation**: 1 hour

**Tip**: Run experiments overnight or during free time!

