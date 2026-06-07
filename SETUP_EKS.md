# AWS EKS Setup Guide

## Prerequisites
- AWS CLI v2 installed and configured
- kubectl installed
- eksctl installed
- GitHub account with repositories

## Step 1: Create EKS Cluster

### Option A: Using eksctl (Recommended)
```bash
# Create cluster
eksctl create cluster \
  --name gitops-cluster \
  --region us-east-1 \
  --nodegroup-name gitops-nodes \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 5 \
  --managed

# Get kubeconfig
aws eks update-kubeconfig \
  --name gitops-cluster \
  --region us-east-1

# Verify cluster
kubectl get nodes
```

### Option B: Using AWS Console
1. Navigate to EKS service
2. Click "Create cluster"
3. Configure:
   - Name: gitops-cluster
   - Version: 1.28 or higher
   - Subnets: Select VPC subnets
   - Security groups: Create new or select existing
4. Review and create
5. Add node group (t3.medium, 3 nodes)

## Step 2: Create ECR Repository

```bash
# Create ECR repository
aws ecr create-repository \
  --repository-name gitops-app \
  --region us-east-1

# Note the repository URI
aws ecr describe-repositories \
  --repository-names gitops-app \
  --region us-east-1
```

## Step 3: Setup IAM for GitHub Actions

### Create GitHub Actions Role
```bash
# Create trust policy JSON file (github-trust-policy.json)
cat > github-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/gitops:ref:refs/heads/main"
        }
      }
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name github-actions-role \
  --assume-role-policy-document file://github-trust-policy.json

# Create inline policy for ECR access
aws iam put-role-policy \
  --role-name github-actions-role \
  --policy-name github-ecr-policy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        "Resource": "*"
      }
    ]
  }'
```

## Step 4: Create Kubernetes Namespace

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Verify
kubectl get namespaces
```

## Step 5: Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/part-of=argocd \
  -n argocd \
  --timeout=300s

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

## Step 6: Access ArgoCD UI

```bash
# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8443:443

# Open browser: https://localhost:8443
# Username: admin
# Password: (from previous step)

# Or setup Ingress for production access
```

## Step 7: Configure ArgoCD Credentials (Optional)

```bash
# Add GitHub repository credentials for private repos
argocd repo add https://github.com/YOUR_USERNAME/gitops-config \
  --username YOUR_GITHUB_USERNAME \
  --password YOUR_GITHUB_TOKEN \
  --insecure-skip-server-verification
```

## Step 8: Deploy Application with ArgoCD

```bash
# Create ArgoCD Application (after GitOps config repo is ready)
kubectl apply -f argocd/application.yaml

# Check sync status
kubectl get applications -n argocd
kubectl describe application gitops-app -n argocd

# View ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f
```

## Troubleshooting

### Check Cluster Status
```bash
kubectl get nodes
kubectl get pods -A
```

### Check Application Deployment
```bash
kubectl get pods -n gitops-app
kubectl describe pod -n gitops-app
kubectl logs -n gitops-app -l app=gitops-app
```

### Check ArgoCD Sync
```bash
argocd app get gitops-app
argocd app logs gitops-app
```

### View Service Endpoint
```bash
kubectl get svc -n gitops-app
# Get the EXTERNAL-IP of the LoadBalancer
```

## Cleanup

```bash
# Delete EKS cluster
eksctl delete cluster --name gitops-cluster --region us-east-1

# Delete ECR repository
aws ecr delete-repository \
  --repository-name gitops-app \
  --force \
  --region us-east-1

# Delete IAM role
aws iam delete-role-policy \
  --role-name github-actions-role \
  --policy-name github-ecr-policy

aws iam delete-role --role-name github-actions-role
```
