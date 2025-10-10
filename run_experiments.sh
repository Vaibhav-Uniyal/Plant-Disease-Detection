#!/bin/bash
# Script to run 20 DVC experiments with different hyperparameters

echo "=========================================="
echo "Running 20 DVC Experiments"
echo "=========================================="

# Activate virtual environment
source venv/bin/activate

# Experiment 1-5: Varying Epochs
echo "Experiments 1-5: Varying Epochs"
dvc exp run -n "exp-01-epochs-10" --set-param training.epochs=10
dvc exp run -n "exp-02-epochs-20" --set-param training.epochs=20
dvc exp run -n "exp-03-epochs-40" --set-param training.epochs=40
dvc exp run -n "exp-04-epochs-50" --set-param training.epochs=50
dvc exp run -n "exp-05-epochs-100" --set-param training.epochs=100

# Experiment 6-10: Varying Batch Size
echo "Experiments 6-10: Varying Batch Size"
dvc exp run -n "exp-06-batch-16" --set-param training.batch_size=16
dvc exp run -n "exp-07-batch-64" --set-param training.batch_size=64
dvc exp run -n "exp-08-batch-128" --set-param training.batch_size=128
dvc exp run -n "exp-09-batch-8" --set-param training.batch_size=8
dvc exp run -n "exp-10-batch-256" --set-param training.batch_size=256

# Experiment 11-15: Varying Learning Rate
echo "Experiments 11-15: Varying Learning Rate"
dvc exp run -n "exp-11-lr-0.0001" --set-param training.learning_rate=0.0001
dvc exp run -n "exp-12-lr-0.01" --set-param training.learning_rate=0.01
dvc exp run -n "exp-13-lr-0.0005" --set-param training.learning_rate=0.0005
dvc exp run -n "exp-14-lr-0.005" --set-param training.learning_rate=0.005
dvc exp run -n "exp-15-lr-0.1" --set-param training.learning_rate=0.1

# Experiment 16-20: Varying Dropout Rate
echo "Experiments 16-20: Varying Dropout Rate"
dvc exp run -n "exp-16-dropout-0.2" --set-param model.dropout_rate=0.2
dvc exp run -n "exp-17-dropout-0.3" --set-param model.dropout_rate=0.3
dvc exp run -n "exp-18-dropout-0.4" --set-param model.dropout_rate=0.4
dvc exp run -n "exp-19-dropout-0.6" --set-param model.dropout_rate=0.6
dvc exp run -n "exp-20-dropout-0.7" --set-param model.dropout_rate=0.7

echo "=========================================="
echo "All 20 experiments completed!"
echo "=========================================="

# Show experiment results
echo "Experiment Results:"
dvc exp show --no-pager

# Save experiments table to file
dvc exp show --no-pager > experiments_results.txt
echo "Results saved to experiments_results.txt"

