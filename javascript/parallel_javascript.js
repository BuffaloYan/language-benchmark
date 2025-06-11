#!/usr/bin/env node
const { Worker } = require('worker_threads');
const fs = require('fs');
const os = require('os');

class OptimizedWorkerPool {
    constructor(workerFile, poolSize = os.cpus().length) {
        this.workers = [];
        this.workerFile = workerFile;
        this.poolSize = poolSize;
        
        console.log(`🔧 Creating optimized worker pool with ${poolSize} workers`);
    }
    
    async createWorkers() {
        // Create workers on demand to avoid startup overhead
        for (let i = 0; i < this.poolSize; i++) {
            const worker = new Worker(this.workerFile);
            this.workers.push(worker);
        }
    }
    
    async executeParallel(tasks) {
        // Execute tasks in parallel, one per worker
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

class OptimizedParallelMergeSort {
    constructor() {
        this.workerPool = new OptimizedWorkerPool('./javascript/parallel_worker.js');
        this.MIN_CHUNK_SIZE = 50000; // Minimum elements per worker to justify overhead
    }
    
    async parallelMergeSort(array) {
        const numWorkers = this.workerPool.poolSize;
        
        // If array is too small, use sequential sort
        if (array.length < this.MIN_CHUNK_SIZE || numWorkers === 1) {
            console.log('[OPTIMIZATION] Using sequential sort (data too small for parallelization)');
            return this.sequentialMergeSort(array);
        }
        
        await this.workerPool.createWorkers();
        
        // Split array into chunks for workers (one chunk per worker)
        const chunkSize = Math.ceil(array.length / numWorkers);
        const chunks = [];
        
        for (let i = 0; i < array.length; i += chunkSize) {
            const chunk = array.slice(i, i + chunkSize);
            if (chunk.length > 0) {
                chunks.push({
                    type: 'SORT_CHUNK',
                    data: chunk,
                    chunkIndex: chunks.length
                });
            }
        }
        
        console.log(`[CHUNKS] Divided ${array.length.toLocaleString()} elements into ${chunks.length} chunks`);
        console.log(`[CHUNKS] Average chunk size: ${Math.floor(array.length / chunks.length).toLocaleString()} elements`);
        
        // Sort chunks in parallel
        const startTime = Date.now();
        const results = await this.workerPool.executeParallel(chunks);
        const parallelTime = Date.now() - startTime;
        
        console.log(`[PARALLEL] Chunk sorting completed in ${(parallelTime / 1000).toFixed(4)} seconds`);
        
        // Merge sorted chunks sequentially (this is the bottleneck we need to minimize)
        const mergeStartTime = Date.now();
        let mergedResult = results[0].result;
        
        for (let i = 1; i < results.length; i++) {
            mergedResult = this.merge(mergedResult, results[i].result);
        }
        
        const mergeTime = Date.now() - mergeStartTime;
        console.log(`[MERGE] Final merge completed in ${(mergeTime / 1000).toFixed(4)} seconds`);
        
        return mergedResult;
    }
    
    sequentialMergeSort(arr) {
        if (arr.length <= 1) return arr;
        
        const mid = Math.floor(arr.length / 2);
        const left = this.sequentialMergeSort(arr.slice(0, mid));
        const right = this.sequentialMergeSort(arr.slice(mid));
        
        return this.merge(left, right);
    }
    
    merge(left, right) {
        const result = new Array(left.length + right.length);
        let i = 0, j = 0, k = 0;
        
        // Optimized merge with pre-allocated array
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
    
    async parallelPrimeCount(numbers) {
        const numWorkers = this.workerPool.poolSize;
        const chunkSize = Math.ceil(numbers.length / numWorkers);
        const chunks = [];
        
        // Divide work among workers - much larger chunks
        for (let i = 0; i < numbers.length; i += chunkSize) {
            const chunk = numbers.slice(i, i + chunkSize);
            if (chunk.length > 0) {
                chunks.push({
                    type: 'COUNT_PRIMES',
                    data: chunk,
                    chunkIndex: chunks.length
                });
            }
        }
        
        console.log(`[PRIME CHUNKS] Divided into ${chunks.length} chunks for prime counting`);
        console.log(`[PRIME CHUNKS] Average chunk size: ${Math.floor(numbers.length / chunks.length).toLocaleString()} elements`);
        
        // Execute prime counting in parallel
        const results = await this.workerPool.executeParallel(chunks);
        
        // Sum up the results
        return results.reduce((total, { result }) => total + result, 0);
    }
    
    loadData(filename) {
        const data = fs.readFileSync(filename, 'utf8');
        return data.trim().split(',').map(num => parseInt(num));
    }
    
    isSorted(arr) {
        for (let i = 1; i < arr.length; i++) {
            if (arr[i-1] > arr[i]) return false;
        }
        return true;
    }
    
    async run(filename = 'test_data.csv') {
        try {
            console.log('[OPTIMIZED PARALLEL] JavaScript Optimized Parallel Merge Sort + Prime Counting');
            console.log('==============================================================================');
            console.log(`Available CPU cores: ${os.cpus().length}`);
            console.log(`Worker pool size: ${this.workerPool.poolSize}`);
            console.log(`Minimum chunk size: ${this.MIN_CHUNK_SIZE.toLocaleString()} elements`);
            console.log();
            
            // Load data
            console.log('[DATA] Loading data...');
            const numbers = this.loadData(filename);
            console.log(`Loaded ${numbers.length.toLocaleString()} numbers`);
            
            // Calculate theoretical overhead
            const dataSize = JSON.stringify(numbers).length;
            console.log(`[OVERHEAD] Data size: ${(dataSize / 1024 / 1024).toFixed(2)} MB`);
            console.log(`[OVERHEAD] Per-worker transfer: ${(dataSize / this.workerPool.poolSize / 1024 / 1024).toFixed(2)} MB`);
            console.log();
            
            // Parallel merge sort
            console.log('[SORT] Starting optimized parallel merge sort...');
            const sortStartTime = Date.now();
            const sortedNumbers = await this.parallelMergeSort([...numbers]);
            const sortEndTime = Date.now();
            
            const sortTime = (sortEndTime - sortStartTime) / 1000;
            console.log(`[SUCCESS] Optimized parallel merge sort completed in ${sortTime.toFixed(4)} seconds`);
            
            // Verify sorting
            const sorted = this.isSorted(sortedNumbers);
            console.log(`[VERIFY] Sorting verified: ${sorted}`);
            
            // Parallel prime counting
            console.log('[PRIME] Starting parallel prime counting...');
            const primeStartTime = Date.now();
            const primeCount = await this.parallelPrimeCount(sortedNumbers);
            const primeEndTime = Date.now();
            
            const primeTime = (primeEndTime - primeStartTime) / 1000;
            const totalTime = sortTime + primeTime;
            
            console.log(`[SUCCESS] Parallel prime counting completed in ${primeTime.toFixed(4)} seconds`);
            console.log(`Found ${primeCount.toLocaleString()} prime numbers`);
            console.log();
            console.log(`[TOTAL] Execution time: ${totalTime.toFixed(4)} seconds`);
            
            // Performance analysis
            const expectedSpeedup = Math.min(this.workerPool.poolSize, 4); // Diminishing returns after 4 cores
            console.log(`[ANALYSIS] Expected speedup: ${expectedSpeedup.toFixed(1)}x (theoretical maximum)`);
            
            return totalTime;
            
        } catch (error) {
            console.error('[ERROR]', error);
            throw error;
        } finally {
            // Clean up worker pool
            await this.workerPool.terminate();
        }
    }
}

async function main() {
    const filename = process.argv[2] || "test_data.csv";
    
    const parallelSort = new OptimizedParallelMergeSort();
    await parallelSort.run(filename);
}

if (require.main === module) {
    main().catch(console.error);
} 