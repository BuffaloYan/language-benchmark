use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::time::Instant;
use rayon::prelude::*;

fn parallel_merge_sort(arr: &mut [i32]) {
    if arr.len() > 1 {
        parallel_merge_sort_recursive(arr);
    }
}

fn parallel_merge_sort_recursive(arr: &mut [i32]) {
    const SEQUENTIAL_THRESHOLD: usize = 10_000; // Switch to sequential for small arrays
    
    if arr.len() <= SEQUENTIAL_THRESHOLD {
        // Use sequential merge sort for small arrays
        arr.sort();
    } else if arr.len() > 1 {
        let mid = arr.len() / 2;
        
        // Split the array into two mutable parts
        let (left_half, right_half) = arr.split_at_mut(mid);
        
        // Use rayon to parallelize the recursive calls
        rayon::join(
            || parallel_merge_sort_recursive(left_half),
            || parallel_merge_sort_recursive(right_half),
        );
        
        // After sorting, merge the two halves using temporary storage
        let left_copy: Vec<i32> = left_half.to_vec();
        let right_copy: Vec<i32> = right_half.to_vec();
        merge_halves(&left_copy, &right_copy, arr);
    }
}

fn merge_halves(left: &[i32], right: &[i32], result: &mut [i32]) {
    let mut left_idx = 0;
    let mut right_idx = 0;
    let mut result_idx = 0;
    
    // Merge both halves into result
    while left_idx < left.len() && right_idx < right.len() {
        if left[left_idx] <= right[right_idx] {
            result[result_idx] = left[left_idx];
            left_idx += 1;
        } else {
            result[result_idx] = right[right_idx];
            right_idx += 1;
        }
        result_idx += 1;
    }
    
    // Copy remaining elements from left half
    while left_idx < left.len() {
        result[result_idx] = left[left_idx];
        left_idx += 1;
        result_idx += 1;
    }
    
    // Copy remaining elements from right half
    while right_idx < right.len() {
        result[result_idx] = right[right_idx];
        right_idx += 1;
        result_idx += 1;
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

    let sqrt_n = (n as f64).sqrt() as i32;
    (3..=sqrt_n).step_by(2).all(|i| n % i != 0)
}

fn parallel_count_primes(numbers: &[i32]) -> usize {
    numbers.par_iter().filter(|&&num| is_prime(num)).count()
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let filename = args.get(1).map(|s| s.as_str()).unwrap_or("test_data.csv");

    println!("🦀 Rust Parallel Merge Sort + Prime Counting");
    println!("============================================");
    
    // Display system information
    let num_threads = rayon::current_num_threads();
    println!("Available CPU cores: {}", num_threads);
    println!("Parallel threshold: 10,000 elements");
    println!();

    // Load data
    println!("📊 Loading data...");
    let mut numbers = load_data(filename)?;
    println!("Loaded {} numbers", numbers.len());

    // Time the parallel sorting
    println!("🔄 Starting parallel merge sort...");
    let start_time = Instant::now();
    parallel_merge_sort(&mut numbers);
    let sort_end_time = Instant::now();

    let sort_time = sort_end_time.duration_since(start_time);
    println!("✅ Parallel merge sort completed in {:.4} seconds", sort_time.as_secs_f64());

    // Verify sorting is correct
    let sorted = is_sorted(&numbers);
    println!("🔍 Sorting verified: {}", sorted);

    // Count prime numbers in parallel
    println!("🔢 Starting parallel prime counting...");
    let prime_start_time = Instant::now();
    let prime_count = parallel_count_primes(&numbers);
    let prime_end_time = Instant::now();

    let prime_time = prime_end_time.duration_since(prime_start_time);
    let total_time = sort_time + prime_time;

    println!("✅ Parallel prime counting completed in {:.4} seconds", prime_time.as_secs_f64());
    println!("🎯 Found {} prime numbers", prime_count);
    println!("⏱️  Total execution time: {:.4} seconds", total_time.as_secs_f64());

    println!();
    println!("📈 Performance Details:");
    println!("- Rayon thread pool size: {}", num_threads);
    println!("- Sequential threshold: 10,000 elements");
    println!("- Sort time: {:.4}s", sort_time.as_secs_f64());
    println!("- Prime time: {:.4}s", prime_time.as_secs_f64());

    Ok(())
} 