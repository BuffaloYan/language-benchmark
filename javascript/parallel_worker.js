// Worker thread module for parallel processing
const { parentPort } = require('worker_threads');

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

// Handle messages from main thread
parentPort.on('message', ({ type, data, taskId }) => {
    try {
        let result;
        const startTime = Date.now();
        
        switch (type) {
            case 'SORT':
                result = mergeSort(data);
                break;
                
            case 'COUNT_PRIMES':
                result = countPrimes(data);
                break;
                
            case 'MERGE':
                // For merging two sorted arrays
                result = merge(data.left, data.right);
                break;
                
            default:
                throw new Error(`Unknown task type: ${type}`);
        }
        
        const endTime = Date.now();
        
        parentPort.postMessage({
            taskId,
            result,
            executionTime: endTime - startTime,
            success: true
        });
    } catch (error) {
        parentPort.postMessage({
            taskId,
            error: error.message,
            success: false
        });
    }
}); 