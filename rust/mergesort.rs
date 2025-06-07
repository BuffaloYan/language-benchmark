use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::time::Instant;

fn merge_sort(arr: &mut [i32], temp: &mut [i32], left: usize, right: usize) {
    if left < right {
        let mid = left + (right - left) / 2;
        
        merge_sort(arr, temp, left, mid);
        merge_sort(arr, temp, mid + 1, right);
        merge(arr, temp, left, mid, right);
    }
}

fn merge(arr: &mut [i32], temp: &mut [i32], left: usize, mid: usize, right: usize) {
    // Copy array section to temp buffer
    for i in left..=right {
        temp[i] = arr[i];
    }
    
    let mut i = left;
    let mut j = mid + 1;
    let mut k = left;
    
    while i <= mid && j <= right {
        if temp[i] <= temp[j] {
            arr[k] = temp[i];
            i += 1;
        } else {
            arr[k] = temp[j];
            j += 1;
        }
        k += 1;
    }
    
    // Add remaining elements from left side
    while i <= mid {
        arr[k] = temp[i];
        i += 1;
        k += 1;
    }
    
    // Add remaining elements from right side
    while j <= right {
        arr[k] = temp[j];
        j += 1;
        k += 1;
    }
}

fn load_data(filename: &str) -> Result<Vec<i32>, Box<dyn std::error::Error>> {
    let file = File::open(filename)?;
    let reader = BufReader::new(file);
    let line = reader.lines().next().unwrap()?;
    
    let numbers: Result<Vec<i32>, _> = line
        .split(',')
        .map(|s| s.trim().parse::<i32>())
        .collect();
    
    Ok(numbers?)
}

fn is_sorted(arr: &[i32]) -> bool {
    arr.windows(2).all(|w| w[0] <= w[1])
}

fn is_prime(n: i32) -> bool {
    if n < 2 {
        return false;
    }
    if n == 2 {
        return true;
    }
    if n % 2 == 0 {
        return false;
    }

    // Check odd divisors up to sqrt(n)
    let mut i = 3;
    while i * i <= n {
        if n % i == 0 {
            return false;
        }
        i += 2;
    }
    true
}

fn count_primes(numbers: &[i32]) -> usize {
    numbers.iter().filter(|&&num| is_prime(num)).count()
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let filename = args.get(1).map(|s| s.as_str()).unwrap_or("test_data.csv");

    // Load data
    println!("Loading data...");
    let mut numbers = load_data(filename)?;
    println!("Loaded {} numbers", numbers.len());

    // Create a temporary buffer for merge operations
    let mut temp = vec![0; numbers.len()];

    // Time the sorting
    println!("Starting merge sort...");
    let start_time = Instant::now();
    let len = numbers.len();
    merge_sort(&mut numbers, &mut temp, 0, len - 1);
    let sort_end_time = Instant::now();

    let sort_time = sort_end_time.duration_since(start_time);
    println!("Rust merge sort completed in {:.4} seconds", sort_time.as_secs_f64());

    // Verify sorting is correct
    let sorted = is_sorted(&numbers);
    println!("Sorting verified: {}", sorted);

    // Count prime numbers
    println!("Counting prime numbers...");
    let prime_start_time = Instant::now();
    let prime_count = count_primes(&numbers);
    let prime_end_time = Instant::now();

    let prime_time = prime_end_time.duration_since(prime_start_time);
    let total_time = sort_time + prime_time;

    println!("Prime counting completed in {:.4} seconds", prime_time.as_secs_f64());
    println!("Found {} prime numbers", prime_count);
    println!("Total execution time: {:.4} seconds", total_time.as_secs_f64());

    Ok(())
} 