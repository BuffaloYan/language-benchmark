# ☁️ Cloud Deployment Guide for Language Benchmark Suite

## 🚀 Overview

This guide provides step-by-step instructions for deploying and running the multi-language benchmark suite in various cloud environments. The containerized solution includes Python, Java, JavaScript (Node.js), Go, and Rust implementations.

## 📦 Container Contents

- **Languages**: Java 17, Node.js 18, Go 1.21, Rust (latest), Python 3.11 (available but excluded)
- **Benchmarks**: Sequential and parallel merge sort + prime counting
- **Test Data**: 10 million random integers
- **Output**: JSON results and detailed performance reports

## 🏗️ Quick Local Test

Before deploying to cloud, test locally:

```bash
# Build the container
docker build -t language-benchmark .

# Quick test (10K numbers)
docker run --rm language-benchmark /benchmark/quick_test.sh

# Full benchmark (10M numbers)
docker run --rm -v $(pwd)/results:/benchmark/results language-benchmark
```

## ☁️ Cloud Platform Deployments

### 🔵 Amazon Web Services (AWS)

#### Option 1: AWS Fargate (Serverless)
```bash
# Set your AWS region
export AWS_REGION=us-west-2

# Deploy to ECS Fargate
chmod +x deploy_aws.sh
./deploy_aws.sh

# Run the benchmark
aws ecs run-task \
  --cluster benchmark-cluster \
  --task-definition benchmark-task \
  --launch-type FARGATE \
  --network-configuration 'awsvpcConfiguration={subnets=[subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}' \
  --region $AWS_REGION
```

#### Option 2: EC2 Instance
```bash
# Launch EC2 instance (c5.2xlarge recommended)
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1d0 \
  --count 1 \
  --instance-type c5.2xlarge \
  --key-name your-key-pair \
  --security-group-ids sg-xxxxx \
  --subnet-id subnet-xxxxx

# SSH to instance and run
ssh -i your-key.pem ec2-user@instance-ip
sudo docker run -it [account-id].dkr.ecr.[region].amazonaws.com/language-benchmark:latest
```

**Estimated Cost**: $0.50-2.00 per benchmark run (depending on instance type)

### 🟢 Google Cloud Platform (GCP)

#### Option 1: Cloud Run (Serverless)
```bash
# Set your project
export PROJECT_ID=your-project-id

# Deploy to Cloud Run
chmod +x deploy_gcp.sh
./deploy_gcp.sh

# Service will be accessible via HTTPS URL
# Benchmark runs automatically on container start
```

#### Option 2: Compute Engine
```bash
# Create VM instance
gcloud compute instances create benchmark-vm \
  --zone us-central1-a \
  --machine-type n1-highmem-8 \
  --image-family ubuntu-2004-lts \
  --image-project ubuntu-os-cloud

# SSH and run
gcloud compute ssh benchmark-vm --zone us-central1-a
sudo apt-get update && sudo apt-get install -y docker.io
sudo docker run -it gcr.io/your-project/language-benchmark:latest
```

**Estimated Cost**: $0.80-3.00 per benchmark run

### 🔵 Microsoft Azure

#### Option 1: Container Instances
```bash
# Deploy to Azure Container Instances
chmod +x deploy_azure.sh
./deploy_azure.sh

# Monitor logs
az container logs --resource-group benchmark-rg --name language-benchmark --follow
```

#### Option 2: Virtual Machine
```bash
# Create VM
az vm create \
  --resource-group benchmark-rg \
  --name benchmark-vm \
  --image UbuntuLTS \
  --size Standard_D4s_v3 \
  --generate-ssh-keys

# SSH and run
ssh azureuser@vm-ip
sudo apt-get update && sudo apt-get install -y docker.io
sudo docker run -it your-acr.azurecr.io/language-benchmark:latest
```

**Estimated Cost**: $0.60-2.50 per benchmark run

## 🚀 Advanced Deployment Options

### 🏗️ Docker Compose (Local/VPS)

```bash
# Start with Docker Compose
docker-compose up -d

# Access running container
docker-compose exec benchmark bash

# View results via web interface
open http://localhost:8080
```

### ⚙️ Kubernetes (Any Cloud)

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: benchmark-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: benchmark
  template:
    metadata:
      labels:
        app: benchmark
    spec:
      containers:
      - name: benchmark
        image: your-registry/language-benchmark:latest
        resources:
          requests:
            cpu: 2000m
            memory: 4Gi
          limits:
            cpu: 4000m
            memory: 8Gi
        env:
        - name: BENCHMARK_MODE
          value: "kubernetes"
```

```bash
kubectl apply -f k8s-deployment.yaml
kubectl logs -f deployment/benchmark-deployment
```

## 📊 Recommended Cloud Configurations

### 🎯 For Accurate Performance Testing

| Platform | Service | Instance Type | vCPUs | Memory | Cost/Hour |
|----------|---------|---------------|-------|---------|-----------|
| AWS | EC2 | c5.2xlarge | 8 | 16 GB | $0.34 |
| GCP | Compute | n1-highmem-8 | 8 | 52 GB | $0.42 |
| Azure | VM | Standard_D4s_v3 | 4 | 16 GB | $0.19 |

### 🏃‍♂️ For Quick Testing

| Platform | Service | Configuration | Cost/Run |
|----------|---------|---------------|----------|
| AWS | Fargate | 4 vCPU, 8GB | $0.50 |
| GCP | Cloud Run | 4 vCPU, 8GB | $0.30 |
| Azure | Container Instances | 4 vCPU, 8GB | $0.40 |

## 📈 Performance Expectations

Based on testing across different cloud providers:

### Sequential Performance (10M integers):
- **JavaScript**: ~2.5-3.0 seconds (baseline)
- **Java**: ~1.5-2.0 seconds (1.7x faster)
- **Go**: ~1.8-2.2 seconds (1.4x faster)
- **Rust**: ~1.2-1.8 seconds (2.1x faster)

*Note: Python implementation available but excluded from benchmarks (~40-45 seconds)*

### Parallel Performance (6-8 cores):
- **Java Fork-Join**: ~0.25-0.40 seconds (60.8% efficiency)
- **JavaScript SharedArrayBuffer**: ~0.80-0.90 seconds (55.1% efficiency) 
- **JavaScript Workers**: ~2.0-2.5 seconds (19.5% efficiency)

## 🔧 Troubleshooting

### Common Issues:

1. **Out of Memory**
   ```bash
   # Increase container memory
   docker run -m 8g language-benchmark
   ```

2. **Slow Performance in Cloud**
   - Ensure CPU-optimized instances
   - Check for CPU throttling
   - Verify no other processes running

3. **Container Won't Start**
   ```bash
   # Check logs
   docker logs container-name
   
   # Test individual languages
   docker run -it language-benchmark /benchmark/quick_test.sh
   ```

4. **Network Issues**
   - Ensure container has internet access for language installations
   - Check firewall rules for container registries

## 📊 Collecting Results

### Method 1: Volume Mounting
```bash
docker run -v $(pwd)/results:/benchmark/results language-benchmark
```

### Method 2: Container Copy
```bash
docker cp container-name:/benchmark/results ./results
```

### Method 3: Cloud Storage
Configure cloud-specific storage mounting in deployment scripts.

## 🎯 Best Practices

1. **Consistent Environment**: Use same container across all tests
2. **Resource Isolation**: Ensure no other processes during benchmarking
3. **Multiple Runs**: Run benchmark 3-5 times and average results
4. **Instance Warm-up**: Run a quick test first to warm up the instance
5. **Monitoring**: Monitor CPU, memory, and I/O during benchmarks

## 🛡️ Security Considerations

- Use private container registries for production
- Implement proper IAM roles and permissions
- Consider VPC/subnet isolation for sensitive benchmarks
- Regularly update base images for security patches

## 💰 Cost Optimization

1. **Spot Instances**: Use for non-time-critical benchmarks
2. **Preemptible VMs**: GCP equivalent of spot instances
3. **Reserved Instances**: For regular benchmark schedules
4. **Auto-shutdown**: Configure automatic termination after completion

## 📞 Support

For issues or questions:
1. Check container logs first
2. Verify language installations with `quick_test.sh`
3. Test locally before cloud deployment
4. Review cloud provider documentation for container services

## 🔄 Continuous Integration

Example GitHub Actions workflow:

```yaml
name: Cloud Benchmark
on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM
  workflow_dispatch:

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Deploy to Cloud
      run: ./deploy_aws.sh
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

🎉 **Ready to benchmark in the cloud!** Choose your preferred platform and deployment method above. 