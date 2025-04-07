#!/bin/bash

set -e

echo "Starting Lab 3..."

echo "Step 1: Create AI account..."
./create-ai-account.sh
if [ $? -ne 0 ]; then
    echo "Error: Step 1 failed. Exiting."
    exit 1
fi

echo "Step 2: Create Spring Boot AI service..."
./create-spring-boot-ai.sh
if [ $? -ne 0 ]; then
    echo "Error: Step 2 failed. Exiting."
    exit 1
fi

echo "Lab 3 completed successfully."