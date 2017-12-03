# To know the values of ORG_ID and BILLING_ID:
# $ gcloud organizations list
# $ gcloud beta billing accounts list

ORG_ID=XXX
BILLING_ID=XXX

PROJECT_ID=sdouche-test-mattermost
ZONE=europe-west1-b
REGION=europe-west1
SA_NAME=mattermost
CLUSTER_NAME=mattermost

PG_INSTANCE_NAME=mattermost
PG_ADMIN_PASSWORD=password
PG_PROXYUSER_NAME=proxyuser
PG_PROXYUSER_PASSWORD=password
