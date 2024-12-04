#!/usr/bin/env bash

DIR=/tmp

INGRESS=internal

create_app() {
    APP_NAME=$1

    echo "Start creating app $APP_NAME ..."

    az containerapp create \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --source ./spring-petclinic-$APP_NAME \
        --registry-server $MYACR.azurecr.io \
        --registry-identity $USER_ID \
        --environment $ACA_ENVIRONMENT \
        --user-assigned $USER_ID \
        --ingress $INGRESS \
        --target-port 8080 \
        --min-replicas 1 \
        --bind $JAVA_CONFIG_COMP_NAME $JAVA_EUREKA_COMP_NAME \
        --runtime java \
        > $DIR/$APP_NAME.create.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Create app $APP_NAME failed, check $DIR/$APP_NAME.create.log for more details"
        return 1
    fi

    return 0
}

CHECK_FAIL=$DIR/aca-lab.$$

for name in customers-service vets-service visits-service; do
    create_app $name || touch $CHECK_FAIL &
done

wait < <(jobs -p)

if [[ -f $CHECK_FAIL ]]; then
    echo "Error happens on create apps, please check the logs for more details"
    exit 1
else
    echo "Create apps succeed"
    exit 0
fi

