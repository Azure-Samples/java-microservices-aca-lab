#!/usr/bin/env bash

DIR=/tmp

update_app_with_ai() {
    APP_NAME=$1

    echo "Updating app $APP_NAME with application insights agent ..."

    az containerapp update \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --set-env-vars JAVA_TOOL_OPTIONS='-javaagent:/applicationinsights-agent.jar' APPLICATIONINSIGHTS_CONNECTION_STRING="$APP_INSIGHTS_CONN" APPLICATIONINSIGHTS_CONFIGURATION_CONTENT='{"role": {"name": "'$APP_NAME'"}}' \
        > $DIR/$APP_NAME.update.log 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Update app $APP_NAME failed, check $DIR/$APP_NAME.update.log for more details"
        return 2
    fi

    echo "Update app $APP_NAME succeed"
    return 0
}

CHECK_FAIL=$DIR/aca-lab.$$

for name in customers-service vets-service visits-service; do
    update_app_with_ai $name || touch $CHECK_FAIL &
done

wait < <(jobs -p)

if [[ -f $CHECK_FAIL ]]; then
    echo "Error happens on update apps, please check the logs for more details"
    exit 1
else
    echo "Update succeed"
    exit 0
fi

