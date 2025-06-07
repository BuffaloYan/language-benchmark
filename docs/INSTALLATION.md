# Installation Guide

This guide provides detailed installation instructions for all programming languages and tools required to run the Language Runtime Performance Benchmark Suite.

## 📋 Required Languages & Tools

Before running the benchmark suite, you need to install the following language compilers and runtimes:

- **Python 3.8+**
- **Node.js 16+** 
- **Java 11+**
- **Go 1.18+**
- **Rust 1.60+** (with rustc compiler and cargo package manager)
- **GCC 9+** (for C implementations)

## 🪟 Windows Installation

### Python
```cmd
# Option 1: Download from python.org
# Visit https://www.python.org/downloads/ and download Python 3.8+

# Option 2: Using winget
winget install Python.Python.3.12

# Option 3: Using Chocolatey
choco install python
```

### Node.js
```cmd
# Option 1: Download from nodejs.org
# Visit https://nodejs.org/ and download LTS version

# Option 2: Using winget
winget install OpenJS.NodeJS

# Option 3: Using Chocolatey
choco install nodejs
```

### Java
```cmd
# Option 1: Download OpenJDK
# Visit https://adoptium.net/ and download JDK 11+

# Option 2: Using winget
winget install Eclipse.Temurin.11.JDK

# Option 3: Using Chocolatey
choco install openjdk11
```

### Go
```cmd
# Option 1: Download from golang.org
# Visit https://golang.org/dl/ and download Go 1.18+

# Option 2: Using winget
winget install GoLang.Go

# Option 3: Using Chocolatey
choco install golang
```

### Rust
```cmd
# Option 1: Using rustup (recommended)
# Visit https://rustup.rs/ and run the installer

# Option 2: Using winget
winget install Rustlang.Rustup

# Option 3: Using Chocolatey
choco install rustup.install
```

### C Compiler (GCC)
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

## 🍎 macOS Installation

### Package Manager (Homebrew)
```bash
# Install Homebrew first if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### All Languages via Homebrew
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

### Alternative Installation Methods
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

## 🐧 Linux Installation

### Ubuntu/Debian

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

### CentOS/RHEL/Fedora

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

### Arch Linux

```bash
# Update system
sudo pacman -Syu

# Install languages
sudo pacman -S python nodejs npm jdk11-openjdk go gcc rust

# Set Java environment
sudo archlinux-java set java-11-openjdk
```

## 🐳 Docker Alternative

If you prefer not to install all languages locally, you can use Docker:

```bash
# Build the container with all dependencies
./build_and_test.sh

# Run benchmarks in container
docker run --rm -v $(pwd)/results:/benchmark/results language-benchmark
```

## ✅ Installation Verification

After installation, verify all languages are working:

```bash
# Check versions
python3 --version    # Should be 3.8+
node --version       # Should be 16+
java -version        # Should be 11+
go version          # Should be 1.18+
rustc --version     # Should be 1.60+
gcc --version       # Should be 9+

# Quick test (if available)
./scripts/quick_test.sh
```

## 🔧 Troubleshooting

### Common Issues

#### Windows PATH Issues
```cmd
# Add to system PATH (replace with actual installation paths)
set PATH=%PATH%;C:\Python312;C:\Program Files\nodejs;C:\Program Files\Java\jdk-11\bin
```

#### macOS Permission Issues
```bash
# Fix Node.js permissions
sudo chown -R $(whoami) ~/.npm
```

#### Linux Missing Dependencies
```bash
# Ubuntu/Debian missing build tools
sudo apt install build-essential cmake

# CentOS/RHEL missing development tools
sudo dnf groupinstall "Development Tools"
```

#### Rust Cargo Path
```bash
# Add to shell profile (.bashrc, .zshrc, etc.)
export PATH="$HOME/.cargo/bin:$PATH"
source ~/.cargo/env
```

### Language-Specific Issues

#### Java Environment
```bash
# Check JAVA_HOME
echo $JAVA_HOME

# Set JAVA_HOME (Linux/macOS)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk

# Set JAVA_HOME (Windows)
set JAVA_HOME="C:\Program Files\Java\jdk-11"
```

#### Node.js Global Packages
```bash
# Fix global package permissions (Linux/macOS)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
```

#### Go Workspace
```bash
# Check Go environment
go env GOPATH
go env GOROOT

# Set Go workspace (if needed)
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

## 🆘 Getting Help

If you encounter issues during installation:

1. **Check system requirements**: Ensure your OS version is supported
2. **Update package managers**: Run system updates before installing
3. **Review error messages**: Most installation errors provide clear guidance
4. **Check official documentation**: Visit each language's official installation guide
5. **Use Docker**: If local installation fails, use the provided Docker container
6. **Create an issue**: Report installation problems in the project repository

## 📚 Additional Resources

- [Python Installation Guide](https://www.python.org/downloads/)
- [Node.js Installation Guide](https://nodejs.org/en/download/)
- [Java Installation Guide](https://adoptium.net/installation/)
- [Go Installation Guide](https://golang.org/doc/install)
- [Rust Installation Guide](https://rustup.rs/)
- [GCC Installation Guide](https://gcc.gnu.org/install/) 