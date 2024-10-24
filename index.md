---
title: Introduction
layout: home
nav_order: 1
---

# Lab: Deploying and running Java Applications with AI in Azure Container Apps

This lab teaches you how to deploy the [Spring Petclinic Microservices](https://github.com/Azure-Samples/java-microservices-aca-lab/tree/main/src) application with OpenAI to [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/overview) and integrate it with additional Azure services, also some samples for Azure Container Apps features.

## Modules

This lab has modules on:

* Plan a Java application migration to Azure Container Apps Service
* Migrate a Spring Apps microservices application to Azure Container Apps Service
* Enable monitoring and end-to-end tracing
* Secure application secrets using Key Vault
* Build intelligent Spring Apps with Azure OpenAI
* Protect endpoints using Web Application Firewalls
* Secure MySQL database and Key Vault using a Private Endpoint
* Messaging between microservices
* Build reliable java apps on Azure Container Apps
* Set up autoscaling for microservices on Azure Container Apps

The lab is available as GitHub pages [here](https://azure-samples.github.io/java-microservices-aca-lab/)

## Getting Started

### Prerequisites

For running this lab you will need:

* A GitHub account
* An Azure Subscription

### Region Availability

This template uses [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview) deployment mododules **gpt-4o** and **text-embedding-ada-002** which may not be available in all Azure regions. Check for [up-to-date region availability](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#standard-deployment-model-availability) and select a region during deployment accordingly

  * We recommend using **East US**, **East US 2**, **North Central US**, **South Central US**, **Sweden Central**, **West US** and **West US 3**.

### Workthrough guide

Based on your current knowledge background and your plan, there are some typical usage scenarios for your reference:

* If you are not familiar with Azure Spring Apps and want to learn how to deploy new project in Azure Container Apps, you may start from these labs:
  * [Lab 2: Migrate a Spring Apps microservices application to Azure Container Apps]({% link docs/02_lab_migrate/02_openlab_setup_aca.md %})
  * [Lab 3: Enable monitoring and end-to-end tracing]({% link docs/03_lab_monitor/03_openlab_monitoring_aca.md %})
  * [Lab 4: Connect to Database securely using identity]({% link docs/04_lab_secrets/04_openlab_secrets_aca.md %})

  It will take about 2 days to learn from selected labs.

* If you already have some experiences on Azure Container Apps, and you want to try some azd automation to get a AI enabled microservice environment, you may jump directly to:
  * [lab 6: Deploy to Azure automatically]({% link docs/06_lab_automation/06_openlab_automation.md %})

  You may get a new environment in 2 hours.

* If you want to learn how AI components are integrated in to microservices, you may check the details in:
  * [Lab 5: Integrate with Azure OpenAI]({% link docs/05_lab_openai/05_openlab_openai_aca.md %})

* If you need a more secure app environment, refer to:
  * [Lab 7: Protect endpoints using Web Application Firewall]({% link docs/07_lab_security/07_openlab_security_aca.md %})
  * [Lab 8: Secure MySQL database and Key Vault using a Private Endpoint]({% link docs/08_lab_private/08_openlab_private_endpoints_aca.md %})

* There are also some useful features in Azure Container Apps, you may find your interested topics in:
  * [Lab 9: Create and configure Azure Service Bus for sending messages between microservices]({% link docs/09_lab_messaging/09_openlab_messaging_aca.md %})
  * [Lab 10: Build reliable Java application on ACA]({% link docs/10_lab_reliable_application/10_reliable_java_aca.md %})
  * [Lab 11: Set up autoscaling for microservices on ACA]({% link docs/11_lab_scale/11_openlab_scale_aca.md %})

### Installation

For running this lab with all the needed tooling, there are 3 options available:

* [Using a GitHub codespace]({% link install.md %}#using-a-github-codespace)
* [Using Visual Studio Code with remote containers option]({% link install.md %}#using-visual-studio-code-with-remote-containers)
* [Install all the tools on your local machine]({% link install.md %}#install-all-the-tools-on-your-local-machine)

All the steps of this lab have been tested in the GitHub CodeSpace. This is the preferred option for running this lab!

Full installation guidance and options for running this lab can be found in the [Installation]({% link install.md %}) instructions.
