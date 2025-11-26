pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('dockerhub-creds')
        IMAGE = "godratan/cicd-docker-website"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git 'https://github.com/2310030433-GodRatan/cicd-docker-website.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE:latest .'
            }
        }

        stage('Docker Login') {
            steps {
                sh "echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin"
            }
        }

        stage('Docker Push') {
            steps {
                sh 'docker push $IMAGE:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s-deployment.yml'
                sh 'kubectl apply -f k8s-service.yml'
            }
        }
    }
}
