---
title: Overview
layout: home
nav_order: 1
---

# Lab: Deploying and running Java Applications in Azure Container Apps

This lab teaches you how to deploy the upstream [Spring Petclinic Microservices](https://github.com/spring-petclinic/spring-petclinic-microservices) application to [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/overview) and integrate it with additional Azure services. Azure Container Apps support spring applications with managed components.

## Modules

This lab has modules on:

* A general introduction to the sample microservices and the related Azure resources
* Launch the [Spring Petclinic Microservices](https://github.com/spring-petclinic/spring-petclinic-microservices) to Azure Container Apps
* Enable monitoring, end-to-end tracing and grafana dashboard for the deployment
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

1. This template uses [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview) deployment mododules **gpt-4o** and **text-embedding-ada-002** which is not available in all Azure regions. Check for [up-to-date region availability](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#standard-deployment-model-availability) and select a region during deployment.

1. The template uses [Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/overview). You may select a region suite for this service.

{: .note }
> We recommend running the lab in regions **West US**, **West US 2**, **East US 2**, **North Central US**, **Sweden Central**.

### Installation

For running this lab with all the needed tooling, there are 3 options available:

* [Using a GitHub codespace]({% link install.md %}#using-a-github-codespace)
* [Using Visual Studio Code with remote containers option]({% link install.md %}#using-visual-studio-code-with-remote-containers)
* [Install all the tools on your local machine]({% link install.md %}#install-all-the-tools-on-your-local-machine)

All the steps of this lab have been tested in the GitHub CodeSpace. This is the preferred option for running this lab!

Full installation guidance and options for running this lab can be found in the [Installation]({% link install.md %}) instructions.
