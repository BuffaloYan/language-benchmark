#!/bin/bash

echo "🚀 Multi-Language Benchmark Suite"
echo "=================================="
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

# Generate test data if not exists
if [ ! -f "test_data.csv" ]; then
    echo "📊 Generating test data..."
    python3 python/generate_data.py
fi

echo "🦀 Rust Compilation Verification:"
echo "================================="
if [ -f "rust/mergesort_rust" ]; then
    echo "✅ Rust binary exists: $(ls -lh rust/mergesort_rust | awk '{print $5, $9}')"
else
    echo "⚠️  Rust binary not found, attempting compilation..."
    if rustc -O rust/mergesort.rs -o rust/mergesort_rust; then
        echo "✅ Rust compilation successful!"
    else
        echo "❌ Rust compilation failed!"
    fi
fi
echo ""

echo "🔄 Running Sequential Benchmarks..."
echo "==================================="
echo "ℹ️  Note: Python excluded from benchmarks (files available for manual testing)"
python3 benchmark.py

echo ""
echo "⚡ Running Parallel Benchmarks..."
echo "================================="
python3 parallel_comparison.py

echo ""
echo "🎯 Benchmark Results Summary:"
echo "=============================="
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
echo "📁 Result files available in /benchmark/results/"
echo "- benchmark_results.json (sequential)"
echo "- benchmark_report.txt (sequential report)"  
echo "- parallel_comparison_results.json (parallel)"

# Results are now already in results directory
echo "All results saved in /benchmark/results/"

echo ""
echo "✅ Benchmark suite completed!" 