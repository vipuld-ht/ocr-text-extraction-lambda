#!/bin/bash

# Export environment variables
export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:?"AWS_ACCOUNT_ID is not set"}
export AWS_REGION=${AWS_REGION:?"AWS_REGION is not set"}

# Variables
IMAGE_NAME="text-extractor-ocr-lambda"
ECR_REPO="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME"

# Build Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME .

# Tag Docker image
echo "Tagging Docker image..."
docker tag $IMAGE_NAME:latest $ECR_REPO:latest

# Create ECR repository (if it doesn't exist)
echo "Creating ECR repository if not exists..."
aws ecr create-repository --repository-name $IMAGE_NAME --region $AWS_REGION || true

# Authenticate Docker to AWS ECR
echo "Authenticating Docker with AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

# Push Docker image to ECR
echo "Pushing Docker image to AWS ECR..."
docker push $ECR_REPO:latest

echo "Docker image successfully pushed to ECR!"