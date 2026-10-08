pipeline {
    agent any

    environment {
        IMAGE_NAME = "enterprise-devsecops-platform"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Build Docker Image") {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage("Test Container") {
            steps {
                sh "docker run -d --name ${IMAGE_NAME}-test-${BUILD_NUMBER} -p 18000:8000 ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "sleep 5"
                sh "curl --fail http://localhost:18000/health"
            }
        }
    }

    post {
        always {
            sh "docker rm -f ${IMAGE_NAME}-test-${BUILD_NUMBER} || true"
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
        }
    }
}
