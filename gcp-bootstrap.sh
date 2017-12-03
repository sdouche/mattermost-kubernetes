#!/usr/bin/env bash

source variables.sh

# Create the project
gcloud projects create ${PROJECT_ID} \
	--organization ${ORG_ID} \
	--set-as-default

# Link the project to the billing account
gcloud beta billing projects link ${PROJECT_ID} \
	--billing-account ${BILLING_ID}

# Create the service account
gcloud iam service-accounts create "${SA_NAME}" \
	--display-name="${SA_NAME}"

# Bind the minimal permissions
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
	--member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role roles/logging.logWriter

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
	--member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role roles/monitoring.metricWriter

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
	--member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role roles/monitoring.viewer

# Create a private key
gcloud iam service-accounts keys create ~/.config/gcloud/${SA_NAME}.json \
    --iam-account ${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

# Activate the APIs
gcloud services enable container.googleapis.com

# Create the cluster
gcloud container clusters create "${CLUSTER_NAME}" \
    --cluster-version "1.7.8-gke.0" \
    --service-account="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Get the k8s cluster credentials
gcloud container clusters get-credentials "${CLUSTER_NAME}" \
	--zone "${ZONE}" \
	--project "${PROJECT_ID}"
