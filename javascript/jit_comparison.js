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

function isPrime(n) {
    if (n < 2) return false;
    if (n === 2) return true;
    if (n % 2 === 0) return false;
    
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

function loadData(filename = "test_data.csv") {
    const data = fs.readFileSync(filename, 'utf8');
    return data.trim().split(',').map(num => parseInt(num));
}

function warmUpJIT(numbers) {
    console.log("[JIT] JIT Warm-up phase...");
    
    // Warm up with smaller dataset to trigger JIT compilation
    const warmupSize = Math.min(100000, numbers.length);
    const warmupData = numbers.slice(0, warmupSize);
    
    // Run multiple iterations to ensure JIT kicks in
    for (let i = 0; i < 3; i++) {
        const sorted = mergeSort([...warmupData]);
        const primeCount = countPrimes(sorted.slice(0, 10000));
        if (i === 0) console.log(`   Warmup iteration ${i + 1}: ${primeCount} primes in sample`);
    }
    
    console.log("   JIT optimization should now be active");
}

function getV8Flags() {
    const flags = process.execArgv;
    if (flags.length === 0) {
        return "Default JIT enabled";
    }
    return `V8 flags: ${flags.join(' ')}`;
}

function main() {
    const filename = process.argv[2] || "test_data.csv";
    
    console.log("JavaScript JIT Comparison Test");
    console.log("=" * 40);
    console.log(`V8 Configuration: ${getV8Flags()}`);
    console.log();
    
    // Load data
    console.log("Loading data...");
    const numbers = loadData(filename);
    console.log(`Loaded ${numbers.length.toLocaleString()} numbers`);
    
    // Warm up JIT if not disabled
    if (!process.execArgv.some(flag => flag.includes('no-opt') || flag.includes('interpreted'))) {
        warmUpJIT(numbers);
        console.log();
    } else {
        console.log("🚫 JIT optimization disabled");
        console.log();
    }
    
    // Main benchmark
    console.log("Starting main benchmark...");
    console.log("[SORT] Sorting phase...");
    const sortStartTime = Date.now();
    const sortedNumbers = mergeSort([...numbers]);
    const sortEndTime = Date.now();
    
    const sortTime = (sortEndTime - sortStartTime) / 1000;
    console.log(`Sort completed in ${sortTime.toFixed(4)} seconds`);
    
    // Verify sorting
    const isSorted = sortedNumbers.every((val, i) => i === 0 || sortedNumbers[i-1] <= val);
    console.log(`Sorting verified: ${isSorted}`);
    
    console.log("🔢 Prime counting phase...");
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