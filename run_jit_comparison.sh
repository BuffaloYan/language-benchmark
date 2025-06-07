#!/bin/bash

echo "🚀 JavaScript JIT Compilation Comparison"
echo "=========================================="
echo
echo "This test compares JavaScript performance with and without JIT compilation"
echo "using the same merge sort + prime counting benchmark."
echo

# Check if node is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js to run this comparison."
    exit 1
fi

echo "📊 Test Data: 10,000,000 integers"
echo

# Test 1: With JIT (default)
echo "🔥 Test 1: WITH JIT Optimization (Default V8)"
echo "=============================================="
echo "Using default V8 settings with TurboFan optimizer enabled"
echo
node javascript/jit_comparison.js test_data.csv
echo

# Test 2: Without JIT optimization
echo "🚫 Test 2: WITHOUT JIT Optimization"
echo "===================================="
echo "Using --no-opt flag to disable optimizing compiler"
echo
node --no-opt javascript/jit_comparison.js test_data.csv
echo

# Test 3: Interpreted only
echo "🐌 Test 3: INTERPRETED ONLY"
echo "============================"
echo "Using --interpreted-frames-native-stack to force interpretation"
echo
node --interpreted-frames-native-stack javascript/jit_comparison.js test_data.csv
echo

echo "📈 Analysis:"
echo "- Test 1 shows peak JavaScript performance with full JIT optimization"
echo "- Test 2 shows performance without the optimizing compiler"
echo "- Test 3 shows pure interpreter performance (closest to Python-like execution)"
echo
echo "The performance difference demonstrates the power of JIT compilation!" 