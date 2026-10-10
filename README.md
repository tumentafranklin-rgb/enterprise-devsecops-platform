# Enterprise DevSecOps Platform

A production-style DevSecOps CI/CD platform demonstrating automated security scanning, containerization, AWS ECR image management, and automated EC2 deployment through AWS Systems Manager.

## Architecture

```text
Developer
    |
    v
GitHub
    |
    | Push to main
    v
Jenkins
    |
    +--> Gitleaks
    |      Secret Detection
    |
    +--> Semgrep
    |      Static Application Security Testing
    |
    +--> Docker Build
    |
    +--> Trivy
    |      Container Vulnerability Scanning
    |
    +--> Container Health Test
    |
    v
Amazon ECR
    |
    | Docker Image
    v
AWS Systems Manager
    |
    v
Amazon EC2
    |
    v
Docker Container
    |
    v
FastAPI Application
    |
    v
/health


---

## What I Learned

Through this project, I gained hands-on experience with:

- Building automated CI/CD pipelines using Jenkins.
- Integrating security scanning into the software delivery process.
- Detecting exposed secrets using Gitleaks.
- Performing static application security testing with Semgrep.
- Scanning Docker images for vulnerabilities using Trivy.
- Building and publishing Docker images to Amazon ECR.
- Deploying applications to AWS EC2 using Systems Manager.
- Troubleshooting AWS IAM permissions and deployment failures.
- Testing application health after deployment.
- Using Git and GitHub for version control and project collaboration.
- Understanding how security gates help prevent vulnerable images from being promoted.

## Security Controls

This project demonstrates the following security practices:

- Automated secret scanning.
- Static application security testing.
- Container vulnerability scanning.
- Critical-severity vulnerability checks.
- Non-root execution inside Docker containers.
- Private container image storage in Amazon ECR.
- Deployment automation through AWS Systems Manager.
- Documented security policies.

## Deployment Verification

The application exposes a health endpoint:

`/health`

The CI/CD pipeline verifies that the application responds successfully after deployment.

## Future Improvements

- Configure GitHub Actions with AWS OIDC instead of long-lived access keys.
- Apply least-privilege IAM permissions to deployment components.
- Secure Jenkins with HTTPS and stronger network restrictions.
- Deploy the application to Kubernetes or Amazon EKS.
- Introduce monitoring using Prometheus and Grafana.
- Add OpenTelemetry and centralized logging.
- Create incident-response runbooks.
- Integrate Sonatype Nexus for artifact management.

## Author

**Franklin Tumenta**

DevOps | AWS Cloud Security | DevSecOps

GitHub: [tumentafranklin-rgb](https://github.com/tumentafranklin-rgb)

Project Repository: [Enterprise DevSecOps Platform](https://github.com/tumentafranklin-rgb/enterprise-devsecops-platform)
