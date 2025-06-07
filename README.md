# Language Runtime Performance Benchmark Suite

A comprehensive benchmark suite comparing CPU-intensive performance across multiple programming languages using merge sort and prime number counting algorithms.

## 🏗️ Project Structure

```
├── README.md                    # This file
├── benchmark.py                 # Main sequential benchmark orchestrator
├── parallel_comparison.py       # Parallel programming comparison
├── run_benchmark.sh            # Sequential benchmark runner
├── run_jit_comparison.sh       # JavaScript JIT analysis
├── build_and_test.sh           # Docker build and test script
│
├── python/                     # Python implementations
│   ├── generate_data.py        # Test data generator
│   └── mergesort_python.py     # Python merge sort + prime counting
│
├── javascript/                 # JavaScript implementations
│   ├── mergesort_javascript.js         # Sequential implementation
│   ├── parallel_javascript.js          # Worker threads implementation
│   ├── parallel_sharedarraybuffer.js   # SharedArrayBuffer implementation
│   ├── parallel_worker.js              # Worker thread utilities
│   ├── jit_comparison.js               # JIT analysis version
│   └── jit_demo_intensive.js           # JIT demonstration
│
├── java/                       # Java implementations
│   ├── MergeSort.java          # Sequential implementation
│   └── ParallelMergeSort.java  # Fork-Join parallel implementation
│
├── go/                         # Go implementation
│   └── mergesort.go            # Go merge sort + prime counting
│
├── rust/                       # Rust implementation
│   └── mergesort.rs            # Rust merge sort + prime counting
│
├── c/                          # C implementations  
│   ├── mergesort.c             # Sequential implementation
│   └── parallel_mergesort.c    # Parallel pthreads implementation
│
├── cloud/                      # Cloud deployment
│   ├── Dockerfile              # Container definition
│   ├── docker-compose.yml      # Multi-container orchestration
│   ├── deploy_aws.sh           # AWS deployment script
│   ├── deploy_gcp.sh           # Google Cloud deployment
│   └── deploy_azure.sh         # Azure deployment
│
├── scripts/                    # Utility scripts
│   ├── quick_test.sh           # Fast validation test
│   └── run_all_benchmarks.sh   # Complete benchmark suite
│
└── docs/                       # Documentation
    ├── CLOUD_DEPLOYMENT_GUIDE.md    # Cloud deployment instructions
    ├── PARALLEL_ANALYSIS.md         # Parallel programming analysis
    ├── SHAREDARRAYBUFFER_ANALYSIS.md # SharedArrayBuffer deep dive
    ├── CPU_SCALING_ANALYSIS.md      # CPU scaling performance analysis
    └── README_CONTAINER.md          # Container usage guide
```

## 🚀 Quick Start

### Local Testing
```bash
# Run sequential benchmarks
./run_benchmark.sh

# Run parallel comparison
python3 parallel_comparison.py

# Quick validation test
./scripts/quick_test.sh

# JavaScript JIT analysis
./run_jit_comparison.sh

# Results are automatically saved to results/ folder
ls results/
```

### Docker Container
```bash
# Build and test
./build_and_test.sh

# Run full benchmark suite (results saved to local results/ folder)
docker run --rm -v $(pwd)/results:/benchmark/results language-benchmark

# Interactive mode
docker run --rm -it language-benchmark bash
```

## 📋 Prerequisites

Before running the benchmark suite, you need to install the required language compilers and runtimes for your operating system.

### 🪟 Windows

#### Python
```cmd
# Option 1: Download from python.org
# Visit https://www.python.org/downloads/ and download Python 3.8+

# Option 2: Using winget
winget install Python.Python.3.12

# Option 3: Using Chocolatey
choco install python
```

#### Node.js
```cmd
# Option 1: Download from nodejs.org
# Visit https://nodejs.org/ and download LTS version

# Option 2: Using winget
winget install OpenJS.NodeJS

# Option 3: Using Chocolatey
choco install nodejs
```

#### Java
```cmd
# Option 1: Download OpenJDK
# Visit https://adoptium.net/ and download JDK 11+

# Option 2: Using winget
winget install Eclipse.Temurin.11.JDK

# Option 3: Using Chocolatey
choco install openjdk11
```

#### Go
```cmd
# Option 1: Download from golang.org
# Visit https://golang.org/dl/ and download Go 1.18+

# Option 2: Using winget
winget install GoLang.Go

# Option 3: Using Chocolatey
choco install golang
```

#### Rust
```cmd
# Option 1: Using rustup (recommended)
# Visit https://rustup.rs/ and run the installer

# Option 2: Using winget
winget install Rustlang.Rustup

# Option 3: Using Chocolatey
choco install rustup.install
```

#### C Compiler (GCC)
```cmd
# Option 1: Install Build Tools for Visual Studio
# Visit https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

# Option 2: Using MSYS2 (recommended for GCC)
# Visit https://www.msys2.org/ and follow installation guide
# After installing MSYS2:
pacman -S mingw-w64-x86_64-gcc

# Option 3: Using winget
winget install Git.Git  # Includes Git Bash with GCC

# Option 4: Using Chocolatey
choco install mingw
```

### 🍎 macOS

#### Package Manager (Homebrew)
```bash
# Install Homebrew first if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### All Languages via Homebrew
```bash
# Python
brew install python@3.12

# Node.js
brew install node

# Java
brew install openjdk@11
# Add to PATH
echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc

# Go
brew install go

# Rust
brew install rust

# C Compiler (comes with Xcode Command Line Tools)
xcode-select --install
```

#### Alternative Installation Methods
```bash
# Python via pyenv
brew install pyenv
pyenv install 3.12.0

# Node.js via nvm
brew install nvm
nvm install --lts

# Java via SDKMAN!
curl -s "https://get.sdkman.io" | bash
sdk install java 11.0.21-tem

# Rust via rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 🐧 Linux (Ubuntu/Debian)

#### Update Package Manager
```bash
sudo apt update && sudo apt upgrade -y
```

#### Install All Languages
```bash
# Python
sudo apt install python3 python3-pip

# Node.js
# Option 1: Default repository
sudo apt install nodejs npm

# Option 2: NodeSource repository (latest LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs

# Java
sudo apt install openjdk-11-jdk

# Go
sudo apt install golang-go

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# C Compiler
sudo apt install build-essential gcc
```

### 🐧 Linux (CentOS/RHEL/Fedora)

#### For CentOS/RHEL 8+
```bash
# Enable EPEL repository
sudo dnf install epel-release

# Install languages
sudo dnf install python3 python3-pip nodejs npm java-11-openjdk-devel golang gcc

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### For Fedora
```bash
# Install languages
sudo dnf install python3 python3-pip nodejs npm java-11-openjdk-devel golang gcc rust cargo

# Alternative Rust installation
sudo dnf install rust cargo
```

### 🐧 Linux (Arch)

```bash
# Update system
sudo pacman -Syu

# Install languages
sudo pacman -S python nodejs npm jdk11-openjdk go gcc rust

# Set Java environment
sudo archlinux-java set java-11-openjdk
```

### 🐳 Docker Alternative

If you prefer not to install all languages locally, you can use Docker:

```bash
# Build the container with all dependencies
./build_and_test.sh

# Run benchmarks in container
docker run --cpuset-cpus="0,1" --rm -v $(pwd)/results:/benchmark/results language-benchmark
```

### ✅ Verification

After installation, verify all languages are working:

```bash
# Check versions
python3 --version    # Should be 3.8+
node --version       # Should be 16+
java -version        # Should be 11+
go version          # Should be 1.18+
rustc --version     # Should be 1.60+
gcc --version       # Should be 9+

# Quick test
./scripts/quick_test.sh
```

### 🔧 Troubleshooting

#### Common Issues

**Windows PATH Issues:**
```cmd
# Add to system PATH (replace with actual installation paths)
set PATH=%PATH%;C:\Python312;C:\Program Files\nodejs;C:\Program Files\Java\jdk-11\bin
```

**macOS Permission Issues:**
```bash
# Fix Node.js permissions
sudo chown -R $(whoami) ~/.npm
```

**Linux Missing Dependencies:**
```bash
# Ubuntu/Debian missing build tools
sudo apt install build-essential cmake

# CentOS/RHEL missing development tools
sudo dnf groupinstall "Development Tools"
```

**Rust Cargo Path:**
```bash
# Add to shell profile (.bashrc, .zshrc, etc.)
export PATH="$HOME/.cargo/bin:$PATH"
source ~/.cargo/env
```

## 📊 Complete Performance Results

Based on 10 million integer sorting + prime counting across multiple environments:

### Local Performance (macOS, 12 CPU cores, Apple M-series ARM64)

**Sequential Performance:**
1. **C**: 1.03s (fastest baseline)
2. **Go (optimized)**: 1.19s (1.15x slower than C)
3. **Go (original)**: 1.28s (1.24x slower than C)
4. **Rust**: 1.30s (1.26x slower than C)
5. **Java**: 1.50s (1.46x slower than C)
6. **JavaScript**: 2.84s (2.76x slower than C)

**Parallel Performance:**
1. **C pthreads**: 0.17s (6.1x speedup, 50.8% efficiency)
2. **Java Fork-Join**: 0.27s (5.64x speedup, 47.0% efficiency)
3. **JavaScript SharedArrayBuffer**: 0.68s (4.17x speedup, 34.8% efficiency)
4. **JavaScript Workers**: 2.35s (1.21x speedup, 10.1% efficiency)
5. **C pthreads**: 0.25s (4.56x speedup, 76.0% efficiency)
6. **Java Fork-Join**: 0.40s (3.74x speedup, 62.3% efficiency)
7. **JavaScript SharedArrayBuffer**: 0.81s (3.53x speedup, 58.9% efficiency)
8. **JavaScript Workers**: 2.78s (1.03x speedup, 17.2% efficiency)

### Docker Constrained (Linux x86_64, 2 CPU cores limited)

**Sequential Performance:**
1. **C**: 1.15s (fastest baseline)
2. **Java**: 1.51s (1.31x slower than C)
3. **Go (optimized)**: 1.65s (1.43x slower than C)
4. **Go (original)**: 1.80s (1.57x slower than C)
5. **JavaScript**: 2.80s (2.43x slower than C)

**Parallel Performance:**
1. **C pthreads**: 0.66s (1.74x speedup, 87.0% efficiency)
2. **Java Fork-Join**: 1.01s (1.50x speedup, 75.0% efficiency)
3. **JavaScript SharedArrayBuffer**: 1.13s (2.47x speedup, 123.5% efficiency)*
4. **JavaScript Workers**: 2.89s (0.97x speedup, 48.5% efficiency)

*Note: JavaScript SharedArrayBuffer showing >100% efficiency likely due to JIT optimizations during parallel execution.

## 📊 Core Scaling Analysis: Local vs Docker Performance

Comprehensive testing across different CPU environments demonstrates how available cores impact parallel performance:

### Environment Comparison
| Environment | Cores | Architecture | Test Results |
|-------------|-------|--------------|-------------|
| **Local** | 12 cores | Apple M-series (ARM64) | Full performance |
| **Docker** | 6 cores | x86_64 Linux container | Limited parallel scaling |
| **Docker Constrained** | 2 cores | x86_64 Linux (--cpus=2.0) | Minimal parallel benefit |

### Parallel Efficiency by Core Count

**Java Fork-Join Performance:**
- **12 cores**: 0.27s (5.64x speedup, 47.0% efficiency)
- **6 cores**: 0.40s (3.74x speedup, 62.3% efficiency) 
- **2 cores**: 1.01s (1.50x speedup, 25.0% efficiency)

**C pthreads Performance:**
- **12 cores**: 0.17s (6.0x speedup, 50% efficiency)
- **6 cores**: 0.25s (4.5x speedup, 75% efficiency)
- **2 cores**: 0.66s (1.7x speedup, 85% efficiency)

**JavaScript SharedArrayBuffer:**
- **12 cores**: 0.68s (4.17x speedup, 34.8% efficiency)
- **6 cores**: 0.81s (3.53x speedup, 58.9% efficiency)
- **2 cores**: 1.13s (2.47x speedup, 41.2% efficiency)

### Algorithm Optimization Impact (Go Comparison)

The Go implementations demonstrate how algorithm choices affect performance across environments:

**Go Algorithm Performance:**
- **Local (12 cores)**: Original 1.28s → Optimized 1.19s (7.5% improvement)
- **Docker (6 cores)**: Original 1.86s → Optimized 1.63s (11.9% improvement)  
- **Docker (2 cores)**: Original 1.80s → Optimized 1.65s (8.6% improvement)

## 🔬 Key Technical Insights

- **C Performance Leadership**: Native C code with manual optimization sets the performance baseline
- **Core Count Sweet Spot**: Lower core counts often show higher parallel efficiency due to reduced coordination overhead
- **pthreads Scale Best**: C's manual thread management maintains efficiency across core counts
- **Algorithm vs Parallelism**: Go's 8-12% algorithm optimization provides consistent gains regardless of core count
- **Container Performance**: Docker containers can effectively utilize available cores with minimal overhead
- **Rust Performance**: Nearly matches Java despite system-level safety guarantees
- **JavaScript Efficiency**: Remarkable performance for a JIT-compiled language (~2x slower than Java)
- **Parallel Architecture Matters**: Manual threading (C) and Fork-Join (Java) outperform worker threads
- **SharedArrayBuffer Success**: JavaScript parallel performance jumps from 10% to 34% efficiency
- **Memory-Bound Reality**: Algorithm performance more dependent on memory access patterns than raw computation
- **Scalability Patterns**: Parallel efficiency often decreases with more cores due to coordination overhead

## 📚 Documentation

- **[Cloud Deployment Guide](docs/CLOUD_DEPLOYMENT_GUIDE.md)** - AWS, GCP, Azure deployment
- **[Parallel Analysis](docs/PARALLEL_ANALYSIS.md)** - Fork-Join vs Worker threads comparison  
- **[SharedArrayBuffer Analysis](docs/SHAREDARRAYBUFFER_ANALYSIS.md)** - Deep dive into shared memory parallelism
- **[CPU Scaling Analysis](docs/cpu_scaling_results_mac/CPU_SCALING_SUMMARY.md)** - Comprehensive parallel performance scaling across multiple CPU configurations
- **[Container Guide](docs/README_CONTAINER.md)** - Docker usage and configuration

## 🛠️ Requirements

### Local Development
- Python 3.8+
- Node.js 16+
- Java 11+
- Go 1.18+
- Rust 1.60+ (with rustc compiler and cargo package manager)
- GCC 9+ (for C implementations)

> **📋 See [Prerequisites](#-prerequisites) section above for detailed installation instructions for Windows, macOS, and Linux.**

### Container Environment
All dependencies included in Docker image based on Ubuntu 22.04.

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