---
title: Introduction
layout: home
nav_order: 1
---

# Lab: Deploying and running Java Applications with AI in Azure Container Apps

This lab teaches you how to deploy the [Spring Petclinic Microservices](https://github.com/Azure-Samples/java-microservices-aca-lab/tree/main/src) application with OpenAI to [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/overview) and integrate it with additional Azure services, also some samples for Azure Container Apps features.

## Modules

This lab has modules on:

* A general introduction to the sample microservices and the related Azure resources
* Launch a Spring Apps microservices application to Azure Container Apps Service
* Enable monitoring and end-to-end tracing
* Connect to services securely with managed identity
* Build intelligent Spring Apps with Azure OpenAI
* Automatically launch the microservices to Azure
* Build reliable java apps on Azure Container Apps

The lab is available as GitHub pages [here](https://azure-samples.github.io/java-microservices-aca-lab/)

## Getting Started

### Prerequisites

For running this lab you will need:

* A GitHub account
* An Azure Subscription

### Region Availability

1. This template uses [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview) deployment mododules **gpt-4o** and **text-embedding-ada-002** which may not be available in all Azure regions. Check for [up-to-date region availability](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#standard-deployment-model-availability) and select a region during deployment accordingly

1. The template uses [Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/overview) version 8.0 to store data. You may select a region suite for this service. Or create a database instance manually then [Reuse existing service](https://azure-samples.github.io/java-microservices-aca-lab/docs/06_lab_automation/0604.html).

  * We recommend using **East US**, **East US 2**, **North Central US**, **Sweden Central**.

### Workthrough guide

Based on your current knowledge background and your plan, there are some typical usage scenarios for your reference:

* If you are not familiar with Azure Spring Apps and want to learn how to deploy new project in Azure Container Apps, you may start from these labs:
  * [Lab 2: Launch a Spring Apps microservices application to Azure Container Apps]({% link docs/02_lab_launch/02_openlab_setup_aca.md %})
  * [Lab 3: Enable monitoring and end-to-end tracing]({% link docs/03_lab_monitor/03_openlab_monitoring_aca.md %})
  * [Lab 4: Connect to Database securely using identity]({% link docs/04_lab_secrets/04_openlab_secrets_aca.md %})

  It will take about 2 days to learn from selected labs.

* If you want to learn how AI components are integrated in to microservices, you may check the details in:
  * [Lab 5: Integrate with Azure OpenAI]({% link docs/05_lab_openai/05_openlab_openai_aca.md %})

* If you already have some experiences on Azure Container Apps, and you want to try some azd automation to get a AI enabled microservice environment, you may jump directly to:
  * [More useful toics / Deploy to Azure automatically]({% link docs/06_lab_automation/06_openlab_automation.md %})

  You may get a new environment in 2 hours.

* There are also some useful features in Azure Container Apps, you may find your interested topics in:
  * [LMore useful toics / Build reliable Java application on ACA]({% link docs/10_lab_reliable_application/10_reliable_java_aca.md %})

### Installation

For running this lab with all the needed tooling, there are 3 options available:

* [Using a GitHub codespace]({% link install.md %}#using-a-github-codespace)
* [Using Visual Studio Code with remote containers option]({% link install.md %}#using-visual-studio-code-with-remote-containers)
* [Install all the tools on your local machine]({% link install.md %}#install-all-the-tools-on-your-local-machine)

All the steps of this lab have been tested in the GitHub CodeSpace. This is the preferred option for running this lab!

Full installation guidance and options for running this lab can be found in the [Installation]({% link install.md %}) instructions.
