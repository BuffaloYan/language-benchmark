#!/usr/bin/env python3
import subprocess
import time
import os
import json
from datetime import datetime
import multiprocessing
import argparse
import sys

def get_system_info():
    """Get system information for context"""
    return {
        'cpu_cores': multiprocessing.cpu_count(),
        'platform': os.uname().sysname if hasattr(os, 'uname') else 'Unknown',
        'python_version': '.'.join(map(str, os.sys.version_info[:3]))
    }

def run_implementation(name, command, timeout=300):
    """Run a single parallel implementation"""
    print(f"\n{'='*60}")
    print(f"[RUNNING] {name}")
    print('='*60)
    
    try:
        start_wall = time.time()
        result = subprocess.run(command, capture_output=True, text=True, timeout=timeout, encoding='utf-8', errors='replace')
        end_wall = time.time()
        
        wall_time = end_wall - start_wall
        
        if result.returncode == 0:
            print(result.stdout)
            
            # Extract execution time and other metrics
            execution_time = extract_execution_time(result.stdout)
            parallelism_info = extract_parallelism_info(result.stdout)
            
            return {
                'success': True,
                'execution_time': execution_time,
                'wall_time': wall_time,
                'stdout': result.stdout,
                'parallelism_info': parallelism_info
            }
        else:
            print(f"[ERROR] {name} failed:")
            print(result.stderr)
            return {
                'success': False,
                'error': result.stderr,
                'wall_time': wall_time
            }
            
    except subprocess.TimeoutExpired:
        print(f"[TIMEOUT] {name} timed out after {timeout}s")
        return {'success': False, 'error': 'Timeout', 'timeout': timeout}
    except FileNotFoundError as e:
        print(f"[ERROR] {name} runtime not found: {e}")
        return {'success': False, 'error': f'Runtime not found: {e}'}

def extract_execution_time(output):
    """Extract total execution time from output"""
    if output is None:
        return 0.0
    lines = output.strip().split('\n')
    
    # Look for total execution time first
    for line in lines:
        if 'total execution time' in line.lower():
            try:
                parts = line.split()
                for i, part in enumerate(parts):
                    if 'seconds' in part.lower() and i > 0:
                        return float(parts[i-1])
            except (ValueError, IndexError):
                continue
    
    # Fallback to any "completed in" line
    for line in lines:
        if 'completed in' in line.lower():
            try:
                parts = line.split()
                for i, part in enumerate(parts):
                    if 'seconds' in part.lower() and i > 0:
                        return float(parts[i-1])
            except (ValueError, IndexError):
                continue
    return 0.0

def extract_parallelism_info(output):
    """Extract parallelism information from output"""
    info = {}
    if output is None:
        return info
    lines = output.strip().split('\n')
    
    for line in lines:
        line_lower = line.lower()
        if 'processors:' in line_lower or 'cores:' in line_lower:
            try:
                info['cores'] = int(line.split(':')[1].strip())
            except:
                pass
        elif 'workers:' in line_lower or 'pool size:' in line_lower:
            try:
                info['workers'] = int(line.split(':')[1].strip())
            except:
                pass
        elif 'parallelism:' in line_lower:
            try:
                info['parallelism'] = int(line.split(':')[1].strip())
            except:
                pass
        elif 'steal count:' in line_lower:
            try:
                info['steal_count'] = int(line.split(':')[1].strip())
            except:
                pass
    
    return info

def compile_java():
    """Compile Java parallel implementation"""
    print("[COMPILE] Compiling Java parallel implementation...")
    try:
        # Compile both implementations
        for java_file in ["java/MergeSort.java", "java/ParallelMergeSort.java"]:
            result = subprocess.run(
                ["javac", "-encoding", "UTF-8", "-cp", "java", java_file], 
                capture_output=True, text=True, timeout=30, encoding='utf-8', errors='replace'
            )
            if result.returncode != 0:
                print(f"[ERROR] Java compilation failed for {java_file}: {result.stderr}")
                return False
        
        print("[SUCCESS] Java compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("[ERROR] Java compiler not found or compilation timeout")
        return False

def compile_go():
    """Compile Go implementations"""
    print("[COMPILE] Compiling Go implementations...")
    try:
        # Compile original Go implementation
        result = subprocess.run(
            ["go", "build", "-o", "go/mergesort_go", "go/mergesort.go"], 
            capture_output=True, text=True, timeout=30, encoding='utf-8', errors='replace'
        )
        if result.returncode != 0:
            print(f"[ERROR] Go (original) compilation failed: {result.stderr}")
            return False
        
        # Compile optimized Go implementation
        result = subprocess.run(
            ["go", "build", "-o", "go/mergesort_go_optimized", "go/mergesort_optimized.go"], 
            capture_output=True, text=True, timeout=30, encoding='utf-8', errors='replace'
        )
        if result.returncode != 0:
            print(f"[ERROR] Go (optimized) compilation failed: {result.stderr}")
            return False
        
        print("[SUCCESS] Go compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("[ERROR] Go compiler not found or compilation timeout")
        return False

def compile_c():
    """Compile C implementations"""
    print("[COMPILE] Compiling C implementations...")
    try:
        # Compile sequential implementation
        result = subprocess.run(
            ["gcc", "-O3", "-o", "c/mergesort_c", "c/mergesort.c"], 
            capture_output=True, text=True, timeout=30, encoding='utf-8', errors='replace'
        )
        if result.returncode != 0:
            print(f"[ERROR] C sequential compilation failed: {result.stderr}")
            return False
        
        # Compile parallel implementation with pthread
        result = subprocess.run(
            ["gcc", "-O3", "-pthread", "-o", "c/parallel_mergesort_c", "c/parallel_mergesort.c", "-lm"], 
            capture_output=True, text=True, timeout=30, encoding='utf-8', errors='replace'
        )
        if result.returncode != 0:
            print(f"[ERROR] C parallel compilation failed: {result.stderr}")
            return False
        
        print("[SUCCESS] C compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("[ERROR] C compiler not found or compilation timeout")
        return False

def compile_rust():
    """Compile Rust implementations"""
    print("[COMPILE] Compiling Rust implementations...")
    try:
        # Compile sequential Rust implementation
        result = subprocess.run(
            ["rustc", "-O", "rust/mergesort.rs", "-o", "rust/mergesort_rust"], 
            capture_output=True, text=True, timeout=60, encoding='utf-8', errors='replace'
        )
        if result.returncode != 0:
            print(f"[ERROR] Rust sequential compilation failed: {result.stderr}")
            return False
        
        # Build parallel Rust implementation using Cargo
        result = subprocess.run(
            ["cargo", "build", "--release"], 
            capture_output=True, text=True, timeout=120, cwd="rust", encoding='utf-8', errors='replace'
        )
        if result.returncode != 0:
            print(f"[ERROR] Rust parallel compilation failed: {result.stderr}")
            return False
        
        # Copy the binary to expected location
        import shutil
        shutil.copy("rust/target/release/parallel_mergesort_rust", "rust/parallel_mergesort_rust")
        
        print("[SUCCESS] Rust compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("[ERROR] Rust compiler not found or compilation timeout")
        return False

def generate_parallel_report(results, sys_info, successful_results):
    """Generate a detailed text report of parallel benchmark results"""
    report = []
    report.append("="*80)
    report.append("PARALLEL vs SEQUENTIAL PERFORMANCE COMPARISON REPORT")
    report.append("="*80)
    report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append(f"System Info: {sys_info['platform']} | {sys_info['cpu_cores']} CPU cores | Python {sys_info['python_version']}")
    report.append("")
    
    # Performance summary table
    report.append("PERFORMANCE SUMMARY")
    report.append("-" * 50)
    report.append(f"{'Implementation':<25} {'Exec Time':<12} {'Wall Time':<12} {'Speedup':<10}")
    report.append("-" * 60)
    
    # Sort by execution time
    sorted_results = sorted(
        successful_results.items(), 
        key=lambda x: x[1]['execution_time']
    )
    
    fastest_time = sorted_results[0][1]['execution_time'] if sorted_results else 0
    
    for name, data in sorted_results:
        exec_time = data['execution_time']
        wall_time = data['wall_time']
        speedup = fastest_time / exec_time if exec_time > 0 else 1
        
        report.append(f"{name:<25} {exec_time:>8.2f}s    {wall_time:>8.2f}s    {speedup:>6.2f}x")
    
    report.append("")
    
    # Parallel efficiency analysis
    report.append("PARALLEL EFFICIENCY ANALYSIS")
    report.append("-" * 40)
    
    parallel_results = {k: v for k, v in successful_results.items() if 'parallel' in k.lower() or 'fork' in k.lower() or 'worker' in k.lower() or 'sharedarraybuffer' in k.lower() or 'rayon' in k.lower()}
    sequential_results = {k: v for k, v in successful_results.items() if 'sequential' in k.lower()}
    
    # Java analysis
    java_parallel = next((k for k in parallel_results.keys() if 'Java' in k), None)
    java_sequential = next((k for k in sequential_results.keys() if 'Java' in k), None)
    
    if java_parallel and java_sequential:
        parallel_time = parallel_results[java_parallel]['execution_time']
        sequential_time = sequential_results[java_sequential]['execution_time']
        speedup = sequential_time / parallel_time
        efficiency = speedup / sys_info['cpu_cores'] * 100
        
        report.append("Java Fork-Join Framework:")
        report.append(f"  Sequential: {sequential_time:.2f}s")
        report.append(f"  Parallel:   {parallel_time:.2f}s")
        report.append(f"  Speedup:    {speedup:.2f}x")
        report.append(f"  Efficiency: {efficiency:.1f}%")
        report.append("")
    
    # C analysis
    c_parallel = next((k for k in parallel_results.keys() if 'C' in k), None)
    c_sequential = next((k for k in sequential_results.keys() if 'C' in k), None)
    
    if c_parallel and c_sequential:
        parallel_time = parallel_results[c_parallel]['execution_time']
        sequential_time = sequential_results[c_sequential]['execution_time']
        speedup = sequential_time / parallel_time
        efficiency = speedup / sys_info['cpu_cores'] * 100
        
        report.append("C pthreads:")
        report.append(f"  Sequential: {sequential_time:.2f}s")
        report.append(f"  Parallel:   {parallel_time:.2f}s")
        report.append(f"  Speedup:    {speedup:.2f}x")
        report.append(f"  Efficiency: {efficiency:.1f}%")
        report.append("")
    
    # Rust analysis
    rust_parallel = next((k for k in parallel_results.keys() if 'Rust' in k), None)
    rust_sequential = next((k for k in sequential_results.keys() if 'Rust' in k), None)
    
    if rust_parallel and rust_sequential:
        parallel_time = parallel_results[rust_parallel]['execution_time']
        sequential_time = sequential_results[rust_sequential]['execution_time']
        speedup = sequential_time / parallel_time
        efficiency = speedup / sys_info['cpu_cores'] * 100
        
        report.append("Rust Rayon:")
        report.append(f"  Sequential: {sequential_time:.2f}s")
        report.append(f"  Parallel:   {parallel_time:.2f}s")
        report.append(f"  Speedup:    {speedup:.2f}x")
        report.append(f"  Efficiency: {efficiency:.1f}%")
        report.append("")
    
    # Go algorithm comparison (single-threaded implementations)
    go_original = next((k for k in successful_results.keys() if 'Go (original)' in k), None)
    go_optimized = next((k for k in successful_results.keys() if 'Go (optimized)' in k), None)
    
    if go_original and go_optimized:
        original_time = successful_results[go_original]['execution_time']
        optimized_time = successful_results[go_optimized]['execution_time']
        
        if original_time > 0 and optimized_time > 0:
            improvement = (original_time - optimized_time) / original_time * 100
            speedup = original_time / optimized_time
            
            report.append("Go Algorithm Comparison (Single-threaded):")
            report.append(f"  Original:   {original_time:.2f}s (allocating approach)")
            report.append(f"  Optimized:  {optimized_time:.2f}s (in-place approach)")
            report.append(f"  Improvement: {improvement:.1f}% ({speedup:.2f}x speedup)")
            report.append("")
        else:
            report.append("Go Algorithm Comparison: Unable to compare (invalid execution times)")
            report.append("")
    
    # JavaScript analysis (compare different parallel approaches)
    js_sequential = next((k for k in sequential_results.keys() if 'JavaScript' in k), None)
    js_workers = next((k for k in parallel_results.keys() if 'Workers' in k), None)
    js_shared = next((k for k in parallel_results.keys() if 'SharedArrayBuffer' in k), None)
    
    if js_sequential:
        sequential_time = sequential_results[js_sequential]['execution_time']
        report.append("JavaScript Parallel Approaches:")
        report.append(f"  Sequential: {sequential_time:.2f}s")
        
        if js_workers:
            workers_time = parallel_results[js_workers]['execution_time']
            workers_speedup = sequential_time / workers_time
            workers_efficiency = workers_speedup / sys_info['cpu_cores'] * 100
            report.append(f"  Workers:    {workers_time:.2f}s (speedup: {workers_speedup:.2f}x, efficiency: {workers_efficiency:.1f}%)")
        
        if js_shared:
            shared_time = parallel_results[js_shared]['execution_time']
            shared_speedup = sequential_time / shared_time
            shared_efficiency = shared_speedup / sys_info['cpu_cores'] * 100
            report.append(f"  SharedArrayBuffer: {shared_time:.2f}s (speedup: {shared_speedup:.2f}x, efficiency: {shared_efficiency:.1f}%)")
        
        report.append("")
    
    # Detailed results section
    report.append("DETAILED RESULTS")
    report.append("-" * 20)
    
    for name, data in results.items():
        report.append(f"\n{name}:")
        if data.get('success', False):
            report.append(f"  Status: SUCCESS")
            report.append(f"  Execution Time: {data['execution_time']:.3f}s")
            report.append(f"  Wall Time: {data['wall_time']:.3f}s")
            if data.get('parallelism_info'):
                for key, value in data['parallelism_info'].items():
                    report.append(f"  {key.title()}: {value}")
        else:
            report.append(f"  Status: FAILED")
            if 'error' in data:
                report.append(f"  Error: {data['error']}")
            if 'timeout' in data:
                report.append(f"  Timeout: {data['timeout']}s")
    
    report.append("")
    report.append("="*80)
    report.append("END OF REPORT")
    report.append("="*80)
    
    return '\n'.join(report)

def main():
    parser = argparse.ArgumentParser(description='Multi-language parallel performance comparison')
    parser.add_argument('--size', type=int, default=10000000, help='Size of data to sort (default: 10000000)')
    parser.add_argument('--data-file', type=str, default='test_data.csv', help='Data file to use (default: test_data.csv)')
    args = parser.parse_args()
    
    print(f"[INIT] Parallel Benchmark Suite")
    print(f"[INIT] Data size: {args.size}")
    print(f"[INIT] Data file: {args.data_file}")
    
    # Get system information
    sys_info = get_system_info()
    print(f"[SYSTEM] Platform: {sys_info['platform']}")
    print(f"[SYSTEM] CPU cores: {sys_info['cpu_cores']}")
    print(f"[SYSTEM] Python version: {sys_info['python_version']}")
    
    # Create results directory
    os.makedirs("results", exist_ok=True)
    
    # Compile implementations
    java_enabled = compile_java()
    go_enabled = compile_go()
    c_enabled = compile_c()
    
    if not compile_rust():
        print("[WARNING] Skipping Rust due to compilation failure")
        rust_enabled = False
    else:
        rust_enabled = True
    
    results = {}
    
    # Test configurations
    tests = []
    
    if java_enabled:
        tests.append(("Java Fork-Join", ["java", "-cp", "java", "ParallelMergeSort", args.data_file]))
    
    if c_enabled:
        tests.append(("C pthreads", ["./c/parallel_mergesort_c", args.data_file]))
    
    if rust_enabled:
        # Use appropriate binary for platform
        import platform
        rust_binary = "./rust/parallel_mergesort_rust.exe" if platform.system() == "Windows" else "./rust/parallel_mergesort_rust"
        tests.append(("Rust Rayon", [rust_binary, args.data_file]))
    
    tests.append(("JavaScript Workers", ["node", "javascript/parallel_javascript.js", args.data_file]))
    tests.append(("JavaScript SharedArrayBuffer", ["node", "javascript/parallel_sharedarraybuffer.js", args.data_file]))
    
    # Add sequential versions for comparison
    if java_enabled:
        tests.append(("Java Sequential", ["java", "-cp", "java", "MergeSort", args.data_file]))
    
    if go_enabled:
        tests.append(("Go (original)", ["./go/mergesort_go", args.data_file]))
        tests.append(("Go (optimized)", ["./go/mergesort_go_optimized", args.data_file]))
    
    if c_enabled:
        tests.append(("C Sequential", ["./c/mergesort_c", args.data_file]))
    
    if rust_enabled:
        rust_seq_binary = "./rust/mergesort_rust.exe" if platform.system() == "Windows" else "./rust/mergesort_rust"
        tests.append(("Rust Sequential", [rust_seq_binary, args.data_file]))
    
    tests.append(("JavaScript Sequential", ["node", "javascript/mergesort_optimized.js", args.data_file]))
    
    # Run all tests
    for name, command in tests:
        results[name] = run_implementation(name, command)
    
    # Generate comparison report
    print(f"\n{'='*80}")
    print("[COMPARISON] PARALLEL vs SEQUENTIAL PERFORMANCE COMPARISON")
    print('='*80)
    
    successful_results = {k: v for k, v in results.items() if v.get('success', False)}
    
    if successful_results:
        print(f"{'Implementation':<25} {'Exec Time':<12} {'Wall Time':<12} {'Speedup':<10}")
        print("-" * 70)
        
        # Sort by execution time
        sorted_results = sorted(
            successful_results.items(), 
            key=lambda x: x[1]['execution_time']
        )
        
        fastest_time = sorted_results[0][1]['execution_time'] if sorted_results else 0
        
        for name, data in sorted_results:
            exec_time = data['execution_time']
            wall_time = data['wall_time']
            speedup = fastest_time / exec_time if exec_time > 0 else 1
            
            print(f"{name:<25} {exec_time:>8.2f}s    {wall_time:>8.2f}s    {speedup:>6.2f}x")
        
        # Parallel efficiency analysis
        print(f"\n[ANALYSIS] PARALLEL EFFICIENCY ANALYSIS:")
        print("-" * 40)
        
        parallel_results = {k: v for k, v in successful_results.items() if 'parallel' in k.lower() or 'fork' in k.lower() or 'worker' in k.lower() or 'sharedarraybuffer' in k.lower() or 'rayon' in k.lower()}
        sequential_results = {k: v for k, v in successful_results.items() if 'sequential' in k.lower()}
        
        # Java analysis
        java_parallel = next((k for k in parallel_results.keys() if 'Java' in k), None)
        java_sequential = next((k for k in sequential_results.keys() if 'Java' in k), None)
        
        if java_parallel and java_sequential:
            parallel_time = parallel_results[java_parallel]['execution_time']
            sequential_time = sequential_results[java_sequential]['execution_time']
            speedup = sequential_time / parallel_time
            efficiency = speedup / sys_info['cpu_cores'] * 100
            
            print(f"Java:")
            print(f"  Sequential: {sequential_time:.2f}s")
            print(f"  Parallel:   {parallel_time:.2f}s")
            print(f"  Speedup:    {speedup:.2f}x")
            print(f"  Efficiency: {efficiency:.1f}%")
            print()
        
        # C analysis
        c_parallel = next((k for k in parallel_results.keys() if 'C' in k), None)
        c_sequential = next((k for k in sequential_results.keys() if 'C' in k), None)
        
        if c_parallel and c_sequential:
            parallel_time = parallel_results[c_parallel]['execution_time']
            sequential_time = sequential_results[c_sequential]['execution_time']
            speedup = sequential_time / parallel_time
            efficiency = speedup / sys_info['cpu_cores'] * 100
            
            print(f"C:")
            print(f"  Sequential: {sequential_time:.2f}s")
            print(f"  Parallel:   {parallel_time:.2f}s")
            print(f"  Speedup:    {speedup:.2f}x")
            print(f"  Efficiency: {efficiency:.1f}%")
            print()
        
        # Rust analysis
        rust_parallel = next((k for k in parallel_results.keys() if 'Rust' in k), None)
        rust_sequential = next((k for k in sequential_results.keys() if 'Rust' in k), None)
        
        if rust_parallel and rust_sequential:
            parallel_time = parallel_results[rust_parallel]['execution_time']
            sequential_time = sequential_results[rust_sequential]['execution_time']
            speedup = sequential_time / parallel_time
            efficiency = speedup / sys_info['cpu_cores'] * 100
            
            print(f"Rust:")
            print(f"  Sequential: {sequential_time:.2f}s")
            print(f"  Parallel:   {parallel_time:.2f}s")
            print(f"  Speedup:    {speedup:.2f}x")
            print(f"  Efficiency: {efficiency:.1f}%")
            print()
        
        # Go algorithm comparison (single-threaded implementations)
        go_original = next((k for k in successful_results.keys() if 'Go (original)' in k), None)
        go_optimized = next((k for k in successful_results.keys() if 'Go (optimized)' in k), None)
        
        if go_original and go_optimized:
            original_time = successful_results[go_original]['execution_time']
            optimized_time = successful_results[go_optimized]['execution_time']
            
            if original_time > 0 and optimized_time > 0:
                improvement = (original_time - optimized_time) / original_time * 100
                speedup = original_time / optimized_time
                
                print(f"Go Algorithm Comparison (Single-threaded):")
                print(f"  Original:   {original_time:.2f}s (allocating approach)")
                print(f"  Optimized:  {optimized_time:.2f}s (in-place approach)")
                print(f"  Improvement: {improvement:.1f}% ({speedup:.2f}x speedup)")
                print()
            else:
                print("Go Algorithm Comparison: Unable to compare (invalid execution times)")
                print()
        
        # JavaScript analysis (compare different parallel approaches)
        js_sequential = next((k for k in sequential_results.keys() if 'JavaScript' in k), None)
        js_workers = next((k for k in parallel_results.keys() if 'Workers' in k), None)
        js_shared = next((k for k in parallel_results.keys() if 'SharedArrayBuffer' in k), None)
        
        if js_sequential:
            sequential_time = sequential_results[js_sequential]['execution_time']
            print(f"JavaScript Parallel Approaches:")
            print(f"  Sequential: {sequential_time:.2f}s")
            
            if js_workers:
                workers_time = parallel_results[js_workers]['execution_time']
                workers_speedup = sequential_time / workers_time
                workers_efficiency = workers_speedup / sys_info['cpu_cores'] * 100
                print(f"  Workers:    {workers_time:.2f}s (speedup: {workers_speedup:.2f}x, efficiency: {workers_efficiency:.1f}%)")
            
            if js_shared:
                shared_time = parallel_results[js_shared]['execution_time']
                shared_speedup = sequential_time / shared_time
                shared_efficiency = shared_speedup / sys_info['cpu_cores'] * 100
                print(f"  SharedArrayBuffer: {shared_time:.2f}s (speedup: {shared_speedup:.2f}x, efficiency: {shared_efficiency:.1f}%)")
            
            print()
        
        # Save detailed results
        report_data = {
            'timestamp': datetime.now().isoformat(),
            'system_info': sys_info,
            'results': results
        }
        
        with open('results/parallel_comparison_results.json', 'w') as f:
            json.dump(report_data, f, indent=2)
        
        # Generate and save text report
        text_report = generate_parallel_report(results, sys_info, successful_results)
        with open('results/parallel_comparison_report.txt', 'w', encoding='utf-8') as f:
            f.write(text_report)
        
        print(f"[SAVE] Detailed results saved to: results/parallel_comparison_results.json")
        print(f"[SAVE] Text report saved to: results/parallel_comparison_report.txt")
    
    else:
        print("[ERROR] No implementations completed successfully")

if __name__ == "__main__":
    main() 