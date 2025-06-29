#!/bin/bash

# === COMMON CONFIGURATION ===
CLUSTER_NAME="movies-cluster"
NAMESPACE="default"
SERVICE_ACCOUNT_NAME="argocd-image-access"
IAM_ROLE_NAME="ArgoCDECRRole"
POLICY_NAME="ECRAccessPolicy"
