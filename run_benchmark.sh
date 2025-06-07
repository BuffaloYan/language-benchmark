#!/bin/bash

echo "==================================================="
echo "Language Runtime Benchmark - Merge Sort"
echo "==================================================="
echo

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not found"
    exit 1
fi

# Run the benchmark
python3 benchmark.py

echo
echo "Benchmark completed!"
echo "Check the following files for results:"
echo "  - benchmark_report.txt (formatted report)"
echo "  - benchmark_results.json (raw data)"
echo 