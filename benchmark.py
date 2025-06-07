#!/usr/bin/env python3
import subprocess
import time
import os
import json
from datetime import datetime
import sys

class LanguageBenchmark:
    def __init__(self):
        self.results = {}
        self.data_file = "test_data.csv"
        
    def ensure_data_exists(self):
        """Generate test data if it doesn't exist"""
        if not os.path.exists(self.data_file):
            print("Generating test data...")
            subprocess.run([sys.executable, "python/generate_data.py"], check=True)
        else:
            print(f"Using existing test data: {self.data_file}")
    
    def compile_if_needed(self):
        """Compile languages that need compilation"""
        print("Compiling programs...")
        
        # Compile Java
        try:
            result = subprocess.run(["javac", "-encoding", "UTF-8", "-cp", "java", "java/MergeSort.java"], 
                                  capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                print("✓ Java compiled successfully")
            else:
                print(f"✗ Java compilation failed: {result.stderr}")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("✗ Java compiler not found or compilation timeout")
            return False
        
        # Compile Go (original)
        try:
            result = subprocess.run(["go", "build", "-o", "go/mergesort_go", "go/mergesort.go"], 
                                  capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                print("✓ Go (original) compiled successfully")
            else:
                print(f"✗ Go (original) compilation failed: {result.stderr}")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("✗ Go compiler not found or compilation timeout")
            return False
        
        # Compile Go (optimized)
        try:
            result = subprocess.run(["go", "build", "-o", "go/mergesort_go_optimized", "go/mergesort_optimized.go"], 
                                  capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                print("✓ Go (optimized) compiled successfully")
            else:
                print(f"✗ Go (optimized) compilation failed: {result.stderr}")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("✗ Go compiler not found or compilation timeout")
            return False
        
        # Check Rust version and compile
        try:
            # Check Rust version first
            version_result = subprocess.run(["rustc", "--version"], 
                                          capture_output=True, text=True, timeout=10)
            if version_result.returncode == 0:
                rust_version = version_result.stdout.strip()
                print(f"✓ Rust found: {rust_version}")
            else:
                print("✗ Rust version check failed")
                return False
                
            # Compile Rust
            result = subprocess.run(["rustc", "-O", "rust/mergesort.rs", "-o", "rust/mergesort_rust"], 
                                  capture_output=True, text=True, timeout=60)
            if result.returncode == 0:
                print("✓ Rust compiled successfully")
            else:
                print(f"✗ Rust compilation failed: {result.stderr}")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("✗ Rust compiler not found or compilation timeout")
            return False
        
        # Compile C
        try:
            result = subprocess.run(["gcc", "-O3", "-o", "c/mergesort_c", "c/mergesort.c"], 
                                  capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                print("✓ C sequential compiled successfully")
            else:
                print(f"✗ C sequential compilation failed: {result.stderr}")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("✗ C compiler not found or compilation timeout")
            return False
        
        # Compile C parallel
        try:
            result = subprocess.run(["gcc", "-O3", "-pthread", "-o", "c/parallel_mergesort_c", "c/parallel_mergesort.c", "-lm"], 
                                  capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                print("✓ C parallel compiled successfully")
            else:
                print(f"✗ C parallel compilation failed: {result.stderr}")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print("✗ C compiler not found or compilation timeout")
            return False
        
        return True
    
    def run_benchmark(self, name, command, timeout=120):
        """Run a single benchmark with timeout"""
        print(f"\nRunning {name}...")
        try:
            start_time = time.time()
            result = subprocess.run(command, capture_output=True, text=True, timeout=timeout)
            end_time = time.time()
            
            if result.returncode == 0:
                # Extract execution time from output
                execution_time = self.extract_time_from_output(result.stdout, name)
                wall_time = end_time - start_time
                
                self.results[name] = {
                    'status': 'success',
                    'execution_time': execution_time,
                    'wall_time': wall_time,
                    'stdout': result.stdout,
                    'stderr': result.stderr
                }
                print(f"✓ {name} completed in {execution_time:.4f}s (wall: {wall_time:.4f}s)")
            else:
                self.results[name] = {
                    'status': 'failed',
                    'error': result.stderr,
                    'stdout': result.stdout
                }
                print(f"✗ {name} failed: {result.stderr}")
                
        except subprocess.TimeoutExpired:
            self.results[name] = {
                'status': 'timeout',
                'timeout': timeout
            }
            print(f"✗ {name} timed out after {timeout}s")
        except FileNotFoundError:
            self.results[name] = {
                'status': 'not_found',
                'error': f"Command not found: {command[0]}"
            }
            print(f"✗ {name} runtime not found: {command[0]}")
    
    def extract_time_from_output(self, output, language):
        """Extract execution time from program output"""
        lines = output.strip().split('\n')
        
        # Look for total execution time first
        for line in lines:
            if 'total execution time' in line.lower():
                try:
                    # Extract number before 'seconds'
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
                    # Extract number before 'seconds'
                    parts = line.split()
                    for i, part in enumerate(parts):
                        if 'seconds' in part.lower() and i > 0:
                            return float(parts[i-1])
                except (ValueError, IndexError):
                    continue
        return 0.0
    
    def run_all_benchmarks(self):
        """Run benchmarks for all languages"""
        benchmarks = [
            # ("Python", [sys.executable, "python/mergesort_python.py", self.data_file]),
            ("JavaScript", ["node", "javascript/mergesort_optimized.js", self.data_file]),
            ("Java", ["java", "-cp", "java", "MergeSort", self.data_file]),
            ("Go (original)", ["./go/mergesort_go", self.data_file]),
            ("Go (optimized)", ["./go/mergesort_go_optimized", self.data_file]),
            ("Rust", ["./rust/mergesort_rust", self.data_file]),
            ("C", ["./c/mergesort_c", self.data_file])
        ]
        
        for name, command in benchmarks:
            self.run_benchmark(name, command)
    
    def generate_report(self):
        """Generate a comprehensive benchmark report"""
        report = []
        report.append("=" * 60)
        report.append("MERGE SORT LANGUAGE BENCHMARK REPORT")
        report.append("=" * 60)
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"Test Data: 10,000,000 random integers")
        report.append("")
        
        # Summary table
        successful_results = {k: v for k, v in self.results.items() 
                            if v['status'] == 'success'}
        
        if successful_results:
            report.append("EXECUTION TIME RESULTS:")
            report.append("-" * 40)
            
            # Sort by execution time
            sorted_results = sorted(successful_results.items(), 
                                  key=lambda x: x[1]['execution_time'])
            
            fastest_time = sorted_results[0][1]['execution_time'] if sorted_results else 0
            
            for i, (name, data) in enumerate(sorted_results):
                rank = i + 1
                exec_time = data['execution_time']
                wall_time = data['wall_time']
                ratio = exec_time / fastest_time if fastest_time > 0 else 1
                
                report.append(f"{rank}. {name:<12} {exec_time:>8.4f}s "
                            f"(wall: {wall_time:>6.4f}s) [{ratio:>5.2f}x]")
        
        # Detailed results
        report.append("\nDETAILED RESULTS:")
        report.append("-" * 40)
        
        for name, data in self.results.items():
            report.append(f"\n{name}:")
            if data['status'] == 'success':
                report.append(f"  Status: ✓ Success")
                report.append(f"  Execution Time: {data['execution_time']:.4f} seconds")
                report.append(f"  Wall Clock Time: {data['wall_time']:.4f} seconds")
            elif data['status'] == 'failed':
                report.append(f"  Status: ✗ Failed")
                report.append(f"  Error: {data['error']}")
            elif data['status'] == 'timeout':
                report.append(f"  Status: ✗ Timeout ({data['timeout']}s)")
            elif data['status'] == 'not_found':
                report.append(f"  Status: ✗ Runtime Not Found")
                report.append(f"  Error: {data['error']}")
        
        # System information
        report.append("\nSYSTEM INFORMATION:")
        report.append("-" * 40)
        try:
            import platform
            report.append(f"OS: {platform.system()} {platform.release()}")
            report.append(f"Architecture: {platform.machine()}")
            report.append(f"Python Version: {platform.python_version()}")
        except:
            report.append("System info unavailable")
        
        # Performance analysis
        if len(successful_results) > 1:
            report.append("\nPERFORMANCE ANALYSIS:")
            report.append("-" * 40)
            
            times = [data['execution_time'] for data in successful_results.values()]
            fastest = min(times)
            slowest = max(times)
            average = sum(times) / len(times)
            
            report.append(f"Fastest: {fastest:.4f}s")
            report.append(f"Slowest: {slowest:.4f}s")
            report.append(f"Average: {average:.4f}s")
            report.append(f"Range: {slowest/fastest:.2f}x difference")
        
        report.append("\n" + "=" * 60)
        
        return "\n".join(report)
    
    def save_results(self):
        """Save results to JSON file"""
        os.makedirs("results", exist_ok=True)
        with open("results/benchmark_results.json", "w") as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'results': self.results
            }, f, indent=2)
    
    def run(self):
        """Run complete benchmark suite"""
        print("Language Runtime Benchmark - Merge Sort")
        print("=" * 50)
        
        # Generate test data
        self.ensure_data_exists()
        
        # Compile programs
        if not self.compile_if_needed():
            print("Some compilations failed. Continuing with available runtimes...")
        
        # Run benchmarks
        print("\nStarting benchmarks...")
        self.run_all_benchmarks()
        
        # Generate and display report
        report = self.generate_report()
        print("\n" + report)
        
        # Save results
        self.save_results()
        
        # Save report to file
        with open("results/benchmark_report.txt", "w") as f:
            f.write(report)
        
        print(f"\nResults saved to:")
        print(f"  - results/benchmark_results.json (raw data)")
        print(f"  - results/benchmark_report.txt (formatted report)")

if __name__ == "__main__":
    benchmark = LanguageBenchmark()
    benchmark.run() 