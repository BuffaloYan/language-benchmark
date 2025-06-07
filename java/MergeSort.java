import java.io.*;
import java.util.*;

public class MergeSort {
    
    public static void mergeSort(int[] arr, int left, int right) {
        if (left < right) {
            int mid = left + (right - left) / 2;
            
            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);
            
            merge(arr, left, mid, right);
        }
    }
    
    private static void merge(int[] arr, int left, int mid, int right) {
        int[] temp = new int[right - left + 1];
        int i = left, j = mid + 1, k = 0;
        
        while (i <= mid && j <= right) {
            if (arr[i] <= arr[j]) {
                temp[k++] = arr[i++];
            } else {
                temp[k++] = arr[j++];
            }
        }
        
        while (i <= mid) {
            temp[k++] = arr[i++];
        }
        
        while (j <= right) {
            temp[k++] = arr[j++];
        }
        
        System.arraycopy(temp, 0, arr, left, temp.length);
    }
    
    private static int[] loadData(String filename) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(filename));
        String line = reader.readLine();
        reader.close();
        
        String[] parts = line.split(",");
        int[] numbers = new int[parts.length];
        for (int i = 0; i < parts.length; i++) {
            numbers[i] = Integer.parseInt(parts[i]);
        }
        
        return numbers;
    }
    
    private static boolean isSorted(int[] arr) {
        for (int i = 1; i < arr.length; i++) {
            if (arr[i-1] > arr[i]) {
                return false;
            }
        }
        return true;
    }
    
    private static boolean isPrime(int n) {
        if (n < 2) return false;
        if (n == 2) return true;
        if (n % 2 == 0) return false;
        
        // Check odd divisors up to sqrt(n)
        for (int i = 3; i * i <= n; i += 2) {
            if (n % i == 0) return false;
        }
        return true;
    }
    
    private static int countPrimes(int[] numbers) {
        int count = 0;
        for (int num : numbers) {
            if (isPrime(num)) {
                count++;
            }
        }
        return count;
    }
    
    public static void main(String[] args) {
        String filename = args.length > 0 ? args[0] : "test_data.csv";
        
        try {
            // Load data
            System.out.println("Loading data...");
            int[] numbers = loadData(filename);
            System.out.printf("Loaded %,d numbers%n", numbers.length);
            
            // Time the sorting
            System.out.println("Starting merge sort...");
            long startTime = System.nanoTime();
            mergeSort(numbers, 0, numbers.length - 1);
            long sortEndTime = System.nanoTime();
            
            double sortTime = (sortEndTime - startTime) / 1_000_000_000.0;
            System.out.printf("Java merge sort completed in %.4f seconds%n", sortTime);
            
            // Verify sorting is correct
            boolean sorted = isSorted(numbers);
            System.out.println("Sorting verified: " + sorted);
            
            // Count prime numbers
            System.out.println("Counting prime numbers...");
            long primeStartTime = System.nanoTime();
            int primeCount = countPrimes(numbers);
            long primeEndTime = System.nanoTime();
            
            double primeTime = (primeEndTime - primeStartTime) / 1_000_000_000.0;
            double totalTime = sortTime + primeTime;
            
            System.out.printf("Prime counting completed in %.4f seconds%n", primeTime);
            System.out.printf("Found %,d prime numbers%n", primeCount);
            System.out.printf("Total execution time: %.4f seconds%n", totalTime);
            
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
        }
    }
} 