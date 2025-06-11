#!/usr/bin/env node

const fs = require('fs');
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');
const os = require('os');

// Optimized SharedArrayBuffer Worker Pool
class SharedArrayBufferWorkerPool {
    constructor(workerFile, poolSize = os.cpus().length) {
        this.workers = [];
        this.workerFile = workerFile;
        this.poolSize = poolSize;
        this.taskQueue = [];
        this.availableWorkers = [];
        
        console.log(`🔧 Creating optimized SharedArrayBuffer worker pool with ${poolSize} workers`);
    }
    
    async createWorkers(sharedBuffer, tempBuffer) {
        // Create workers once at startup
        for (let i = 0; i < this.poolSize; i++) {
            const worker = new Worker(this.workerFile, {
                workerData: {
                    workerId: i,
                    sharedBuffer: sharedBuffer,
                    tempBuffer: tempBuffer
                }
            });
            
            this.workers.push(worker);
            this.availableWorkers.push(worker);
        }
    }
    
    async executeParallel(tasks) {
        // Execute tasks in parallel using worker pool
        const promises = tasks.map((task, index) => {
            return new Promise((resolve, reject) => {
                const worker = this.workers[index % this.workers.length];
                
                const messageHandler = ({ result, error, success, executionTime }) => {
                    worker.off('message', messageHandler);
                    worker.off('error', errorHandler);
                    
                    if (success) {
                        resolve({ result, executionTime });
                    } else {
                        reject(new Error(error));
                    }
                };
                
                const errorHandler = (error) => {
                    worker.off('message', messageHandler);
                    worker.off('error', errorHandler);
                    reject(error);
                };
                
                worker.on('message', messageHandler);
                worker.on('error', errorHandler);
                worker.postMessage(task);
            });
        });
        
        return Promise.all(promises);
    }
    
    async terminate() {
        await Promise.all(this.workers.map(worker => worker.terminate()));
    }
}

// Optimized SharedArrayBuffer-based parallel merge sort implementation
class OptimizedSharedArrayBufferMergeSort {
    constructor(data) {
        this.data = data;
        this.length = data.length;
        this.numWorkers = Math.min(os.cpus().length, 8); // Cap at 8 workers
        this.sequentialThreshold = Math.ceil(data.length / this.numWorkers); // One chunk per worker
        
        // Create SharedArrayBuffer for the data
        this.sharedBuffer = new SharedArrayBuffer(this.length * 4); // 4 bytes per int32
        this.sharedArray = new Int32Array(this.sharedBuffer);
        
        // Create SharedArrayBuffer for temporary array (needed for merge)
        this.tempBuffer = new SharedArrayBuffer(this.length * 4);
        this.tempArray = new Int32Array(this.tempBuffer);
        
        // Copy data to shared buffer
        for (let i = 0; i < this.length; i++) {
            this.sharedArray[i] = data[i];
        }
        
        // Create worker pool
        this.workerPool = new SharedArrayBufferWorkerPool(__filename, this.numWorkers);
        
        console.log(`🔧 Optimized SharedArrayBuffer Setup:`);
        console.log(`   - Data size: ${this.length.toLocaleString()} integers`);
        console.log(`   - Workers: ${this.numWorkers}`);
        console.log(`   - Chunk size: ${this.sequentialThreshold.toLocaleString()}`);
        console.log(`   - Shared memory: ${(this.sharedBuffer.byteLength / 1024 / 1024).toFixed(1)} MB`);
    }
    
    async parallelSort() {
        const startTime = process.hrtime.bigint();
        
        // Create worker pool
        await this.workerPool.createWorkers(this.sharedBuffer, this.tempBuffer);
        
        // Use task-based approach instead of recursive divide-and-conquer
        const chunkSize = Math.ceil(this.length / this.numWorkers);
        const sortTasks = [];
        
        // Create sorting tasks for each worker
        for (let i = 0; i < this.numWorkers; i++) {
            const start = i * chunkSize;
            const end = Math.min(start + chunkSize, this.length);
            
            if (start >= this.length) break;
            
            sortTasks.push({
                type: 'SORT_CHUNK',
                start: start,
                end: end - 1, // Make it inclusive
                workerId: i
            });
        }
        
        console.log(`[CHUNKS] Divided ${this.length.toLocaleString()} elements into ${sortTasks.length} chunks`);
        console.log(`[CHUNKS] Average chunk size: ${Math.floor(this.length / sortTasks.length).toLocaleString()} elements`);
        
        // Sort chunks in parallel
        const sortResults = await this.workerPool.executeParallel(sortTasks);
        console.log(`[PARALLEL] Chunk sorting completed`);
        
        // Merge sorted chunks sequentially in shared memory
        const mergeStartTime = process.hrtime.bigint();
        await this.mergeChunks(sortTasks);
        const mergeEndTime = process.hrtime.bigint();
        const mergeTime = Number(mergeEndTime - mergeStartTime) / 1_000_000_000;
        
        console.log(`[MERGE] Final merge completed in ${mergeTime.toFixed(4)} seconds`);
        
        const endTime = process.hrtime.bigint();
        const sortTime = Number(endTime - startTime) / 1_000_000_000;
        
        return sortTime;
    }
    
    async mergeChunks(chunks) {
        // Iteratively merge sorted chunks
        let activeChunks = chunks.map((chunk, index) => ({
            start: chunk.start,
            end: chunk.end,
            index: index
        }));
        
        while (activeChunks.length > 1) {
            const newChunks = [];
            
            // Merge pairs of chunks
            for (let i = 0; i < activeChunks.length; i += 2) {
                if (i + 1 < activeChunks.length) {
                    // Merge chunk i with chunk i+1
                    const leftChunk = activeChunks[i];
                    const rightChunk = activeChunks[i + 1];
                    
                    this.merge(leftChunk.start, leftChunk.end, rightChunk.end);
                    
                    newChunks.push({
                        start: leftChunk.start,
                        end: rightChunk.end,
                        index: leftChunk.index
                    });
                } else {
                    // Odd chunk, keep as is
                    newChunks.push(activeChunks[i]);
                }
            }
            
            activeChunks = newChunks;
        }
    }
    
    merge(left, mid, right) {
        // Copy to temp array
        for (let i = left; i <= right; i++) {
            this.tempArray[i] = this.sharedArray[i];
        }
        
        let i = left, j = mid + 1, k = left;
        
        // Merge back to shared array
        while (i <= mid && j <= right) {
            if (this.tempArray[i] <= this.tempArray[j]) {
                this.sharedArray[k++] = this.tempArray[i++];
            } else {
                this.sharedArray[k++] = this.tempArray[j++];
            }
        }
        
        // Copy remaining elements
        while (i <= mid) {
            this.sharedArray[k++] = this.tempArray[i++];
        }
        while (j <= right) {
            this.sharedArray[k++] = this.tempArray[j++];
        }
    }
    
    async parallelPrimeCount() {
        const startTime = process.hrtime.bigint();
        
        const chunkSize = Math.ceil(this.length / this.numWorkers);
        const primeTasks = [];
        
        // Create prime counting tasks
        for (let i = 0; i < this.numWorkers; i++) {
            const start = i * chunkSize;
            const end = Math.min(start + chunkSize, this.length);
            
            if (start >= this.length) break;
            
            primeTasks.push({
                type: 'COUNT_PRIMES',
                start: start,
                end: end,
                workerId: i
            });
        }
        
        console.log(`[PRIME CHUNKS] Divided into ${primeTasks.length} chunks for prime counting`);
        console.log(`[PRIME CHUNKS] Average chunk size: ${Math.floor(this.length / primeTasks.length).toLocaleString()} elements`);
        
        // Execute prime counting in parallel using existing worker pool
        const results = await this.workerPool.executeParallel(primeTasks);
        
        const totalPrimes = results.reduce((sum, { result }) => sum + result, 0);
        
        const endTime = process.hrtime.bigint();
        const primeTime = Number(endTime - startTime) / 1_000_000_000;
        
        return { primeCount: totalPrimes, primeTime };
    }
    
    isSorted() {
        for (let i = 1; i < this.length; i++) {
            if (this.sharedArray[i - 1] > this.sharedArray[i]) {
                return false;
            }
        }
        return true;
    }
    
    getResult() {
        return Array.from(this.sharedArray);
    }
    
    async cleanup() {
        await this.workerPool.terminate();
    }
}

// Worker thread code
if (!isMainThread) {
    const { workerId, sharedBuffer, tempBuffer } = workerData;
    const sharedArray = new Int32Array(sharedBuffer);
    const tempArray = new Int32Array(tempBuffer);
    
    function sequentialMergeSort(left, right) {
        if (left < right) {
            const mid = Math.floor((left + right) / 2);
            sequentialMergeSort(left, mid);
            sequentialMergeSort(mid + 1, right);
            merge(left, mid, right);
        }
    }
    
    function merge(left, mid, right) {
        // Copy to temp array
        for (let i = left; i <= right; i++) {
            tempArray[i] = sharedArray[i];
        }
        
        let i = left, j = mid + 1, k = left;
        
        while (i <= mid && j <= right) {
            if (tempArray[i] <= tempArray[j]) {
                sharedArray[k++] = tempArray[i++];
            } else {
                sharedArray[k++] = tempArray[j++];
            }
        }
        
        while (i <= mid) {
            sharedArray[k++] = tempArray[i++];
        }
        while (j <= right) {
            sharedArray[k++] = tempArray[j++];
        }
    }
    
    function isPrime(n) {
        if (n < 2) return false;
        if (n === 2) return true;
        if (n % 2 === 0) return false;
        
        const sqrt = Math.sqrt(n);
        for (let i = 3; i <= sqrt; i += 2) {
            if (n % i === 0) return false;
        }
        return true;
    }
    
    function countPrimes(start, end) {
        let count = 0;
        for (let i = start; i < end; i++) {
            if (isPrime(sharedArray[i])) {
                count++;
            }
        }
        return count;
    }
    
    // Handle messages from main thread
    parentPort.on('message', ({ type, start, end, workerId }) => {
        try {
            let result;
            const startTime = Date.now();
            
            switch (type) {
                case 'SORT_CHUNK':
                    // Sort chunk in shared memory
                    sequentialMergeSort(start, end);
                    result = 'sorted';
                    break;
                    
                case 'COUNT_PRIMES':
                    // Count primes in the chunk
                    result = countPrimes(start, end);
                    break;
                    
                default:
                    throw new Error(`Unknown task type: ${type}`);
            }
            
            const endTime = Date.now();
            
            parentPort.postMessage({
                result,
                executionTime: endTime - startTime,
                success: true,
                workerId
            });
        } catch (error) {
            parentPort.postMessage({
                error: error.message,
                success: false,
                workerId
            });
        }
    });
}

// Main execution
async function main() {
    if (!isMainThread) return;
    
    const filename = process.argv[2] || 'test_data.csv';
    
    console.log('[OPTIMIZED SHAREDARRAYBUFFER] JavaScript Optimized SharedArrayBuffer Parallel Merge Sort + Prime Counting');
    console.log('=====================================================================================================');
    console.log(`Available CPU cores: ${os.cpus().length}`);
    
    try {
        // Load data
        console.log('[DATA] Loading data...');
        const csvData = fs.readFileSync(filename, 'utf8').trim();
        const numbers = csvData.split(',').map(num => parseInt(num.trim(), 10));
        console.log(`Loaded ${numbers.length.toLocaleString()} numbers`);
        
        // Create sorter instance
        const sorter = new OptimizedSharedArrayBufferMergeSort(numbers);
        
        // Parallel merge sort
        console.log('\n[SORT] Starting optimized SharedArrayBuffer parallel merge sort...');
        const sortTime = await sorter.parallelSort();
        console.log(`[SUCCESS] Parallel merge sort completed in ${sortTime.toFixed(4)} seconds`);
        
        // Verify sorting
        const sorted = sorter.isSorted();
        console.log(`[VERIFY] Sorting verified: ${sorted}`);
        
        // Parallel prime counting
        console.log('\n[PRIMES] Starting optimized SharedArrayBuffer parallel prime counting...');
        const { primeCount, primeTime } = await sorter.parallelPrimeCount();
        console.log(`[SUCCESS] Parallel prime counting completed in ${primeTime.toFixed(4)} seconds`);
        console.log(`[RESULT] Found ${primeCount.toLocaleString()} prime numbers`);
        
        const totalTime = sortTime + primeTime;
        console.log(`\n[TIME] Total execution time: ${totalTime.toFixed(4)} seconds`);
        
        // Performance details
        console.log('\n[PERFORMANCE] Performance Details:');
        console.log(`- Workers used: ${sorter.numWorkers}`);
        console.log(`- Chunk size: ${sorter.sequentialThreshold.toLocaleString()}`);
        console.log(`- Shared memory size: ${(sorter.sharedBuffer.byteLength / 1024 / 1024).toFixed(1)} MB`);
        console.log(`- Sort time: ${sortTime.toFixed(4)}s`);
        console.log(`- Prime time: ${primeTime.toFixed(4)}s`);
        
        // Cleanup
        await sorter.cleanup();
        
        return totalTime;
        
    } catch (error) {
        console.error('[ERROR]', error);
        throw error;
    }
}

// Only run main if this is the main thread and script is executed directly
if (isMainThread && require.main === module) {
    main().catch(console.error);
}

module.exports = OptimizedSharedArrayBufferMergeSort; 