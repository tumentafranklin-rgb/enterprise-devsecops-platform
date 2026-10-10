# Enterprise DevSecOps Platform Architecture

This diagram illustrates the CI/CD pipeline implemented in this project.

```mermaid
flowchart TD
    A[Developer] --> B[GitHub Repository]
    B --> C[Jenkins CI/CD Pipeline]

    C --> D[Gitleaks<br/>Secret Scanning]
    D --> E[Semgrep<br/>Static Analysis]
    E --> F[Docker Image Build]
    F --> G[Trivy<br/>Vulnerability Scanning]
    G --> H[Container Health Test]
    H --> I[Amazon ECR]

    I --> J[AWS Systems Manager]
    J --> K[Amazon EC2]
    K --> L[Docker Container]
    L --> M[FastAPI Application]
    M --> N[/health Endpoint]

    classDef source fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef security fill:#fef3c7,stroke:#d97706,color:#111827
    classDef deployment fill:#dcfce7,stroke:#16a34a,color:#111827

    class A,B source
    class D,E,G security
    class I,J,K,L,M,N deployment
```
