#!/usr/bin/env bash
shopt -s expand_aliases
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Verify that the scripts are being run from Linux and not Mac
if [[ $OSTYPE != "linux-gnu" ]]; then
    echo "ERROR: This script and consecutive set up scripts have only been tested on Linux. Currently, only Linux (debian) is supported. Please run in Cloud Shell or in a VM running Linux".
    exit;
fi

export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")
START_DIR=${PWD}
BASE_DIR="${SCRIPT_DIR}/../"
LOG_DIR="${SCRIPT_DIR}/../logs/infra"
mkdir -p ${LOG_DIR}
TEMP_DIR="${BASE_DIR}/../"
mkdir -p ${TEMP_DIR}

if [ ! -f ${LOG_DIR}/vars.sh ]; then
    cp ${SCRIPT_DIR}/vars.sh ${LOG_DIR}/vars.sh
else 
    source ${LOG_DIR}/vars.sh
fi

export LOG_FILE=${LOG_DIR}/platform-bootstrap-$(date +%s).log
touch ${LOG_FILE}
exec 2>&1
exec &> >(tee -i ${LOG_FILE})

#functions.sh helps make the script interactive
source ${SCRIPT_DIR}/functions.sh

# Read all the mandatroy variables from an input file
file_name=$1
IFS="="
while read name value
do
    # Check value for sanity?  Name too?
    eval $name="$value"
done < $file_name

echo ${ORG_NAME}
echo ${FOLDER_NAME}

# Ensure Org ID is defined otherwise collect
while [ -z ${ORG_NAME} ]
    do
    read -p "$(echo -e "Please provide your Organization Name (your active account must be Org Admin): ")" ORG_NAME
    done

# Validate ORG_NAME exists
ORG_ID=$(gcloud organizations list \
  --filter="display_name=${ORG_NAME}" \
  --format="value(ID)")
[ ${ORG_ID} ] || { echo "Organization with that name does not exist or you do not have correct permissions in this org."; exit; }

# Validate active user is org admin
export ADMIN_USER=$(gcloud config get-value account)
#gcloud organizations get-iam-policy ${ORG_ID} --format=json | \
#jq '.bindings[] | select(.role=="roles/resourcemanager.organizationAdmin")' | grep ${ADMIN_USER}  &>/dev/null
#[[ $? -eq 0 ]] || { echo "Active user is not an organization admin in $ORG_NAME"; exit; }

# Ensure Billing account is defined otherwise collect
while [ -z ${BILLING_ACCOUNT_ID} ]
    do
    read -p "$(echo -e "Please provide your Billing Account ID (your active account must be Billing Account Admin): ")" BILLING_ACCOUNT_ID
    done

# Check if FOLDER_NAME is needed. If not, enter just press enter
read -p "$(echo -e "Please provide Folder Name (your active account must be Org Admin): ")" FOLDER_NAME

# Ensure infra setup project name is defined
while [ -z ${INFRA_SETUP_PROJECT} ]
    do
    read -p "$(echo -e "Please provide the name for multi-tenant admin project: ")" INFRA_SETUP_PROJECT
    done

# Ensure infra setup repo name is defined
while [ -z ${INFRA_SETUP_REPO} ]
    do
    read -p "$(echo -e "Please provide the name for multi-tenant platform repo: ")" INFRA_SETUP_REPO
    done

# Ensure github user is defined
while [ -z ${GITHUB_USER} ]
    do
    read -p "$(echo -e "Please provide your github user: ")" GITHUB_USER
    done

# Ensure github personal access token is defined
while [ -z ${TOKEN} ]
    do
    read -p "$(echo -e "Please provide your github personal access token: ")" TOKEN
    done

# Ensure github org is defined
while [ -z ${GITHUB_ORG} ]
    do
    read -p "$(echo -e "Please provide your github org: ")" GITHUB_ORG
    done

# Ensure IAM group name is defined
while [ -z ${IAM_GROUP} ]
    do
    read -p "$(echo -e "Please provide a name for DevOps IAM group: ")" IAM_GROUP
    done

# Ensure terraform service account is defined
while [ -z ${TF_SERVICE_ACCOUNT} ]
    do
    read -p "$(echo -e "Please provide the terraform service account: ")" TF_SERVICE_ACCOUNT
    done

# Ensure terraform service account is defined
while [ -z ${TF_SERVICE_ACCOUNT_PROJECT} ]
    do
    read -p "$(echo -e "Please provide the terraform service account project ID: ")" TF_SERVICE_ACCOUNT_PROJECT
    done
  
# Ensure dev GKE cluster project ID is defined
while [ -z ${DEV_GKE_PROJECT_ID} ]
    do
    read -p "$(echo -e "Please provide the dev GKE cluster project ID: ")" DEV_GKE_PROJECT_ID
    done

# Ensure dev VPC host project ID is defined
while [ -z ${DEV_VPC_HOST_PROJECT_ID} ]
    do
    read -p "$(echo -e "Please provide the dev VPC host project ID: ")" DEV_VPC_HOST_PROJECT_ID
    done

# Ensure dev network name is defined
while [ -z ${DEV_NETWORK_NAME} ]
    do
    read -p "$(echo -e "Please provide the dev network name: ")" DEV_NETWORK_NAME
    done

# Ensure dev subnet name is defined
while [ -z ${DEV_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the dev subnet name: ")" DEV_SUBNET_NAME
    done

# Ensure dev subnet region is defined
while [ -z ${DEV_SUBNET_REGION} ]
    do
    read -p "$(echo -e "Please provide the dev subnet region: ")" DEV_SUBNET_REGION
    done

# Ensure dev secondary service subnet name is defined
while [ -z ${DEV_SERVICE_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the dev secondary service subnet name: ")" DEV_SERVICE_SUBNET_NAME
    done

# Ensure dev secondary pod subnet name is defined
while [ -z ${DEV_POD_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the dev secondary pod subnet name: ")" DEV_POD_SUBNET_NAME
    done

# Ensure dev zones are defined
while [ -z ${DEV_ZONES} ]
    do
    read -p "$(echo -e "Please provide the dev zones in this format [\"us-central1-a\",\"us-central1-b\"]: ")" DEV_ZONES
    done

# Ensure dev GKE nodepool machine type defined
while [ -z ${DEV_NODEPOOL_MACHINE_TYPE} ]
    do
    read -p "$(echo -e "Please provide the dev GKE nodepool machine type: ")" DEV_NODEPOOL_MACHINE_TYPE
    done

# Ensure dev GKE nodepool min count defined
while [ -z ${DEV_NODEPOOL_MIN_COUNT} ]
    do
    read -p "$(echo -e "Please provide the dev GKE nodepool min count: ")" DEV_NODEPOOL_MIN_COUNT
    done

# Ensure dev GKE nodepool max count defined
while [ -z ${DEV_NODEPOOL_MAX_COUNT} ]
    do
    read -p "$(echo -e "Please provide the dev GKE nodepool max count: ")" DEV_NODEPOOL_MAX_COUNT
    done

# Ensure staging GKE cluster project ID is defined
while [ -z ${STAGING_GKE_PROJECT_ID} ]
    do
    read -p "$(echo -e "Please provide the staging GKE cluster project ID: ")" STAGING_GKE_PROJECT_ID
    done

# Ensure staging VPC host project ID is defined
while [ -z ${STAGING_VPC_HOST_PROJECT_ID} ]
    do
    read -p "$(echo -e "Please provide the staging VPC host project ID: ")" STAGING_VPC_HOST_PROJECT_ID
    done

# Ensure staging network name is defined
while [ -z ${STAGING_NETWORK_NAME} ]
    do
    read -p "$(echo -e "Please provide the staging network name: ")" STAGING_NETWORK_NAME
    done

# Ensure staging subnet name is defined
while [ -z ${STAGING_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the staging subnet name: ")" STAGING_SUBNET_NAME
    done

# Ensure staging subnet region is defined
while [ -z ${STAGING_SUBNET_REGION} ]
    do
    read -p "$(echo -e "Please provide the staging subnet region: ")" STAGING_SUBNET_REGION
    done

# Ensure staging secondary service subnet name is defined
while [ -z ${STAGING_SERVICE_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the staging secondary service subnet name: ")" STAGING_SERVICE_SUBNET_NAME
    done

# Ensure staging secondary pod subnet name is defined
while [ -z ${STAGING_POD_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the staging secondary pod subnet name: ")" STAGING_POD_SUBNET_NAME
    done

# Ensure staging zones are defined
while [ -z ${STAGING_ZONES} ]
    do
    read -p "$(echo -e "Please provide the staging zones in this format [\"us-central1-a\",\"us-central1-b\"]: ")" STAGING_ZONES
    done

# Ensure staging GKE nodepool machine type defined
while [ -z ${STAGING_NODEPOOL_MACHINE_TYPE} ]
    do
    read -p "$(echo -e "Please provide the staging GKE nodepool machine type: ")" STAGING_NODEPOOL_MACHINE_TYPE
    done

# Ensure staging GKE nodepool min count defined
while [ -z ${STAGING_NODEPOOL_MIN_COUNT} ]
    do
    read -p "$(echo -e "Please provide the staging GKE nodepool min count: ")" STAGING_NODEPOOL_MIN_COUNT
    done

# Ensure staging GKE nodepool max count defined
while [ -z ${STAGING_NODEPOOL_MAX_COUNT} ]
    do
    read -p "$(echo -e "Please provide the staging GKE nodepool max count: ")" STAGING_NODEPOOL_MAX_COUNT
    done

# Ensure prod GKE cluster project ID is defined
while [ -z ${PROD_GKE_PROJECT_ID} ]
    do
    read -p "$(echo -e "Please provide the prod GKE cluster project ID: ")" PROD_GKE_PROJECT_ID
    done

# Ensure prod VPC host project ID is defined
while [ -z ${PROD_VPC_HOST_PROJECT_ID} ]
    do
    read -p "$(echo -e "Please provide the prod VPC host project ID: ")" PROD_VPC_HOST_PROJECT_ID
    done

# Ensure prod network name is defined
while [ -z ${PROD_NETWORK_NAME} ]
    do
    read -p "$(echo -e "Please provide the prod network name: ")" PROD_NETWORK_NAME
    done

# Ensure prod subnet name is defined
while [ -z ${PROD_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the prod subnet name: ")" PROD_SUBNET_NAME
    done

# Ensure prod subnet region is defined
while [ -z ${PROD_SUBNET_REGION} ]
    do
    read -p "$(echo -e "Please provide the prod subnet region: ")" PROD_SUBNET_REGION
    done

# Ensure prod secondary service subnet name is defined
while [ -z ${PROD_SERVICE_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the prod secondary service subnet name: ")" PROD_SERVICE_SUBNET_NAME
    done

# Ensure prod secondary pod subnet name is defined
while [ -z ${PROD_POD_SUBNET_NAME} ]
    do
    read -p "$(echo -e "Please provide the prod secondary pod subnet name: ")" PROD_POD_SUBNET_NAME
    done

# Ensure prod zones are defined
while [ -z ${PROD_ZONES} ]
    do
    read -p "$(echo -e "Please provide the prod zones in this format [\"us-central1-a\",\"us-central1-b\"]: ")" PROD_ZONES
    done

# Ensure prod GKE nodepool machine type defined
while [ -z ${PROD_NODEPOOL_MACHINE_TYPE} ]
    do
    read -p "$(echo -e "Please provide the prod GKE nodepool machine type: ")" PROD_NODEPOOL_MACHINE_TYPE
    done

# Ensure prod GKE nodepool min count defined
while [ -z ${PROD_NODEPOOL_MIN_COUNT} ]
    do
    read -p "$(echo -e "Please provide the prod GKE nodepool min count: ")" PROD_NODEPOOL_MIN_COUNT
    done

# Ensure prod GKE nodepool max count defined
while [ -z ${PROD_NODEPOOL_MAX_COUNT} ]
    do
    read -p "$(echo -e "Please provide the prod GKE nodepool max count: ")" PROD_NODEPOOL_MAX_COUNT
    done

        
TEMPLATE_INFRA_REPO="platform-template"
TEMPLATE_ACM_REPO="acm-template"
ACM_REPO="acm-${INFRA_SETUP_REPO}"
GITHUB_SECRET_NAME="github-token"
TIMESTAMP=$(date "+%Y%m%d%H%M%S")
SA_FOR_API_KEY="api-key-sa-${TIMESTAMP}"
PROJECT_ID_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
if [[ -z ${INFRA_SETUP_PROJECT_ID} ]]; then
    INFRA_SETUP_PROJECT_ID=${INFRA_SETUP_PROJECT}-${PROJECT_ID_SUFFIX}
fi

# Validate active user is billing admin for billing account

while [ -z ${IS_GROUP} ]
    do
    read -p "$(echo -e "Is the identity running the script a part of billing admin group? (yes/no): ")" IS_GROUP
    done

if [ "$IS_GROUP" = "yes" ]; then
    while [ -z ${GROUP_NAME} ]
        do
        read -p "$(echo -e "Please enter group name: ")" GROUP_NAME
        done

    gcloud beta billing accounts get-iam-policy ${BILLING_ACCOUNT_ID} --format=json | \
    jq '.bindings[] | select(.role=="roles/billing.admin")' | grep $GROUP_NAME &>/dev/null
    [[ $? -eq 0 ]] || { echo "Active user is not an billing account billing admin in $BILLING_ACCOUNT_ID"; exit; }
    
else
    gcloud beta billing accounts get-iam-policy ${BILLING_ACCOUNT_ID} --format=json | \
    jq '.bindings[] | select(.role=="roles/billing.admin")' | grep $ADMIN_USER &>/dev/null
    [[ $? -eq 0 ]] || { echo "Active user is not an billing account billing admin in $BILLING_ACCOUNT_ID"; exit; }
fi    


#FUNCTIONS DEFINITIONS BELOW
generate_api_key () {
    title_no_wait "Creaing a Service Account for creating an API key ..." 
    print_and_execute "gcloud iam service-accounts create ${SA_FOR_API_KEY}  --display-name \"API Key {SA_FOR_API_KEY}\""

    title_no_wait "Granting access to cloudbuild SA for accessing the API key ..." 
    print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID} \
                       --member serviceAccount:${SA_FOR_API_KEY}@${INFRA_SETUP_PROJECT_ID}.iam.gserviceaccount.com \
                       --role roles/serviceusage.apiKeysAdmin"

    title_no_wait "Creating credentials for the SA ..."   
    print_and_execute "gcloud iam service-accounts keys create ~/credentials.json \
                       --iam-account ${SA_FOR_API_KEY}@${INFRA_SETUP_PROJECT_ID}.iam.gserviceaccount.com"

    if [[ `which oauth2l | wc -l` -eq 0 ]]; then
        title_no_wait "oauth2l not installed"
        title_no_wait "Download and install oauth2l ..." 
        print_and_execute "git clone  https://${GITHUB_USER}:${TOKEN}@github.com/google/oauth2l ${START_DIR}/oauth2l-${TIMESTAMP}"
        print_and_execute "cd ${START_DIR}/oauth2l-${TIMESTAMP}"
        print_and_execute "make dev"
        print_and_execute "oauth2l fetch --credentials ~/credentials.json --scope cloud-platform"
        print_and_execute "alias gcurl='curl -S -H \"$(oauth2l header --json ~/credentials.json cloud-platform userinfo.email)\" -H \"Content-Type: application/json\"'"
    
    else
        title_no_wait "oauth2l is already installed ..." 
        print_and_execute "alias gcurl='curl -S -H \"$(oauth2l header --json ~/credentials.json cloud-platform userinfo.email)\" -H \"Content-Type: application/json\"'"
    fi

    title_no_wait "checking if we are all set to create API key ..." 
    print_and_execute "type gcurl"
    if [ $? -ne 0 ]; then
        title_no_wait "gcurl alias not set. Problem in using oauth2l. Exiting"
        exit 1
    fi

    title_no_wait "Creating a API key for webhook ..." 
    # print_and_execute "operation_id=$(gcurl https://apikeys.googleapis.com/v2/projects/${INFRA_PROJECT_NUMBER}/locations/global/keys -X POST -d '{\"displayName\" : \"webhook\",\"restrictions\": {\"api_targets\": [{\"service\": \"cloudbuild.googleapis.com\"}]}}' | jq .name)"
    print_and_execute "operation_id=$(gcurl https://apikeys.googleapis.com/v2/projects/${INFRA_PROJECT_NUMBER}/locations/global/keys -X POST -d '{"displayName" : "webhook","restrictions": {"apiTargets": [{"service": "cloudbuild.googleapis.com"}]}}' | jq '."name"')"
    title_no_wait "Polling for the operation to complete ..."  
    status="false"
    while  [ ${status} != "true" ]
    do
        title_no_wait "Waititng for operation to create API to complete. Sleeping for 5"
        print_and_execute "status=$(gcurl https://apikeys.googleapis.com/v2/${operation_id} | jq .done)"
        if [[ -z ${status} ]]; then
            title_no_wait "Unable to fetch the status of API key create operaton. Possibly the command to create API key had issues. Aborting"
            exit   
        fi
        sleep 5
    done
    print_and_execute "API_KEY=$(gcurl https://apikeys.googleapis.com/v2/${operation_id} | jq .response.keyString)"
}

create_webhook () {

    title_no_wait "Creating a secret for webhook ..." 
    SECRET_NAME=webhook-secret-${TIMESTAMP}
    SECRET_VALUE=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 15))
    SECRET_PATH=projects/${INFRA_PROJECT_NUMBER}/secrets/${SECRET_NAME}/versions/1
    print_and_execute "printf ${SECRET_VALUE} | gcloud secrets create ${SECRET_NAME} --data-file=-"
    title_no_wait "Providing read access to Cloudbuild service account on the secret ..." 
    print_and_execute "gcloud secrets add-iam-policy-binding ${SECRET_NAME} \
         --member=serviceAccount:service-${INFRA_PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com \
         --role='roles/secretmanager.secretAccessor'"
 
    title_no_wait "Creating a webhook trigger ..."  
    print_and_execute "gcloud alpha builds triggers create webhook --name=\"infra-trigger-${TIMESTAMP}\"  --inline-config=\"${TEMP_DIR}/${INFRA_SETUP_REPO}/cloudbuild.yaml\" --secret=${SECRET_PATH} --substitutions='_REF=\$(body.ref),_REPO=\$(body.repository.full_name)'" 
    # Retrieve the URL
    WEBHOOK_URL="https://cloudbuild.googleapis.com/v1/projects/${INFRA_SETUP_PROJECT_ID}/triggers/infra-trigger-${TIMESTAMP}:webhook?key=${API_KEY}&secret=${SECRET_VALUE}"

    title_no_wait "Creating a github trigger ..."  
 
    print_and_execute "curl -H \"Authorization: token ${TOKEN}\" \
     -d '{\"config\": {\"url\": \"${WEBHOOK_URL}\", \"content_type\": \"json\"}}' \
     -X POST https://api.github.com/repos/$GITHUB_ORG/$INFRA_SETUP_REPO/hooks"

}
title_no_wait "STARTING"
# Create folder if the FOLDER_NAME was not entered blank
if [[ -n ${FOLDER_NAME} ]]; then 
    title_no_wait "Checking if folder ${FOLDER_NAME} already exists..."
    print_and_execute "folder_flag=$(gcloud resource-manager folders list --organization ${ORG_ID} --format=json --filter="display_name=${FOLDER_NAME}" | grep "\"displayName\": \"$FOLDER_NAME\"" | wc -l)"
    if [ ${folder_flag} -eq 0 ]; then
        title_no_wait "Folder ${FOLDER_NAME} does not exist. Creating it..."
        print_and_execute "gcloud resource-manager folders create --display-name=${FOLDER_NAME} --organization=${ORG_ID}"
        FOLDER_ID=$(gcloud resource-manager folders list --organization=${ORG_ID} --filter="display_name=${FOLDER_NAME}" --format="value(ID)")
        grep -q "export FOLDER_ID.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
    else
        title_no_wait "Folder ${FOLDER_NAME} already exists. Finding its ID..."
        FOLDER_ID=$(gcloud resource-manager folders list --organization=${ORG_ID} --filter="display_name=${FOLDER_NAME}" --format="value(ID)")
        grep -q "export FOLDER_ID.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
    fi
fi

# Create infa setup project
title_no_wait "Checking if ${INFRA_SETUP_PROJECT_ID} exist already..."
project_id=$(gcloud  projects list  --filter="PROJECT_ID=${INFRA_SETUP_PROJECT_ID}" --format="value(PROJECT_ID)")
if [[ -z ${project_id} ]]; then
    title_no_wait "${INFRA_SETUP_PROJECT_ID} does not exist.Creating platform setup project ..."
    if [[ -n ${FOLDER_NAME} ]]; then
        print_and_execute "gcloud projects create ${INFRA_SETUP_PROJECT_ID} \
            --folder ${FOLDER_ID} \
            --name ${INFRA_SETUP_PROJECT_ID} \
            --set-as-default"
    else
        print_and_execute "gcloud projects create ${INFRA_SETUP_PROJECT_ID} \
        --name ${INFRA_SETUP_PROJECT_ID} \
        --set-as-default"  
    fi
else
    title_no_wait "${INFRA_SETUP_PROJECT_ID} already exists, not creating it..."
fi

title_no_wait "Linking billing account to the ${INFRA_SETUP_PROJECT_ID}..."
print_and_execute "gcloud beta billing projects link ${INFRA_SETUP_PROJECT_ID} \
--billing-account ${BILLING_ACCOUNT_ID}"

#Storing variables in the state file so the script start from where it left off in even of a failure
grep -q "export INFRA_SETUP_PROJECT_ID.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_PROJECT_ID=${INFRA_SETUP_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export INFRA_SETUP_PROJECT=.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_PROJECT=${INFRA_SETUP_PROJECT}" >> ${LOG_DIR}/vars.sh
grep -q "export BILLING_ACCOUNT_ID=.*" ${LOG_DIR}/vars.sh|| echo -e "export BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export ORG_NAME=.*" ${LOG_DIR}/vars.sh|| echo -e "export ORG_NAME=${ORG_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export ORG_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export ORG_ID=${ORG_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export FOLDER_NAME=.*" ${LOG_DIR}/vars.sh|| echo -e "export FOLDER_NAME=${FOLDER_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export FOLDER_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export INFRA_SETUP_REPO=.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_REPO=${INFRA_SETUP_REPO}" >> ${LOG_DIR}/vars.sh
grep -q "export GITHUB_USER=.*" ${LOG_DIR}/vars.sh || echo -e "export GITHUB_USER=${GITHUB_USER}" >> ${LOG_DIR}/vars.sh
grep -q "export TOKEN=.*" ${LOG_DIR}/vars.sh|| echo -e "export TOKEN=${TOKEN}" >> ${LOG_DIR}/vars.sh
grep -q "export GITHUB_ORG=.*" ${LOG_DIR}/vars.sh || echo -e "export GITHUB_ORG=${GITHUB_ORG}" >> ${LOG_DIR}/vars.sh
grep -q "export TF_SERVICE_ACCOUNT=.*" ${LOG_DIR}/vars.sh || echo -e "export TF_SERVICE_ACCOUNT=${TF_SERVICE_ACCOUNT}" >> ${LOG_DIR}/vars.sh

grep -q "export DEV_GKE_PROJECT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_GKE_PROJECT_ID=${DEV_GKE_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_VPC_HOST_PROJECT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_VPC_HOST_PROJECT_ID=${DEV_VPC_HOST_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_NETWORK_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_NETWORK_NAME=${DEV_NETWORK_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_SUBNET_NAME=${DEV_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_SUBNET_REGION=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_SUBNET_REGION=${DEV_SUBNET_REGION}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_SERVICE_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_SERVICE_SUBNET_NAME=${DEV_SERVICE_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_POD_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_POD_SUBNET_NAME=${DEV_POD_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_ZONES=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_ZONES=${DEV_ZONES}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_NODEPOOL_MACHINE_TYPE=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_NODEPOOL_MACHINE_TYPE=${DEV_NODEPOOL_MACHINE_TYPE}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_NODEPOOL_MIN_COUNT=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_NODEPOOL_MIN_COUNT=${DEV_NODEPOOL_MIN_COUNT}" >> ${LOG_DIR}/vars.sh
grep -q "export DEV_NODEPOOL_MAX_COUNT=.*" ${LOG_DIR}/vars.sh || echo -e "export DEV_NODEPOOL_MAX_COUNT=${DEV_NODEPOOL_MAX_COUNT}" >> ${LOG_DIR}/vars.sh

grep -q "export STAGING_GKE_PROJECT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_GKE_PROJECT_ID=${STAGING_GKE_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_VPC_HOST_PROJECT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_VPC_HOST_PROJECT_ID=${STAGING_VPC_HOST_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_NETWORK_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_NETWORK_NAME=${STAGING_NETWORK_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_SUBNET_NAME=${STAGING_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_SUBNET_REGION=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_SUBNET_REGION=${STAGING_SUBNET_REGION}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_SERVICE_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_SERVICE_SUBNET_NAME=${STAGING_SERVICE_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_POD_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_POD_SUBNET_NAME=${STAGING_POD_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_ZONES=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_ZONES=${STAGING_ZONES}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_NODEPOOL_MACHINE_TYPE=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_NODEPOOL_MACHINE_TYPE=${STAGING_NODEPOOL_MACHINE_TYPE}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_NODEPOOL_MIN_COUNT=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_NODEPOOL_MIN_COUNT=${STAGING_NODEPOOL_MIN_COUNT}" >> ${LOG_DIR}/vars.sh
grep -q "export STAGING_NODEPOOL_MAX_COUNT=.*" ${LOG_DIR}/vars.sh || echo -e "export STAGING_NODEPOOL_MAX_COUNT=${STAGING_NODEPOOL_MAX_COUNT}" >> ${LOG_DIR}/vars.sh

grep -q "export PROD_GKE_PROJECT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_GKE_PROJECT_ID=${PROD_GKE_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_VPC_HOST_PROJECT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_VPC_HOST_PROJECT_ID=${PROD_VPC_HOST_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_NETWORK_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_NETWORK_NAME=${PROD_NETWORK_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_SUBNET_NAME=${PROD_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_SUBNET_REGION=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_SUBNET_REGION=${PROD_SUBNET_REGION}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_SERVICE_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_SERVICE_SUBNET_NAME=${PROD_SERVICE_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_POD_SUBNET_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_POD_SUBNET_NAME=${PROD_POD_SUBNET_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_ZONES=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_ZONES=${PROD_ZONES}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_NODEPOOL_MACHINE_TYPE=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_NODEPOOL_MACHINE_TYPE=${PROD_NODEPOOL_MACHINE_TYPE}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_NODEPOOL_MIN_COUNT=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_NODEPOOL_MIN_COUNT=${PROD_NODEPOOL_MIN_COUNT}" >> ${LOG_DIR}/vars.sh
grep -q "export PROD_NODEPOOL_MAX_COUNT=.*" ${LOG_DIR}/vars.sh || echo -e "export PROD_NODEPOOL_MAX_COUNT=${PROD_NODEPOOL_MAX_COUNT}" >> ${LOG_DIR}/vars.sh

# # Creating acm repo in your org and commiting the code from template to it

## ACM REPO NOT CREATED - YOGESH AGRAWAL 
title_no_wait "Checking if ${ACM_REPO} already exists..."
repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${ACM_REPO}" | jq '.id')
if [ ${repo_id_exists} = "null" ]; then
    title_no_wait "${ACM_REPO} does not exist. Creating it..."
    print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
        -d "{ \
            \"name\": \"${ACM_REPO}\", \
            \"private\": true \
        }" \
    -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"

    sleep 5
    if [ ${repo_id} = "null" ]; then
        echo "Unable to create git repo.Exiting"
        exit 1
    else
        grep -q "export ACM_REPO=.*" ${LOG_DIR}/vars.sh || echo -e "export ACM_REPO=${ACM_REPO}" >> ${LOG_DIR}/vars.sh
    fi
else
    echo "The repo ${ACM_REPO} already exists, not creating it"
fi
title_no_wait "Cloning recently created acm repo..."
print_and_execute "rm -rf ${TEMP_DIR}/${ACM_REPO} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${ACM_REPO} ${TEMP_DIR}/${ACM_REPO}"
if [[ -d ${BASE_DIR}/${TEMPLATE_ACM_REPO} ]]; then
    print_and_execute "cd ${TEMP_DIR}/${ACM_REPO}"
    print_and_execute "git checkout dev 2>/dev/null || git checkout -b dev"
    print_and_execute "cp -r ${BASE_DIR}/${TEMPLATE_ACM_REPO}/* ."
    print_and_execute "git add . && git commit -m \"Adding repo\""
    print_and_execute "git push -u origin dev"

    title_no_wait "Pushing staging branch to ${ACM_REPO} ..."
    print_and_execute "git checkout staging 2>/dev/null || git checkout -b staging"
    print_and_execute "git push -u origin staging"

    title_no_wait "Pushing prod branch to ${ACM_REPO} ..."
    print_and_execute "git checkout prod 2>/dev/null || git checkout -b prod"
    print_and_execute "git push -u origin prod"
else
    title_no_wait "Can not find ${BASE_DIR}/${TEMPLATE_ACM_REPO}. Exiting"
    print_and_execute "exit 1"
fi

#Secure staging and prod branch but disallowing direct push to them
title_no_wait "Applying branch protection..."
print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$ACM_REPO/branches/staging/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "

print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$ACM_REPO/branches/prod/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "

# Creating platform repo in your org and commiting the code from template to it
title_no_wait "Checking if ${INFRA_SETUP_REPO} already exists..."
repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${INFRA_SETUP_REPO}" | jq '.id')
if [ ${repo_id_exists} = "null" ]; then
    title_no_wait "${INFRA_SETUP_REPO} does not exist. Creating it ..."
    print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
        -d "{ \
            \"name\": \"${INFRA_SETUP_REPO}\", \
            \"private\": true \
        }" \
        -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"

    sleep 5
    if [ ${repo_id} = "null" ]; then
        echo "Unable to create git repo.Exiting"
        exit 1
    else
        grep -q "export INFRA_SETUP_REPO=.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_REPO=${INFRA_SETUP_REPO}" >> ${LOG_DIR}/vars.sh
    fi
else
    echo "The repo ${INFRA_SETUP_REPO} already exists, not creating it"
fi

title_no_wait "Cloning recently created infra repo ${INFRA_SETUP_REPO}..."
print_and_execute "rm -rf ${TEMP_DIR}/${INFRA_SETUP_REPO} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${INFRA_SETUP_REPO} ${TEMP_DIR}/${INFRA_SETUP_REPO}"
if [[ -d ${BASE_DIR}/${TEMPLATE_INFRA_REPO} ]]; then
    print_and_execute "cd ${TEMP_DIR}/${INFRA_SETUP_REPO}"
    print_and_execute "git checkout dev 2>/dev/null || git checkout -b dev"
    print_and_execute "cp -r ${BASE_DIR}/${TEMPLATE_INFRA_REPO}/* ."
    print_and_execute "git add . && git commit -m \"Adding repo\""
    print_and_execute "git push -u origin dev"

    title_no_wait "Pushing staging branch to ${INFRA_SETUP_REPO} ..."
    print_and_execute "git checkout staging 2>/dev/null || git checkout -b staging"
    print_and_execute "git push -u origin staging"

    title_no_wait "Pushing prod branch to ${INFRA_SETUP_REPO} ..."
    print_and_execute "git checkout prod 2>/dev/null || git checkout -b prod"
    print_and_execute "git push -u origin prod"
else
    title_no_wait "Can not find ${BASE_DIR}/${TEMPLATE_INFRA_REPO}. Exiting"
    print_and_execute "exit 1"
fi    

#Secure staging and prod branch but disallowing direct push to them
title_no_wait "Applying branch protection..."
print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$INFRA_SETUP_REPO/branches/staging/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "

print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$INFRA_SETUP_REPO/branches/prod/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "
#Setting up the infrastructure setup project
title_no_wait "Setting project..."
print_and_execute "gcloud config set project ${INFRA_SETUP_PROJECT_ID}"

title_no_wait "Enabling APIs..."
print_and_execute "gcloud services enable cloudresourcemanager.googleapis.com \
cloudbilling.googleapis.com \
cloudbuild.googleapis.com \
iam.googleapis.com \
secretmanager.googleapis.com \
container.googleapis.com \
apikeys.googleapis.com \
cloudidentity.googleapis.com"

## Removed Devgroup present testing - Yogesh Agrawal
title_no_wait "Checking if IAM Group already exists..."
print_and_execute "group_id_exists=$(gcloud beta identity groups describe "${IAM_GROUP}@${ORG_NAME}" --format=json | jq '.name' | tr '"' ' ' | awk -F '/' '{print $2}')"
if [[ -z ${group_id_exists} ]]; then
    title_no_wait "${IAM_GROUP}@${ORG_NAME} does not exist. Creating it..."
    print_and_execute "gcloud beta identity groups create "${IAM_GROUP}@${ORG_NAME}" --organization=${ORG_ID}"
else
    title_no_wait "IAM group ${IAM_GROUP}@${ORG_NAME} already exists, not creating it..."
fi
title_no_wait "Fetching IAM Group ID that you created above..."
print_and_execute "GROUP_ID=$(gcloud beta identity groups describe "${IAM_GROUP}@${ORG_NAME}" --format=json | jq '.name' | tr '"' ' ' | awk -F '/' '{print $2}')"
grep -q "export IAM_GROUP=.*" ${LOG_DIR}/vars.sh || echo -e "export IAM_GROUP=${IAM_GROUP}@${ORG_NAME}" >> ${LOG_DIR}/vars.sh

# title_and_wait "ATTENTION : We need to update the IAM group to allow external members so we can add service accounts to it. As of now, there is no easy way of doing it automatically, press ENTER for instructions for doing it manually."
# title_and_wait_step "Go to https://admin.google.com/u/2/ac/groups/${GROUP_ID} . Click Access Settings. Click the pencil icon and turn on the Allow members outside your organization setting. Click Save."

title_no_wait "Granting required roles to the IAM goup..."
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID} --member group:"${IAM_GROUP}@${ORG_NAME}"  --role=roles/secretmanager.viewer --condition=None"
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID} --member group:"${IAM_GROUP}@${ORG_NAME}"  --role=roles/secretmanager.secretAccessor --condition=None"
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID} --member group:"${IAM_GROUP}@${ORG_NAME}"  --role=roles/storage.objectViewer --condition=None"
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID} --member group:"${IAM_GROUP}@${ORG_NAME}"  --role=roles/container.developer --condition=None"



title_no_wait "Getting project number for ${INFRA_SETUP_PROJECT}"
print_and_execute "INFRA_PROJECT_NUMBER=$(gcloud projects describe ${INFRA_SETUP_PROJECT_ID} --format=json | jq '.projectNumber')"
title_no_wait "Add Cloud build service account as billing account user on the org"
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/billing.user --condition=None"

title_no_wait "Give cloudbuild service account projectCreator role at Org level..."
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.projectCreator --condition=None"

title_no_wait "Give cloudbuild service account secretmanager admin role at project level..."
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/secretmanager.admin"

title_no_wait "Give cloudbuild service account service account token creator role at project level..."
print_and_execute "gcloud projects add-iam-policy-binding  ${TF_SERVICE_ACCOUNT_PROJECT} --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/iam.serviceAccountTokenCreator"

title_no_wait "Adding github token to secret manager..."
print_and_execute "printf ${TOKEN} | gcloud secrets create ${GITHUB_SECRET_NAME} --data-file=-"

### Adding permission for billing account - Yogesh Agrawal
title_no_wait "Add Cloud build service account for Infra project as billing account user in Account - Yogesh Agrawal"
print_and_execute "gcloud beta billing accounts add-iam-policy-binding ${BILLING_ACCOUNT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/billing.user"



INFRA_TF_BUCKET="${INFRA_SETUP_PROJECT_ID}-platform-tf"

title_no_wait "Creating GCS bucket for holding terraform state files..."
print_and_execute "gsutil mb gs://${INFRA_TF_BUCKET}"

#The following two functions create thr webhook trigger
generate_api_key
create_webhook

#Perform sed operation to replace templated variables with real values
cd ${TEMP_DIR}/${INFRA_SETUP_REPO}
title_no_wait "Checkout dev branch..."
print_and_execute "git checkout dev"

title_no_wait "Replacing variables in variables.tf under dev, staging and prod folder in ${INFRA_SETUP_REPO}..."
# sed -i "s/YOUR_INFRA_PROJECT_ID/${INFRA_SETUP_PROJECT_ID}/"  env/*/variables.tf
# sed -i "s/YOUR_IAM_GROUP/${IAM_GROUP}@${ORG_NAME}/"  env/*/variables.tf
# sed -i "s/YOUR_BILLING_ACCOUNT/${BILLING_ACCOUNT_ID}/"  env/*/variables.tf
# sed -i "s/YOUR_ORG_ID/${ORG_ID}/"  env/*/variables.tf
# sed -i "s/YOUR_ACM_REPO/${ACM_REPO}/" env/*/variables.tf
# sed -i "s/YOUR_GITHUB_USER/${GITHUB_USER}/"  env/*/variables.tf
# sed -i "s/YOUR_GITHUB_ORG/${GITHUB_ORG}/"  env/*/variables.tf

sed -i "s/YOUR_INFRA_PROJECT_ID/${INFRA_SETUP_PROJECT_ID}/"  env/*/*.auto.tfvars
sed -i "s/YOUR_IAM_GROUP/${IAM_GROUP}@${ORG_NAME}/"  env/*/*.auto.tfvars
sed -i "s/YOUR_BILLING_ACCOUNT/${BILLING_ACCOUNT_ID}/"  env/*/*.auto.tfvars
sed -i "s/YOUR_ORG_ID/${ORG_ID}/"  env/*/*.auto.tfvars
sed -i "s/YOUR_ACM_REPO/${ACM_REPO}/" env/*/*.auto.tfvars
sed -i "s/YOUR_GITHUB_USER/${GITHUB_USER}/"  env/*/*.auto.tfvars
sed -i "s/YOUR_GITHUB_ORG/${GITHUB_ORG}/"  env/*/*.auto.tfvars
sed -i "s/SLZ_TERRAFORM_INFRA_SERVICE_ACCOUNT/${TF_SERVICE_ACCOUNT}/"  env/*/*.auto.tfvars


if [[ -n ${FOLDER_ID} ]]; then
    #sed -i "s/YOUR_FOLDER_ID/${FOLDER_ID}/"  env/*/variables.tf
    sed -i "s/YOUR_FOLDER_ID/${FOLDER_ID}/"  env/*/*.auto.tfvars
else
    #sed -i "s/YOUR_FOLDER_ID//"  env/*/variables.tf
    sed -i "s/YOUR_FOLDER_ID//"  env/*/*.auto.tfvars
fi

title_no_wait "Replacing variables in variables.tf under dev folder only in ${INFRA_SETUP_REPO}..."
# sed -i "s/YOUR_GITHUB_EMAIL/${GITHUB_USER}@github.com/"  env/dev/variables.tf
# sed -i "s/YOUR_GROUP_ID/${GROUP_ID}/"  env/dev/variables.tf

sed -i "s/YOUR_GITHUB_EMAIL/${GITHUB_USER}@github.com/"  env/*/*.auto.tfvars
sed -i "s/YOUR_GROUP_ID/${GROUP_ID}/"  env/*/*.auto.tfvars

sed -i "s/YOUR_DEV_GKE_PROJECT_ID/${DEV_GKE_PROJECT_ID}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_VPC_HOST_PROJECT_ID/${DEV_VPC_HOST_PROJECT_ID}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_NETWORK_NAME/${DEV_NETWORK_NAME}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_SUBNET_NAME/${DEV_SUBNET_NAME}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_SUBNET_REGION/${DEV_SUBNET_REGION}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_SERVICE_SUBNET_NAME/${DEV_SERVICE_SUBNET_NAME}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_POD_SUBNET_NAME/${DEV_POD_SUBNET_NAME}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_ZONES/${DEV_ZONES}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_NODEPOOL_MACHINE_TYPE/${DEV_NODEPOOL_MACHINE_TYPE}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_NODEPOOL_MIN_COUNT/${DEV_NODEPOOL_MIN_COUNT}/"  env/dev/*.auto.tfvars
sed -i "s/YOUR_DEV_NODEPOOL_MAX_COUNT/${DEV_NODEPOOL_MAX_COUNT}/"  env/dev/*.auto.tfvars


title_no_wait "Replacing variables in staging.auto.tfvars under staging folder only in ${INFRA_SETUP_REPO}..."

sed -i "s/YOUR_STAGING_GKE_PROJECT_ID/${STAGING_GKE_PROJECT_ID}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_VPC_HOST_PROJECT_ID/${STAGING_VPC_HOST_PROJECT_ID}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_NETWORK_NAME/${STAGING_NETWORK_NAME}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_SUBNET_NAME/${STAGING_SUBNET_NAME}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_SUBNET_REGION/${STAGING_SUBNET_REGION}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_SERVICE_SUBNET_NAME/${STAGING_SERVICE_SUBNET_NAME}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_POD_SUBNET_NAME/${STAGING_POD_SUBNET_NAME}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_ZONES/${STAGING_ZONES}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_NODEPOOL_MACHINE_TYPE/${STAGING_NODEPOOL_MACHINE_TYPE}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_NODEPOOL_MIN_COUNT/${STAGING_NODEPOOL_MIN_COUNT}/"  env/staging/*.auto.tfvars
sed -i "s/YOUR_STAGING_NODEPOOL_MAX_COUNT/${STAGING_NODEPOOL_MAX_COUNT}/"  env/staging/*.auto.tfvars

title_no_wait "Replacing variables in prod.auto.tfvars under prod folder only in ${INFRA_SETUP_REPO}..."

sed -i "s/YOUR_PROD_GKE_PROJECT_ID/${PROD_GKE_PROJECT_ID}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_VPC_HOST_PROJECT_ID/${PROD_VPC_HOST_PROJECT_ID}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_NETWORK_NAME/${PROD_NETWORK_NAME}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_SUBNET_NAME/${PROD_SUBNET_NAME}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_SUBNET_REGION/${PROD_SUBNET_REGION}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_SERVICE_SUBNET_NAME/${PROD_SERVICE_SUBNET_NAME}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_POD_SUBNET_NAME/${PROD_POD_SUBNET_NAME}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_ZONES/${PROD_ZONES}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_NODEPOOL_MACHINE_TYPE/${PROD_NODEPOOL_MACHINE_TYPE}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_NODEPOOL_MIN_COUNT/${PROD_NODEPOOL_MIN_COUNT}/"  env/prod/*.auto.tfvars
sed -i "s/YOUR_PROD_NODEPOOL_MAX_COUNT/${PROD_NODEPOOL_MAX_COUNT}/"  env/prod/*.auto.tfvars

title_no_wait "Replacing tf bucket in backend.tf in ${INFRA_SETUP_REPO}..."
sed -i "s/YOUR_PLATFORM_INFRA_TERRAFORM_STATE_BUCKET/${INFRA_TF_BUCKET}/" env/*/backend.tf

title_no_wait "Committing and pushing changes to ${INFRA_SETUP_REPO}..."
git add env/*/variables.tf env/*/backend.tf env/*/dev.auto.tfvars env/*/prod.auto.tfvars env/*/staging.auto.tfvars
git config --global user.name ${GITHUB_USER}
git config --global user.email "${GITHUB_USER}github.com"
git commit -m "Initial setup"
git push

title_no_wait "The push to the ${INFRA_SETUP_REPO} has started the cloudbuild trigger. Go to https://console.cloud.google.com/cloud-build/builds?project=${INFRA_SETUP_PROJECT} ."
title_no_wait "FINISHED"
