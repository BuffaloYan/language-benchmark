@echo off
REM CPU Scaling Test Script for Windows
REM Tests the language benchmark with different CPU core configurations

echo [CPU-SCALING] Language Benchmark CPU Scaling Test
echo ================================================

REM Create results directories
if not exist "results\cpu-scaling\1core" mkdir "results\cpu-scaling\1core"
if not exist "results\cpu-scaling\2core" mkdir "results\cpu-scaling\2core"
if not exist "results\cpu-scaling\4core" mkdir "results\cpu-scaling\4core"
if not exist "results\cpu-scaling\8core" mkdir "results\cpu-scaling\8core"

REM Test with 1 CPU core
echo [TEST] Running with 1 CPU core...
docker run --cpus="1.0" --memory="2g" --rm -v "%cd%\results\cpu-scaling\1core:/benchmark/results" language-benchmark

REM Test with 2 CPU cores
echo [TEST] Running with 2 CPU cores...
docker run --cpus="2.0" --memory="4g" --rm -v "%cd%\results\cpu-scaling\2core:/benchmark/results" language-benchmark

REM Test with 4 CPU cores
echo [TEST] Running with 4 CPU cores...
docker run --cpus="4.0" --memory="8g" --rm -v "%cd%\results\cpu-scaling\4core:/benchmark/results" language-benchmark

REM Test with 8 CPU cores
echo [TEST] Running with 8 CPU cores...
docker run --cpus="8.0" --memory="8g" --rm -v "%cd%\results\cpu-scaling\8core:/benchmark/results" language-benchmark

echo [COMPLETE] CPU scaling tests completed!
echo [RESULTS] Check results\cpu-scaling\ for detailed results

REM Optional: Generate comparison report
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo [ANALYSIS] Generating CPU scaling analysis...
    python -c "import json; import os; cores = ['1core', '2core', '4core', '8core']; print('\nCPU Scaling Analysis:'); print('=' * 50); [print(f'\n{core.upper()} Results:') or [print(f'  Rust Rayon: {result[\"execution_time\"]:.4f}s') for name, result in json.load(open(f'results/cpu-scaling/{core}/parallel_comparison_results.json'))['results'].items() if result.get('success') and 'Rayon' in name][:1] if os.path.exists(f'results/cpu-scaling/{core}/parallel_comparison_results.json') else print(f'  {core}: No results found') for core in cores]"
) else (
    echo [INFO] Python not found, skipping analysis
)

pause 