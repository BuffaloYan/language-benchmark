#!/usr/bin/env node
const fs = require('fs');

function mergeSort(arr) {
    if (arr.length <= 1) {
        return arr;
    }
    
    const mid = Math.floor(arr.length / 2);
    const left = mergeSort(arr.slice(0, mid));
    const right = mergeSort(arr.slice(mid));
    
    return merge(left, right);
}

function merge(left, right) {
    const result = [];
    let i = 0, j = 0;
    
    while (i < left.length && j < right.length) {
        if (left[i] <= right[j]) {
            result.push(left[i]);
            i++;
        } else {
            result.push(right[j]);
            j++;
        }
    }
    
    // Add remaining elements
    while (i < left.length) {
        result.push(left[i]);
        i++;
    }
    while (j < right.length) {
        result.push(right[j]);
        j++;
    }
    
    return result;
}

function loadData(filename = "test_data.csv") {
    const data = fs.readFileSync(filename, 'utf8');
    return data.trim().split(',').map(num => parseInt(num));
}

function isPrime(n) {
    if (n < 2) return false;
    if (n === 2) return true;
    if (n % 2 === 0) return false;
    
    // Check odd divisors up to sqrt(n)
    for (let i = 3; i * i <= n; i += 2) {
        if (n % i === 0) return false;
    }
    return true;
}

function countPrimes(numbers) {
    let count = 0;
    for (const num of numbers) {
        if (isPrime(num)) {
            count++;
        }
    }
    return count;
}

function main() {
    const filename = process.argv[2] || "test_data.csv";
    
    // Load data
    console.log("Loading data...");
    const numbers = loadData(filename);
    console.log(`Loaded ${numbers.length.toLocaleString()} numbers`);
    
    // Time the sorting
    console.log("Starting merge sort...");
    const startTime = Date.now();
    const sortedNumbers = mergeSort([...numbers]);
    const sortEndTime = Date.now();
    
    const sortTime = (sortEndTime - startTime) / 1000;
    console.log(`JavaScript merge sort completed in ${sortTime.toFixed(4)} seconds`);
    
    // Verify sorting is correct
    const isSorted = sortedNumbers.every((val, i) => i === 0 || sortedNumbers[i-1] <= val);
    console.log(`Sorting verified: ${isSorted}`);
    
    // Count prime numbers
    console.log("Counting prime numbers...");
    const primeStartTime = Date.now();
    const primeCount = countPrimes(sortedNumbers);
    const primeEndTime = Date.now();
    
    const primeTime = (primeEndTime - primeStartTime) / 1000;
    const totalTime = sortTime + primeTime;
    
    console.log(`Prime counting completed in ${primeTime.toFixed(4)} seconds`);
    console.log(`Found ${primeCount.toLocaleString()} prime numbers`);
    console.log(`Total execution time: ${totalTime.toFixed(4)} seconds`);
    
    return totalTime;
}

if (require.main === module) {
    main();
} 