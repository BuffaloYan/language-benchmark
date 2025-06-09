#!/bin/bash

# Parse command line arguments
DATA_SIZE="${1:-10000000}"  # Default to 10 million if not specified
DATA_FILE="${2:-test_data.csv}"  # Default filename

echo "[BENCHMARK] Multi-Language Benchmark Suite"
echo "=========================================="
echo "Data Size: ${DATA_SIZE}"
echo "Data File: ${DATA_FILE}"
echo "Container Environment Information:"
echo "- OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "- CPU Cores: $(nproc)"
echo "- Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "- Python: $(python3 --version)"
echo "- Java: $(java -version 2>&1 | head -1)"
echo "- Node.js: $(node --version)"
echo "- Go: $(go version | cut -d' ' -f3-4)"
echo "- Rust: $(rustc --version)"
echo "- Cargo: $(cargo --version)"
echo "- Rust toolchain: $(rustup show active-toolchain 2>/dev/null || echo 'default')"
echo "- GCC: $(gcc --version | head -1 | cut -d' ' -f1-4)"
echo ""

cd /benchmark

# Generate test data if not exists or if size doesn't match
if [ ! -f "${DATA_FILE}" ]; then
    echo "[DATA] Generating test data with ${DATA_SIZE} elements..."
    python3 python/generate_data.py --size "${DATA_SIZE}" --filename "${DATA_FILE}"
    
    # Verify the data file was created successfully
    if [ -f "${DATA_FILE}" ]; then
        FILE_SIZE=$(wc -c < "${DATA_FILE}")
        echo "[DATA] Generated data file: ${DATA_FILE} (${FILE_SIZE} bytes)"
        # Show first few characters to verify content
        echo "[DATA] First 100 characters: $(head -c 100 "${DATA_FILE}")"
    else
        echo "[ERROR] Failed to generate data file: ${DATA_FILE}"
        exit 1
    fi
else
    FILE_SIZE=$(wc -c < "${DATA_FILE}")
    echo "[DATA] Using existing data file: ${DATA_FILE} (${FILE_SIZE} bytes)"
    # Show first few characters to verify content
    echo "[DATA] First 100 characters: $(head -c 100 "${DATA_FILE}")"
fi

echo "[RUST] Rust Compilation Verification:"
echo "====================================="
if [ -f "rust/mergesort_rust" ]; then
    echo "[SUCCESS] Rust binary exists: $(ls -lh rust/mergesort_rust | awk '{print $5, $9}')"
else
    echo "[WARNING] Rust binary not found, attempting compilation..."
    if rustc -O rust/mergesort.rs -o rust/mergesort_rust; then
        echo "[SUCCESS] Rust compilation successful!"
    else
        echo "[ERROR] Rust compilation failed!"
    fi
fi
echo ""

echo "[SEQUENTIAL] Running Sequential Benchmarks..."
echo "============================================="
echo "[INFO] Note: Python excluded from benchmarks (files available for manual testing)"
python3 benchmark.py --size "${DATA_SIZE}" --data-file "${DATA_FILE}"

echo ""
echo "[PARALLEL] Running Parallel Benchmarks..."
echo "=========================================="
python3 parallel_comparison.py --size "${DATA_SIZE}" --data-file "${DATA_FILE}"

echo ""
echo "[RESULTS] Benchmark Results Summary:"
echo "===================================="
if [ -f "results/benchmark_results.json" ]; then
    echo "Sequential results:"
    cat results/benchmark_results.json | python3 -m json.tool | grep -A 5 -B 5 "execution_time"
fi

if [ -f "results/parallel_comparison_results.json" ]; then
    echo ""
    echo "Parallel results:"
    cat results/parallel_comparison_results.json | python3 -m json.tool | grep -A 10 -B 5 "results"
fi

echo ""
echo "[FILES] Result files available in /benchmark/results/"
echo "- benchmark_results.json (sequential)"
echo "- benchmark_report.txt (sequential report)"  
echo "- parallel_comparison_results.json (parallel)"

# Results are now already in results directory
echo "All results saved in /benchmark/results/"

# Upload results to S3 if running in cloud mode
if [ "$BENCHMARK_MODE" = "cloud" ] && [ -n "$S3_RESULTS_BUCKET" ]; then
    echo ""
    echo "[UPLOAD] Uploading results to S3..."
    /benchmark/scripts/upload_results.sh
fi

echo ""
echo "[COMPLETE] Benchmark suite completed!" 