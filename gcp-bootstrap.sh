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

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
	--member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
	--role roles/cloudsql.client

# Create a private key
gcloud iam service-accounts keys create ~/.config/gcloud/${SA_NAME}.json \
    --iam-account ${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

# Activate the APIs
gcloud services enable container.googleapis.com
gcloud services enable sql-component.googleapis.com

# Create the cluster
gcloud container clusters create "${CLUSTER_NAME}" \
    --cluster-version "1.7.8-gke.0" \
    --service-account="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Get the k8s cluster credentials
gcloud container clusters get-credentials "${CLUSTER_NAME}" \
	--zone "${ZONE}" \
	--project "${PROJECT_ID}"

# Create the PG database
gcloud sql instances create "${PG_INSTANCE_NAME}" \
	--region="${REGION}" \
	--cpu=2 \
	--memory=7680MiB \
	--database-version=POSTGRES_9_6

# Set the password of the postgres user
gcloud sql users set-password postgres no-host \
	--instance="${PG_INSTANCE_NAME}" \
	--password="${PG_ADMIN_PASSWORD}"

# Create the proxy user
gcloud sql users create "${PG_PROXYUSER_NAME}" host \
	--instance="${PG_INSTANCE_NAME}" \
	--password="${PG_PROXYUSER_PASSWORD}"

# FIXME: Translate these commands to a k8s file
# Create the Secret which enables authentication to Cloud SQL
kubectl create secret generic cloudsql-instance-credentials \
	--from-file=credentials.json=/home/sdouche/.config/gcloud/${SA_NAME}.json

# Create the Secret needed for database access
kubectl create secret generic cloudsql-db-credentials \
	--from-literal=username="${PG_PROXYUSER_NAME}" \
	--from-literal=password="${PG_PROXYUSER_PASSWORD}"

