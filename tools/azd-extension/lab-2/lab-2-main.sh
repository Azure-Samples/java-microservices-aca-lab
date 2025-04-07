#!/bin/bash

echo "Starting Lab 2..."

echo "Step 1: Collecting user information..."
./collect-user-info.sh

echo "Step 2: Creating Azure Container Apps environment..."
./create-aca-env.sh

echo "Step 3: Creating MySql instance..."
./create-mysql.sh

echo "Step 4: Creating Azure Container Registry..."
./create-container-registry.sh

echo "Step 5: Creating Java Spring Boot components..."
./create-java-components.sh

echo "Step 6: Deploy API Gateway..."
./deploy-component-apps.sh

echo "Lab 2 completed."