// Worker thread module for parallel processing
const { parentPort } = require('worker_threads');

function mergeSort(arr, start = 0, end = arr.length - 1) {
    if (start >= end) {
        return;
    }
    
    const mid = Math.floor((start + end) / 2);
    mergeSort(arr, start, mid);
    mergeSort(arr, mid + 1, end);
    mergeInPlace(arr, start, mid, end);
}

function mergeInPlace(arr, start, mid, end) {
    // Create temporary arrays for the two halves
    const leftSize = mid - start + 1;
    const rightSize = end - mid;
    
    const leftArr = new Array(leftSize);
    const rightArr = new Array(rightSize);
    
    // Copy data to temporary arrays
    for (let i = 0; i < leftSize; i++) {
        leftArr[i] = arr[start + i];
    }
    for (let j = 0; j < rightSize; j++) {
        rightArr[j] = arr[mid + 1 + j];
    }
    
    // Merge the temporary arrays back into arr[start..end]
    let i = 0, j = 0, k = start;
    
    while (i < leftSize && j < rightSize) {
        if (leftArr[i] <= rightArr[j]) {
            arr[k] = leftArr[i];
            i++;
        } else {
            arr[k] = rightArr[j];
            j++;
        }
        k++;
    }
    
    // Copy remaining elements
    while (i < leftSize) {
        arr[k] = leftArr[i];
        i++;
        k++;
    }
    while (j < rightSize) {
        arr[k] = rightArr[j];
        j++;
        k++;
    }
}

function merge(left, right) {
    // Keep this function for backward compatibility with MERGE task type
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
                // Create a copy of the data for in-place sorting
                const dataCopy = [...data];
                mergeSort(dataCopy);
                result = dataCopy;
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