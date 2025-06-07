#!/usr/bin/env python3
import subprocess
import time
import os
import json
from datetime import datetime
import multiprocessing

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
    print(f"🚀 Running {name}")
    print('='*60)
    
    try:
        start_wall = time.time()
        result = subprocess.run(command, capture_output=True, text=True, timeout=timeout)
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
            print(f"❌ {name} failed:")
            print(result.stderr)
            return {
                'success': False,
                'error': result.stderr,
                'wall_time': wall_time
            }
            
    except subprocess.TimeoutExpired:
        print(f"❌ {name} timed out after {timeout}s")
        return {'success': False, 'error': 'Timeout', 'timeout': timeout}
    except FileNotFoundError as e:
        print(f"❌ {name} runtime not found: {e}")
        return {'success': False, 'error': f'Runtime not found: {e}'}

def extract_execution_time(output):
    """Extract total execution time from output"""
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
    print("🔧 Compiling Java parallel implementation...")
    try:
        # Compile both implementations
        for java_file in ["java/MergeSort.java", "java/ParallelMergeSort.java"]:
            result = subprocess.run(
                ["javac", "-encoding", "UTF-8", "-cp", "java", java_file], 
                capture_output=True, text=True, timeout=30
            )
            if result.returncode != 0:
                print(f"❌ Java compilation failed for {java_file}: {result.stderr}")
                return False
        
        print("✅ Java compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("❌ Java compiler not found or compilation timeout")
        return False

def compile_go():
    """Compile Go implementations"""
    print("🔧 Compiling Go implementations...")
    try:
        # Compile original Go implementation
        result = subprocess.run(
            ["go", "build", "-o", "go/mergesort_go", "go/mergesort.go"], 
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"❌ Go (original) compilation failed: {result.stderr}")
            return False
        
        # Compile optimized Go implementation
        result = subprocess.run(
            ["go", "build", "-o", "go/mergesort_go_optimized", "go/mergesort_optimized.go"], 
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"❌ Go (optimized) compilation failed: {result.stderr}")
            return False
        
        print("✅ Go compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("❌ Go compiler not found or compilation timeout")
        return False

def compile_c():
    """Compile C implementations"""
    print("🔧 Compiling C implementations...")
    try:
        # Compile sequential implementation
        result = subprocess.run(
            ["gcc", "-O3", "-o", "c/mergesort_c", "c/mergesort.c"], 
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"❌ C sequential compilation failed: {result.stderr}")
            return False
        
        # Compile parallel implementation with pthread
        result = subprocess.run(
            ["gcc", "-O3", "-pthread", "-o", "c/parallel_mergesort_c", "c/parallel_mergesort.c", "-lm"], 
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"❌ C parallel compilation failed: {result.stderr}")
            return False
        
        print("✅ C compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("❌ C compiler not found or compilation timeout")
        return False

def compile_rust():
    """Compile Rust implementations"""
    print("🔧 Compiling Rust implementations...")
    try:
        # Compile sequential implementation
        result = subprocess.run(
            ["rustc", "-O", "rust/mergesort.rs", "-o", "rust/mergesort_rust"], 
            capture_output=True, text=True, timeout=60
        )
        if result.returncode != 0:
            print(f"❌ Rust sequential compilation failed: {result.stderr}")
            return False
        
        # Compile parallel implementation using cargo
        result = subprocess.run(
            ["cargo", "build", "--release", "--manifest-path", "rust/Cargo.toml"], 
            capture_output=True, text=True, timeout=120
        )
        if result.returncode != 0:
            print(f"❌ Rust parallel compilation failed: {result.stderr}")
            return False
        
        # Copy the built binary to expected location
        import shutil
        shutil.copy2("rust/target/release/parallel_mergesort_rust", "rust/parallel_mergesort_rust")
        
        print("✅ Rust compilation successful")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError):
        print("❌ Rust compiler not found or compilation timeout")
        return False

def main():
    print("🏁 Parallel Programming Language Comparison")
    print("===========================================")
    print("Comparing Java Fork-Join vs JavaScript Worker Threads vs C pthreads vs Rust Rayon")
    print("Including Go single-threaded implementations for algorithm comparison")
    print()
    
    # System info
    sys_info = get_system_info()
    print(f"💻 System: {sys_info['cpu_cores']} CPU cores, {sys_info['platform']}")
    print(f"📊 Test: 10,000,000 integers → sort + prime counting")
    print()
    
    # Check data file
    if not os.path.exists('test_data.csv'):
        print("📁 Generating test data...")
        subprocess.run(['python3', 'python/generate_data.py'], check=True)
    
    # Compile Java
    if not compile_java():
        print("⚠️  Skipping Java due to compilation failure")
        java_enabled = False
    else:
        java_enabled = True
    
    # Compile Go
    if not compile_go():
        print("⚠️  Skipping Go due to compilation failure")
        go_enabled = False
    else:
        go_enabled = True
    
    # Compile C
    if not compile_c():
        print("⚠️  Skipping C due to compilation failure")
        c_enabled = False
    else:
        c_enabled = True
    
    # Compile Rust
    if not compile_rust():
        print("⚠️  Skipping Rust due to compilation failure")
        rust_enabled = False
    else:
        rust_enabled = True
    
    results = {}
    
    # Test configurations
    tests = []
    
    if java_enabled:
        tests.append(("Java Fork-Join", ["java", "-cp", "java", "ParallelMergeSort", "test_data.csv"]))
    
    if c_enabled:
        tests.append(("C pthreads", ["./c/parallel_mergesort_c", "test_data.csv"]))
    
    if rust_enabled:
        tests.append(("Rust Rayon", ["./rust/parallel_mergesort_rust", "test_data.csv"]))
    
    tests.append(("JavaScript Workers", ["node", "javascript/parallel_javascript.js", "test_data.csv"]))
    tests.append(("JavaScript SharedArrayBuffer", ["node", "javascript/parallel_sharedarraybuffer.js", "test_data.csv"]))
    
    # Add sequential versions for comparison
    if java_enabled:
        tests.append(("Java Sequential", ["java", "-cp", "java", "MergeSort", "test_data.csv"]))
    
    if go_enabled:
        tests.append(("Go (original)", ["./go/mergesort_go", "test_data.csv"]))
        tests.append(("Go (optimized)", ["./go/mergesort_go_optimized", "test_data.csv"]))
    
    if c_enabled:
        tests.append(("C Sequential", ["./c/mergesort_c", "test_data.csv"]))
    
    if rust_enabled:
        tests.append(("Rust Sequential", ["./rust/mergesort_rust", "test_data.csv"]))
    
    tests.append(("JavaScript Sequential", ["node", "javascript/mergesort_javascript.js", "test_data.csv"]))
    
    # Run all tests
    for name, command in tests:
        results[name] = run_implementation(name, command)
    
    # Generate comparison report
    print(f"\n{'='*80}")
    print("📊 PARALLEL vs SEQUENTIAL PERFORMANCE COMPARISON")
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
        print(f"\n📈 PARALLEL EFFICIENCY ANALYSIS:")
        print("-" * 40)
        
        parallel_results = {k: v for k, v in successful_results.items() if 'parallel' in k.lower() or 'fork' in k.lower() or 'worker' in k.lower() or 'sharedarraybuffer' in k.lower()}
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
            improvement = (original_time - optimized_time) / original_time * 100
            speedup = original_time / optimized_time
            
            print(f"Go Algorithm Comparison (Single-threaded):")
            print(f"  Original:   {original_time:.2f}s (allocating approach)")
            print(f"  Optimized:  {optimized_time:.2f}s (in-place approach)")
            print(f"  Improvement: {improvement:.1f}% ({speedup:.2f}x speedup)")
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
        os.makedirs("results", exist_ok=True)
        report_data = {
            'timestamp': datetime.now().isoformat(),
            'system_info': sys_info,
            'results': results
        }
        
        with open('results/parallel_comparison_results.json', 'w') as f:
            json.dump(report_data, f, indent=2)
        
        print(f"💾 Detailed results saved to: results/parallel_comparison_results.json")
    
    else:
        print("❌ No implementations completed successfully")

if __name__ == "__main__":
    main() 