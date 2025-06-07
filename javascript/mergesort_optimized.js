#!/usr/bin/env node
const fs = require('fs');

function mergeSort(arr, temp, left, right) {
    if (left < right) {
        const mid = left + Math.floor((right - left) / 2);
        
        mergeSort(arr, temp, left, mid);
        mergeSort(arr, temp, mid + 1, right);
        merge(arr, temp, left, mid, right);
    }
}

function merge(arr, temp, left, mid, right) {
    // Copy array section to temp buffer
    for (let i = left; i <= right; i++) {
        temp[i] = arr[i];
    }
    
    let i = left, j = mid + 1, k = left;
    
    while (i <= mid && j <= right) {
        if (temp[i] <= temp[j]) {
            arr[k] = temp[i];
            i++;
        } else {
            arr[k] = temp[j];
            j++;
        }
        k++;
    }
    
    // Add remaining elements from left side
    while (i <= mid) {
        arr[k] = temp[i];
        i++;
        k++;
    }
    
    // Add remaining elements from right side
    while (j <= right) {
        arr[k] = temp[j];
        j++;
        k++;
    }
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
    
    // Create copy for sorting and temp buffer
    const sortNumbers = [...numbers];
    const temp = new Array(numbers.length);
    
    // Time the sorting
    console.log("Starting merge sort...");
    const startTime = Date.now();
    mergeSort(sortNumbers, temp, 0, sortNumbers.length - 1);
    const sortEndTime = Date.now();
    
    const sortTime = (sortEndTime - startTime) / 1000;
    console.log(`JavaScript optimized merge sort completed in ${sortTime.toFixed(4)} seconds`);
    
    // Verify sorting is correct
    const isSorted = sortNumbers.every((val, i) => i === 0 || sortNumbers[i-1] <= val);
    console.log(`Sorting verified: ${isSorted}`);
    
    // Count prime numbers
    console.log("Counting prime numbers...");
    const primeStartTime = Date.now();
    const primeCount = countPrimes(sortNumbers);
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