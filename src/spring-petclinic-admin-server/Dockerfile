# syntax=docker/dockerfile:1

# build
FROM mcr.microsoft.com/openjdk/jdk:17-mariner AS build

ARG AI_VERSION=3.5.4

RUN yum update && \
    yum install -y wget

RUN wget https://github.com/microsoft/ApplicationInsights-Java/releases/download/$AI_VERSION/applicationinsights-agent-$AI_VERSION.jar -O ai.jar

# run
FROM mcr.microsoft.com/openjdk/jdk:17-distroless

ARG VERSION=3.2.5

COPY --from=build ./ai.jar ai.jar

COPY ./target/spring-petclinic-admin-server-$VERSION.jar app.jar

EXPOSE 8080

# Run the jar file
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-javaagent:/ai.jar", "-jar", "/app.jar"]
