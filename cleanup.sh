#!/bin/bash

# Cleanup Script for Language Benchmark Suite
# Removes all generated files: test data, compiled binaries, results, and temporary files

set -e

echo "🧹 Language Benchmark Suite Cleanup"
echo "==================================="

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to safely remove files/directories
safe_remove() {
    local path="$1"
    local description="$2"
    
    if [ -e "$path" ]; then
        echo -e "${YELLOW}🗑️  Removing ${description}...${NC}"
        rm -rf "$path"
        echo -e "${GREEN}✅ Removed: $path${NC}"
    else
        echo -e "ℹ️  Not found: $path (already clean)"
    fi
}

# Function to remove files matching a pattern
remove_pattern() {
    local pattern="$1"
    local description="$2"
    
    if ls $pattern 1> /dev/null 2>&1; then
        echo -e "${YELLOW}🗑️  Removing ${description}...${NC}"
        rm -f $pattern
        echo -e "${GREEN}✅ Removed files matching: $pattern${NC}"
    else
        echo -e "ℹ️  No files found matching: $pattern"
    fi
}

echo ""
echo "📊 Removing Test Data Files"
echo "==========================="
safe_remove "test_data.csv" "main test dataset (10M integers)"
remove_pattern "test_*.csv" "temporary test files"
remove_pattern "*_test_data.csv" "additional test datasets"

echo ""
echo "🔧 Removing Compiled Binaries"
echo "=============================="

# Java compiled files
echo -e "${YELLOW}☕ Java bytecode files:${NC}"
safe_remove "java/*.class" "Java .class files"
safe_remove "java/MergeSort.class" "MergeSort.class"
safe_remove "java/ParallelMergeSort.class" "ParallelMergeSort.class"
safe_remove "java/ParallelMergeSort\$MergeSortTask.class" "inner class files"
safe_remove "java/ParallelMergeSort\$PrimeCountTask.class" "inner class files"

# Go compiled binaries
echo -e "${YELLOW}🐹 Go binaries:${NC}"
safe_remove "go/mergesort_go" "Go original binary"
safe_remove "go/mergesort_go_optimized" "Go optimized binary"

# Rust compiled binaries
echo -e "${YELLOW}🦀 Rust binaries:${NC}"
safe_remove "rust/mergesort_rust" "Rust binary"

# C compiled binaries
echo -e "${YELLOW}⚡ C binaries:${NC}"
safe_remove "c/mergesort_c" "C sequential binary"
safe_remove "c/parallel_mergesort_c" "C parallel binary"

echo ""
echo "📁 Removing Results and Reports"
echo "==============================="
echo -e "${YELLOW}📊 Results directory contents (keeping .gitignore):${NC}"

# Remove all files in results/ except .gitignore
if [ -d "results" ]; then
    find results/ -type f ! -name ".gitignore" -delete 2>/dev/null || true
    if [ "$(find results/ -type f ! -name '.gitignore' | wc -l)" -eq 0 ]; then
        echo -e "${GREEN}✅ Cleaned results directory (kept .gitignore)${NC}"
    else
        echo -e "${RED}⚠️  Some files remain in results directory${NC}"
    fi
else
    echo -e "ℹ️  Results directory not found"
fi

echo ""
echo "🧹 Removing Temporary Files"
echo "==========================="

# Remove temporary files that might be created during development/testing
remove_pattern "*.tmp" "temporary files"
remove_pattern "*.log" "log files"
remove_pattern "*~" "backup files"
remove_pattern ".DS_Store" "macOS system files"
remove_pattern "*.swp" "Vim swap files"
remove_pattern "*.swo" "Vim swap files"

# Remove test files we created earlier
safe_remove "test.c" "test C file"
safe_remove "test.cpp" "test C++ file"
safe_remove "test_c" "test C binary"
safe_remove "test_cpp" "test C++ binary"

echo ""
echo "🐳 Docker Cleanup (Optional)"
echo "============================"
echo -e "${YELLOW}Docker images and containers (if any):${NC}"

# Check if Docker is available and running
if command -v docker &> /dev/null; then
    # Remove benchmark-related Docker images (safely)
    if docker images | grep -q "language-benchmark"; then
        echo -e "${YELLOW}🐳 Found benchmark Docker images...${NC}"
        docker images | grep "language-benchmark" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
        echo -e "${GREEN}✅ Removed benchmark Docker images${NC}"
    else
        echo -e "ℹ️  No benchmark Docker images found"
    fi
    
    # Clean up any stopped containers
    if docker ps -a | grep -q "language-benchmark"; then
        echo -e "${YELLOW}🐳 Removing stopped benchmark containers...${NC}"
        docker ps -a | grep "language-benchmark" | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true
        echo -e "${GREEN}✅ Removed benchmark containers${NC}"
    else
        echo -e "ℹ️  No benchmark containers found"
    fi
else
    echo -e "ℹ️  Docker not available (skipping Docker cleanup)"
fi

echo ""
echo "📦 Language-Specific Cleanup"
echo "============================"

# Node.js
if [ -d "node_modules" ]; then
    echo -e "${YELLOW}🟨 Node.js modules:${NC}"
    safe_remove "node_modules" "Node.js dependencies"
    safe_remove "package-lock.json" "Node.js lock file"
fi

# Rust
if [ -d "target" ]; then
    echo -e "${YELLOW}🦀 Rust target directory:${NC}"
    safe_remove "target" "Rust build artifacts"
fi

# Go
if [ -f "go.mod" ] || [ -f "go.sum" ]; then
    echo -e "${YELLOW}🐹 Go modules:${NC}"
    safe_remove "go.sum" "Go module checksums"
fi

# Python cache
echo -e "${YELLOW}🐍 Python cache files:${NC}"
remove_pattern "**/__pycache__" "Python cache directories"
remove_pattern "*.pyc" "Python bytecode files"
remove_pattern "*.pyo" "Python optimized bytecode"

echo ""
echo "🎯 Cleanup Summary"
echo "=================="
echo -e "${GREEN}✅ Cleanup completed successfully!${NC}"
echo ""
echo "📋 What was cleaned:"
echo "   • Test data files (CSV)"
echo "   • Compiled binaries (Java, Go, Rust, C)"
echo "   • Results and reports (JSON, TXT)"
echo "   • Temporary and cache files"
echo "   • Docker images/containers (if found)"
echo "   • Language-specific build artifacts"
echo ""
echo "📂 Preserved files:"
echo "   • Source code (.java, .go, .rs, .c, .js, .py)"
echo "   • Configuration files (Dockerfile, .gitignore)"
echo "   • Documentation (README.md, docs/)"
echo "   • Build scripts (.sh)"
echo ""
echo -e "${YELLOW}💡 Tip: Run './build_and_test.sh' to rebuild everything${NC}"
echo -e "${YELLOW}💡 Or run 'python3 benchmark.py' to regenerate test data${NC}" 