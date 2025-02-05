---
title: 'Lab 3: Enable monitoring'  
layout: default  
nav_order: 5  
has_children: true
---

# Lab 03: Enable monitoring and end-to-end event tracing

## Introduction

In the previous lab, you created a new Azure Container Apps environment, deployed your applications to it, exposed them to the public internet through the api-gateway application, and confirmed that everything is up and running. Now you’d like to be able to monitor your application’s availability and to detect any errors or exceptions.

In this lab, you’ll use Azure-based tools and services to add monitoring and end-to-end event tracing to your applications.

## What you’ll cover

As you work through this lab, you’ll learn how to:

- Inspect your Azure Container Apps in the Azure portal.
- Enable Log Analytics monitoring on your Azure Container Apps environment.
- Configure Application Insights to receive your application’s monitoring data.
- Analyze your application’s monitoring data and logs.
- Build a Java metrics dashboard with Azure Managed Grafana.

The following image shows how your application’s architecture should look once you complete this lab.

![lab 3 overview](../../images/acalab3.png)

## Duration

**Estimated time:** 30 minutes

{: .note }
> This lab assumes that you successfully completed the previous lab and are using the same lab environment, including your command-line session, with the relevant environment variables already set.
