#!/bin/bash
# Before performing any additional actions, store user info as an environment variable that
# can be used in subsequent steps.

export USER_NAME=$(az account show --query user.name --output tsv)
echo "Current user:" $USER_NAME

export AAD_USER_ID=$(az ad signed-in-user show --query id --output tsv)
echo "Object ID:" $AAD_USER_ID
