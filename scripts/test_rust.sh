#!/bin/bash

echo "🦀 Comprehensive Rust Testing"
echo "============================="

cd /benchmark

echo "📋 Rust Environment Information:"
echo "- Rust compiler: $(rustc --version)"
echo "- Cargo package manager: $(cargo --version)"
echo "- Rustup toolchain manager: $(rustup --version)"
echo "- Active toolchain: $(rustup show active-toolchain)"
echo ""

echo "🔧 Available Rust components:"
rustup component list --installed
echo ""

echo "📊 Rust compilation test:"
echo "========================"
echo "Compiling Rust merge sort implementation..."

# Test compilation with verbose output
if rustc -O rust/mergesort.rs -o rust/mergesort_rust --verbose; then
    echo "✅ Rust compilation successful!"
    
    echo ""
    echo "📝 Binary information:"
    ls -lh rust/mergesort_rust
    echo "Binary type: $(ls -la rust/mergesort_rust | awk '{print $1}')"
    
    echo ""
    echo "🧪 Running Rust test with small dataset..."
    
    # Generate small test data
    python3 -c "
import random
import csv
numbers = [random.randint(1, 1000) for _ in range(1000)]
with open('rust_test_data.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(numbers)
print('Generated 1,000 test numbers for Rust verification')
"
    
    # Run the Rust sequential binary
    echo "Running Rust sequential benchmark:"
    ./rust/mergesort_rust rust_test_data.csv
    
    echo ""
    echo "🧪 Testing Rust parallel implementation..."
    if [ -f "rust/parallel_mergesort_rust" ]; then
        echo "Running Rust parallel benchmark:"
        ./rust/parallel_mergesort_rust rust_test_data.csv
    else
        echo "⚠️  Rust parallel binary not found (may need cargo build)"
    fi
    
    # Clean up test data
    rm -f rust_test_data.csv
    
    echo ""
    echo "✅ Rust test completed successfully!"
else
    echo "❌ Rust compilation failed!"
    exit 1
fi 