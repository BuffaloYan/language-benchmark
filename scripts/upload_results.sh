#!/bin/bash

# Upload Results to S3 Script
# This script uploads benchmark results to an S3 bucket

set -e

# Check if S3_RESULTS_BUCKET environment variable is set
if [ -z "$S3_RESULTS_BUCKET" ]; then
    echo "❌ S3_RESULTS_BUCKET environment variable is not set"
    exit 1
fi

# Check if AWS credentials are available
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS credentials not configured or not valid"
    exit 1
fi

# Create timestamp for unique folder
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HOSTNAME=${HOSTNAME:-"unknown"}
S3_PREFIX="benchmark-results/${TIMESTAMP}_${HOSTNAME}"

echo "📤 Uploading benchmark results to S3..."
echo "Bucket: ${S3_RESULTS_BUCKET}"
echo "Prefix: ${S3_PREFIX}"

# Check if results directory exists
if [ ! -d "/benchmark/results" ]; then
    echo "❌ Results directory not found at /benchmark/results"
    exit 1
fi

# Upload all results to S3
aws s3 sync /benchmark/results s3://${S3_RESULTS_BUCKET}/${S3_PREFIX}/ \
    --exclude "*.tmp" \
    --exclude ".*" \
    --delete

echo "✅ Results uploaded successfully!"
echo "📥 To download results:"
echo "aws s3 sync s3://${S3_RESULTS_BUCKET}/${S3_PREFIX}/ ./results"
echo ""
echo "🔗 S3 Console URL:"
echo "https://s3.console.aws.amazon.com/s3/buckets/${S3_RESULTS_BUCKET}?prefix=${S3_PREFIX}/"

# Create a manifest file with metadata
cat > /tmp/manifest.json << EOF
{
  "timestamp": "${TIMESTAMP}",
  "hostname": "${HOSTNAME}",
  "s3_bucket": "${S3_RESULTS_BUCKET}",
  "s3_prefix": "${S3_PREFIX}",
  "upload_time": "$(date -Iseconds)",
  "aws_region": "${AWS_REGION:-us-east-1}"
}
EOF

# Upload manifest
aws s3 cp /tmp/manifest.json s3://${S3_RESULTS_BUCKET}/${S3_PREFIX}/manifest.json

echo "📋 Manifest uploaded with run metadata" 