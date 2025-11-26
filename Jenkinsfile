pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = '2310030433/cicd-docker-website'
        IMAGE_TAG = '${BUILD_NUMBER}'
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        GITHUB_CREDENTIALS = credentials('github-credentials')
    }

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {
            steps {
                echo '========== Checking out source code =========='
                checkout scm
                sh 'git log --oneline -5'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '========== Building Docker image =========='
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Test Docker Container') {
            steps {
                echo '========== Testing Docker container =========='
                sh '''
                    # Start container
                    docker run -d --name test-${BUILD_NUMBER} -p 8080:80 ${IMAGE_NAME}:${IMAGE_TAG}
                    
                    # Wait for container to be ready
                    sleep 10
                    
                    # Run health checks
                    echo "Testing HTTP response..."
                    docker exec test-${BUILD_NUMBER} wget --quiet --tries=1 --spider http://localhost/
                    
                    # Check HTML content
                    echo "Validating HTML content..."
                    docker exec test-${BUILD_NUMBER} grep -q "CI/CD Docker Platform" /usr/share/nginx/html/index.html
                    
                    # Get container stats
                    echo "Container stats:"
                    docker stats --no-stream test-${BUILD_NUMBER}
                    
                    # Stop test container
                    docker stop test-${BUILD_NUMBER}
                    docker rm test-${BUILD_NUMBER}
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '========== Pushing image to Docker Hub =========='
                sh '''
                    echo ${DOCKER_CREDENTIALS_PSW} | docker login -u ${DOCKER_CREDENTIALS_USR} --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                    docker logout
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo '========== Deploying to Kubernetes =========='
                sh '''
                    # Update image tag in k8s deployment
                    sed -i "s|IMAGE_TAG|${IMAGE_TAG}|g" k8s-deployment.yml
                    
                    # Apply Kubernetes manifests
                    kubectl apply -f k8s-namespace.yml
                    kubectl apply -f k8s-deployment.yml
                    kubectl apply -f k8s-service.yml
                    
                    # Wait for deployment to be ready
                    kubectl rollout status deployment/cicd-website -n cicd-namespace --timeout=5m
                    
                    # Get deployment info
                    kubectl get pods -n cicd-namespace
                    kubectl get svc -n cicd-namespace
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '========== Verifying Kubernetes deployment =========='
                sh '''
                    # Get service details
                    kubectl get all -n cicd-namespace
                    
                    # Port forward and test (background)
                    kubectl port-forward svc/cicd-website 8080:80 -n cicd-namespace &
                    sleep 5
                    
                    # Test the service
                    curl -f http://localhost:8080/ || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo '========== Build Successful =========='
            sh '''
                echo "Deployment completed successfully!"
                kubectl get pods -n cicd-namespace
            '''
        }
        failure {
            echo '========== Build Failed =========='
            sh '''
                # Cleanup on failure
                docker stop test-${BUILD_NUMBER} || true
                docker rm test-${BUILD_NUMBER} || true
            '''
        }
        always {
            echo '========== Cleanup =========='
            sh '''
                docker system prune -f --filter "until=24h" || true
            '''
        }
    }
}
