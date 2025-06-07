import java.io.*;
import java.util.*;
import java.util.concurrent.*;

public class ParallelMergeSort {
    private static final int SEQUENTIAL_THRESHOLD = 1000; // Switch to sequential below this size
    private static final int AVAILABLE_PROCESSORS = Runtime.getRuntime().availableProcessors();
    
    // Parallel merge sort using Fork-Join framework
    static class MergeSortTask extends RecursiveAction {
        private final int[] array;
        private final int[] temp;
        private final int left;
        private final int right;
        
        MergeSortTask(int[] array, int[] temp, int left, int right) {
            this.array = array;
            this.temp = temp;
            this.left = left;
            this.right = right;
        }
        
        @Override
        protected void compute() {
            if (right - left <= SEQUENTIAL_THRESHOLD) {
                // Use sequential merge sort for small arrays
                sequentialMergeSort(array, temp, left, right);
            } else {
                int mid = left + (right - left) / 2;
                
                // Fork left and right halves
                MergeSortTask leftTask = new MergeSortTask(array, temp, left, mid);
                MergeSortTask rightTask = new MergeSortTask(array, temp, mid + 1, right);
                
                // Execute both tasks in parallel
                leftTask.fork();
                rightTask.compute();
                leftTask.join();
                
                // Merge the sorted halves
                merge(array, temp, left, mid, right);
            }
        }
        
        private void sequentialMergeSort(int[] arr, int[] temp, int left, int right) {
            if (left < right) {
                int mid = left + (right - left) / 2;
                sequentialMergeSort(arr, temp, left, mid);
                sequentialMergeSort(arr, temp, mid + 1, right);
                merge(arr, temp, left, mid, right);
            }
        }
        
        private void merge(int[] arr, int[] temp, int left, int mid, int right) {
            // Copy array to temp
            for (int i = left; i <= right; i++) {
                temp[i] = arr[i];
            }
            
            int i = left, j = mid + 1, k = left;
            
            while (i <= mid && j <= right) {
                if (temp[i] <= temp[j]) {
                    arr[k++] = temp[i++];
                } else {
                    arr[k++] = temp[j++];
                }
            }
            
            while (i <= mid) {
                arr[k++] = temp[i++];
            }
            
            while (j <= right) {
                arr[k++] = temp[j++];
            }
        }
    }
    
    // Parallel prime counting using Fork-Join framework
    static class PrimeCountTask extends RecursiveTask<Integer> {
        private final int[] numbers;
        private final int start;
        private final int end;
        private static final int PRIME_THRESHOLD = 10000;
        
        PrimeCountTask(int[] numbers, int start, int end) {
            this.numbers = numbers;
            this.start = start;
            this.end = end;
        }
        
        @Override
        protected Integer compute() {
            if (end - start <= PRIME_THRESHOLD) {
                // Sequential prime counting for small chunks
                return sequentialPrimeCount(numbers, start, end);
            } else {
                int mid = start + (end - start) / 2;
                
                PrimeCountTask leftTask = new PrimeCountTask(numbers, start, mid);
                PrimeCountTask rightTask = new PrimeCountTask(numbers, mid, end);
                
                leftTask.fork();
                int rightResult = rightTask.compute();
                int leftResult = leftTask.join();
                
                return leftResult + rightResult;
            }
        }
        
        private int sequentialPrimeCount(int[] nums, int start, int end) {
            int count = 0;
            for (int i = start; i < end; i++) {
                if (isPrime(nums[i])) {
                    count++;
                }
            }
            return count;
        }
    }
    
    private static boolean isPrime(int n) {
        if (n < 2) return false;
        if (n == 2) return true;
        if (n % 2 == 0) return false;
        
        for (int i = 3; i * i <= n; i += 2) {
            if (n % i == 0) return false;
        }
        return true;
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
    
    public static void main(String[] args) {
        String filename = args.length > 0 ? args[0] : "test_data.csv";
        
        System.out.println("🚀 Java Parallel Merge Sort + Prime Counting");
        System.out.println("============================================");
        System.out.printf("Available processors: %d%n", AVAILABLE_PROCESSORS);
        System.out.printf("Sequential threshold: %d elements%n", SEQUENTIAL_THRESHOLD);
        System.out.println();
        
        ForkJoinPool forkJoinPool = new ForkJoinPool();
        try {
            // Load data
            System.out.println("📊 Loading data...");
            int[] numbers = loadData(filename);
            System.out.printf("Loaded %,d numbers%n", numbers.length);
            
            // Create a copy for sorting
            int[] sortArray = Arrays.copyOf(numbers, numbers.length);
            int[] tempArray = new int[numbers.length];
            
            // Parallel merge sort
            System.out.println("🔄 Starting parallel merge sort...");
            long sortStartTime = System.nanoTime();
            
            MergeSortTask sortTask = new MergeSortTask(sortArray, tempArray, 0, sortArray.length - 1);
            forkJoinPool.invoke(sortTask);
            
            long sortEndTime = System.nanoTime();
            double sortTime = (sortEndTime - sortStartTime) / 1_000_000_000.0;
            
            System.out.printf("✅ Parallel merge sort completed in %.4f seconds%n", sortTime);
            
            // Verify sorting
            boolean sorted = isSorted(sortArray);
            System.out.printf("🔍 Sorting verified: %s%n", sorted);
            
            // Parallel prime counting
            System.out.println("🔢 Starting parallel prime counting...");
            long primeStartTime = System.nanoTime();
            
            PrimeCountTask primeTask = new PrimeCountTask(sortArray, 0, sortArray.length);
            Integer primeCount = forkJoinPool.invoke(primeTask);
            
            long primeEndTime = System.nanoTime();
            double primeTime = (primeEndTime - primeStartTime) / 1_000_000_000.0;
            
            System.out.printf("✅ Parallel prime counting completed in %.4f seconds%n", primeTime);
            System.out.printf("🎯 Found %,d prime numbers%n", primeCount);
            
            double totalTime = sortTime + primeTime;
            System.out.printf("⏱️  Total execution time: %.4f seconds%n", totalTime);
            
            // Performance info
            System.out.println();
            System.out.println("📈 Performance Details:");
            System.out.printf("- Pool parallelism: %d%n", forkJoinPool.getParallelism());
            System.out.printf("- Active thread count: %d%n", forkJoinPool.getActiveThreadCount());
            System.out.printf("- Steal count: %d%n", forkJoinPool.getStealCount());
            
        } catch (IOException e) {
            System.err.println("❌ Error reading file: " + e.getMessage());
        } finally {
            forkJoinPool.shutdown();
        }
    }
} 