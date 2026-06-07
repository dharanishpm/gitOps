# Complete CI/CD and ArgoCD Guide

## What is CI/CD?

**CI (Continuous Integration):** Automatically build, test, and validate code on every commit
**CD (Continuous Deployment):** Automatically deploy approved changes to production

## What is GitOps?

GitOps treats Git repository as the single source of truth for infrastructure and application configuration. ArgoCD ensures the cluster always matches the Git repository state.

## What is ArgoCD?

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes that:
- Monitors Git repositories for changes
- Automatically syncs cluster state with Git
- Provides UI for deployment visualization
- Supports rollback to any previous state

## Complete Workflow

```
Developer pushes code to GitHub
         ↓
GitHub Actions triggers (build.yml)
         ↓
1. Checkout code
2. Build with Maven
3. Run tests
4. Build Docker image
5. Push to ECR
         ↓
GitHub Actions triggers (deploy.yml)
         ↓
1. Update K8s manifests in GitOps repo
2. Commit changes
3. Push to main branch
         ↓
ArgoCD detects changes in Git
         ↓
ArgoCD syncs with EKS cluster
         ↓
EKS pulls new Docker image from ECR
         ↓
New pods are created with updated image
         ↓
Old pods are terminated (RollingUpdate)
         ↓
Application is now running latest version
```

## Key Concepts

### 1. Infrastructure as Code (IaC)
All infrastructure defined in YAML files in Git
- Deployment manifests
- Service definitions
- ConfigMaps
- Secrets

### 2. Declarative Configuration
Declare DESIRED state, not HOW to achieve it
- K8s reconciles cluster to desired state
- More reliable and reproducible

### 3. GitOps Principles
- Git is single source of truth
- Continuous reconciliation
- Version history for audit trail
- Easy rollbacks

## Repository Structure

### Main Application Repository
```
gitops/
├── .github/workflows/
│   ├── build.yml          # Build pipeline
│   └── deploy.yml         # Deploy trigger
├── src/                   # Source code
├── Dockerfile             # Container image
├── docker-compose.yml     # Local testing
├── pom.xml               # Maven config
├── k8s/                  # K8s manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── serviceaccount.yaml
└── DEPLOYMENT_PLAN.md    # This plan
```

### GitOps Configuration Repository
```
gitops-config/
├── base/                 # Common configs
├── overlays/
│   ├── dev/
│   ├── staging/
│   └── prod/             # Production config
└── argocd/
    └── application.yaml  # ArgoCD sync definition
```

## Step-by-Step Implementation

### Phase 1: Local Development
1. Build Docker image locally
2. Test with docker-compose
3. Verify application works in container

### Phase 2: CI Pipeline Setup
1. Create GitHub Actions build workflow
2. Test build process
3. Verify Maven build succeeds
4. Confirm tests pass

### Phase 3: AWS Infrastructure
1. Create EKS cluster
2. Create ECR repository
3. Configure IAM roles
4. Setup security groups

### Phase 4: GitOps Repository
1. Create separate GitOps config repository
2. Add K8s manifests
3. Setup Kustomize overlays for environments
4. Create ArgoCD Application

### Phase 5: Deploy Pipeline
1. Setup GitHub Actions deploy workflow
2. Configure GitOps config repo reference
3. Test end-to-end deployment

### Phase 6: ArgoCD Setup
1. Install ArgoCD on EKS
2. Configure ArgoCD credentials
3. Create ArgoCD Application
4. Test automatic sync

### Phase 7: Testing & Validation
1. Make code change
2. Push to main
3. Watch GitHub Actions build
4. Verify ECR image pushed
5. Check GitOps repo updated
6. Verify ArgoCD syncs
7. Confirm new version deployed to EKS

## Configuration Files Explained

### Dockerfile
- Multi-stage build for smaller image size
- Uses Maven to build JAR
- Non-root user for security
- Health checks

### deployment.yaml
- 3 replicas for high availability
- Resource requests/limits for scheduling
- Liveness probe: restarts unhealthy containers
- Readiness probe: removes unhealthy pods from load balancer
- Security context: runs as non-root

### service.yaml
- LoadBalancer type for external access
- Maps port 80 (external) to 8080 (pod)
- Automatically distributes traffic

### GitHub Actions Workflows

**build.yml:**
- Triggers on push to main/develop
- Builds and tests application
- Pushes Docker image to ECR
- Uses AWS IAM role for authentication

**deploy.yml:**
- Triggers after successful build
- Updates K8s manifest with new image
- Commits changes to GitOps repo
- ArgoCD watches and auto-deploys

### ArgoCD Application
- Points to GitOps repository
- Watches production branch
- Auto-syncs enabled
- Prunes deleted resources

## Security Best Practices

1. **Never commit secrets to Git**
   - Use AWS Secrets Manager
   - Use sealed-secrets for K8s secrets

2. **Use IAM roles instead of access keys**
   - GitHub Actions uses OIDC for temporary credentials

3. **Non-root containers**
   - Reduces blast radius of compromised container

4. **Network policies**
   - Restrict pod-to-pod communication

5. **Image scanning**
   - ECR scans images for vulnerabilities

6. **RBAC**
   - Least privilege access

## Monitoring & Logging

### Application Metrics
- Use Prometheus for metrics collection
- Grafana for visualization
- CloudWatch for centralized logging

### Deployment Health
- ArgoCD UI shows sync status
- GitHub Actions shows pipeline status
- EKS shows pod/node health

## Common Troubleshooting

### Image not found in ECR
- Check ECR repository name matches
- Verify IAM permissions
- Check image tag in manifest

### Pod not starting
- Check resource limits
- Verify image exists in ECR
- Check security policies
- Review pod events: `kubectl describe pod`

### ArgoCD not syncing
- Check Git credentials
- Verify repository URL
- Check branch name
- Review ArgoCD logs

### Health checks failing
- Verify application is responding on `/api/items/health`
- Check resource limits
- Increase initialDelaySeconds

## Next Steps After Deployment

1. **Setup monitoring**
   - Install Prometheus
   - Install Grafana
   - Configure alerts

2. **Setup logging**
   - CloudWatch logs
   - ELK stack
   - Log aggregation

3. **Setup backup**
   - EBS snapshot policy
   - RDS backups
   - GitOps config backups

4. **Setup scaling**
   - Horizontal Pod Autoscaler (HPA)
   - Cluster autoscaler
   - Load balancer scaling

5. **Setup disaster recovery**
   - Multi-region deployment
   - Backup and restore procedures
   - Disaster recovery testing
