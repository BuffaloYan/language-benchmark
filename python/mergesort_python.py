#!/usr/bin/env python3
import csv
import time
import sys

def merge_sort(arr):
    """Implementation of merge sort algorithm"""
    if len(arr) <= 1:
        return arr
    
    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    
    return merge(left, right)

def merge(left, right):
    """Merge two sorted arrays"""
    result = []
    i, j = 0, 0
    
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    
    # Add remaining elements
    result.extend(left[i:])
    result.extend(right[j:])
    
    return result

def load_data(filename="test_data.csv"):
    """Load numbers from CSV file"""
    with open(filename, 'r') as csvfile:
        reader = csv.reader(csvfile)
        numbers = [int(x) for x in next(reader)]
    return numbers

def is_prime(n):
    """Check if a number is prime"""
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    
    # Check odd divisors up to sqrt(n)
    i = 3
    while i * i <= n:
        if n % i == 0:
            return False
        i += 2
    return True

def count_primes(numbers):
    """Count prime numbers in the list"""
    count = 0
    for num in numbers:
        if is_prime(num):
            count += 1
    return count

def main():
    filename = sys.argv[1] if len(sys.argv) > 1 else "test_data.csv"
    
    # Load data
    print("Loading data...")
    numbers = load_data(filename)
    print(f"Loaded {len(numbers):,} numbers")
    
    # Time the sorting
    print("Starting merge sort...")
    start_time = time.time()
    sorted_numbers = merge_sort(numbers.copy())
    sort_end_time = time.time()
    
    sort_time = sort_end_time - start_time
    print(f"Python merge sort completed in {sort_time:.4f} seconds")
    
    # Verify sorting is correct
    is_sorted = all(sorted_numbers[i] <= sorted_numbers[i+1] for i in range(len(sorted_numbers)-1))
    print(f"Sorting verified: {is_sorted}")
    
    # Count prime numbers
    print("Counting prime numbers...")
    prime_start_time = time.time()
    prime_count = count_primes(sorted_numbers)
    prime_end_time = time.time()
    
    prime_time = prime_end_time - prime_start_time
    total_time = sort_time + prime_time
    
    print(f"Prime counting completed in {prime_time:.4f} seconds")
    print(f"Found {prime_count:,} prime numbers")
    print(f"Total execution time: {total_time:.4f} seconds")
    
    return total_time

if __name__ == "__main__":
    main() 