---
title: 'Lab 3: Enable monitoring'
layout: default
nav_order: 5
has_children: true
---

# Lab 03: Enable monitoring and end-to-end tracing

# Student manual

## Lab scenario

You have created your Azure Container Apps environment, deployed your applications to it and exposed them through the api-gateway service. Now that everything is up and running, it would be nice to monitor the availability of your applications and to be able to see if any errors or exceptions occur in your applications. In this lab you will add monitoring and end-to-end tracing to your applications.

## Objectives

After you complete this lab, you will be able to:

- Inspect your Azure Container Apps in the Azure Portal
- Configure Azure Container Apps environment monitoring
- Configure Application Insights to receive monitoring information from your applications
- Analyze application specific monitoring data

The below image illustrates the end state you will be building in this lab.

![lab 3 overview](../../images/acalab3.png)

## Lab Duration

- **Estimated Time**: 60 minutes

## Instructions

In this lab, you will:

- Inspect your Azure Container Apps in the Azure Portal
- Configure Azure Container Apps environment monitoring
- Configure Application Insights to receive monitoring information from your applications
- Analyze application specific monitoring data
- Analyze logs
- (Optional) Build Java metrics dashboard with Azure Managed Grafana

{: .note }
> The instructions provided in this exercise assume that you successfully completed the previous exercise and are using the same lab environment, including your Git Bash session with the relevant environment variables already set.
