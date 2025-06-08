@echo off
REM Build and Test Script for Language Benchmark Suite (Windows)
REM This script builds the Docker container and runs basic tests

echo [BUILD] Building Language Benchmark Container
echo ========================================

echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker first.
    exit /b 1
)

REM Build the container
echo [DOCKER] Building Docker image...
docker build -f cloud/Dockerfile -t language-benchmark .
if errorlevel 1 (
    echo [ERROR] Docker build failed
    exit /b 1
)

echo.
echo [TEST] Running Quick Tests
echo =====================

REM Run quick test
docker run --rm language-benchmark /benchmark/scripts/quick_test.sh
if errorlevel 1 (
    echo [ERROR] Quick tests failed
    exit /b 1
)

echo.
echo [INFO] Container Information
echo =======================

REM Show container details
docker run --rm language-benchmark bash -c "echo 'Container size:' && du -sh /benchmark && echo '' && echo 'Installed language versions:' && python3 --version && java -version 2>&1 | head -1 && node --version && go version && echo 'Rust compiler:' $(rustc --version) && echo 'Rust toolchain:' $(rustup show | head -1) && gcc --version | head -1 && echo '' && echo 'Available processors:' $(nproc) && echo 'Memory:' $(free -h | awk '/^Mem:/ {print $2}')"

echo.
echo [SUCCESS] Build and test completed successfully!
echo.
echo [DEPLOY] Ready for deployment! Use one of these commands:
echo.
echo [LOCAL] Local full benchmark:
echo docker run --rm -v "%cd%\results:/benchmark/results" language-benchmark
echo.
echo [INTERACTIVE] Interactive mode:
echo docker run --rm -it language-benchmark bash
echo.
echo [CLOUD] Cloud deployment:
echo ./cloud/deploy_aws.sh     # for AWS
echo ./cloud/deploy_gcp.sh     # for Google Cloud
echo ./cloud/deploy_azure.sh   # for Azure
echo.
echo [DOCS] See docs/CLOUD_DEPLOYMENT_GUIDE.md for detailed instructions

pause 