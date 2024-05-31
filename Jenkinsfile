pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '767397878056' 
        AWS_REGION = 'us-east-1'       
        ECR_REPOSITORY = 'app-repo'      
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
        AWS_CREDENTIALS_ID = 'awscreds'  
        KUBECONFIG_CREDENTIALS_ID = 'k8screds'
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
                    sh "docker tag backend:latest ${ECR_URL}:backend-${env.BRANCH_NAME}"
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                script {
                    sh 'cd frontend && docker build -t frontend:latest .'  // Ensure Dockerfile exists in 'frontend' directory
                    sh "docker tag frontend:latest ${ECR_URL}:frontend-${env.BRANCH_NAME}"
                }
            }
        }

        stage('Push Backend Docker Image to ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                        sh "docker push ${ECR_URL}:backend-${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Push Frontend Docker Image to ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        sh "docker push ${ECR_URL}:frontend-${env.BRANCH_NAME}"
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
