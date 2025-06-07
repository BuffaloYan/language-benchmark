#!/usr/bin/env node
const { Worker } = require('worker_threads');
const fs = require('fs');
const os = require('os');

class WorkerPool {
    constructor(workerFile, poolSize = os.cpus().length) {
        this.workers = [];
        this.taskQueue = [];
        this.taskId = 0;
        this.activeTasks = new Map();
        
        console.log(`🔧 Creating worker pool with ${poolSize} workers`);
        
        // Create worker threads
        for (let i = 0; i < poolSize; i++) {
            const worker = new Worker(workerFile);
            worker.isAvailable = true;
            worker.on('message', this.handleWorkerMessage.bind(this));
            worker.on('error', (error) => {
                console.error(`Worker ${i} error:`, error);
            });
            this.workers.push(worker);
        }
    }
    
    handleWorkerMessage({ taskId, result, executionTime, success, error }) {
        const task = this.activeTasks.get(taskId);
        if (!task) return;
        
        this.activeTasks.delete(taskId);
        
        // Mark worker as available
        const worker = this.workers.find(w => !w.isAvailable);
        if (worker) {
            worker.isAvailable = true;
            this.processQueue();
        }
        
        if (success) {
            task.resolve({ result, executionTime });
        } else {
            task.reject(new Error(error));
        }
    }
    
    execute(type, data) {
        return new Promise((resolve, reject) => {
            const taskId = ++this.taskId;
            const task = { taskId, type, data, resolve, reject };
            
            this.taskQueue.push(task);
            this.processQueue();
        });
    }
    
    processQueue() {
        while (this.taskQueue.length > 0) {
            const availableWorker = this.workers.find(w => w.isAvailable);
            if (!availableWorker) break;
            
            const task = this.taskQueue.shift();
            availableWorker.isAvailable = false;
            this.activeTasks.set(task.taskId, task);
            
            availableWorker.postMessage({
                type: task.type,
                data: task.data,
                taskId: task.taskId
            });
        }
    }
    
    async terminate() {
        await Promise.all(this.workers.map(worker => worker.terminate()));
    }
}

class ParallelMergeSort {
    constructor() {
        this.workerPool = new WorkerPool('./javascript/parallel_worker.js');
        this.PARALLEL_THRESHOLD = 10000; // Use workers for chunks larger than this
    }
    
    async parallelMergeSort(array) {
        if (array.length <= this.PARALLEL_THRESHOLD) {
            // Use sequential sort for small arrays
            return this.sequentialMergeSort(array);
        }
        
        const mid = Math.floor(array.length / 2);
        const leftHalf = array.slice(0, mid);
        const rightHalf = array.slice(mid);
        
        // Sort both halves in parallel
        const [leftResult, rightResult] = await Promise.all([
            this.parallelMergeSort(leftHalf),
            this.parallelMergeSort(rightHalf)
        ]);
        
        // Merge the sorted halves
        return this.merge(leftResult, rightResult);
    }
    
    sequentialMergeSort(arr) {
        if (arr.length <= 1) return arr;
        
        const mid = Math.floor(arr.length / 2);
        const left = this.sequentialMergeSort(arr.slice(0, mid));
        const right = this.sequentialMergeSort(arr.slice(mid));
        
        return this.merge(left, right);
    }
    
    merge(left, right) {
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
        
        while (i < left.length) result.push(left[i++]);
        while (j < right.length) result.push(right[j++]);
        
        return result;
    }
    
    async parallelPrimeCount(numbers) {
        const numWorkers = this.workerPool.workers.length;
        const chunkSize = Math.ceil(numbers.length / numWorkers);
        const chunks = [];
        
        // Divide work among workers
        for (let i = 0; i < numbers.length; i += chunkSize) {
            const chunk = numbers.slice(i, i + chunkSize);
            if (chunk.length > 0) {
                chunks.push(chunk);
            }
        }
        
        console.log(`📦 Divided into ${chunks.length} chunks for prime counting`);
        
        // Execute prime counting in parallel
        const promises = chunks.map(chunk => 
            this.workerPool.execute('COUNT_PRIMES', chunk)
        );
        
        const results = await Promise.all(promises);
        
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
            console.log('🚀 JavaScript Parallel Merge Sort + Prime Counting');
            console.log('===================================================');
            console.log(`Available CPU cores: ${os.cpus().length}`);
            console.log(`Worker pool size: ${this.workerPool.workers.length}`);
            console.log(`Parallel threshold: ${this.PARALLEL_THRESHOLD.toLocaleString()} elements`);
            console.log();
            
            // Load data
            console.log('📊 Loading data...');
            const numbers = this.loadData(filename);
            console.log(`Loaded ${numbers.length.toLocaleString()} numbers`);
            
            // Parallel merge sort
            console.log('🔄 Starting parallel merge sort...');
            const sortStartTime = Date.now();
            const sortedNumbers = await this.parallelMergeSort([...numbers]);
            const sortEndTime = Date.now();
            
            const sortTime = (sortEndTime - sortStartTime) / 1000;
            console.log(`✅ Parallel merge sort completed in ${sortTime.toFixed(4)} seconds`);
            
            // Verify sorting
            const sorted = this.isSorted(sortedNumbers);
            console.log(`🔍 Sorting verified: ${sorted}`);
            
            // Parallel prime counting
            console.log('🔢 Starting parallel prime counting...');
            const primeStartTime = Date.now();
            const primeCount = await this.parallelPrimeCount(sortedNumbers);
            const primeEndTime = Date.now();
            
            const primeTime = (primeEndTime - primeStartTime) / 1000;
            console.log(`✅ Parallel prime counting completed in ${primeTime.toFixed(4)} seconds`);
            console.log(`🎯 Found ${primeCount.toLocaleString()} prime numbers`);
            
            const totalTime = sortTime + primeTime;
            console.log(`⏱️  Total execution time: ${totalTime.toFixed(4)} seconds`);
            
            console.log();
            console.log('📈 Performance Details:');
            console.log(`- Active workers: ${this.workerPool.workers.length}`);
            console.log(`- Completed tasks: ${this.workerPool.taskId}`);
            
            await this.workerPool.terminate();
            
            return { sortTime, primeTime, totalTime, primeCount };
            
        } catch (error) {
            console.error('❌ Error:', error.message);
            await this.workerPool.terminate();
            throw error;
        }
    }
}

async function main() {
    const filename = process.argv[2] || 'test_data.csv';
    const parallelSort = new ParallelMergeSort();
    await parallelSort.run(filename);
}

if (require.main === module) {
    main().catch(console.error);
} 