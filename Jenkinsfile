pipeline {
    agent any

    environment {
        IMAGE_NAME = "enterprise-devsecops-platform"
        IMAGE_TAG = "${BUILD_NUMBER}"
        AWS_REGION = "us-east-1"
        ECR_REGISTRY = "126309364316.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPOSITORY = "aws-cicd-pipeline"
        EC2_INSTANCE_ID = "i-028193a3d35a63527"
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
                sh '''
                    rm -rf .semgrep-scan
                    mkdir .semgrep-scan
                    git archive HEAD | tar -x -C .semgrep-scan

                    docker run --rm \
                      -v "${WORKSPACE}/.semgrep-scan:/src:ro" \
                      semgrep/semgrep \
                      semgrep scan --config auto --error /src

                    rm -rf .semgrep-scan
                '''
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
                sh '''
                    docker run -d \
                      --name ${IMAGE_NAME}-test-${BUILD_NUMBER} \
                      -p 18000:8000 \
                      ${IMAGE_NAME}:${IMAGE_TAG}

                    sleep 5

                    curl --fail http://localhost:18000/health
                '''
            }
        }

        stage("Push Image to ECR") {
            steps {
                sh '''
                    aws ecr get-login-password \
                      --region ${AWS_REGION} | \
                      docker login \
                      --username AWS \
                      --password-stdin ${ECR_REGISTRY}

                    docker tag \
                      ${IMAGE_NAME}:${IMAGE_TAG} \
                      ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}

                    docker push \
                      ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                '''
            }
        }

        stage("Deploy to EC2 via SSM") {
            steps {
                sh '''
                    set -e

                    echo "Starting EC2 deployment..."
                    echo "Deploying image tag: ${IMAGE_TAG}"

                    COMMAND_ID=$(aws ssm send-command \
                      --region ${AWS_REGION} \
                      --document-name AWS-RunShellScript \
                      --instance-ids ${EC2_INSTANCE_ID} \
                      --parameters "{\"commands\":[\"set -e\",\"echo Starting deployment on EC2\",\"aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 126309364316.dkr.ecr.us-east-1.amazonaws.com\",\"docker pull 126309364316.dkr.ecr.us-east-1.amazonaws.com/aws-cicd-pipeline:${IMAGE_TAG}\",\"docker stop enterprise-devsecops-api || true\",\"docker rm enterprise-devsecops-api || true\",\"docker run -d --restart unless-stopped --name enterprise-devsecops-api -p 8000:8000 126309364316.dkr.ecr.us-east-1.amazonaws.com/aws-cicd-pipeline:${IMAGE_TAG}\",\"sleep 5\",\"curl --fail http://localhost:8000/health\",\"echo Deployment completed successfully\"]}" \
                      --query 'Command.CommandId' \
                      --output text)

                    echo "SSM Command ID: ${COMMAND_ID}"

                    for i in $(seq 1 20); do

                        STATUS=$(aws ssm get-command-invocation \
                          --region ${AWS_REGION} \
                          --command-id "${COMMAND_ID}" \
                          --instance-id ${EC2_INSTANCE_ID} \
                          --query 'Status' \
                          --output text)

                        echo "SSM deployment status: ${STATUS}"

                        if [ "${STATUS}" = "Success" ]; then

                            aws ssm get-command-invocation \
                              --region ${AWS_REGION} \
                              --command-id "${COMMAND_ID}" \
                              --instance-id ${EC2_INSTANCE_ID} \
                              --query '{Status:Status,Output:StandardOutputContent,Error:StandardErrorContent}' \
                              --output json

                            echo "EC2 deployment successful."
                            exit 0
                        fi

                        if [ "${STATUS}" = "Failed" ] || \
                           [ "${STATUS}" = "Cancelled" ] || \
                           [ "${STATUS}" = "TimedOut" ]; then

                            aws ssm get-command-invocation \
                              --region ${AWS_REGION} \
                              --command-id "${COMMAND_ID}" \
                              --instance-id ${EC2_INSTANCE_ID} \
                              --query '{Status:Status,Output:StandardOutputContent,Error:StandardErrorContent}' \
                              --output json

                            echo "EC2 deployment failed."
                            exit 1
                        fi

                        sleep 3
                    done

                    echo "SSM deployment timed out."
                    exit 1
                '''
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
