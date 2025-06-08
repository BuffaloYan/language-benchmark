#!/bin/bash

# Google Cloud Platform Deployment Script for Language Benchmark Suite
# Prerequisites: gcloud CLI configured, Docker installed

set -e

# Configuration
PROJECT_ID=${PROJECT_ID:-$(gcloud config get-value project)}
REGION=${REGION:-us-central1}
SERVICE_NAME="language-benchmark"
IMAGE_NAME="language-benchmark"

echo "🚀 Deploying Language Benchmark Suite to Google Cloud"
echo "====================================================="

echo "📋 Configuration:"
echo "- Project ID: ${PROJECT_ID}"
echo "- Region: ${REGION}"
echo "- Service Name: ${SERVICE_NAME}"
echo ""

# Enable required APIs
echo "🔧 Enabling required Google Cloud APIs..."
gcloud services enable cloudbuild.googleapis.com \
    run.googleapis.com \
    containerregistry.googleapis.com \
    compute.googleapis.com

# Build and push to Google Container Registry
echo "🔨 Building and pushing Docker image..."
gcloud builds submit --tag gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest \
    --region ${REGION} \
    --platform managed \
    --memory 8Gi \
    --cpu 4 \
    --timeout 3600 \
    --max-instances 1 \
    --set-env-vars BENCHMARK_MODE=cloud,GCP_PROJECT=${PROJECT_ID} \
    --allow-unauthenticated

# Get service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)')

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Service URL: ${SERVICE_URL}"
echo ""
echo "🚀 To run the benchmark:"
echo "curl -X POST ${SERVICE_URL}/run-benchmark"
echo ""
echo "📊 To view logs:"
echo "gcloud logs tail cloud-run/${SERVICE_NAME} --region ${REGION}"
echo ""
echo "🔧 Alternative: Run on Compute Engine:"
echo "1. Create VM instance:"
echo "   gcloud compute instances create benchmark-vm \\"
echo "     --zone ${REGION}-a \\"
echo "     --machine-type n1-highmem-8 \\"
echo "     --image-family ubuntu-2004-lts \\"
echo "     --image-project ubuntu-os-cloud"
echo ""
echo "2. SSH and run:"
echo "   gcloud compute ssh benchmark-vm --zone ${REGION}-a"
echo "   sudo apt-get update && sudo apt-get install -y docker.io"
echo "   sudo docker run -it gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest"
echo ""
echo "🎯 GKE deployment (advanced):"
echo "gcloud container clusters create benchmark-cluster \\"
echo "  --zone ${REGION}-a \\"
echo "  --machine-type n1-highmem-4 \\"
echo "  --num-nodes 1"
echo ""
echo "kubectl run benchmark \\"
echo "  --image gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest \\"
echo "  --requests='cpu=2,memory=4Gi' \\"
echo "  --limits='cpu=4,memory=8Gi'" 