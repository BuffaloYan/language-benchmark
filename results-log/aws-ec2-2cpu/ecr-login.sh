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

# Get ECR login
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
