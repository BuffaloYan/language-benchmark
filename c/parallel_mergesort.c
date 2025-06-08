#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
#include <math.h>
#include <pthread.h>
#include <unistd.h>

#define SEQUENTIAL_THRESHOLD 1000
#define PRIME_THRESHOLD 10000

// Thread pool management
typedef struct {
    int num_threads;
    int max_depth;
} ThreadConfig;

// Merge sort task structure
typedef struct {
    int* array;
    int* temp;
    int left;
    int right;
    int depth;
    ThreadConfig* config;
} MergeSortTask;

// Prime counting task structure
typedef struct {
    int* numbers;
    int start;
    int end;
    int* result;
    int depth;
    ThreadConfig* config;
} PrimeCountTask;

// Function prototypes
void* parallel_merge_sort_worker(void* arg);
void sequential_merge_sort(int arr[], int temp[], int left, int right);
void merge(int arr[], int temp[], int left, int mid, int right);
void* parallel_prime_count_worker(void* arg);
int sequential_prime_count(int arr[], int start, int end);
int* load_data(const char* filename, int* count);
bool is_sorted(int arr[], int n);
bool is_prime(int n);

void* parallel_merge_sort_worker(void* arg) {
    MergeSortTask* task = (MergeSortTask*)arg;
    
    int size = task->right - task->left + 1;
    
    // Use sequential merge sort for small arrays or deep recursion
    if (size <= SEQUENTIAL_THRESHOLD || task->depth >= task->config->max_depth) {
        sequential_merge_sort(task->array, task->temp, task->left, task->right);
        return NULL;
    }
    
    int mid = task->left + (task->right - task->left) / 2;
    
    // Create tasks for left and right halves
    MergeSortTask left_task = {
        .array = task->array,
        .temp = task->temp,
        .left = task->left,
        .right = mid,
        .depth = task->depth + 1,
        .config = task->config
    };
    
    MergeSortTask right_task = {
        .array = task->array,
        .temp = task->temp,
        .left = mid + 1,
        .right = task->right,
        .depth = task->depth + 1,
        .config = task->config
    };
    
    pthread_t left_thread;
    
    // Create thread for left half
    pthread_create(&left_thread, NULL, parallel_merge_sort_worker, &left_task);
    
    // Process right half in current thread
    parallel_merge_sort_worker(&right_task);
    
    // Wait for left thread to complete
    pthread_join(left_thread, NULL);
    
    // Merge the sorted halves
    merge(task->array, task->temp, task->left, mid, task->right);
    
    return NULL;
}

void sequential_merge_sort(int arr[], int temp[], int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        sequential_merge_sort(arr, temp, left, mid);
        sequential_merge_sort(arr, temp, mid + 1, right);
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

void* parallel_prime_count_worker(void* arg) {
    PrimeCountTask* task = (PrimeCountTask*)arg;
    
    int size = task->end - task->start;
    
    // Use sequential counting for small chunks or deep recursion
    if (size <= PRIME_THRESHOLD || task->depth >= task->config->max_depth) {
        *(task->result) = sequential_prime_count(task->numbers, task->start, task->end);
        return NULL;
    }
    
    int mid = task->start + size / 2;
    
    int left_result = 0, right_result = 0;
    
    // Create tasks for left and right halves
    PrimeCountTask left_task = {
        .numbers = task->numbers,
        .start = task->start,
        .end = mid,
        .result = &left_result,
        .depth = task->depth + 1,
        .config = task->config
    };
    
    PrimeCountTask right_task = {
        .numbers = task->numbers,
        .start = mid,
        .end = task->end,
        .result = &right_result,
        .depth = task->depth + 1,
        .config = task->config
    };
    
    pthread_t left_thread;
    
    // Create thread for left half
    pthread_create(&left_thread, NULL, parallel_prime_count_worker, &left_task);
    
    // Process right half in current thread
    parallel_prime_count_worker(&right_task);
    
    // Wait for left thread to complete
    pthread_join(left_thread, NULL);
    
    *(task->result) = left_result + right_result;
    return NULL;
}

int sequential_prime_count(int arr[], int start, int end) {
    int count = 0;
    for (int i = start; i < end; i++) {
        if (is_prime(arr[i])) {
            count++;
        }
    }
    return count;
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

int main(int argc, char* argv[]) {
    const char* filename = (argc > 1) ? argv[1] : "test_data.csv";
    
    // Get number of CPU cores
    int num_cores = (int)sysconf(_SC_NPROCESSORS_ONLN);
    ThreadConfig config = {
        .num_threads = num_cores,
        .max_depth = (int)log2(num_cores) + 2  // Limit recursion depth
    };
    
    printf("🚀 C Parallel Merge Sort + Prime Counting\n");
    printf("=========================================\n");
    printf("Available processors: %d\n", num_cores);
    printf("Max recursion depth: %d\n", config.max_depth);
    printf("Sequential threshold: %d elements\n", SEQUENTIAL_THRESHOLD);
    printf("\n");
    
    printf("📊 Loading data...\n");
    int count;
    int* numbers = load_data(filename, &count);
    if (!numbers) {
        return 1;
    }
    printf("Loaded %d numbers\n", count);
    
    // Create arrays for sorting
    int* sort_array = malloc(count * sizeof(int));
    int* temp_array = malloc(count * sizeof(int));
    if (!sort_array || !temp_array) {
        printf("Error: Memory allocation failed for sorting arrays\n");
        free(numbers);
        return 1;
    }
    
    memcpy(sort_array, numbers, count * sizeof(int));
    
    // Parallel merge sort
    printf("🔄 Starting parallel merge sort...\n");
    struct timespec sort_start, sort_end;
    clock_gettime(CLOCK_MONOTONIC, &sort_start);
    
    MergeSortTask main_task = {
        .array = sort_array,
        .temp = temp_array,
        .left = 0,
        .right = count - 1,
        .depth = 0,
        .config = &config
    };
    
    parallel_merge_sort_worker(&main_task);
    
    clock_gettime(CLOCK_MONOTONIC, &sort_end);
    double sort_time = (sort_end.tv_sec - sort_start.tv_sec) + 
                       (sort_end.tv_nsec - sort_start.tv_nsec) / 1e9;
    
    printf("✅ Parallel merge sort completed in %.4f seconds\n", sort_time);
    
    // Verify sorting
    bool sorted = is_sorted(sort_array, count);
    printf("🔍 Sorting verified: %s\n", sorted ? "true" : "false");
    
    // Parallel prime counting
    printf("🔢 Starting parallel prime counting...\n");
    struct timespec prime_start, prime_end;
    clock_gettime(CLOCK_MONOTONIC, &prime_start);
    
    int prime_result = 0;
    PrimeCountTask prime_task = {
        .numbers = sort_array,
        .start = 0,
        .end = count,
        .result = &prime_result,
        .depth = 0,
        .config = &config
    };
    
    parallel_prime_count_worker(&prime_task);
    
    clock_gettime(CLOCK_MONOTONIC, &prime_end);
    double prime_time = (prime_end.tv_sec - prime_start.tv_sec) + 
                        (prime_end.tv_nsec - prime_start.tv_nsec) / 1e9;
    
    double total_time = sort_time + prime_time;
    
    printf("✅ Parallel prime counting completed in %.4f seconds\n", prime_time);
    printf("📊 Found %d prime numbers\n", prime_result);
    printf("⏱️  Total execution time: %.4f seconds\n", total_time);
    
    // Performance metrics
    printf("\n📈 Performance Analysis:\n");
    printf("- Sort time: %.4f seconds\n", sort_time);
    printf("- Prime time: %.4f seconds\n", prime_time);
    printf("- Total time: %.4f seconds\n", total_time);
    printf("- CPU cores used: %d\n", num_cores);
    
    // Cleanup
    free(numbers);
    free(sort_array);
    free(temp_array);
    
    return 0;
} 