---
title: 'Lab 7: Protect endpoints using Web Application Firewalls'
layout: default
nav_order: 10
has_children: true
---

# Lab 7: Protect endpoints using Web Application Firewall

# Student manual

## Lab scenario

By now, you have completed setting up your Spring Boot application in Azure on Azure Container Apps and you are using a passwordless connection to connect to their data store. You are satisfied with the results, but you do recognize that there is still room for improvement. In particular, you are concerned with the public endpoints of the application which are directly accessible to anyone with access to the internet. You would like to add a Web Application Firewall to filter incoming requests to your application. In this exercise, you will step through implementing this configuration.

## Objectives

After you complete this lab, you will be able to:

- Create additional networking resources
- Create an Azure Key Vault service
- Acquire a certificate and add it to Key Vault
- Redeploy your Azure Container Apps environment with internal networking
- Create the Application Gateway resource
- Access the application by DNS name
- Enable the WAF policy

The below image illustrates the end state you will be building in this lab.

![lab 7 overview](../../images/acalab7.png)

## Lab Duration

- **Estimated Time**: 60 minutes

## Instructions

During this lab, you will:

- Create additional networking resources
- Create an Azure Key Vault service
- Acquire a certificate and add it to Key Vault
- Redeploy your Azure Container Apps environment with internal networking
- Create the Application Gateway resource
- Access the application by DNS name
- Enable the WAF policy

{: .note }
> The instructions provided in this exercise assume that you successfully completed the previous exercise and are using the same lab environment, including your Git Bash session with the relevant environment variables already set.
