#!/usr/bin/env bash

DIR=/tmp

PROFILE=passwordless

update_app_passwordless() {
    APP_NAME=$1

    APP_ID=$(az containerapp show \
            --resource-group $RESOURCE_GROUP \
            --name $APP_NAME \
            --query id \
            -o tsv)

    echo "Creating service connection for app $APP_NAME ..."
    az containerapp connection create mysql-flexible \
        --resource-group $RESOURCE_GROUP \
        --connection mysql_conn \
        --source-id $APP_ID \
        --target-id $DB_ID \
        --client-type SpringBoot \
        --user-identity client-id=$APPS_IDENTITY_CLIENT_ID subs-id=$SUBID mysql-identity-id=$ADMIN_IDENTITY_RESOURCE_ID user-object-id=$AAD_USER_ID \
        --container $APP_NAME > $DIR/$APP_NAME.connection.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Create service connection for $APP_NAME failed, check $DIR/$APP_NAME.connection.log for more details"
        return 1
    fi

    az containerapp identity assign \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --user-assigned $APPS_IDENTITY_ID

    echo "Updating app $APP_NAME with PROFILE=passwordless ..."
    az containerapp update \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --source ./spring-petclinic-$APP_NAME \
        --set-env-vars SPRING_PROFILES_ACTIVE=$PROFILE \
        --remove-env-vars SQL_SERVER SQL_USER SQL_PASSWORD
        > $DIR/$APP_NAME.update.log 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Update app $APP_NAME failed, check $DIR/$APP_NAME.update.log for more details"
        return 2
    fi

    az containerapp secret remove \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --secret-names sql-password

    return 0
}

CHECK_FAIL=$DIR/aca-lab.$$

for name in vets-service visits-service; do
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
