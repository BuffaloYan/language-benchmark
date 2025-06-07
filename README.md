# Language Runtime Performance Benchmark Suite

A comprehensive benchmark suite comparing CPU-intensive performance across multiple programming languages using merge sort and prime number counting algorithms.

## Local Testing
It's recommended to use docker to run the tests as there are quite a few softwares (compilers) need to be installed on the host.

### 📋 Prerequisites

The benchmark suite requires multiple programming languages and runtimes to be installed:

- **Python 3.8+**
- **Node.js 16+** 
- **Java 11+**
- **Go 1.18+**
- **Rust 1.60+** (with rustc compiler and cargo package manager)
- **GCC 9+** (for C implementations)

For detailed installation instructions for your operating system (Windows, macOS, Linux), see our comprehensive **[Installation Guide](INSTALLATION.md)**.

Here is how you can run tests locally.
```bash
# Run sequential benchmarks
./run_benchmark.sh
python3 benchmark.py

# Run parallel comparison
python3 parallel_comparison.py


# Results are automatically saved to results/ folder
ls results/
```

### Docker Container

If you prefer not to install all languages locally, you can use Docker:

```bash
# Build the container with all dependencies
./build_and_test.sh

# Run benchmarks in container
docker run --cpus=2 --rm -v $(pwd)/results:/benchmark/results language-benchmark
# you can further limit visible cpu core with --cpuset-cpus
# --cpuset-cpus="0-5"
# --cpuset-cpus="2,3,6"
```

## 📊 Complete Performance Results

There some snapshot results for different platform and resource setting in results-log foler.

There is a comprehensive scalling report for parallel workloads. 
- **[CPU_SCALING_SUMMARY](docs/cpu_scaling_results_mac/CPU_SCALING_SUMMARY.md)**
- **[CPU_SCALING_CHART](docs/cpu_scaling_results_mac/runtime_performance_chart.png)**


## 🔬 Key Technical Insights

- **C Performance Leadership**: Native C code with manual optimization sets the performance baseline
- **Core Count Sweet Spot**: Lower core counts often show higher parallel efficiency due to reduced coordination overhead
- **pthreads Scale Best**: C's manual thread management maintains efficiency across core counts
- **Algorithm vs Parallelism**: Go's 8-12% algorithm optimization provides consistent gains regardless of core count
- **Container Performance**: Docker containers can effectively utilize available cores with minimal overhead
- **Rust Performance**: Nearly matches C despite system-level safety guarantees
- **JavaScript Efficiency**: Remarkable performance for a JIT-compiled language (close to Java and Go in single thread mode)
- **Parallel Architecture Matters**: Manual threading (C) and Fork-Join (Java) outperform worker threads
- **SharedArrayBuffer Success**: JavaScript parallel performance jumps from 10% to 34% efficiency
- **Memory-Bound Reality**: Algorithm performance more dependent on memory access patterns than raw computation
- **Scalability Patterns**: Parallel efficiency often decreases with more cores due to coordination overhead

## 📚 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Complete setup instructions for all languages and platforms
- **[Cloud Deployment Guide](docs/CLOUD_DEPLOYMENT_GUIDE.md)** - AWS, GCP, Azure deployment
- **[Parallel Analysis](docs/PARALLEL_ANALYSIS.md)** - Fork-Join vs Worker threads comparison  
- **[SharedArrayBuffer Analysis](docs/SHAREDARRAYBUFFER_ANALYSIS.md)** - Deep dive into shared memory parallelism
- **[CPU Scaling Analysis](docs/cpu_scaling_results_mac/CPU_SCALING_SUMMARY.md)** - Comprehensive parallel performance scaling across multiple CPU configurations
- **[Container Guide](docs/README_CONTAINER.md)** - Docker usage and configuration


## 🌐 Cloud Deployment

Deploy to major cloud platforms:

```bash
# AWS ECS Fargate
./cloud/deploy_aws.sh

# Google Cloud Run
./cloud/deploy_gcp.sh

# Azure Container Instances
./cloud/deploy_azure.sh
```

See [Cloud Deployment Guide](docs/CLOUD_DEPLOYMENT_GUIDE.md) for detailed instructions.

## 🧪 Test Data

- **Size**: 10 million random integers (1-1,000,000 range)
- **Format**: CSV file (~80MB)
- **Operations**: Merge sort + prime number counting
- **Generated**: Automatically by `python/generate_data.py`

## 📁 Results & Output

- **Results Directory**: All benchmark outputs saved to `results/` folder
- **File Types**: JSON data, formatted reports, performance analysis
- **Git Ignored**: Results folder configured to ignore output files
- **Docker Volumes**: Mount `results/` for persistent storage across container runs

## 📈 Benchmark Features

- **Multi-Language Support**: Python, JavaScript, Java, Go, Rust, C
- **Sequential & Parallel**: Both implementations for performance comparison
- **Parallel Computing**: Fork-Join (Java), Worker Threads (JavaScript), pthreads (C)
- **Automatic Compilation**: Handles Java, Go, Rust, C compilation
- **Timeout Protection**: Prevents hanging processes
- **Error Handling**: Graceful failure with detailed reporting
- **JSON Output**: Machine-readable results
- **Performance Analysis**: Speedup ratios and efficiency metrics
- **System Information**: Hardware context for results

## 🔧 Customization

### Adding New Languages
1. Create language folder: `mkdir newlang/`
2. Implement merge sort + prime counting
3. Update `benchmark.py` configuration
4. Add compilation steps if needed

### Modifying Test Parameters
- **Data size**: Edit `python/generate_data.py`
- **Timeout values**: Modify `benchmark.py` timeout parameters
- **Prime algorithm**: Update prime counting logic in implementations

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Add language implementation in appropriate folder
4. Update benchmark configuration
5. Test with `./scripts/quick_test.sh`
6. Submit pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🏆 Acknowledgments

- V8 JavaScript Engine team for exceptional runtime performance
- OpenJDK team for Fork-Join framework
- Go and Rust communities for systems programming excellence
- Cloud providers for scalable compute infrastructure 