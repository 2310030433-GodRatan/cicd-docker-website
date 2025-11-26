#!/bin/bash

# CI/CD Docker Build and Test Script
# This script builds the Docker image and performs testing

set -e  # Exit on error

echo "=========================================="
echo "CI/CD Docker Build and Test Script"
echo "=========================================="

# Variables
IMAGE_NAME="cicd-docker-website"
IMAGE_TAG="latest"
CONTAINER_NAME="test-${IMAGE_NAME}-$$"
PORT=8080

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Step 1: Build Docker Image
print_info "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
print_status "Docker image built successfully"

# Step 2: Run Docker Container
print_info "Starting Docker container..."
docker run -d --name ${CONTAINER_NAME} -p ${PORT}:80 ${IMAGE_NAME}:${IMAGE_TAG}
print_status "Container started: ${CONTAINER_NAME}"

# Wait for container to be ready
print_info "Waiting for container to be ready..."
sleep 10

# Step 3: Health Check
print_info "Running health checks..."
if docker exec ${CONTAINER_NAME} wget --quiet --tries=1 --spider http://localhost/; then
    print_status "HTTP health check passed"
else
    print_error "HTTP health check failed"
    docker logs ${CONTAINER_NAME}
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
    exit 1
fi

# Step 4: Validate HTML Content
print_info "Validating HTML content..."
if docker exec ${CONTAINER_NAME} grep -q "CI/CD Docker Platform" /usr/share/nginx/html/index.html; then
    print_status "HTML content validation passed"
else
    print_error "HTML content validation failed"
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
    exit 1
fi

# Step 5: Get Container Stats
print_info "Container resource usage:"
docker stats --no-stream ${CONTAINER_NAME}

# Step 6: Test HTTP Request
print_info "Testing HTTP request to container..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT}/)
if [ $RESPONSE -eq 200 ]; then
    print_status "HTTP request successful (Status: $RESPONSE)"
else
    print_error "HTTP request failed (Status: $RESPONSE)"
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
    exit 1
fi

# Step 7: Display Running Container Info
print_info "Running container information:"
docker ps | grep ${CONTAINER_NAME}

echo ""
print_status "All tests passed successfully!"
echo ""
print_info "Container is running at: http://localhost:${PORT}"
print_info "Container name: ${CONTAINER_NAME}"
echo ""
print_info "To stop and remove container, run:"
echo "  docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"

echo ""
echo "=========================================="
echo "Build and Test Complete"
echo "=========================================="
