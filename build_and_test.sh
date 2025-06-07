#!/bin/bash

# Build and Test Script for Language Benchmark Suite
# This script builds the Docker container and runs basic tests

set -e

echo "🔨 Building Language Benchmark Container"
echo "========================================"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build the container
echo "📦 Building Docker image..."
docker build -f cloud/Dockerfile -t language-benchmark .

echo ""
echo "🧪 Running Quick Tests"
echo "====================="

# Run quick test
docker run --rm language-benchmark /benchmark/scripts/quick_test.sh

echo ""
echo "📊 Container Information"
echo "======================="

# Show container details
docker run --rm language-benchmark bash -c "
echo 'Container size:' 
du -sh /benchmark

echo ''
echo 'Installed language versions:'
python3 --version
java -version 2>&1 | head -1
node --version
go version
echo 'Rust compiler:' \$(rustc --version)
echo 'Rust toolchain:' \$(rustup show | head -1)
gcc --version | head -1

echo ''
echo 'Available processors:' \$(nproc)
echo 'Memory:' \$(free -h | awk '/^Mem:/ {print \$2}')
"

echo ""
echo "✅ Build and test completed successfully!"
echo ""
echo "🚀 Ready for deployment! Use one of these commands:"
echo ""
echo "📋 Local full benchmark:"
echo "docker run --rm -v \$(pwd)/results:/benchmark/results language-benchmark"
echo ""
echo "🔍 Interactive mode:"
echo "docker run --rm -it language-benchmark bash"
echo ""
echo "☁️  Cloud deployment:"
echo "./cloud/deploy_aws.sh     # for AWS"
echo "./cloud/deploy_gcp.sh     # for Google Cloud"
echo "./cloud/deploy_azure.sh   # for Azure"
echo ""
echo "📖 See docs/CLOUD_DEPLOYMENT_GUIDE.md for detailed instructions" 