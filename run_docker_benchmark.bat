@echo off
REM Docker Benchmark Runner Script for Windows
REM Usage: run_docker_benchmark.bat [DATA_SIZE] [DATA_FILE]
REM Example: run_docker_benchmark.bat 5000000 my_test_data.csv

set DATA_SIZE=%1
set DATA_FILE=%2
set IMAGE_NAME=language-benchmark
set RESULTS_DIR=.\results

REM Set defaults if not provided
if "%DATA_SIZE%"=="" set DATA_SIZE=10000000
if "%DATA_FILE%"=="" set DATA_FILE=test_data.csv

echo ===========================================
echo Language Benchmark Docker Runner
echo ===========================================
echo Data Size: %DATA_SIZE%
echo Data File: %DATA_FILE%
echo Image: %IMAGE_NAME%
echo.

REM Create results directory if it doesn't exist
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

REM Check if image exists
docker image inspect %IMAGE_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo [BUILD] Docker image '%IMAGE_NAME%' not found. Building...
    docker build -t %IMAGE_NAME% -f cloud/Dockerfile .
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to build Docker image
        pause
        exit /b 1
    )
    echo [SUCCESS] Docker image built successfully
    echo.
)

echo [RUN] Starting benchmark container with data size: %DATA_SIZE%
echo ======================================================

REM Run the benchmark container with volume mount for results
docker run --rm -v "%cd%/results:/benchmark/results" %IMAGE_NAME% /benchmark/scripts/run_all_benchmarks.sh %DATA_SIZE% %DATA_FILE%

REM Check if results were generated
if exist "%RESULTS_DIR%\benchmark_results.json" (
    echo.
    echo [SUCCESS] Benchmark completed! Results available in:
    echo   - %RESULTS_DIR%\benchmark_results.json (sequential results^)
    echo   - %RESULTS_DIR%\benchmark_report.txt (sequential report^)
    if exist "%RESULTS_DIR%\parallel_comparison_results.json" (
        echo   - %RESULTS_DIR%\parallel_comparison_results.json (parallel results^)
        echo   - %RESULTS_DIR%\parallel_comparison_report.txt (parallel report^)
    )
) else (
    echo.
    echo [WARNING] No results file found. Check the container logs above for errors.
)

echo.
echo [COMPLETE] Docker benchmark finished!
pause 