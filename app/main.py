from fastapi import FastAPI

app = FastAPI(title="Enterprise DevSecOps Platform")

@app.get("/")
def root():
    return {"application": "enterprise-devsecops-platform", "status": "running"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/api/info")
def info():
    return {"service": "devsecops-demo-api", "version": "1.0.0", "environment": "development"}
