#!/bin/bash

echo "=== Environment Test Script ==="
echo "Testing Docker environment before running benchmarks"
echo ""

cd /benchmark

# Test 1: Check if we can generate a small test file
echo "[TEST 1] Testing data generation..."
python3 python/generate_data.py --size 100 --filename test_small.csv
if [ -f "test_small.csv" ]; then
    FILE_SIZE=$(wc -c < "test_small.csv")
    echo "✓ Data generation successful: test_small.csv (${FILE_SIZE} bytes)"
    echo "Content preview: $(head -c 50 test_small.csv)"
    rm test_small.csv
else
    echo "✗ Data generation failed"
    exit 1
fi

# Test 2: Test Java with small data
echo ""
echo "[TEST 2] Testing Java with small dataset..."
python3 python/generate_data.py --size 10 --filename test_java.csv
if java -cp java MergeSort test_java.csv; then
    echo "✓ Java test successful"
else
    echo "✗ Java test failed"
fi
rm -f test_java.csv

# Test 3: Test Rust with small data
echo ""
echo "[TEST 3] Testing Rust with small dataset..."
python3 python/generate_data.py --size 10 --filename test_rust.csv
if ./rust/mergesort_rust test_rust.csv; then
    echo "✓ Rust test successful"
else
    echo "✗ Rust test failed"
fi
rm -f test_rust.csv

# Test 4: Test data file permissions and content
echo ""
echo "[TEST 4] Testing file system permissions..."
echo "Working directory: $(pwd)"
echo "Directory contents:"
ls -la
echo ""
echo "Python path:"
which python3
echo ""
echo "Available disk space:"
df -h .

echo ""
echo "=== Environment Test Complete ===" 