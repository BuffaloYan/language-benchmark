#!/bin/bash

# Docker Benchmark Runner Script
# Usage: ./run_docker_benchmark.sh [DATA_SIZE] [DATA_FILE]
# Example: ./run_docker_benchmark.sh 5000000 my_test_data.csv

DATA_SIZE="${1:-10000000}"  # Default to 10 million if not specified
DATA_FILE="${2:-test_data.csv}"  # Default filename
IMAGE_NAME="language-benchmark"
RESULTS_DIR="./results"

echo "==========================================="
echo "Language Benchmark Docker Runner"
echo "==========================================="
echo "Data Size: ${DATA_SIZE}"
echo "Data File: ${DATA_FILE}"
echo "Image: ${IMAGE_NAME}"
echo ""

# Create results directory if it doesn't exist
mkdir -p "${RESULTS_DIR}"

# Check if image exists
if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    echo "[BUILD] Docker image '${IMAGE_NAME}' not found. Building..."
    docker build -t "${IMAGE_NAME}" -f cloud/Dockerfile .
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to build Docker image"
        exit 1
    fi
    echo "[SUCCESS] Docker image built successfully"
    echo ""
fi

echo "[RUN] Starting benchmark container with data size: ${DATA_SIZE}"
echo "======================================================"

# Run the benchmark container with volume mount for results
docker run --rm \
    -v "${PWD}/results:/benchmark/results" \
    "${IMAGE_NAME}" \
    /benchmark/scripts/run_all_benchmarks.sh "${DATA_SIZE}" "${DATA_FILE}"

# Check if results were generated
if [ -f "${RESULTS_DIR}/benchmark_results.json" ]; then
    echo ""
    echo "[SUCCESS] Benchmark completed! Results available in:"
    echo "  - ${RESULTS_DIR}/benchmark_results.json (sequential results)"
    echo "  - ${RESULTS_DIR}/benchmark_report.txt (sequential report)"
    if [ -f "${RESULTS_DIR}/parallel_comparison_results.json" ]; then
        echo "  - ${RESULTS_DIR}/parallel_comparison_results.json (parallel results)"
        echo "  - ${RESULTS_DIR}/parallel_comparison_report.txt (parallel report)"
    fi
else
    echo ""
    echo "[WARNING] No results file found. Check the container logs above for errors."
fi

echo ""
echo "[COMPLETE] Docker benchmark finished!" 