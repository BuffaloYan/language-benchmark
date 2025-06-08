#!/usr/bin/env python3
import random
import csv
import argparse
import sys

def generate_random_numbers(count=10_000_000, filename="test_data.csv"):
    """Generate random integers and save to CSV file"""
    print(f"Generating {count:,} random numbers...")
    
    # Generate random numbers between 1 and 1,000,000
    numbers = [random.randint(1, 10_000_000) for _ in range(count)]
    
    # Save to CSV file
    with open(filename, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(numbers)
    
    print(f"Data saved to {filename}")
    return numbers

def main():
    parser = argparse.ArgumentParser(description='Generate test data for language benchmarks')
    parser.add_argument('--size', '-s', type=int, default=10_000_000,
                        help='Number of random integers to generate (default: 10,000,000)')
    parser.add_argument('--filename', '-f', type=str, default='test_data.csv',
                        help='Output filename (default: test_data.csv)')
    
    args = parser.parse_args()
    
    # Validate size
    if args.size <= 0:
        print("Error: Size must be a positive integer", file=sys.stderr)
        sys.exit(1)
    
    # Generate data
    generate_random_numbers(args.size, args.filename)

if __name__ == "__main__":
    main() 