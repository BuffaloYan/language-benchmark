#!/bin/bash

# Azure Deployment Script for Language Benchmark Suite
# Prerequisites: Azure CLI configured, Docker installed

set -e

# Configuration
RESOURCE_GROUP=${RESOURCE_GROUP:-benchmark-rg}
LOCATION=${LOCATION:-eastus}
ACR_NAME=${ACR_NAME:-benchmarkacr$(date +%s)}
CONTAINER_NAME="language-benchmark"
IMAGE_NAME="language-benchmark"

echo "🚀 Deploying Language Benchmark Suite to Azure"
echo "==============================================="

echo "📋 Configuration:"
echo "- Resource Group: ${RESOURCE_GROUP}"
echo "- Location: ${LOCATION}"
echo "- ACR Name: ${ACR_NAME}"
echo ""

# Create resource group
echo "🏗️  Creating resource group..."
az group create --name ${RESOURCE_GROUP} --location ${LOCATION}

# Create Azure Container Registry
echo "🏗️  Creating Azure Container Registry..."
az acr create --resource-group ${RESOURCE_GROUP} \
    --name ${ACR_NAME} \
    --sku Basic \
    --admin-enabled true

# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name ${ACR_NAME} --query loginServer --output tsv)

# Login to ACR
echo "🔐 Logging into ACR..."
az acr login --name ${ACR_NAME}

# Build and push Docker image
echo "🔨 Building and pushing Docker image..."
az acr build --registry ${ACR_NAME} --image ${IMAGE_NAME}:latest .

# Get ACR credentials
ACR_USERNAME=$(az acr credential show --name ${ACR_NAME} --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name ${ACR_NAME} --query passwords[0].value --output tsv)

# Deploy to Azure Container Instances
echo "🚀 Deploying to Azure Container Instances..."
az container create \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CONTAINER_NAME} \
    --image ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest \
    --cpu 4 \
    --memory 8 \
    --restart-policy Never \
    --environment-variables \
        BENCHMARK_MODE=cloud \
        AZURE_RESOURCE_GROUP=${RESOURCE_GROUP} \
    --registry-login-server ${ACR_LOGIN_SERVER} \
    --registry-username ${ACR_USERNAME} \
    --registry-password ${ACR_PASSWORD}

# Get container details
CONTAINER_IP=$(az container show --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_NAME} --query ipAddress.ip --output tsv)

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Container IP: ${CONTAINER_IP}"
echo ""
echo "📊 To view logs:"
echo "az container logs --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_NAME} --follow"
echo ""
echo "🔧 To check status:"
echo "az container show --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_NAME} --query instanceView.state"
echo ""
echo "🔄 To restart container:"
echo "az container restart --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_NAME}"
echo ""
echo "🗑️  To clean up resources:"
echo "az group delete --name ${RESOURCE_GROUP} --yes --no-wait"
echo ""
echo "🎯 Alternative: Azure Container Apps (serverless):"
echo "az containerapp env create \\"
echo "  --name benchmark-env \\"
echo "  --resource-group ${RESOURCE_GROUP} \\"
echo "  --location ${LOCATION}"
echo ""
echo "az containerapp create \\"
echo "  --name benchmark-app \\"
echo "  --resource-group ${RESOURCE_GROUP} \\"
echo "  --environment benchmark-env \\"
echo "  --image ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest \\"
echo "  --cpu 2 \\"
echo "  --memory 4Gi \\"
echo "  --registry-server ${ACR_LOGIN_SERVER} \\"
echo "  --registry-username ${ACR_USERNAME} \\"
echo "  --registry-password ${ACR_PASSWORD}" 