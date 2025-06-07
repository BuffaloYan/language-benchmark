#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
#include <math.h>

// Function prototypes
void merge_sort(int arr[], int temp[], int left, int right);
void merge(int arr[], int temp[], int left, int mid, int right);
int* load_data(const char* filename, int* count);
bool is_sorted(int arr[], int n);
bool is_prime(int n);
int count_primes(int arr[], int n);

void merge_sort(int arr[], int temp[], int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        
        merge_sort(arr, temp, left, mid);
        merge_sort(arr, temp, mid + 1, right);
        merge(arr, temp, left, mid, right);
    }
}

void merge(int arr[], int temp[], int left, int mid, int right) {
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

int* load_data(const char* filename, int* count) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        printf("Error: Could not open file %s\n", filename);
        return NULL;
    }
    
    // Get file size to estimate capacity
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    // Allocate initial buffer - estimate based on file size
    int capacity = file_size / 6; // rough estimate of numbers per byte
    int* numbers = malloc(capacity * sizeof(int));
    if (!numbers) {
        printf("Error: Memory allocation failed\n");
        fclose(file);
        return NULL;
    }
    
    char* line = NULL;
    size_t len = 0;
    *count = 0;
    
    // Read the CSV line
    if (getline(&line, &len, file) != -1) {
        char* token = strtok(line, ",");
        while (token != NULL) {
            // Resize array if needed
            if (*count >= capacity) {
                capacity *= 2;
                numbers = realloc(numbers, capacity * sizeof(int));
                if (!numbers) {
                    printf("Error: Memory reallocation failed\n");
                    free(line);
                    fclose(file);
                    return NULL;
                }
            }
            
            numbers[*count] = atoi(token);
            (*count)++;
            token = strtok(NULL, ",");
        }
    }
    
    free(line);
    fclose(file);
    
    // Resize to exact size
    numbers = realloc(numbers, (*count) * sizeof(int));
    return numbers;
}

bool is_sorted(int arr[], int n) {
    for (int i = 1; i < n; i++) {
        if (arr[i-1] > arr[i]) {
            return false;
        }
    }
    return true;
}

bool is_prime(int n) {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;
    
    // Check odd divisors up to sqrt(n)
    for (int i = 3; i * i <= n; i += 2) {
        if (n % i == 0) return false;
    }
    return true;
}

int count_primes(int arr[], int n) {
    int count = 0;
    for (int i = 0; i < n; i++) {
        if (is_prime(arr[i])) {
            count++;
        }
    }
    return count;
}

int main(int argc, char* argv[]) {
    const char* filename = (argc > 1) ? argv[1] : "test_data.csv";
    
    printf("Loading data...\n");
    int count;
    int* numbers = load_data(filename, &count);
    if (!numbers) {
        return 1;
    }
    printf("Loaded %d numbers\n", count);
    
    // Create a copy for sorting
    int* sort_array = malloc(count * sizeof(int));
    int* temp_array = malloc(count * sizeof(int));
    if (!sort_array || !temp_array) {
        printf("Error: Memory allocation failed for sorting arrays\n");
        free(numbers);
        return 1;
    }
    
    memcpy(sort_array, numbers, count * sizeof(int));
    
    // Time the sorting
    printf("Starting merge sort...\n");
    clock_t sort_start = clock();
    merge_sort(sort_array, temp_array, 0, count - 1);
    clock_t sort_end = clock();
    
    double sort_time = ((double)(sort_end - sort_start)) / CLOCKS_PER_SEC;
    printf("C merge sort completed in %.4f seconds\n", sort_time);
    
    // Verify sorting is correct
    bool sorted = is_sorted(sort_array, count);
    printf("Sorting verified: %s\n", sorted ? "true" : "false");
    
    // Count prime numbers
    printf("Counting prime numbers...\n");
    clock_t prime_start = clock();
    int prime_count = count_primes(sort_array, count);
    clock_t prime_end = clock();
    
    double prime_time = ((double)(prime_end - prime_start)) / CLOCKS_PER_SEC;
    double total_time = sort_time + prime_time;
    
    printf("Prime counting completed in %.4f seconds\n", prime_time);
    printf("Found %d prime numbers\n", prime_count);
    printf("Total execution time: %.4f seconds\n", total_time);
    
    // Cleanup
    free(numbers);
    free(sort_array);
    free(temp_array);
    
    return 0;
} 