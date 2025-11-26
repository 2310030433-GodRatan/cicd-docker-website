# CI/CD Docker Website - DevOps Project

## Overview
This project demonstrates a complete CI/CD pipeline using Docker, Jenkins, and Kubernetes for automated testing and deployment of a static HTML website.

## Project Structure
```
cicd/
├── cicd.html                 # Main HTML website
├── Dockerfile               # Docker image configuration
├── docker-compose.yml       # Local Docker development setup
├── Jenkinsfile             # Jenkins CI/CD pipeline configuration
├── k8s-namespace.yml       # Kubernetes namespace
├── k8s-deployment.yml      # Kubernetes deployment manifest
├── k8s-service.yml         # Kubernetes service manifest
├── docker-build-test.sh    # Docker build and test script
└── README.md               # This file
```

## Technologies Used
- **Docker**: Containerization
- **Jenkins**: CI/CD Automation
- **Kubernetes**: Container Orchestration
- **Nginx**: Web Server
- **GitHub**: Version Control

## Quick Start

### 1. Local Testing with Docker Compose
```bash
cd c:\Users\dell\OneDrive\Desktop\cicd
docker-compose up -d
```
Access the website at: `http://localhost:8080`

### 2. Manual Docker Build and Test
```bash
# Build image
docker build -t cicd-docker-website:latest .

# Run container
docker run -d -p 8080:80 --name cicd-website cicd-docker-website:latest

# Test
curl http://localhost:8080

# Stop and cleanup
docker stop cicd-website
docker rm cicd-website
```

## CI/CD Pipeline Stages

### Jenkins Pipeline
The Jenkinsfile orchestrates the following stages:

1. **Checkout**: Clone repository from GitHub
2. **Build Docker Image**: Build Docker image from Dockerfile
3. **Test Docker Container**: 
   - Start container
   - Run health checks
   - Validate HTML content
4. **Push to Docker Hub**: Push image to Docker Hub registry
5. **Deploy to Kubernetes**: Deploy to Kubernetes cluster
6. **Verify Deployment**: Verify pods and services are running

## Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (minikube, Docker Desktop K8s, or cloud cluster)
- kubectl configured
- Docker images pushed to registry

### Deploy to Kubernetes
```bash
# Apply manifests
kubectl apply -f k8s-namespace.yml
kubectl apply -f k8s-deployment.yml
kubectl apply -f k8s-service.yml

# Check status
kubectl get pods -n cicd-namespace
kubectl get svc -n cicd-namespace

# Port forward to access
kubectl port-forward svc/cicd-website 8080:80 -n cicd-namespace

# Access website
# Browser: http://localhost:8080
```

### Access the Application

**Via LoadBalancer Service (Cloud clusters):**
```bash
kubectl get svc -n cicd-namespace
# Get EXTERNAL-IP and access: http://EXTERNAL-IP
```

**Via NodePort Service:**
```bash
# Access on any cluster node:
http://cluster-node-ip:30080
```

**Via Port Forward (Local/Dev):**
```bash
kubectl port-forward svc/cicd-website 8080:80 -n cicd-namespace
# Access: http://localhost:8080
```

## Jenkins Setup Instructions

### 1. Install Jenkins
```bash
# Using Docker
docker run -d -p 8081:8080 --name jenkins jenkins/jenkins:lts

# Get initial password
docker logs jenkins | grep "Initial admin password"
```

### 2. Configure Jenkins Pipeline
1. Create new Pipeline job in Jenkins
2. Point to GitHub repository: `https://github.com/2310030433-GodRatan/cicd-docker-website.git`
3. Pipeline script from SCM: `Jenkinsfile`

### 3. Add Credentials
- Docker Hub credentials (username/password)
- GitHub credentials (for repository access)
- Kubernetes config (for cluster deployment)

### 4. Configure Docker Socket Access
```bash
# For Linux-based Jenkins
sudo chmod 666 /var/run/docker.sock

# Or add jenkins user to docker group
sudo usermod -aG docker jenkins
```

## Testing

### Local Docker Testing
```bash
# Run docker-compose
docker-compose up -d

# Verify health
docker exec cicd-docker-website wget --spider http://localhost/

# View logs
docker logs cicd-docker-website

# Cleanup
docker-compose down
```

### Kubernetes Testing
```bash
# Check pod health
kubectl get pods -n cicd-namespace
kubectl describe pod <pod-name> -n cicd-namespace
kubectl logs <pod-name> -n cicd-namespace

# Test service connectivity
kubectl run -it --rm debug --image=ubuntu:latest --restart=Never -n cicd-namespace -- bash
# Inside pod: curl http://cicd-website/
```

## Monitoring and Logs

### Docker Logs
```bash
docker logs cicd-website
docker logs -f cicd-website  # Follow logs
```

### Kubernetes Logs
```bash
kubectl logs <pod-name> -n cicd-namespace
kubectl logs -f <pod-name> -n cicd-namespace  # Follow logs
kubectl logs <pod-name> -n cicd-namespace --tail=100
```

### Kubernetes Dashboard
```bash
kubectl proxy
# Access: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

## Scaling

### Manual Scaling
```bash
# Scale deployment to 5 replicas
kubectl scale deployment cicd-website -n cicd-namespace --replicas=5

# Verify
kubectl get pods -n cicd-namespace
```

### Horizontal Pod Autoscaler
```bash
kubectl autoscale deployment cicd-website \
  -n cicd-namespace \
  --min=2 \
  --max=10 \
  --cpu-percent=80
```

## Cleanup

### Docker Cleanup
```bash
docker-compose down
docker image rm cicd-docker-website:latest
docker system prune -a
```

### Kubernetes Cleanup
```bash
kubectl delete namespace cicd-namespace
# Or delete individual resources:
kubectl delete deployment cicd-website -n cicd-namespace
kubectl delete service cicd-website -n cicd-namespace
kubectl delete namespace cicd-namespace
```

## Author
- **Name**: Ratan
- **Institution**: KL University
- **Email**: 2310030433@klh.edu.in
- **GitHub**: github.com/2310030433-GodRatan
- **Specialization**: Cloud Computing & DevOps

## License
This project is open source and available under the MIT License.

## Support
For issues or questions, please contact:
- Email: 2310030433@klh.edu.in
- Phone: +91-7075969686
- GitHub Issues: github.com/2310030433-GodRatan/cicd-docker-website/issues
