#!/usr/bin/env bash

DIR=/tmp

build_and_deploy() {
    APP_NAME=$1

    echo "Start building and deploying app $APP_NAME with application insights agent ..."

    az acr build -g $RESOURCE_GROUP --registry $MYACR \
        --image spring-petclinic-$APP_NAME:$IMAGE_TAG \
        --file spring-petclinic-$APP_NAME/ai.Dockerfile spring-petclinic-$APP_NAME \
        > $DIR/$APP_NAME.build.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Build image for $APP_NAME failed, check $DIR/$APP_NAME.build.log for more details"
        return 1
    fi

    az containerapp update \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --image $MYACR.azurecr.io/spring-petclinic-$APP_NAME:$IMAGE_TAG \
        --set-env-vars APPLICATIONINSIGHTS_CONNECTION_STRING=$AI_CONNECTIONSTRING APPLICATIONINSIGHTS_CONFIGURATION_CONTENT='{"role": {"name": "'$APP_NAME'"}}' \
        > $DIR/$APP_NAME.deploy.log 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Deploy app $APP_NAME failed, check $DIR/$APP_NAME.deploy.log for more details"
        return 2
    fi

    return 0
}

CHECK_FAIL=$DIR/aca-lab.$$

for name in customers-service vets-service visits-service; do
    build_and_deploy $name || touch $CHECK_FAIL &
done

wait < <(jobs -p)

if [[ -f $CHECK_FAIL ]]; then
    echo "Error happens on build and depploy apps, please check the logs for more details"
    exit 1
else
    echo "Build and deploy apps succeed"
    exit 0
fi

