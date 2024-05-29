pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '767397878056'  // Replace with your AWS account ID
        AWS_REGION = 'us-east-1'         // Replace with your AWS region
        ECR_REPOSITORY = 'app-repo'      // Replace with your ECR repository name
        ECR_URL = "${767397878056}.dkr.ecr.${us-east-1}.amazonaws.com/${app-repo}" //767397878056.dkr.ecr.us-east-1.amazonaws.com/app-repo
        AWS_CREDENTIALS_ID = 'awscreds'  // Replace with the ID of your AWS credentials in Jenkins
        KUBECONFIG_CREDENTIALS_ID = 'k8screds'  // Replace with the ID of your kubeconfig file in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Yasser-gamil/NTI-Final-Project.git'  // Replace with your GitHub repo URL and branch
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                script {
                    sh 'cd backend && docker build -t backend:latest .'  // Ensure Dockerfile exists in 'backend' directory
                    sh "docker tag backend:latest ${767397878056.dkr.ecr.us-east-1.amazonaws.com/app-repo}:backend-${main}"
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                script {
                    sh 'cd frontend && docker build -t frontend:latest .'  // Ensure Dockerfile exists in 'frontend' directory
                    sh "docker tag frontend:latest ${767397878056.dkr.ecr.us-east-1.amazonaws.com/app-repo}:frontend-${main}"
                }
            }
        }

        stage('Push Backend Docker Image to ECR') {
            steps {
                script {
                    withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, region: AWS_REGION)]) {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                        sh "docker push ${767397878056.dkr.ecr.us-east-1.amazonaws.com/app-repo}:backend-${main}"
                    }
                }
            }
        }

        stage('Push Frontend Docker Image to ECR') {
            steps {
                script {
                    withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, region: AWS_REGION)]) {
                        sh "docker push ${767397878056.dkr.ecr.us-east-1.amazonaws.com/app-repo}:frontend-${main}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG')]) {
                        sh 'kubectl apply -f k8s'  // Ensure your Kubernetes manifests are in the 'k8s' directory
                    }
                }
            }
        }
    }
}
