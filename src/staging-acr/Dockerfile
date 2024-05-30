FROM mcr.microsoft.com/openjdk/jdk:17-mariner
   
   ARG ARTIFACT_NAME
   ARG APP_PORT
   ARG AI_JAR
   
   EXPOSE ${APP_PORT} 8778 9779
   
   # The application's jar file
   ARG JAR_FILE=${ARTIFACT_NAME}
   ARG APP_INSIGHTS_JAR=${AI_JAR}
   
   # Add the application's jar to the container
   ADD ${JAR_FILE} app.jar
   
   # Add App Insights jar to the container
   ADD ${APP_INSIGHTS_JAR} ai.jar
   
   # Run the jar file
   ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-javaagent:/ai.jar","-jar","/app.jar"]