pipeline {
    agent any

    environment {
        IMAGE_NAME = "enterprise-devsecops-platform"
        IMAGE_TAG = "${BUILD_NUMBER}"
        AWS_REGION = "us-east-1"
        ECR_REGISTRY = "126309364316.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPOSITORY = "aws-cicd-pipeline"
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Secret Scan - Gitleaks") {
            steps {
                sh "gitleaks detect --source . --verbose"
            }
        }

        stage("SAST - Semgrep") {
            steps {
                sh "rm -rf .semgrep-scan && mkdir .semgrep-scan && git archive HEAD | tar -x -C .semgrep-scan && docker run --rm -v \"${WORKSPACE}/.semgrep-scan:/src:ro\" semgrep/semgrep semgrep scan --config auto --error /src; rm -rf .semgrep-scan"
            }
        }

        stage("Build Docker Image") {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage("Container Scan - Trivy") {
            steps {
                sh "trivy image --scanners vuln --severity CRITICAL --exit-code 1 ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage("Test Container") {
            steps {
                sh "docker run -d --name ${IMAGE_NAME}-test-${BUILD_NUMBER} -p 18000:8000 ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "sleep 5"
                sh "curl --fail http://localhost:18000/health"
            }
        }

        stage("Push Image to ECR") {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
            }
        }
    }

    post {
        always {
            sh "docker rm -f ${IMAGE_NAME}-test-${BUILD_NUMBER} || true"
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
            sh "docker rmi ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} || true"
        }
    }
}
