# DevSecOps Security Policy

## Purpose

This project uses automated security gates to identify security issues before application changes are promoted toward deployment.

## Security Controls

- Secret scanning: detect accidentally committed credentials and secrets.
- Static application security testing (SAST): identify insecure application code patterns.
- Dependency scanning: identify vulnerable third-party packages.
- Container scanning: identify vulnerabilities in Docker images.
- Infrastructure-as-Code scanning: identify insecure Terraform configurations.

## Security Gate

Critical security findings must block promotion until they are reviewed and resolved or formally accepted.

## Principle

Security checks are automated as part of CI/CD rather than performed only after deployment.
