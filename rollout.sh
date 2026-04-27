#!/bin/bash

set -e

env

SERVICE_NAME="${SERVICE_NAME:-new-api}"
services=("$SERVICE_NAME")

COMPUTE_REGION="${COMPUTE_REGION:-asia-east2}"
DEPLOY_ENV="${DEPLOY_ENV:-testnet}"
ADDITIONAL_FLAGS=""
env=""

if [[ "$DEPLOY_ENV" == "prod" ]] ; then
    env="-prod"
elif [[ "$DEPLOY_ENV" == "staging" ]] ; then
    env="-staging"
else
    env="-dev"
fi


if [[ $# -eq 0 ]] ; then
    echo "DEPLOY_ENV=prod ./rollout.sh <image>"
    exit 1
elif [[ $# -eq 1 ]] ; then
    image=$1
else
    echo "invalid arguments"
    echo "DEPLOY_ENV=prod ./rollout.sh <image>"
    exit 1
fi

for svc in ${services[@]}; do
    echo "Rolling out $svc$env"
    gcloud run services update $svc$env \
        --image $image \
        --command /new-api \
        --region $COMPUTE_REGION \
        --set-env-vars "TZ=Asia/Shanghai" \
        --set-env-vars "ERROR_LOG_ENABLED=true" \
        --set-env-vars "BATCH_UPDATE_ENABLED=true" \
        $ADDITIONAL_FLAGS
done
