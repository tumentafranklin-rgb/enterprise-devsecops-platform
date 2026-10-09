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
