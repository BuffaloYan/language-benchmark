#!/bin/bash

# AWS Deployment Script for Language Benchmark Suite
# Prerequisites: AWS CLI configured, Docker installed

set -e

# Configuration
AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REPO_NAME="language-benchmark"
CLUSTER_NAME="benchmark-cluster"
SERVICE_NAME="benchmark-service"
TASK_FAMILY="benchmark-task"

echo "🚀 Deploying Language Benchmark Suite to AWS"
echo "=============================================="

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

echo "📋 Configuration:"
echo "- AWS Region: ${AWS_REGION}"
echo "- Account ID: ${ACCOUNT_ID}"
echo "- ECR Repository: ${ECR_URI}"
echo ""

# Create ECR repository if it doesn't exist
echo "🏗️  Setting up ECR repository..."
aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_REGION} 2>/dev/null || \
aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION}

# Get ECR login
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}

# Build and push Docker image
echo "🔨 Building Docker image..."
cd ..
docker build -f cloud/Dockerfile -t ${ECR_REPO_NAME}:latest .
docker tag ${ECR_REPO_NAME}:latest ${ECR_URI}:latest

echo "📤 Pushing to ECR..."
docker push ${ECR_URI}:latest

# Create ECS cluster if it doesn't exist
echo "🏗️  Setting up ECS cluster..."
aws ecs describe-clusters --clusters ${CLUSTER_NAME} --region ${AWS_REGION} 2>/dev/null || \
aws ecs create-cluster --cluster-name ${CLUSTER_NAME} --region ${AWS_REGION}

# Create task definition
echo "📝 Creating ECS task definition..."
cat > task-definition.json << EOF
{
  "family": "${TASK_FAMILY}",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "4096",
  "memory": "8192",
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "benchmark-container",
      "image": "${ECR_URI}:latest",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/benchmark",
          "awslogs-region": "${AWS_REGION}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "environment": [
        {"name": "BENCHMARK_MODE", "value": "cloud"},
        {"name": "AWS_REGION", "value": "${AWS_REGION}"}
      ]
    }
  ]
}
EOF

# Create CloudWatch log group
aws logs create-log-group --log-group-name /ecs/benchmark --region ${AWS_REGION} 2>/dev/null || true

# Register task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json --region ${AWS_REGION}

echo ""
echo "✅ Deployment setup complete!"
echo ""
echo "🧪 To test the environment first:"
echo "docker run --rm ${ECR_URI}:latest /benchmark/scripts/test_environment.sh"
echo ""
echo "🚀 To run the benchmark:"
echo "aws ecs run-task \\"
echo "  --cluster ${CLUSTER_NAME} \\"
echo "  --task-definition ${TASK_FAMILY} \\"
echo "  --launch-type FARGATE \\"
echo "  --network-configuration 'awsvpcConfiguration={subnets=[subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}' \\"
echo "  --region ${AWS_REGION}"
echo ""
echo "📊 To view logs:"
echo "aws logs tail /ecs/benchmark --follow --region ${AWS_REGION}"
echo ""
echo "🔧 Alternative: Run on EC2 instance:"
echo "1. Launch EC2 instance with Docker"
echo "2. Install Docker and AWS CLI"
echo "3. Test: docker run --rm ${ECR_URI}:latest /benchmark/scripts/test_environment.sh"
echo "4. Run: docker run --rm -v \$(pwd)/results:/benchmark/results ${ECR_URI}:latest"

# Clean up
rm -f task-definition.json 