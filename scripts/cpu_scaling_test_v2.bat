@echo off
setlocal enabledelayedexpansion

REM Enhanced CPU Scaling Test Script v3 - Windows Version
REM Fixed version using correct Docker syntax and data file mounting

echo [CPU-SCALING-V3] Enhanced Language Benchmark CPU Scaling Test
echo =============================================================

REM Test configuration
set DOCKER_IMAGE=language-benchmark
set TIMEOUT=600

REM Create results directories
if not exist "results\cpu-scaling-v3" mkdir "results\cpu-scaling-v3"
if not exist "results\cpu-scaling-v3\0.5cpu" mkdir "results\cpu-scaling-v3\0.5cpu"
if not exist "results\cpu-scaling-v3\1cpu" mkdir "results\cpu-scaling-v3\1cpu"
if not exist "results\cpu-scaling-v3\2cpu" mkdir "results\cpu-scaling-v3\2cpu"
if not exist "results\cpu-scaling-v3\4cpu" mkdir "results\cpu-scaling-v3\4cpu"
if not exist "results\cpu-scaling-v3\6cpu" mkdir "results\cpu-scaling-v3\6cpu"
if not exist "results\cpu-scaling-v3\8cpu" mkdir "results\cpu-scaling-v3\8cpu"

REM Build Docker image if it doesn't exist
docker image inspect %DOCKER_IMAGE% >nul 2>&1
if errorlevel 1 (
    echo [BUILD] Building Docker image...
    docker build -f cloud/Dockerfile -t %DOCKER_IMAGE% .
    if errorlevel 1 (
        echo [ERROR] Failed to build Docker image
        exit /b 1
    )
)

REM Get CPU core count for Windows
for /f "tokens=2 delims==" %%i in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set CPU_CORES=%%i

REM Test configurations with proper core limiting
echo [INFO] Available CPU cores on host: %CPU_CORES%
echo [INFO] Running tests with progressively more cores...

echo.
echo [TEST] Running with 0.5 CPU core...
echo        CPU set: 0
echo        CPU limit: 0.5
docker run --cpuset-cpus="0" --cpus="0.5" --memory="4g" --rm -v "%cd%/results:/benchmark/results" -v "%cd%/test_data.csv:/benchmark/test_data.csv:ro" %DOCKER_IMAGE% sh -c "cd /benchmark && python3 parallel_comparison.py --size 10000000 --data-file test_data.csv && cp results/parallel_comparison_results.json results/cpu-scaling-v3/0.5cpu/"
if errorlevel 1 (
    echo [ERROR] 0.5 CPU cores test failed with exit code %errorlevel%
) else (
    echo [SUCCESS] 0.5 CPU core test completed
)

echo.
echo [TEST] Running with 1 CPU core...
echo        CPU set: 0
echo        CPU limit: 1
docker run --cpuset-cpus="0" --cpus="1" --memory="4g" --rm -v "%cd%/results:/benchmark/results" -v "%cd%/test_data.csv:/benchmark/test_data.csv:ro" %DOCKER_IMAGE% sh -c "cd /benchmark && python3 parallel_comparison.py --size 10000000 --data-file test_data.csv && cp results/parallel_comparison_results.json results/cpu-scaling-v3/1cpu/"
if errorlevel 1 (
    echo [ERROR] 1 CPU core test failed with exit code %errorlevel%
) else (
    echo [SUCCESS] 1 CPU core test completed
)

echo.
echo [TEST] Running with 2 CPU cores...
echo        CPU set: 0-1
echo        CPU limit: 2
docker run --cpuset-cpus="0-1" --cpus="2" --memory="4g" --rm -v "%cd%/results:/benchmark/results" -v "%cd%/test_data.csv:/benchmark/test_data.csv:ro" %DOCKER_IMAGE% sh -c "cd /benchmark && python3 parallel_comparison.py --size 10000000 --data-file test_data.csv && cp results/parallel_comparison_results.json results/cpu-scaling-v3/2cpu/"
if errorlevel 1 (
    echo [ERROR] 2 CPU cores test failed with exit code %errorlevel%
) else (
    echo [SUCCESS] 2 CPU cores test completed
)

echo.
echo [TEST] Running with 4 CPU cores...
echo        CPU set: 0-3
echo        CPU limit: 4
docker run --cpuset-cpus="0-3" --cpus="4" --memory="4g" --rm -v "%cd%/results:/benchmark/results" -v "%cd%/test_data.csv:/benchmark/test_data.csv:ro" %DOCKER_IMAGE% sh -c "cd /benchmark && python3 parallel_comparison.py --size 10000000 --data-file test_data.csv && cp results/parallel_comparison_results.json results/cpu-scaling-v3/4cpu/"
if errorlevel 1 (
    echo [ERROR] 4 CPU cores test failed with exit code %errorlevel%
) else (
    echo [SUCCESS] 4 CPU cores test completed
)

echo.
echo [TEST] Running with 6 CPU cores...
echo        CPU set: 0-5
echo        CPU limit: 6
docker run --cpuset-cpus="0-5" --cpus="6" --memory="4g" --rm -v "%cd%/results:/benchmark/results" -v "%cd%/test_data.csv:/benchmark/test_data.csv:ro" %DOCKER_IMAGE% sh -c "cd /benchmark && python3 parallel_comparison.py --size 10000000 --data-file test_data.csv && cp results/parallel_comparison_results.json results/cpu-scaling-v3/6cpu/"
if errorlevel 1 (
    echo [ERROR] 6 CPU cores test failed with exit code %errorlevel%
) else (
    echo [SUCCESS] 6 CPU cores test completed
)

echo.
echo [TEST] Running with 8 CPU cores...
echo        CPU set: 0-7
echo        CPU limit: 8
docker run --cpuset-cpus="0-7" --cpus="8" --memory="4g" --rm -v "%cd%/results:/benchmark/results" -v "%cd%/test_data.csv:/benchmark/test_data.csv:ro" %DOCKER_IMAGE% sh -c "cd /benchmark && python3 parallel_comparison.py --size 10000000 --data-file test_data.csv && cp results/parallel_comparison_results.json results/cpu-scaling-v3/8cpu/"
if errorlevel 1 (
    echo [ERROR] 8 CPU cores test failed with exit code %errorlevel%
) else (
    echo [SUCCESS] 8 CPU cores test completed
)

echo.
echo [COMPLETE] CPU scaling tests completed!
echo [RESULTS] Check results\cpu-scaling-v3\ for detailed results

REM Generate analysis report
echo.
echo [ANALYSIS] Generating CPU scaling analysis...

REM Create Python analysis script
echo import json > temp_analysis.py
echo import os >> temp_analysis.py
echo from datetime import datetime >> temp_analysis.py
echo. >> temp_analysis.py
echo print('\\n' + '='*80) >> temp_analysis.py
echo print('CPU SCALING ANALYSIS REPORT - v3') >> temp_analysis.py
echo print('='*80) >> temp_analysis.py
echo. >> temp_analysis.py
echo configs = ['0.5cpu', '1cpu', '2cpu', '4cpu', '6cpu', '8cpu'] >> temp_analysis.py
echo implementations = [ >> temp_analysis.py
echo     'Java Fork-Join', 'C pthreads', 'Rust Rayon', >> temp_analysis.py
echo     'JavaScript SharedArrayBuffer', 'JavaScript Workers', 'Go Parallel' >> temp_analysis.py
echo ] >> temp_analysis.py
echo. >> temp_analysis.py
echo # Load results from all configurations >> temp_analysis.py
echo all_results = {} >> temp_analysis.py
echo for config in configs: >> temp_analysis.py
echo     try: >> temp_analysis.py
echo         with open(f'results/cpu-scaling-v3/{config}/parallel_comparison_results.json', 'r') as f: >> temp_analysis.py
echo             data = json.load(f) >> temp_analysis.py
echo             all_results[config] = data['results'] >> temp_analysis.py
echo         print(f'[LOADED] Results for {config}') >> temp_analysis.py
echo     except Exception as e: >> temp_analysis.py
echo         print(f'[ERROR] Could not load results for {config}: {e}') >> temp_analysis.py
echo         all_results[config] = {} >> temp_analysis.py
echo. >> temp_analysis.py
echo # Performance comparison table >> temp_analysis.py
echo print(f'\\nEXECUTION TIME COMPARISON (seconds)') >> temp_analysis.py
echo print('-' * 100) >> temp_analysis.py
echo header = f'{"CPU Config":^12}' >> temp_analysis.py
echo for impl in implementations[:5]:  # First 5 implementations >> temp_analysis.py
echo     header += f'{impl:^16}' >> temp_analysis.py
echo print(header) >> temp_analysis.py
echo print('-' * 100) >> temp_analysis.py
echo. >> temp_analysis.py
echo for config in configs: >> temp_analysis.py
echo     results = all_results.get(config, {}) >> temp_analysis.py
echo     row = f'{config:^12}' >> temp_analysis.py
echo     >> temp_analysis.py
echo     for impl in implementations[:5]: >> temp_analysis.py
echo         if impl in results and results[impl].get('success'): >> temp_analysis.py
echo             exec_time = results[impl]['execution_time'] >> temp_analysis.py
echo             row += f'{exec_time:^12.4f}    ' >> temp_analysis.py
echo         else: >> temp_analysis.py
echo             row += f'{"FAILED":^12}    ' >> temp_analysis.py
echo     >> temp_analysis.py
echo     print(row) >> temp_analysis.py
echo. >> temp_analysis.py
echo # Find best performers >> temp_analysis.py
echo print(f'\\nBEST PERFORMANCE BY IMPLEMENTATION') >> temp_analysis.py
echo print('-' * 70) >> temp_analysis.py
echo. >> temp_analysis.py
echo for impl in implementations: >> temp_analysis.py
echo     best_time = float('inf') >> temp_analysis.py
echo     best_config = 'None' >> temp_analysis.py
echo     baseline_time = 0 >> temp_analysis.py
echo     >> temp_analysis.py
echo     # Find baseline (0.5cpu) and best performance >> temp_analysis.py
echo     for config in configs: >> temp_analysis.py
echo         results = all_results.get(config, {}) >> temp_analysis.py
echo         if impl in results and results[impl].get('success'): >> temp_analysis.py
echo             exec_time = results[impl]['execution_time'] >> temp_analysis.py
echo             >> temp_analysis.py
echo             if config == '0.5cpu': >> temp_analysis.py
echo                 baseline_time = exec_time >> temp_analysis.py
echo             >> temp_analysis.py
echo             if exec_time ^< best_time: >> temp_analysis.py
echo                 best_time = exec_time >> temp_analysis.py
echo                 best_config = config >> temp_analysis.py
echo     >> temp_analysis.py
echo     if best_time ^< float('inf'): >> temp_analysis.py
echo         improvement = baseline_time / best_time if baseline_time ^> 0 else 1 >> temp_analysis.py
echo         print(f'{impl:^30}: {best_time:^8.4f}s @ {best_config:^8} ({improvement:^5.1f}x improvement)') >> temp_analysis.py
echo. >> temp_analysis.py
echo # Save detailed analysis >> temp_analysis.py
echo analysis_data = { >> temp_analysis.py
echo     'timestamp': datetime.now().isoformat(), >> temp_analysis.py
echo     'test_type': 'cpu_scaling_v3_fixed_windows', >> temp_analysis.py
echo     'configurations': configs, >> temp_analysis.py
echo     'implementations': implementations, >> temp_analysis.py
echo     'results': all_results, >> temp_analysis.py
echo     'host_cpu_cores': '%CPU_CORES%' >> temp_analysis.py
echo } >> temp_analysis.py
echo. >> temp_analysis.py
echo if not os.path.exists('results/cpu-scaling-v3'): >> temp_analysis.py
echo     os.makedirs('results/cpu-scaling-v3') >> temp_analysis.py
echo with open('results/cpu-scaling-v3/scaling_analysis.json', 'w') as f: >> temp_analysis.py
echo     json.dump(analysis_data, f, indent=2) >> temp_analysis.py
echo. >> temp_analysis.py
echo print(f'\\n[SAVED] Analysis saved to: results/cpu-scaling-v3/scaling_analysis.json') >> temp_analysis.py

REM Run the analysis
python temp_analysis.py

REM Clean up temporary file
del temp_analysis.py

echo.
echo [COMPLETE] Enhanced CPU scaling analysis complete!
echo [INFO] Used correct Docker syntax with --cpuset-cpus and --cpus
echo [INFO] Mounted test_data.csv properly into container
echo [INFO] Windows batch version completed successfully

pause 