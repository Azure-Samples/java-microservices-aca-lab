---
title: 'Lab 6: Deploy to Azure automatically'
layout: default
nav_order: 9
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

![lab 6 overview](../../images/acalab6.png)

## Lab Duration

- **Estimated Time**: 30 minutes

## Instructions

During this lab, you will:

- Run `azd up` command to deploy the sample soluton to Azure Container Apps.
- Learn how to triage some problems with the one-click solution.

## Others

   - This version of azd templates includes most operations in:
      - [Lab 2: Migrate a Spring Apps microservices application to Azure Container Apps](https://azure-samples.github.io/java-microservices-aca-lab/docs/02_lab_migrate/02_openlab_setup_aca.html)
      - [Lab 3: Enable monitoring and end-to-end tracing](https://azure-samples.github.io/java-microservices-aca-lab/docs/03_lab_monitor/03_openlab_monitoring_aca.html)
      - [Lab 4: Connect to Database securely using identity](https://azure-samples.github.io/java-microservices-aca-lab/docs/04_lab_secrets/04_openlab_secrets_aca.html)
      - [Lab 5: Integrate with Azure OpenAI](https://azure-samples.github.io/java-microservices-aca-lab/docs/05_lab_openai/05_openlab_openai_aca.html)

   - By default, the automation process will create MySQL server admin user password with random string, you may reset the admin password
      - Portal: Go to your MySQL server instance page, `Overview` > `Reset password`
      - CLI: `az mysql flexible-server update -g <group-name> -n <server-name> --admin-password "<new-password>"`

{: .note }
> The instructions provided in this exercise assume that you successfully completed the previous exercise and are using the same lab environment, including your Git Bash session with the relevant environment variables already set.
