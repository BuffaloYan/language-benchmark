#!/usr/bin/env python3
import random
import csv

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

if __name__ == "__main__":
    generate_random_numbers() 