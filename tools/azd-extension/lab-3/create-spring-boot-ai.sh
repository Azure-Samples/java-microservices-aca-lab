#!/bin/bash

AZURE_CONFIG_FILE="../config/azure-resource.profile"
source $AZURE_CONFIG_FILE

SPRING_PETCLINIC_MICROSERIVCES="../../../spring-petclinic-microservices"
SPRING_PETCLINIC_CHAT_SERVICE="spring-petclinic-chat-service"

cd $SPRING_PETCLINIC_MICROSERIVCES
# Check if the spring-petclinic-chat-service directory exists
if [ -d "$SPRING_PETCLINIC_CHAT_SERVICE" ]; then
  # remove the directory
  echo "Remove directory: $SPRING_PETCLINIC_CHAT_SERVICE."
  rm -rf $SPRING_PETCLINIC_CHAT_SERVICE

  echo "Recreate directory: $SPRING_PETCLINIC_CHAT_SERVICE."
  # recreate the directory
  mkdir -p $SPRING_PETCLINIC_CHAT_SERVICE
fi

 curl https://start.spring.io/starter.tgz \
     -d dependencies=web,cloud-eureka,actuator,lombok,spring-ai-azure-openai \
     -d name=chat-service -d type=maven-project \
     -d jvmVersion=17 -d language=java -d packaging=jar \
     -d groupId=org.springframework.samples.petclinic -d artifactId=chat \
     -d description="Spring Petclinic Chat Service" \
     | tar -xzvf - -C $SPRING_PETCLINIC_CHAT_SERVICE

POM=$SPRING_PETCLINIC_CHAT_SERVICE/pom.xml
SPRING_AI_VERSION="1.0.0-M6"

# # update the spring-ai.version in the pom.xml
# if grep -q "<spring-ai.version>" $POM; then
#   sed -i "s|<spring-ai.version>.*</spring-ai.version>|<spring-ai.version>$SPRING_AI_VERSION</spring-ai.version>|" $POM
# else
#   sed -i "/<properties>/a \    <spring-ai.version>$SPRING_AI_VERSION</spring-ai.version>" $POM
# fi

{ 
  echo "## AI VERSION"
  echo "SPRING_AI_VERSION=$SPRING_AI_VERSION" 
} >> $AZURE_CONFIG_FILE

TEST_FILE="https://raw.githubusercontent.com/spring-projects/spring-ai/refs/heads/$SPRING_AI_VERSION/models/spring-ai-azure-openai/src/test/java/org/springframework/ai/azure/openai/AzureOpenAiChatClientIT.java"
curl $TEST_FILE -o $SPRING_PETCLINIC_CHAT_SERVICE/src/main/resources/AzureOpenAiChatClientIT.java

CHAT_CONFIGURE_JAVA="../tools/azd-extension/lab-3/AzureOpenAiConfig.java"
CHAT_CONTROLLER_JAVA="../tools/azd-extension/lab-3/ChatController.java"
APPLICATION_PROPERTIES="../tools/azd-extension/lab-3/application.properties"
DOCKERFILE="../tools/Dockerfile"

cp $CHAT_CONFIGURE_JAVA $SPRING_PETCLINIC_CHAT_SERVICE/src/main/java/org/springframework/samples/petclinic/chat
cp $CHAT_CONTROLLER_JAVA $SPRING_PETCLINIC_CHAT_SERVICE/src/main/java/org/springframework/samples/petclinic/chat

{
  echo "spring.application.name=chat-service" 
  echo "spring.ai.azure.openai.api-key=$AZURE_OPENAI_API_KEY"
  echo "spring.ai.azure.openai.endpoint=$AZURE_OPENAI_ENDPOINT"
  echo "spring.ai.azure.openai.chat.options.deployment-name=gpt-4o"
  echo "spring.ai.azure.openai.chat.options.temperature=0.7"
} > $APPLICATION_PROPERTIES

cp $APPLICATION_PROPERTIES $SPRING_PETCLINIC_CHAT_SERVICE/src/main/resources/application.properties

cd $SPRING_PETCLINIC_CHAT_SERVICE
mvn clean package -DskipTests

# Export the environment variables
export AZURE_OPENAI_API_KEY="$AZURE_OPENAI_API_KEY"
export AZURE_OPENAI_ENDPOINT="$AZURE_OPENAI_ENDPOINT"

APP_NAME=chat-service

cd ..
echo "APPS_IDENTITY_ID: $APPS_IDENTITY_ID"

cp -f $DOCKERFILE ./spring-petclinic-$APP_NAME/Dockerfile
# Disable path conversion for MSYS (Git Bash)
export MSYS_NO_PATHCONV=1
az containerapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ACA_ENVIRONMENT \
    --source ./spring-petclinic-$APP_NAME \
    --registry-server $MYACR.azurecr.io \
    --registry-identity $APPS_IDENTITY_ID \
    --ingress external \
    --target-port 8080 \
    --min-replicas 1 \
    --bind $JAVA_CONFIG_COMP_NAME $JAVA_EUREKA_COMP_NAME \
    --runtime java

CHAT_URL=$(az containerapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query properties.configuration.ingress.fqdn \
  -o tsv)

echo "Chat service URL: $CHAT_URL"

curl https://$CHAT_URL/ai/generate
