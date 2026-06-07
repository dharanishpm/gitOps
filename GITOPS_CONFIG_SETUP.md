# GitOps Configuration Repository Setup

This guide helps you setup a separate repository for GitOps configurations.

## Repository Structure

```
gitops-config/
├── README.md
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── namespace.yaml
├── overlays/
│   ├── dev/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   │       └── deployment-patch.yaml
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   │       └── deployment-patch.yaml
│   └── prod/
│       ├── kustomization.yaml
│       └── patches/
│           └── deployment-patch.yaml
└── argocd/
    ├── application.yaml
    └── application-multi-env.yaml
```

## Step 1: Create GitOps Repository

```bash
# Create new repository on GitHub
# Name: gitops-config
# Visibility: Private (for production)

# Clone locally
git clone https://github.com/YOUR_USERNAME/gitops-config.git
cd gitops-config
```

## Step 2: Setup Directory Structure

```bash
mkdir -p base overlays/{dev,staging,prod} argocd

# Copy manifests from main repository
cp ../gitops/k8s/*.yaml base/
```

## Step 3: Create Kustomization Files

### base/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: gitops-app

resources:
  - namespace.yaml
  - serviceaccount.yaml
  - configmap.yaml
  - deployment.yaml
  - service.yaml

images:
  - name: gitops-app
    newName: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/gitops-app
    newTag: latest
```

### overlays/prod/kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

namePrefix: prod-

replicas:
  - name: gitops-app
    count: 3

patchesStrategicMerge:
  - patches/deployment-patch.yaml

images:
  - name: gitops-app
    newTag: latest
```

### overlays/prod/patches/deployment-patch.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitops-app
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: gitops-app
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
```

## Step 4: Create ArgoCD Application

### argocd/application.yaml
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitops-app
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/YOUR_USERNAME/gitops-config
    targetRevision: main
    path: overlays/prod
  
  destination:
    server: https://kubernetes.default.svc
    namespace: gitops-app
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## Step 5: Initialize Git Repository

```bash
git add .
git commit -m "Initial commit: Add GitOps configuration"
git push -u origin main
```

## Step 6: Update Deployment Manifest Path

In your main application repository, update GitHub Actions workflow to point to this config repo:

### .github/workflows/deploy.yml
Replace the repository reference:
```yaml
- name: Checkout GitOps config repository
  uses: actions/checkout@v4
  with:
    repository: YOUR_USERNAME/gitops-config
    token: ${{ secrets.GITHUB_TOKEN }}
    path: gitops-config
```

## Testing

### Test Kustomization Locally
```bash
kubectl kustomize overlays/prod
```

### Deploy with Kustomize (without ArgoCD)
```bash
kubectl apply -k overlays/prod
```

## ArgoCD Sync Options Explained

- **automated.prune**: Remove resources deleted from Git
- **automated.selfHeal**: Sync whenever cluster state drifts
- **CreateNamespace**: Create namespace if it doesn't exist
- **retry.limit**: Maximum number of sync retries
- **retry.backoff**: Exponential backoff for retries

## Branching Strategy for GitOps

```
main → Production
├── staging → Staging environment
└── develop → Development environment
```

Each ArgoCD Application watches a different branch:
- Production ArgoCD app watches: main
- Staging ArgoCD app watches: staging
- Dev ArgoCD app watches: develop
