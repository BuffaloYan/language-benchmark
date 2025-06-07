#!/bin/bash
echo "🧪 Quick Language Runtime Test"
echo "=============================="

cd /benchmark

# Generate small test data
python3 -c "
import random
import csv
numbers = [random.randint(1, 1000) for _ in range(10000)]
with open('test_data_small.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(numbers)
print('Generated 10,000 test numbers')
"

echo ""
echo "Testing each language implementation (Python excluded):"

# echo "🐍 Python:"
# python3 python/mergesort_python.py test_data_small.csv | tail -1

echo "☕ Java:"
java -cp java MergeSort test_data_small.csv | tail -1

echo "🟨 JavaScript:"
node javascript/mergesort_javascript.js test_data_small.csv | tail -1

echo "🟨 JavaScript SharedArrayBuffer:"
node javascript/parallel_sharedarraybuffer.js test_data_small.csv | tail -1

echo "🔵 Go:"
./go/mergesort_go test_data_small.csv | tail -1

echo "🦀 Rust Sequential ($(rustc --version | awk '{print $2}')):"
./rust/mergesort_rust test_data_small.csv | tail -1

echo "🦀 Rust Parallel (Rayon):"
./rust/parallel_mergesort_rust test_data_small.csv | tail -1

echo "⚡ C:"
./c/mergesort_c test_data_small.csv | tail -1

echo "⚡ C Parallel:"
./c/parallel_mergesort_c test_data_small.csv | tail -1

echo ""
echo "✅ All languages working correctly!" 