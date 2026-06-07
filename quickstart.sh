#!/bin/bash

# GitOps Quick Start - Local Testing Script

set -e

echo "=========================================="
echo "GitOps Application - Quick Start"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed"
    exit 1
fi
echo -e "${GREEN}✓ Docker installed${NC}"

if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: Docker Compose is not installed"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose installed${NC}"

if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed"
    exit 1
fi
echo -e "${GREEN}✓ Maven installed${NC}"

# Build the application
echo -e "\n${YELLOW}Building application with Maven...${NC}"
mvn clean package -DskipTests
echo -e "${GREEN}✓ Build successful${NC}"

# Build Docker image
echo -e "\n${YELLOW}Building Docker image...${NC}"
docker build -t gitops-app:latest .
echo -e "${GREEN}✓ Docker image built${NC}"

# Start application with Docker Compose
echo -e "\n${YELLOW}Starting application with Docker Compose...${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Application started${NC}"

# Wait for application to start
echo -e "\n${YELLOW}Waiting for application to be ready...${NC}"
sleep 5

# Test the API
echo -e "\n${YELLOW}Testing API endpoints...${NC}"

# Health check
HEALTH_RESPONSE=$(curl -s http://localhost:8080/api/items/health)
echo -e "Health check: ${GREEN}$HEALTH_RESPONSE${NC}"

# Get items
echo -e "\n${YELLOW}Creating a test item...${NC}"
CREATE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Item","description":"Created during quick start"}')
echo -e "Created: ${GREEN}$CREATE_RESPONSE${NC}"

# Get all items
echo -e "\n${YELLOW}Retrieving all items...${NC}"
GET_RESPONSE=$(curl -s http://localhost:8080/api/items)
echo -e "Items: ${GREEN}$GET_RESPONSE${NC}"

echo -e "\n=========================================="
echo -e "${GREEN}Quick start completed successfully!${NC}"
echo "=========================================="
echo -e "\nApplication is running at: ${GREEN}http://localhost:8080${NC}"
echo -e "API Health: ${GREEN}http://localhost:8080/api/items/health${NC}"
echo -e "Get Items: ${GREEN}http://localhost:8080/api/items${NC}"
echo -e "\nTo stop the application, run:"
echo -e "  ${YELLOW}docker-compose down${NC}"
echo -e "\nTo view logs, run:"
echo -e "  ${YELLOW}docker-compose logs -f${NC}"
echo -e "\nNext steps:"
echo -e "  1. Review: ${YELLOW}DEPLOYMENT_PLAN.md${NC}"
echo -e "  2. Read: ${YELLOW}CICD_ARGOCD_GUIDE.md${NC}"
echo -e "  3. Setup: ${YELLOW}SETUP_EKS.md${NC}"
echo -e "  4. Configure: ${YELLOW}GITOPS_CONFIG_SETUP.md${NC}"
