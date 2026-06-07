# GitOps Application - EKS Deployment with ArgoCD

Complete guide to deploy a Spring Boot application to Amazon EKS using GitOps principles with ArgoCD and GitHub Actions CI/CD.

## 📋 Documentation Structure

### Getting Started
- **[DEPLOYMENT_PLAN.md](DEPLOYMENT_PLAN.md)** - Complete 4-week implementation roadmap with phased approach
- **[quickstart.sh](quickstart.sh)** - Quick local testing script (Make executable: `chmod +x quickstart.sh`)
- **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Detailed checklist for each phase

### Detailed Guides
- **[CICD_ARGOCD_GUIDE.md](CICD_ARGOCD_GUIDE.md)** - Complete CI/CD and ArgoCD concepts, workflow, and best practices
- **[SETUP_EKS.md](SETUP_EKS.md)** - AWS EKS cluster setup, IAM configuration, and troubleshooting
- **[GITOPS_CONFIG_SETUP.md](GITOPS_CONFIG_SETUP.md)** - GitOps configuration repository structure and setup

## 🚀 Quick Start

### 1. Test Locally
```bash
# Make script executable
chmod +x quickstart.sh

# Run quick start
./quickstart.sh
```

This will:
- Check prerequisites
- Build Maven application
- Build Docker image
- Start with Docker Compose
- Test API endpoints
- Display running application info

### 2. Manual Local Testing
```bash
# Build Docker image
docker build -t gitops-app:latest .

# Run with Docker Compose
docker-compose up -d

# Test API
curl http://localhost:8080/api/items/health

# Stop application
docker-compose down
```

## 📁 Project Structure

```
gitops/                              # Main application repository
├── src/                             # Spring Boot source code
│   ├── main/java/com/example/gitOps/
│   │   ├── GitOpsApplication.java  # Main application class
│   │   ├── Item.java               # Model class
│   │   └── ItemController.java     # REST API controller
│   ├── test/                        # Unit tests
│   └── resources/
│       └── application.properties   # Application configuration
├── .github/workflows/               # GitHub Actions CI/CD
│   ├── build.yml                    # Build and push to ECR
│   └── deploy.yml                   # Update manifests and deploy
├── k8s/                             # Kubernetes manifests
│   ├── namespace.yaml               # K8s namespace
│   ├── deployment.yaml              # Pod deployment config
│   ├── service.yaml                 # K8s service for load balancing
│   ├── configmap.yaml               # Application configuration
│   └── serviceaccount.yaml          # K8s service account
├── argocd/
│   └── application.yaml             # ArgoCD sync configuration
├── Dockerfile                       # Container image definition
├── docker-compose.yml               # Local testing with Docker Compose
├── pom.xml                          # Maven project configuration
└── Documentation/
    ├── DEPLOYMENT_PLAN.md           # 4-week implementation plan
    ├── CICD_ARGOCD_GUIDE.md        # Detailed concepts and workflow
    ├── SETUP_EKS.md                 # AWS setup guide
    ├── GITOPS_CONFIG_SETUP.md      # GitOps repo configuration
    ├── IMPLEMENTATION_CHECKLIST.md  # Step-by-step checklist
    └── README.md                    # This file
```

## 🏗️ Architecture

```
GitHub Repository
    ↓
GitHub Actions CI
    ├─→ Maven build
    ├─→ Docker build
    └─→ Push to ECR
         ↓
GitOps Config Repository
    ├─→ Update K8s manifest
    └─→ Push to Git
         ↓
ArgoCD (Watches Git)
    ├─→ Detect changes
    └─→ Sync to EKS
         ↓
EKS Cluster
    └─→ Pull image from ECR
    └─→ Deploy new version
```

## 🔄 Workflow

### Developer Workflow
1. Make code change
2. Commit and push to `main` branch
3. GitHub Actions automatically builds and tests
4. Docker image pushed to AWS ECR
5. K8s manifests updated in GitOps repo
6. ArgoCD detects changes
7. ArgoCD syncs EKS cluster
8. New version automatically deployed

### Result
- **No manual deployments**
- **Full audit trail in Git**
- **Easy rollbacks**
- **Declarative infrastructure**

## 📦 What's Included

### Spring Boot Application
- REST API with CRUD operations
- Health check endpoint
- Item management endpoints
- Containerized with Docker

### CI/CD Pipeline
- Automatic build on commit
- Maven test execution
- Docker image creation
- ECR push
- Automated manifest updates

### Kubernetes Configuration
- Deployment with 3 replicas
- LoadBalancer service
- ConfigMap for configuration
- Health checks (liveness & readiness)
- Resource limits and requests
- Security best practices

### GitOps
- ArgoCD for continuous deployment
- Automatic synchronization
- Git-based rollbacks
- Reconciliation every 3 seconds

## 🛠️ Prerequisites

### Local Development
- Docker & Docker Compose
- Java 21 (JDK)
- Maven 3.9+
- curl (for testing)

### AWS Setup
- AWS Account
- AWS CLI v2
- kubectl
- eksctl (for cluster creation)

### GitHub
- GitHub Account
- Git installed

## 📊 Implementation Timeline

| Phase | Duration | Activities |
|-------|----------|-----------|
| **Phase 1** | Week 1 | Containerization, Local testing |
| **Phase 2** | Week 2 | CI/CD setup, AWS infrastructure |
| **Phase 3** | Week 3 | ArgoCD, GitOps repository |
| **Phase 4** | Week 4 | Testing, Security, Monitoring |

**Total: 4 weeks** for production-ready setup

## 💰 Cost Estimate (Monthly)

| Component | Cost |
|-----------|------|
| EKS Control Plane | $73 |
| EC2 Nodes (3×t3.medium) | $100 |
| ECR Repository | <$5 |
| Data Transfer | <$10 |
| **Total** | **~$188** |

*Prices are approximate and may vary by region*

## ✅ Implementation Steps

### Step 1: Start Here
1. Read [DEPLOYMENT_PLAN.md](DEPLOYMENT_PLAN.md)
2. Understand the 4-phase approach
3. Review this README

### Step 2: Test Locally
1. Run `./quickstart.sh`
2. Verify application works
3. Review Docker configuration

### Step 3: Follow Checklist
1. Use [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)
2. Complete each phase systematically
3. Validate at each step

### Step 4: Setup AWS
1. Follow [SETUP_EKS.md](SETUP_EKS.md)
2. Create EKS cluster
3. Configure ECR

### Step 5: Configure CI/CD
1. Setup GitHub Actions (see `.github/workflows/`)
2. Configure GitHub secrets
3. Test build pipeline

### Step 6: Setup GitOps
1. Follow [GITOPS_CONFIG_SETUP.md](GITOPS_CONFIG_SETUP.md)
2. Create config repository
3. Setup ArgoCD

### Step 7: Deploy & Test
1. Install ArgoCD (see [SETUP_EKS.md](SETUP_EKS.md))
2. Deploy application
3. Test end-to-end

## 🔐 Security Features

- ✅ Non-root containers
- ✅ Resource limits and requests
- ✅ Health checks (liveness & readiness)
- ✅ RBAC (Role-Based Access Control)
- ✅ ServiceAccount per application
- ✅ SecurityContext enforcement
- ✅ Network policies
- ✅ No hardcoded secrets (AWS Secrets Manager)
- ✅ IAM roles instead of access keys
- ✅ Image scanning in ECR

## 📈 Monitoring & Logging

After deployment, setup:
- **Prometheus** for metrics
- **Grafana** for visualization
- **CloudWatch** for centralized logging
- **Alerts** for critical issues

See [CICD_ARGOCD_GUIDE.md](CICD_ARGOCD_GUIDE.md) for details.

## 🆘 Troubleshooting

### Build Issues
- Check Java version: `java -version`
- Clear Maven cache: `mvn clean`
- See [SETUP_EKS.md](SETUP_EKS.md) for details

### Docker Issues
- Verify Docker is running: `docker ps`
- Check image: `docker images | grep gitops`
- View logs: `docker logs <container-id>`

### Kubernetes Issues
- Check cluster: `kubectl get nodes`
- Verify pods: `kubectl get pods -n gitops-app`
- View pod logs: `kubectl logs -n gitops-app -l app=gitops-app`
- Describe pod: `kubectl describe pod -n gitops-app <pod-name>`

### ArgoCD Issues
- Check ArgoCD pods: `kubectl get pods -n argocd`
- View app status: `argocd app get gitops-app`
- Check sync errors: `argocd app logs gitops-app`

See individual documentation files for comprehensive troubleshooting.

## 📚 Learning Resources

### Concepts
- [CI/CD Concepts](CICD_ARGOCD_GUIDE.md#what-is-cicd)
- [GitOps Principles](CICD_ARGOCD_GUIDE.md#what-is-gitops)
- [ArgoCD Overview](CICD_ARGOCD_GUIDE.md#what-is-argocd)

### Tools
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

## 🔄 Continuous Improvement

After initial deployment:
1. **Scale up** - Add more nodes, configure HPA
2. **Monitor** - Setup Prometheus, Grafana, alerts
3. **Secure** - Implement network policies, pod security
4. **Optimize** - Review resource usage, costs
5. **Automate** - Add deployment stages, testing
6. **Disaster Recovery** - Multi-region, backups

## 📝 Key Files Reference

| File | Purpose |
|------|---------|
| `Dockerfile` | Container image definition |
| `.github/workflows/build.yml` | Build & push pipeline |
| `.github/workflows/deploy.yml` | Deploy trigger |
| `k8s/deployment.yaml` | Pod deployment config |
| `k8s/service.yaml` | Service & load balancer |
| `argocd/application.yaml` | ArgoCD sync config |

## 🎯 Next Steps

1. **Read** the [DEPLOYMENT_PLAN.md](DEPLOYMENT_PLAN.md) for complete overview
2. **Run** `./quickstart.sh` to test locally
3. **Follow** [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) step by step
4. **Reference** [SETUP_EKS.md](SETUP_EKS.md) for AWS setup
5. **Understand** [CICD_ARGOCD_GUIDE.md](CICD_ARGOCD_GUIDE.md) for concepts

## 📞 Support

For issues or questions:
1. Check relevant documentation file
2. Review troubleshooting section
3. Check pod/application logs
4. Verify GitHub Actions output

## 📄 License

This project is provided as-is for educational and deployment purposes.

---

**Last Updated:** 2024
**Status:** Ready for Production
**Support Level:** Full Documentation Provided
