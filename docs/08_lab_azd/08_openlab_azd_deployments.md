---
title: 'Lab 8: Use Azd to deploy the lab solution'
layout: default
nav_order: 10
has_children: true
---

# Lab 7: Use Azd to deploy the lab solution to Azure Container App

# Student manual

## Lab scenario

Use [azd](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/) tool to deploy the petclinic solution to Azure Container Apps environment.

## Objectives

After you complete this lab, you will be able to:

- Deploy the sample solution to new ACA environment.
- Test your setup

## Lab Duration

- **Estimated Time**: 60 minutes

## Instructions

During this lab, you will:

- Update the configuration according to you azure environment
- Run `azd up` command to deploy the sample soluton to Azure Container Apps.
- Test your setup

## Limits

- This version of azd templates includes most operations in [Lab 1](https://azure-samples.github.io/java-microservices-aca-lab/docs/01_lab_plan/01_openlab_plan_migrating_to_aca.html), [Lab 2](https://azure-samples.github.io/java-microservices-aca-lab/docs/02_lab_migrate/02_openlab_setup_aca.html), [Lab 3](https://azure-samples.github.io/java-microservices-aca-lab/docs/03_lab_monitor/03_openlab_monitoring_aca.html) and [Lab 4](https://azure-samples.github.io/java-microservices-aca-lab/docs/04_lab_secrets/04_openlab_secrets_aca.html)

{: .note }
> The instructions provided in this exercise assume that you successfully completed the previous exercise and are using the same lab environment, including your Git Bash session with the relevant environment variables already set.
