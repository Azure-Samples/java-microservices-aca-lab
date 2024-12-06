#!/usr/bin/env bash

DIR=/tmp

PROFILE=passwordless

update_app_passwordless() {
    APP_NAME=$1

    echo "Start updating app $APP_NAME with application insights agent ..."

    cp -f ../tools/ai.Dockerfile ./spring-petclinic-$APP_NAME/Dockerfile

    az containerapp update \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --source ./spring-petclinic-$APP_NAME \
        --set-env-vars SPRING_PROFILES_ACTIVE=$PROFILE \
        > $DIR/$APP_NAME.update.log 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Update app $APP_NAME failed, check $DIR/$APP_NAME.update.log for more details"
        return 2
    fi

    return 0
}

CHECK_FAIL=$DIR/aca-lab.$$

for name in customers-service vets-service visits-service; do
    update_app_passwordless $name || touch $CHECK_FAIL &
done

wait < <(jobs -p)

if [[ -f $CHECK_FAIL ]]; then
    echo "Error happens on update apps, please check the logs for more details"
    exit 1
else
    echo "Update apps succeed"
    exit 0
fi

