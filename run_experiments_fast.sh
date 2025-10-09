#!/bin/bash
# Script to run 20 DVC experiments - FAST VERSION
# Focuses on lower epochs with some variety to show understanding

echo "=========================================="
echo "Running 20 DVC Experiments (Fast Version)"
echo "=========================================="

# Activate virtual environment
source venv/bin/activate

# Group 1: Low Epochs (1-10) - Very fast experiments
echo "Experiments 1-10: Low epochs (1-10) - Fast exploration"
for epoch in {1..10}; do
    exp_name=$(printf "exp-%02d-epochs-%d" $epoch $epoch)
    echo "Running $exp_name..."
    dvc exp run -n "$exp_name" --set-param training.epochs=$epoch
done

# Group 2: Medium Epochs (5 experiments) - Better convergence
echo "Experiments 11-15: Medium epochs - Better models"
for epoch in 12 15 18 20 25; do
    num=$((10 + (epoch / 3)))
    exp_name=$(printf "exp-%02d-epochs-%d" $num $epoch)
    echo "Running $exp_name..."
    dvc exp run -n "$exp_name" --set-param training.epochs=$epoch
done

# Group 3: Different hyperparameters (5 experiments) - Show variety
echo "Experiments 16-20: Different hyperparameters - Show understanding"

echo "Running exp-16-batch-16..."
dvc exp run -n "exp-16-batch-16" --set-param training.batch_size=16

echo "Running exp-17-batch-64..."
dvc exp run -n "exp-17-batch-64" --set-param training.batch_size=64

echo "Running exp-18-lr-0.0001..."
dvc exp run -n "exp-18-lr-0.0001" --set-param training.learning_rate=0.0001

echo "Running exp-19-lr-0.01..."
dvc exp run -n "exp-19-lr-0.01" --set-param training.learning_rate=0.01

echo "Running exp-20-dropout-0.3..."
dvc exp run -n "exp-20-dropout-0.3" --set-param model.dropout_rate=0.3

echo "=========================================="
echo "All 20 experiments completed!"
echo "=========================================="

# Show experiment results
echo "Experiment Results:"
dvc exp show --no-pager | head -30

# Save experiments table to file
dvc exp show --no-pager > experiments_results.txt
dvc exp show --csv > experiments_results.csv
echo "Results saved to experiments_results.txt and experiments_results.csv"

echo ""
echo "Key insights to analyze:"
echo "  - How accuracy improves with more epochs (exp 1-15)"
echo "  - Impact of batch size on training (exp 16-17)"  
echo "  - Impact of learning rate on convergence (exp 18-19)"
echo "  - Impact of dropout on overfitting (exp 20)"

