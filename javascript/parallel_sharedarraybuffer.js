#!/usr/bin/env node

const fs = require('fs');
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');
const os = require('os');

// SharedArrayBuffer-based parallel merge sort implementation
class SharedArrayBufferMergeSort {
    constructor(data) {
        this.data = data;
        this.length = data.length;
        this.numWorkers = Math.min(os.cpus().length, 8); // Cap at 8 workers
        this.sequentialThreshold = 50000; // Switch to sequential below this size
        
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
        
        // Create coordination buffer for worker synchronization
        this.coordBuffer = new SharedArrayBuffer(64); // Space for coordination data
        this.coordArray = new Int32Array(this.coordBuffer);
        
        console.log(`🔧 SharedArrayBuffer Setup:`);
        console.log(`   - Data size: ${this.length.toLocaleString()} integers`);
        console.log(`   - Workers: ${this.numWorkers}`);
        console.log(`   - Sequential threshold: ${this.sequentialThreshold.toLocaleString()}`);
        console.log(`   - Shared memory: ${(this.sharedBuffer.byteLength / 1024 / 1024).toFixed(1)} MB`);
    }
    
    async parallelSort() {
        const startTime = process.hrtime.bigint();
        
        // Parallel merge sort using divide-and-conquer with work stealing
        await this.parallelMergeSortRecursive(0, this.length - 1, 0);
        
        const endTime = process.hrtime.bigint();
        const sortTime = Number(endTime - startTime) / 1_000_000_000;
        
        return sortTime;
    }
    
    async parallelMergeSortRecursive(left, right, depth) {
        const size = right - left + 1;
        
        // Use sequential sort for small chunks or when we've gone deep enough
        if (size <= this.sequentialThreshold || depth > Math.log2(this.numWorkers)) {
            this.sequentialMergeSort(left, right);
            return;
        }
        
        const mid = Math.floor((left + right) / 2);
        
        // Create workers for left and right halves
        const leftWorker = new Worker(__filename, {
            workerData: {
                type: 'mergeSort',
                sharedBuffer: this.sharedBuffer,
                tempBuffer: this.tempBuffer,
                coordBuffer: this.coordBuffer,
                left: left,
                right: mid,
                depth: depth + 1,
                sequentialThreshold: this.sequentialThreshold
            }
        });
        
        const rightWorker = new Worker(__filename, {
            workerData: {
                type: 'mergeSort',
                sharedBuffer: this.sharedBuffer,
                tempBuffer: this.tempBuffer,
                coordBuffer: this.coordBuffer,
                left: mid + 1,
                right: right,
                depth: depth + 1,
                sequentialThreshold: this.sequentialThreshold
            }
        });
        
        // Wait for both workers to complete
        await Promise.all([
            new Promise((resolve, reject) => {
                leftWorker.on('message', resolve);
                leftWorker.on('error', reject);
            }),
            new Promise((resolve, reject) => {
                rightWorker.on('message', resolve);
                rightWorker.on('error', reject);
            })
        ]);
        
        // Terminate workers
        leftWorker.terminate();
        rightWorker.terminate();
        
        // Merge the sorted halves
        this.merge(left, mid, right);
    }
    
    sequentialMergeSort(left, right) {
        if (left < right) {
            const mid = Math.floor((left + right) / 2);
            this.sequentialMergeSort(left, mid);
            this.sequentialMergeSort(mid + 1, right);
            this.merge(left, mid, right);
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
        const workers = [];
        const promises = [];
        
        for (let i = 0; i < this.numWorkers; i++) {
            const start = i * chunkSize;
            const end = Math.min(start + chunkSize, this.length);
            
            if (start >= this.length) break;
            
            const worker = new Worker(__filename, {
                workerData: {
                    type: 'primeCount',
                    sharedBuffer: this.sharedBuffer,
                    start: start,
                    end: end
                }
            });
            
            workers.push(worker);
            promises.push(new Promise((resolve, reject) => {
                worker.on('message', resolve);
                worker.on('error', reject);
            }));
        }
        
        const results = await Promise.all(promises);
        
        // Terminate all workers
        workers.forEach(worker => worker.terminate());
        
        const totalPrimes = results.reduce((sum, count) => sum + count, 0);
        
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
}

// Worker thread code
if (!isMainThread) {
    const { type, sharedBuffer, tempBuffer, coordBuffer, start, end, left, right, depth, sequentialThreshold } = workerData;
    
    if (type === 'mergeSort') {
        const sharedArray = new Int32Array(sharedBuffer);
        const tempArray = new Int32Array(tempBuffer);
        
        // Sequential merge sort for worker
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
        
        // Perform the sort
        sequentialMergeSort(left, right);
        parentPort.postMessage('complete');
        
    } else if (type === 'primeCount') {
        const sharedArray = new Int32Array(sharedBuffer);
        
        function isPrime(n) {
            if (n < 2) return false;
            if (n === 2) return true;
            if (n % 2 === 0) return false;
            
            for (let i = 3; i * i <= n; i += 2) {
                if (n % i === 0) return false;
            }
            return true;
        }
        
        let primeCount = 0;
        for (let i = start; i < end; i++) {
            if (isPrime(sharedArray[i])) {
                primeCount++;
            }
        }
        
        parentPort.postMessage(primeCount);
    }
}

// Main execution
async function main() {
    if (!isMainThread) return;
    
    const filename = process.argv[2] || 'test_data.csv';
    
    console.log('🚀 JavaScript SharedArrayBuffer Parallel Merge Sort + Prime Counting');
    console.log('====================================================================');
    console.log(`Available CPU cores: ${os.cpus().length}`);
    
    try {
        // Load data
        console.log('📊 Loading data...');
        const csvData = fs.readFileSync(filename, 'utf8').trim();
        const numbers = csvData.split(',').map(num => parseInt(num.trim(), 10));
        console.log(`Loaded ${numbers.length.toLocaleString()} numbers`);
        
        // Create sorter instance
        const sorter = new SharedArrayBufferMergeSort(numbers);
        
        // Parallel merge sort
        console.log('\n🔄 Starting SharedArrayBuffer parallel merge sort...');
        const sortTime = await sorter.parallelSort();
        console.log(`✅ Parallel merge sort completed in ${sortTime.toFixed(4)} seconds`);
        
        // Verify sorting
        const sorted = sorter.isSorted();
        console.log(`🔍 Sorting verified: ${sorted}`);
        
        // Parallel prime counting
        console.log('\n🔢 Starting SharedArrayBuffer parallel prime counting...');
        const { primeCount, primeTime } = await sorter.parallelPrimeCount();
        console.log(`✅ Parallel prime counting completed in ${primeTime.toFixed(4)} seconds`);
        console.log(`🎯 Found ${primeCount.toLocaleString()} prime numbers`);
        
        const totalTime = sortTime + primeTime;
        console.log(`\n⏱️  Total execution time: ${totalTime.toFixed(4)} seconds`);
        
        // Performance details
        console.log('\n📈 Performance Details:');
        console.log(`- Workers used: ${sorter.numWorkers}`);
        console.log(`- Sequential threshold: ${sorter.sequentialThreshold.toLocaleString()}`);
        console.log(`- Shared memory size: ${(sorter.sharedBuffer.byteLength / 1024 / 1024).toFixed(1)} MB`);
        console.log(`- Sort time: ${sortTime.toFixed(4)}s`);
        console.log(`- Prime time: ${primeTime.toFixed(4)}s`);
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

// Only run main if this is the main thread and script is executed directly
if (isMainThread && require.main === module) {
    main().catch(console.error);
} 