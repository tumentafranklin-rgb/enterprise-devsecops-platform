#!/bin/bash

set -e

AWS_REGION="us-east-1"
ECR_REGISTRY="126309364316.dkr.ecr.us-east-1.amazonaws.com"
ECR_REPOSITORY="aws-cicd-pipeline"
EC2_INSTANCE_ID="i-028193a3d35a63527"
IMAGE_TAG="${1}"

if [ -z "${IMAGE_TAG}" ]; then
    echo "ERROR: Image tag is required."
    exit 1
fi

echo "Starting EC2 deployment..."
echo "Deploying image tag: ${IMAGE_TAG}"

cat > ssm-commands.json <<EOF
{
  "commands": [
    "set -e",
    "echo Starting deployment on EC2",
    "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}",
    "docker pull ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}",
    "docker stop enterprise-devsecops-api || true",
    "docker rm enterprise-devsecops-api || true",
    "docker run -d --restart unless-stopped --name enterprise-devsecops-api -p 8000:8000 ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}",
    "sleep 5",
    "curl --fail http://localhost:8000/health",
    "echo Deployment completed successfully"
  ]
}
EOF

echo "Sending deployment command to EC2..."

COMMAND_ID=$(aws ssm send-command \
    --region "${AWS_REGION}" \
    --document-name AWS-RunShellScript \
    --instance-ids "${EC2_INSTANCE_ID}" \
    --parameters file://ssm-commands.json \
    --query 'Command.CommandId' \
    --output text)

echo "SSM Command ID: ${COMMAND_ID}"

rm -f ssm-commands.json

for i in $(seq 1 30); do

    STATUS=$(aws ssm get-command-invocation \
        --region "${AWS_REGION}" \
        --command-id "${COMMAND_ID}" \
        --instance-id "${EC2_INSTANCE_ID}" \
        --query 'Status' \
        --output text 2>/dev/null || printf 'Pending')

    echo "SSM deployment status: ${STATUS}"

    if [ "${STATUS}" = "Success" ]; then

        aws ssm get-command-invocation \
            --region "${AWS_REGION}" \
            --command-id "${COMMAND_ID}" \
            --instance-id "${EC2_INSTANCE_ID}" \
            --query '{Status:Status,Output:StandardOutputContent,Error:StandardErrorContent}' \
            --output json

        echo "EC2 deployment successful."
        exit 0
    fi

    if [ "${STATUS}" = "Failed" ] || \
       [ "${STATUS}" = "Cancelled" ] || \
       [ "${STATUS}" = "TimedOut" ]; then

        aws ssm get-command-invocation \
            --region "${AWS_REGION}" \
            --command-id "${COMMAND_ID}" \
            --instance-id "${EC2_INSTANCE_ID}" \
            --query '{Status:Status,Output:StandardOutputContent,Error:StandardErrorContent}' \
            --output json

        echo "EC2 deployment failed."
        exit 1
    fi

    sleep 3
done

echo "SSM deployment timed out."
exit 1
