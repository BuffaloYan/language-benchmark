// Optimized Worker thread module for parallel processing
const { parentPort } = require('worker_threads');

function mergeSort(arr) {
    // Optimized recursive merge sort
    if (arr.length <= 1) {
        return arr;
    }
    
    const mid = Math.floor(arr.length / 2);
    const left = mergeSort(arr.slice(0, mid));
    const right = mergeSort(arr.slice(mid));
    
    return merge(left, right);
}

function merge(left, right) {
    // Optimized merge with pre-allocated array
    const result = new Array(left.length + right.length);
    let i = 0, j = 0, k = 0;
    
    while (i < left.length && j < right.length) {
        if (left[i] <= right[j]) {
            result[k++] = left[i++];
        } else {
            result[k++] = right[j++];
        }
    }
    
    // Copy remaining elements
    while (i < left.length) result[k++] = left[i++];
    while (j < right.length) result[k++] = right[j++];
    
    return result;
}

function isPrime(n) {
    if (n < 2) return false;
    if (n === 2) return true;
    if (n % 2 === 0) return false;
    
    // Optimized prime checking
    const sqrt = Math.sqrt(n);
    for (let i = 3; i <= sqrt; i += 2) {
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

// Handle messages from main thread
parentPort.on('message', ({ type, data, chunkIndex }) => {
    try {
        let result;
        const startTime = Date.now();
        
        switch (type) {
            case 'SORT_CHUNK':
                // Sort entire chunk using optimized merge sort
                result = mergeSort(data);
                break;
                
            case 'COUNT_PRIMES':
                // Count primes in the chunk
                result = countPrimes(data);
                break;
                
            default:
                throw new Error(`Unknown task type: ${type}`);
        }
        
        const endTime = Date.now();
        
        parentPort.postMessage({
            result,
            executionTime: endTime - startTime,
            success: true,
            chunkIndex
        });
    } catch (error) {
        parentPort.postMessage({
            error: error.message,
            success: false,
            chunkIndex
        });
    }
}); 