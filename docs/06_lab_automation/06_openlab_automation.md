---
title: 'Lab 6: Deploy to Azure automatically'
layout: default
nav_order: 8
has_children: true
---

# Lab 6: Deploy to Azure automatically

# Student manual

## Lab scenario

In the Lab 2, Lab 3, Lab 4 and Lab 5 we deploy the petclinic microservice solution to Azure Container Apps step by step.
These steps are full of details but time costing.

In this lab, we introduce a new tool [azd](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/) to help deploy the solution to Azure with single command.

## Objectives

After you complete this lab, you will be able to:

- Get familiar with the azd tool.
- Deploy the petclinic solution (with AI) to new ACA environment.
- Test your setup.

## Lab Duration

- **Estimated Time**: 90 minutes

## Instructions

During this lab, you will:

- Prepare your azd tools environment.
- Get your Azure Registry ready and fill the configuration files.
- Run `azd up` command to deploy the sample soluton to Azure Container Apps.
- Learn how to triage some problems with the one-click solution.

## Limits

- This version of azd templates includes most operations in [Lab 1](https://azure-samples.github.io/java-microservices-aca-lab/docs/01_lab_plan/01_openlab_plan_migrating_to_aca.html), [Lab 2](https://azure-samples.github.io/java-microservices-aca-lab/docs/02_lab_migrate/02_openlab_setup_aca.html), [Lab 3](https://azure-samples.github.io/java-microservices-aca-lab/docs/03_lab_monitor/03_openlab_monitoring_aca.html) and [Lab 4](https://azure-samples.github.io/java-microservices-aca-lab/docs/04_lab_secrets/04_openlab_secrets_aca.html)

{: .note }
> The instructions provided in this exercise assume that you successfully completed the previous exercise and are using the same lab environment, including your Git Bash session with the relevant environment variables already set.
