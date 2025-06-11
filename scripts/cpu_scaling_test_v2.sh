#!/bin/bash

# Enhanced CPU Scaling Test Script v3 
# Fixed version using correct Docker syntax and data file mounting

echo "[CPU-SCALING-V3] Enhanced Language Benchmark CPU Scaling Test"
echo "============================================================="

# Test configuration
DOCKER_IMAGE="language-benchmark"
TIMEOUT=600

# Create results directories
mkdir -p results/cpu-scaling-v3/{0.5cpu,1cpu,2cpu,4cpu,6cpu,8cpu}

# Build Docker image if it doesn't exist
if ! docker image inspect $DOCKER_IMAGE >/dev/null 2>&1; then
    echo "[BUILD] Building Docker image..."
    docker build -f cloud/Dockerfile -t $DOCKER_IMAGE .
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to build Docker image"
        exit 1
    fi
fi

# Function to run CPU scaling test for a specific configuration
run_cpu_test() {
    local cpu_config="$1"
    local cpuset_cpus="$2"
    local cpu_limit="$3"
    local description="$4"
    
    echo ""
    echo "[TEST] Running with $description..."
    echo "       CPU set: $cpuset_cpus"
    echo "       CPU limit: $cpu_limit"
    
    # Create specific results directory for this test
    local results_dir="results/cpu-scaling-v3/$cpu_config"
    
    # Run the benchmark with specific CPU configuration and mount both results and data
    docker run \
        --cpuset-cpus="$cpuset_cpus" \
        --cpus="$cpu_limit" \
        --memory="4g" \
        --rm \
        -v $(pwd)/results:/benchmark/results \
        -v $(pwd)/test_data.csv:/benchmark/test_data.csv:ro \
        $DOCKER_IMAGE \
        sh -c "cd /benchmark && python3 parallel_comparison.py --size 10000000 --data-file test_data.csv && cp results/parallel_comparison_results.json results/cpu-scaling-v3/$cpu_config/"
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "[SUCCESS] $description test completed"
    else
        echo "[ERROR] $description test failed with exit code $exit_code"
    fi
    
    return $exit_code
}

# Test configurations with proper core limiting
echo "[INFO] Available CPU cores on host: $(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 'unknown')"
echo "[INFO] Running tests with progressively more cores..."

# Test 1: 0.5 CPU (half a core)
run_cpu_test "0.5cpu" "0" "0.5" "0.5 CPU core"

# Test 2: 1 CPU  
run_cpu_test "1cpu" "0" "1" "1 CPU core"

# Test 3: 2 CPUs
run_cpu_test "2cpu" "0-1" "2" "2 CPU cores"

# Test 4: 4 CPUs
run_cpu_test "4cpu" "0-3" "4" "4 CPU cores"

# Test 5: 6 CPUs
run_cpu_test "6cpu" "0-5" "6" "6 CPU cores"

# Test 6: 8 CPUs
run_cpu_test "8cpu" "0-7" "8" "8 CPU cores"

echo ""
echo "[COMPLETE] CPU scaling tests completed!"
echo "[RESULTS] Check results/cpu-scaling-v3/ for detailed results"

# Generate analysis report
echo ""
echo "[ANALYSIS] Generating CPU scaling analysis..."

python3 << 'EOF'
import json
import os
from datetime import datetime

print('\n' + '='*80)
print('CPU SCALING ANALYSIS REPORT - v3')
print('='*80)

configs = ['0.5cpu', '1cpu', '2cpu', '4cpu', '6cpu', '8cpu']
implementations = [
    'Java Fork-Join', 'C pthreads', 'Rust Rayon', 
    'JavaScript SharedArrayBuffer', 'JavaScript Workers', 'Go Parallel'
]

# Load results from all configurations
all_results = {}
for config in configs:
    try:
        with open(f'results/cpu-scaling-v3/{config}/parallel_comparison_results.json', 'r') as f:
            data = json.load(f)
            all_results[config] = data['results']
        print(f'✓ Loaded results for {config}')
    except Exception as e:
        print(f'✗ Could not load results for {config}: {e}')
        all_results[config] = {}

# Performance comparison table
print(f'\n📊 EXECUTION TIME COMPARISON (seconds)')
print('-' * 100)
header = f'{"CPU Config":<12}'
for impl in implementations[:5]:  # First 5 implementations
    header += f'{impl:<16}'
print(header)
print('-' * 100)

for config in configs:
    results = all_results.get(config, {})
    row = f'{config:<12}'
    
    for impl in implementations[:5]:
        if impl in results and results[impl].get('success'):
            exec_time = results[impl]['execution_time']
            row += f'{exec_time:>12.4f}    '
        else:
            row += f'{"FAILED":>12}    '
    
    print(row)

# Find best performers
print(f'\n🏆 BEST PERFORMANCE BY IMPLEMENTATION')
print('-' * 70)

for impl in implementations:
    best_time = float('inf')
    best_config = 'None'
    baseline_time = 0
    
    # Find baseline (0.5cpu) and best performance
    for config in configs:
        results = all_results.get(config, {})
        if impl in results and results[impl].get('success'):
            exec_time = results[impl]['execution_time']
            
            if config == '0.5cpu':
                baseline_time = exec_time
            
            if exec_time < best_time:
                best_time = exec_time
                best_config = config
    
    if best_time < float('inf'):
        improvement = baseline_time / best_time if baseline_time > 0 else 1
        print(f'{impl:<30}: {best_time:>8.4f}s @ {best_config:<8} ({improvement:>5.1f}x improvement)')

# Save detailed analysis
analysis_data = {
    'timestamp': datetime.now().isoformat(),
    'test_type': 'cpu_scaling_v3_fixed',
    'configurations': configs,
    'implementations': implementations,
    'results': all_results,
    'host_cpu_cores': os.popen('sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 0').read().strip()
}

os.makedirs('results/cpu-scaling-v3', exist_ok=True)
with open('results/cpu-scaling-v3/scaling_analysis.json', 'w') as f:
    json.dump(analysis_data, f, indent=2)

print(f'\n[SAVED] Analysis saved to: results/cpu-scaling-v3/scaling_analysis.json')
EOF

echo ""
echo "[COMPLETE] Enhanced CPU scaling analysis complete!"
echo "[INFO] Used correct Docker syntax with --cpuset-cpus and --cpus"
echo "[INFO] Mounted test_data.csv properly into container" 