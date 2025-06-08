package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"strconv"
	"time"
)

func mergeSort(arr []int) []int {
	if len(arr) <= 1 {
		return arr
	}

	mid := len(arr) / 2
	left := mergeSort(arr[:mid])
	right := mergeSort(arr[mid:])

	return merge(left, right)
}

func merge(left, right []int) []int {
	result := make([]int, 0, len(left)+len(right))
	i, j := 0, 0

	for i < len(left) && j < len(right) {
		if left[i] <= right[j] {
			result = append(result, left[i])
			i++
		} else {
			result = append(result, right[j])
			j++
		}
	}

	// Add remaining elements
	result = append(result, left[i:]...)
	result = append(result, right[j:]...)

	return result
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

func countPrimes(numbers []int) int {
	count := 0
	for _, num := range numbers {
		if isPrime(num) {
			count++
		}
	}
	return count
}

func main() {
	filename := "test_data.csv"
	if len(os.Args) > 1 {
		filename = os.Args[1]
	}

	// Load data
	fmt.Println("Loading data...")
	numbers, err := loadData(filename)
	if err != nil {
		fmt.Printf("Error loading data: %v\n", err)
		return
	}
	fmt.Printf("Loaded %d numbers\n", len(numbers))

	// Make a copy for sorting
	numbersCopy := make([]int, len(numbers))
	copy(numbersCopy, numbers)

	// Time the sorting
	fmt.Println("Starting merge sort...")
	startTime := time.Now()
	sortedNumbers := mergeSort(numbersCopy)
	sortEndTime := time.Now()

	sortTime := sortEndTime.Sub(startTime).Seconds()
	fmt.Printf("Go merge sort completed in %.4f seconds\n", sortTime)

	// Verify sorting is correct
	sorted := isSorted(sortedNumbers)
	fmt.Printf("Sorting verified: %t\n", sorted)

	// Count prime numbers
	fmt.Println("Counting prime numbers...")
	primeStartTime := time.Now()
	primeCount := countPrimes(sortedNumbers)
	primeEndTime := time.Now()

	primeTime := primeEndTime.Sub(primeStartTime).Seconds()
	totalTime := sortTime + primeTime

	fmt.Printf("Prime counting completed in %.4f seconds\n", primeTime)
	fmt.Printf("Found %d prime numbers\n", primeCount)
	fmt.Printf("Total execution time: %.4f seconds\n", totalTime)
} 