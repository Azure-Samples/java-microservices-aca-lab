# syntax=docker/dockerfile:1

# run
FROM mcr.microsoft.com/openjdk/jdk:17-distroless

# Prepare the Application Insights Java agent
ARG AI_VERSION=3.6.2
ADD https://github.com/microsoft/ApplicationInsights-Java/releases/download/$AI_VERSION/applicationinsights-agent-$AI_VERSION.jar /applicationinsights-agent.jar

COPY ./target/*.jar app.jar

EXPOSE 8080

# Run the jar file
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]
