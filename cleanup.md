---
title: Clean up resources
layout: home
nav_order: 90
---

# Cleanup
{: .no_toc }

If you're not going to continue to use this lab environment, run the following command to delete the resource group along with all the resources created in this lab.

1. (Optional) Clean up the Azure OpenAI instance

   In the previous [Lab 5]({% link docs/05_lab_openai/05_openlab_openai_aca.md %}), create a new OpenAI instance is optional. If you created a new Azure OpenAI instance in that lab, delete it. Or just ignore this step.

   - delete the Azure OpenAI instance with module deployments

     ```bash
     az cognitiveservices account delete -g $RESOURCE_GROUP -n $OPEN_AI_SERVICE_NAME
     ```

1. Delete the resource group with all the resources

   ```bash
   az group delete --name $RESOURCE_GROUP --yes --no-wait

   az configure --default group=''
   ```

{: .note }

> It takes about 30 minutes to delete all the resources in the environment. Do not wait for the long-running operation to finish with option `--no-wait`.
