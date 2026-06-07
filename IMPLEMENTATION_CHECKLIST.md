# Implementation Checklist

## Pre-Deployment Setup

### Phase 1: Local Development & Testing (Week 1)
- [ ] Review `DEPLOYMENT_PLAN.md`
- [ ] Run `./quickstart.sh` to test locally
- [ ] Verify Docker build works: `docker build -t gitops-app:latest .`
- [ ] Test Docker Compose: `docker-compose up` 
- [ ] Test API endpoints:
  - [ ] `GET http://localhost:8080/api/items/health`
  - [ ] `POST http://localhost:8080/api/items` with sample data
  - [ ] `GET http://localhost:8080/api/items`
- [ ] Verify all K8s manifests are valid
- [ ] Run: `kubectl apply --dry-run=client -f k8s/`

### Phase 2: AWS Account & Permissions (Week 2)
- [ ] Create AWS Account or use existing
- [ ] Verify IAM permissions for EKS, ECR, IAM
- [ ] Install AWS CLI v2: `aws --version`
- [ ] Configure AWS credentials: `aws configure`
- [ ] Test AWS access: `aws sts get-caller-identity`

### Phase 3: Create AWS Infrastructure (Week 2)
- [ ] Create ECR Repository:
  ```bash
  aws ecr create-repository --repository-name gitops-app --region us-east-1
  ```
- [ ] Note the repository URI (e.g., `123456789.dkr.ecr.us-east-1.amazonaws.com/gitops-app`)
- [ ] Create EKS Cluster (see `SETUP_EKS.md`):
  ```bash
  eksctl create cluster --name gitops-cluster --region us-east-1 --nodegroup-name gitops-nodes --node-type t3.medium --nodes 3
  ```
- [ ] Verify cluster: `kubectl get nodes`
- [ ] Create GitHub Actions IAM role (see `SETUP_EKS.md`)

### Phase 4: GitHub Setup (Week 2-3)
- [ ] Create GitHub repository: `gitops`
- [ ] Push application code to main branch
- [ ] Create GitHub Personal Access Token with:
  - [ ] repo access
  - [ ] workflow access
- [ ] Create GitHub repository secrets:
  - [ ] `AWS_ACCOUNT_ID`: Your AWS account ID
  - [ ] `AWS_REGION`: us-east-1
- [ ] Create separate repository: `gitops-config`
- [ ] Initialize GitOps config repository (see `GITOPS_CONFIG_SETUP.md`)

### Phase 5: CI/CD Pipeline Setup (Week 3)
- [ ] Review `.github/workflows/build.yml`
- [ ] Update AWS_ACCOUNT_ID and AWS_REGION in workflow
- [ ] Test build workflow:
  - [ ] Push code change to GitHub
  - [ ] Verify GitHub Actions runs
  - [ ] Check build completes successfully
  - [ ] Verify image pushed to ECR
- [ ] Review `.github/workflows/deploy.yml`
- [ ] Test deploy workflow:
  - [ ] Verify GitOps config repo updated
  - [ ] Check image tag updated in manifests
  - [ ] Verify commit to main branch

### Phase 6: ArgoCD Installation & Setup (Week 3)
- [ ] Install ArgoCD on EKS:
  ```bash
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```
- [ ] Verify ArgoCD pods are running:
  ```bash
  kubectl get pods -n argocd
  ```
- [ ] Get ArgoCD password:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```
- [ ] Access ArgoCD UI:
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8443:443
  ```
  Then visit: `https://localhost:8443`
- [ ] Configure ArgoCD for GitOps repo (if private)

### Phase 7: Deploy Application (Week 4)
- [ ] Create K8s namespace:
  ```bash
  kubectl apply -f k8s/namespace.yaml
  ```
- [ ] Deploy ArgoCD Application:
  ```bash
  kubectl apply -f argocd/application.yaml
  ```
- [ ] Verify ArgoCD syncs:
  ```bash
  argocd app get gitops-app
  ```
- [ ] Check application pods:
  ```bash
  kubectl get pods -n gitops-app
  ```
- [ ] Get service endpoint:
  ```bash
  kubectl get svc -n gitops-app
  ```
- [ ] Test deployed application:
  - [ ] Get LoadBalancer external IP
  - [ ] Test health endpoint
  - [ ] Create test item via API

### Phase 8: End-to-End Testing (Week 4)
- [ ] Make code change (e.g., new API endpoint)
- [ ] Commit and push to GitHub
- [ ] Monitor GitHub Actions build
- [ ] Verify ECR image created with new tag
- [ ] Check GitOps config repo updated
- [ ] Monitor ArgoCD for sync
- [ ] Verify new version deployed to EKS
- [ ] Test new feature works

### Phase 9: Security & Hardening (Week 4)
- [ ] Review K8s security context
- [ ] Enable RBAC:
  - [ ] Create service account with minimal permissions
  - [ ] Review role bindings
- [ ] Setup network policies
- [ ] Enable ECR image scanning
- [ ] Review and rotate AWS credentials
- [ ] Setup secret management (use AWS Secrets Manager)
- [ ] Enable pod security policies

### Phase 10: Monitoring & Logging (Week 4+)
- [ ] Install Prometheus (optional)
- [ ] Install Grafana (optional)
- [ ] Configure CloudWatch logging
- [ ] Setup alerts
- [ ] Create dashboards

---

## Deployment Validation

### Application Health
- [ ] Pod status: `kubectl get pods -n gitops-app`
- [ ] Pod logs: `kubectl logs -n gitops-app -l app=gitops-app`
- [ ] Pod events: `kubectl describe pod -n gitops-app`
- [ ] Service running: `kubectl get svc -n gitops-app`

### ArgoCD Health
- [ ] ArgoCD pods running: `kubectl get pods -n argocd`
- [ ] Application synced: `argocd app get gitops-app`
- [ ] Sync status shows "Synced"
- [ ] No sync errors

### GitHub Actions Health
- [ ] Build workflow completes
- [ ] Deploy workflow completes
- [ ] No pipeline errors

### AWS Infrastructure Health
- [ ] EKS cluster running: `aws eks describe-cluster --name gitops-cluster`
- [ ] ECR repository has images: `aws ecr describe-images --repository-name gitops-app`
- [ ] Nodes ready: `kubectl get nodes`

---

## Rollback & Recovery

### Rollback Application
```bash
# Via ArgoCD UI: Click "History" → Select previous version → "Rollback"

# Via CLI:
argocd app rollback gitops-app <revision-number>
```

### Rollback Git Commit
```bash
# Revert last commit in GitOps repo
git revert HEAD
git push

# ArgoCD will automatically sync to previous state
```

### Delete Deployment
```bash
argocd app delete gitops-app
kubectl delete namespace gitops-app
```

---

## Documentation References

- [DEPLOYMENT_PLAN.md](DEPLOYMENT_PLAN.md) - Complete implementation plan
- [CICD_ARGOCD_GUIDE.md](CICD_ARGOCD_GUIDE.md) - CI/CD and ArgoCD concepts
- [SETUP_EKS.md](SETUP_EKS.md) - EKS and AWS setup
- [GITOPS_CONFIG_SETUP.md](GITOPS_CONFIG_SETUP.md) - GitOps repository setup

---

## Estimated Timeline
- **Week 1**: Local setup & containerization
- **Week 2**: AWS infrastructure & GitHub Actions
- **Week 3**: ArgoCD setup & deployment
- **Week 4**: Testing, security, monitoring, and hardening

**Total: 4 weeks for complete production-ready setup**

---

## Support & Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Build fails | Check Maven dependencies, Java version |
| Image not in ECR | Verify IAM permissions, GitHub Actions secret |
| Pod won't start | Check resource limits, image exists in ECR |
| ArgoCD not syncing | Verify Git credentials, branch name, manifest syntax |
| API not accessible | Check service type, security groups, load balancer |

See individual documentation files for detailed troubleshooting.
