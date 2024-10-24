---
title: Clean up resources
layout: home
nav_order: 13
---

# Cleanup
{: .no_toc }

If you're not going to continue to use this lab environment, run the following command to delete the resource group along with all the resources created in this lab.

- TOC
{:toc}

{: .note }
> There is a known issue when delete OpenAI instance, [Azd down on OpenAI instance](https://github.com/Azure/azure-dev/issues/4210), extra steps required to delete all the resources.

## Delete environment created by Azd automation

1. Prepare

   - Set config flag for OpenAI instance
  
     `azd config set alpha.deployment.stacks on`

1. Tear down the azd environment

   - run `azd env list` to see all the environments
   - run `azd down -e <env-name> --force --purge` to clean up the target environment

## Delete environment created by manual steps

1. Clean up the Azure Cognitive Services account

   - list the deployments

      `az cognitiveservices account deployment list -g $RESOURCE_GROUP -n $OPEN_AI_SERVICE_NAME -o table`

   - delete the deployments on by one

      `az cognitiveservices account deployment delete -g $RESOURCE_GROUP -n $OPEN_AI_SERVICE_NAME --deployment-name <deployment-name>`

   - delete the Azure Cognitive Services account

      `az cognitiveservices account delete -g $RESOURCE_GROUP -n $OPEN_AI_SERVICE_NAME`

1. Delete the resource group with all the resources

   `az group delete --name $RESOURCE_GROUP`

{: .note }

> It takes about 30 minutes to delete all the resources in the environment.
