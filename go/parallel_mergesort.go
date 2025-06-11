package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"runtime"
	"strconv"
	"sync"
	"time"
)

// Threshold for switching to sequential sort for small arrays
const PARALLEL_THRESHOLD = 10000

func parallelMergeSort(arr []int, temp []int, left, right int, depth int) {
	if left < right {
		// Use sequential sort for small arrays or when we've used too many goroutines
		if right-left < PARALLEL_THRESHOLD || depth > 10 {
			sequentialMergeSort(arr, temp, left, right)
			return
		}

		mid := left + (right-left)/2
		
		// Use goroutines for parallel execution on larger arrays
		var wg sync.WaitGroup
		wg.Add(2)
		
		go func() {
			defer wg.Done()
			parallelMergeSort(arr, temp, left, mid, depth+1)
		}()
		
		go func() {
			defer wg.Done()
			parallelMergeSort(arr, temp, mid+1, right, depth+1)
		}()
		
		wg.Wait()
		merge(arr, temp, left, mid, right)
	}
}

func sequentialMergeSort(arr []int, temp []int, left, right int) {
	if left < right {
		mid := left + (right-left)/2
		
		sequentialMergeSort(arr, temp, left, mid)
		sequentialMergeSort(arr, temp, mid+1, right)
		merge(arr, temp, left, mid, right)
	}
}

func merge(arr []int, temp []int, left, mid, right int) {
	// Copy array section to temp buffer
	for i := left; i <= right; i++ {
		temp[i] = arr[i]
	}
	
	i, j, k := left, mid+1, left
	
	for i <= mid && j <= right {
		if temp[i] <= temp[j] {
			arr[k] = temp[i]
			i++
		} else {
			arr[k] = temp[j]
			j++
		}
		k++
	}
	
	// Add remaining elements from left side
	for i <= mid {
		arr[k] = temp[i]
		i++
		k++
	}
	
	// Add remaining elements from right side  
	for j <= right {
		arr[k] = temp[j]
		j++
		k++
	}
}

func loadData(filename string) ([]int, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	if len(records) == 0 {
		return nil, fmt.Errorf("empty file")
	}

	numbers := make([]int, len(records[0]))
	for i, str := range records[0] {
		num, err := strconv.Atoi(str)
		if err != nil {
			return nil, err
		}
		numbers[i] = num
	}

	return numbers, nil
}

func isSorted(arr []int) bool {
	for i := 1; i < len(arr); i++ {
		if arr[i-1] > arr[i] {
			return false
		}
	}
	return true
}

func isPrime(n int) bool {
	if n < 2 {
		return false
	}
	if n == 2 {
		return true
	}
	if n%2 == 0 {
		return false
	}

	// Check odd divisors up to sqrt(n)
	for i := 3; i*i <= n; i += 2 {
		if n%i == 0 {
			return false
		}
	}
	return true
}

func countPrimesParallel(numbers []int) int {
	numWorkers := runtime.NumCPU()
	chunkSize := len(numbers) / numWorkers
	if chunkSize == 0 {
		chunkSize = 1
	}
	
	var wg sync.WaitGroup
	results := make([]int, numWorkers)
	
	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go func(workerID int) {
			defer wg.Done()
			start := workerID * chunkSize
			end := start + chunkSize
			if workerID == numWorkers-1 {
				end = len(numbers) // Last worker takes remaining elements
			}
			
			count := 0
			for j := start; j < end; j++ {
				if isPrime(numbers[j]) {
					count++
				}
			}
			results[workerID] = count
		}(i)
	}
	
	wg.Wait()
	
	totalCount := 0
	for _, count := range results {
		totalCount += count
	}
	
	return totalCount
}

func main() {
	filename := "test_data.csv"
	if len(os.Args) > 1 {
		filename = os.Args[1]
	}

	// Get system info
	numCPU := runtime.NumCPU()
	runtime.GOMAXPROCS(numCPU)

	// Load data
	fmt.Println("Loading data...")
	numbers, err := loadData(filename)
	if err != nil {
		fmt.Printf("Error loading data: %v\n", err)
		return
	}
	fmt.Printf("Loaded %d numbers\n", len(numbers))
	fmt.Printf("Processors: %d\n", numCPU)
	fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))

	// Create temporary buffer for merge operations (single allocation)
	temp := make([]int, len(numbers))

	// Time the sorting
	fmt.Println("Starting parallel merge sort...")
	startTime := time.Now()
	parallelMergeSort(numbers, temp, 0, len(numbers)-1, 0)
	sortEndTime := time.Now()

	sortTime := sortEndTime.Sub(startTime).Seconds()
	fmt.Printf("Go parallel merge sort completed in %.4f seconds\n", sortTime)

	// Verify sorting is correct
	sorted := isSorted(numbers)
	fmt.Printf("Sorting verified: %t\n", sorted)

	// Count prime numbers in parallel
	fmt.Println("Counting prime numbers...")
	primeStartTime := time.Now()
	primeCount := countPrimesParallel(numbers)
	primeEndTime := time.Now()

	primeTime := primeEndTime.Sub(primeStartTime).Seconds()
	totalTime := sortTime + primeTime

	fmt.Printf("Prime counting completed in %.4f seconds\n", primeTime)
	fmt.Printf("Found %d prime numbers\n", primeCount)
	fmt.Printf("Total execution time: %.4f seconds\n", totalTime)
} 