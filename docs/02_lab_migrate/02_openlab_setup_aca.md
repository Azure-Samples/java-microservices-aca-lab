---
title: 'Lab 2: Migrate to Azure Container App'
layout: default
nav_order: 4
has_children: true
---

# Lab 02: Migrate a Spring Apps microservices application to Azure Container App

# Student manual

## Lab scenario

You have established a plan for migrating the Spring Petclinic application to Azure Container App. It is now time to perform the actual migration of the Spring Petclinic application components.

## Objectives

After you complete this lab, you will be able to:

- Create an ACA environment.
- Set up a configuration repository.
- Create an Azure MySQL Database service.
- Create java components for config and discovery server.
- Deploy the microservices of the Spring Petclinic app to the ACA and bind them to java components.
- Test the application through the publicly available endpoint.

The below image illustrates the end state you will be building in this lab.

![lab 2 overview](../../images/lab2.png)

## Lab Duration

- **Estimated Time**: 120 minutes

## Instructions

During the process you'll:

- Create an ACA environmewnt.
- Set up a configuration repository.
- Create an Azure MySQL Database service.
- Create java components for config and discovery server.
- Deploy the microservices of the Spring Petclinic app to the ACA and bind them to java components.
- Test the application through the publicly available endpoint.

{: .note }
> The Azure-Samples/java-microservices-ACA-lab repository contains a dev container for Java development. This container contains all the needed tools for running this lab. In case you want to use this dev container you can either use a [GitHub CodeSpace](https://github.com/features/codespaces) in case your GitHub account is enabled for Codespaces. Or you can use the [Visual Studio Code Remote Containers option](https://code.visualstudio.com/docs/remote/containers). You can find all steps to get this set up in the [installation instructions]({% link install.md %}).
