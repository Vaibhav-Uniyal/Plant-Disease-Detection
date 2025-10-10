#!/bin/bash
# Script to run 20 DVC experiments - EPOCHS ONLY (1-20)
# Fast approach for demonstrating DVC experiment tracking

echo "=========================================="
echo "Running 20 DVC Experiments (Epochs 1-20)"
echo "=========================================="

# Activate virtual environment
source venv/bin/activate

# Experiments 1-20: Varying Epochs from 1 to 20
echo "Running epoch experiments 1-20..."

for epoch in {1..20}; do
    exp_name=$(printf "exp-%02d-epochs-%d" $epoch $epoch)
    echo "Running $exp_name..."
    dvc exp run -n "$exp_name" --set-param training.epochs=$epoch
done

echo "=========================================="
echo "All 20 experiments completed!"
echo "=========================================="

# Show experiment results
echo "Experiment Results:"
dvc exp show --no-pager

# Save experiments table to file
dvc exp show --no-pager > experiments_results.txt
echo "Results saved to experiments_results.txt"

echo ""
echo "To analyze results:"
echo "  dvc exp show"
echo "  dvc exp show --csv > experiments.csv"
echo "  dvc exp diff exp-01-epochs-1 exp-20-epochs-20"

