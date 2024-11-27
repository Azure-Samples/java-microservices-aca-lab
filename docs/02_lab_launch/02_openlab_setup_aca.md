---
title: 'Lab 2: Launch to Azure Container Apps'
layout: default
nav_order: 4
has_children: true
---

# Lab 02: Launch a Spring Apps microservices application to Azure Container Apps

# Student manual

## Lab scenario

You have a general description about the microservice application. It is time to launch the components to Azure Container Apps (ACA).

## Objectives

After you complete this lab, you will be able to:

- Create an Azure Container Apps environment
- Set up a configuration repository
- Create an Azure MySQL Database service
- Create the ACA managed java components for your services
- Deploy the microservices of the Spring Petclinic app to ACA and bind them to java components
- Test the application through the publicly available endpoint

The below image illustrates the end state you will be building in this lab.

![lab 2 overview](../../images/acalab2.png)

## Lab Duration

- **Estimated Time**: 120 minutes

{: .note }
> The Azure-Samples/java-microservices-aca-lab repository contains a dev container for Java development. This container contains all the needed tools for running this lab. In case you want to use this dev container you can either use a [GitHub CodeSpace](https://github.com/features/codespaces) in case your GitHub account is enabled for Codespaces. Or you can use the [Visual Studio Code Remote Containers option](https://code.visualstudio.com/docs/remote/containers). You can find all steps to get this set up in the [installation instructions]({% link install.md %}).
