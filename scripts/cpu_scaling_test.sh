#!/bin/bash

# CPU Scaling Test Script
# Tests the language benchmark with different CPU core configurations

echo "[CPU-SCALING] Language Benchmark CPU Scaling Test"
echo "================================================"

# Create results directories
mkdir -p results/cpu-scaling/{1core,2core,4core,8core}

# Test with 1 CPU core
echo "[TEST] Running with 1 CPU core..."
docker run --cpus="1.0" --memory="2g" --rm \
  -v $(pwd)/results/cpu-scaling/1core:/benchmark/results \
  language-benchmark

# Test with 2 CPU cores
echo "[TEST] Running with 2 CPU cores..."
docker run --cpus="2.0" --memory="4g" --rm \
  -v $(pwd)/results/cpu-scaling/2core:/benchmark/results \
  language-benchmark

# Test with 4 CPU cores
echo "[TEST] Running with 4 CPU cores..."
docker run --cpus="4.0" --memory="8g" --rm \
  -v $(pwd)/results/cpu-scaling/4core:/benchmark/results \
  language-benchmark

# Test with 8 CPU cores
echo "[TEST] Running with 8 CPU cores..."
docker run --cpus="8.0" --memory="8g" --rm \
  -v $(pwd)/results/cpu-scaling/8core:/benchmark/results \
  language-benchmark

echo "[COMPLETE] CPU scaling tests completed!"
echo "[RESULTS] Check results/cpu-scaling/ for detailed results"

# Optional: Generate comparison report
if command -v python3 &> /dev/null; then
    echo "[ANALYSIS] Generating CPU scaling analysis..."
    python3 -c "
import json
import os

cores = ['1core', '2core', '4core', '8core']
print('\\nCPU Scaling Analysis:')
print('=' * 50)

for core in cores:
    try:
        with open(f'results/cpu-scaling/{core}/parallel_comparison_results.json', 'r') as f:
            data = json.load(f)
            results = data['results']
            
        print(f'\\n{core.upper()} Results:')
        for name, result in results.items():
            if result.get('success') and 'Rayon' in name:
                exec_time = result['execution_time']
                print(f'  Rust Rayon: {exec_time:.4f}s')
                break
    except:
        print(f'  {core}: No results found')
"
fi 