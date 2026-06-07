# GitOps Deployment Plan: Spring Boot to AWS EKS with ArgoCD

## Overview
This plan outlines a complete GitOps workflow for deploying a Spring Boot application to Amazon EKS with automated CI/CD using GitHub Actions and GitOps principles with ArgoCD.

## Architecture
```
GitHub Repository (Source Code)
    ↓
GitHub Actions (CI Pipeline)
    ↓
Build & Push Docker Image to ECR
    ↓
Update K8s Manifests
    ↓
Push to Config Repository
    ↓
ArgoCD (CD Pipeline)
    ↓
Automatically Deploy to EKS
```

## Phase 1: Containerization (Week 1)
### 1.1 Create Dockerfile
- Multi-stage build for optimization
- Use Maven to build the application
- Base image: openjdk:21-slim

### 1.2 Create Docker Compose (Optional - for local testing)
- Service: gitops-app
- Port mapping: 8080

---

## Phase 2: Kubernetes Manifests (Week 1)
### 2.1 Create K8s Deployment Manifest
- Replicas: 3
- Resource requests/limits
- Liveness and readiness probes
- Image: ECR repository URI

### 2.2 Create K8s Service Manifest
- Type: LoadBalancer or NodePort
- Expose port 8080

### 2.3 Create Namespace
- Namespace: gitops-app

### 2.4 Create ConfigMap
- Application properties
- Spring profile configuration

---

## Phase 3: CI/CD Pipeline with GitHub Actions (Week 2)
### 3.1 Build Pipeline (.github/workflows/build.yml)
**Triggers:** Push to main/develop branches

**Steps:**
1. Checkout code
2. Set up JDK 21
3. Build with Maven (mvn clean package)
4. Run tests
5. Build Docker image
6. Push to AWS ECR
7. Trigger deployment pipeline

### 3.2 Deployment Pipeline (.github/workflows/deploy.yml)
**Triggers:** Successful build

**Steps:**
1. Update K8s manifests with new image tag
2. Commit changes to config repository
3. Push to GitOps repository

**Note:** ArgoCD watches this repository and auto-deploys

---

## Phase 4: AWS Infrastructure Setup (Week 2-3)
### 4.1 AWS Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured
- kubectl installed and configured

### 4.2 EKS Cluster
**Steps:**
1. Create EKS cluster (eksctl or CloudFormation)
2. Configure kubectl context
3. Install required add-ons:
   - VPC CNI
   - CoreDNS
   - kube-proxy

### 4.3 ECR Repository
- Create private ECR repository: `gitops-app`
- Configure lifecycle policies for image retention

### 4.4 IAM Roles & Policies
- EKS Cluster Role
- EKS Node Group Role
- GitHub Actions Role (for ECR push)
- ArgoCD Role (for EKS deployment)

---

## Phase 5: ArgoCD Setup (Week 3)
### 5.1 Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 5.2 Configure ArgoCD Application
**YAML Definition:**
- Source: GitHub Config Repository (K8s manifests)
- Destination: EKS Cluster
- Sync Policy: Automatic
- Namespace: gitops-app

### 5.3 ArgoCD Access
- Configure ArgoCD ingress or port-forward
- Setup RBAC policies
- Password management

---

## Phase 6: GitOps Repository Structure (Week 3)
**Repository Structure:**
```
gitops-config/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/
│   │   ├── kustomization.yaml
│   │   └── values.yaml
│   ├── staging/
│   └── prod/
│       ├── kustomization.yaml
│       └── values.yaml
└── argocd/
    └── application.yaml
```

---

## Phase 7: Monitoring & Logging (Week 4)
### 7.1 Deploy Prometheus & Grafana
- Monitor EKS cluster health
- Monitor application metrics
- Create dashboards

### 7.2 Deploy ELK Stack or CloudWatch
- Centralized logging
- Application logs
- Pod logs

### 7.3 Alerts
- Configure alerts for critical metrics
- Slack/Email notifications

---

## Phase 8: Security (Week 4)
### 8.1 Network Policies
- Restrict pod-to-pod communication
- Limit ingress/egress

### 8.2 RBAC
- Namespace-level access control
- Service account permissions

### 8.3 Secrets Management
- Use AWS Secrets Manager or Sealed Secrets
- Never commit secrets to Git

### 8.4 Image Scanning
- ECR image scanning
- Vulnerability assessments

---

## Phase 9: Testing & Validation (Week 4)
### 9.1 Local Testing
- Docker Compose for local development
- kubectl with local/minikube cluster

### 9.2 Integration Tests
- Test CI/CD pipeline end-to-end
- Validate ArgoCD sync

### 9.3 Load Testing
- Stress test EKS cluster
- Verify auto-scaling

---

## Implementation Checklist

### Week 1
- [ ] Create Dockerfile
- [ ] Create K8s manifests (deployment, service, configmap)
- [ ] Test locally with Docker and Docker Compose

### Week 2
- [ ] Setup GitHub Actions workflows
- [ ] Create ECR repository
- [ ] Configure AWS credentials in GitHub

### Week 3
- [ ] Create EKS cluster
- [ ] Install ArgoCD
- [ ] Create GitOps config repository
- [ ] Configure ArgoCD Application

### Week 4
- [ ] End-to-end testing
- [ ] Setup monitoring and logging
- [ ] Implement security policies
- [ ] Documentation

---

## Key Files to Create

1. **Dockerfile** - Container image definition
2. **.github/workflows/build.yml** - Build pipeline
3. **.github/workflows/deploy.yml** - Deploy trigger
4. **k8s/deployment.yaml** - K8s deployment manifest
5. **k8s/service.yaml** - K8s service manifest
6. **k8s/configmap.yaml** - Application configuration
7. **gitops-config/argocd-app.yaml** - ArgoCD Application definition
8. **docker-compose.yml** - Local testing

---

## Cost Estimates (Rough)
- EKS Cluster: ~$73/month (control plane)
- EC2 Nodes (3 nodes, t3.medium): ~$100/month
- ECR: <$5/month
- **Total: ~$180/month**

---

## Next Steps
1. Start with Phase 1: Create Dockerfile
2. Test locally with Docker
3. Create K8s manifests
4. Setup GitHub Actions
5. Create EKS cluster
6. Install and configure ArgoCD
7. Test full CI/CD pipeline
