# Multi-language benchmark container
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /benchmark

# Update package lists and install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

# Install Python 3.11
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create python3 symlink
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3

# Install Java OpenJDK 17
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Node.js 18.x (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install Go 1.21
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz \
    && rm go1.21.5.linux-amd64.tar.gz

# Set Go environment
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/go"
ENV PATH="$GOPATH/bin:$PATH"

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
# Ensure we have the latest stable toolchain and show version info
RUN rustup update stable && rustup default stable
RUN echo "Rust toolchain info:" && rustup show

# Verify installations
RUN echo "=== Language Versions ===" \
    && python3 --version \
    && java -version \
    && node --version \
    && npm --version \
    && go version \
    && echo "Rust compiler: $(rustc --version)" \
    && echo "Rust toolchain: $(rustup show | head -1 | awk '{print $1, $2}')" \
    && echo "Cargo version: $(cargo --version)" \
    && echo "AWS CLI: $(aws --version)"

# Copy source files in organized structure
COPY python/ /benchmark/python/
COPY javascript/ /benchmark/javascript/
COPY java/ /benchmark/java/
COPY go/ /benchmark/go/
COPY rust/ /benchmark/rust/
COPY c/ /benchmark/c/
COPY scripts/ /benchmark/scripts/
COPY docs/ /benchmark/docs/

# Copy orchestration files to root
COPY benchmark.py /benchmark/
COPY parallel_comparison.py /benchmark/

# Copy test data file - this will be created by the benchmark script if not present
# We'll let the script generate it as needed

# Make scripts executable
RUN chmod +x /benchmark/*.py /benchmark/javascript/*.js /benchmark/scripts/*.sh

# Create benchmark output directory
RUN mkdir -p /benchmark/results

# Set up environment for benchmark execution
ENV PYTHONPATH="/benchmark"
ENV NODE_PATH="/benchmark"

# Compile Java programs with UTF-8 encoding
RUN cd /benchmark && javac -encoding UTF-8 -cp java java/*.java

# Verify Java compilation
RUN cd /benchmark && ls -la java/*.class

# Build Go programs
RUN cd /benchmark && go build -o go/mergesort_go go/mergesort.go
RUN cd /benchmark && go build -o go/mergesort_go_optimized go/mergesort_optimized.go
RUN cd /benchmark && go build -o go/parallel_mergesort_go go/parallel_mergesort.go

# Build Rust programs with optimizations
RUN cd /benchmark && rustc -O rust/mergesort.rs -o rust/mergesort_rust
# Build Rust parallel implementation using Cargo
RUN cd /benchmark/rust && cargo build --release
RUN cp /benchmark/rust/target/release/parallel_mergesort_rust /benchmark/rust/parallel_mergesort_rust
# Verify Rust binaries were created successfully
RUN ls -la /benchmark/rust/mergesort_rust && echo "Rust sequential binary size: $(du -h /benchmark/rust/mergesort_rust | cut -f1)"
RUN ls -la /benchmark/rust/parallel_mergesort_rust && echo "Rust parallel binary size: $(du -h /benchmark/rust/parallel_mergesort_rust | cut -f1)"

# Verify all binaries are executable
RUN cd /benchmark && echo "=== Binary verification ===" && \
    ls -la go/mergesort_go* rust/mergesort_rust* c/mergesort_c* c/parallel_mergesort_c java/*.class

# Build C programs with optimizations
RUN cd /benchmark && gcc -O3 -o c/mergesort_c c/mergesort.c
RUN cd /benchmark && gcc -O3 -pthread -o c/parallel_mergesort_c c/parallel_mergesort.c -lm

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 --version && java -version && node --version && go version && rustc --version && cargo --version && gcc --version || exit 1

# Default command
CMD ["/benchmark/scripts/run_all_benchmarks.sh"]

# Expose any ports if needed (for future web interface)
EXPOSE 8080

# Add labels for better container management
LABEL maintainer="benchmark-suite"
LABEL description="Multi-language performance benchmark container"
LABEL version="1.0"
LABEL languages="python,java,javascript,go,rust,c" 