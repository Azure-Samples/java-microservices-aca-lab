---
title: 'Lab Tips and troubleshooting'
layout: home
nav_order: 99
---

# A couple of tips when you run this lab
{: .no_toc }

An overview of the tips in this section:

- TOC
{:toc}

## Use Codespaces

The best and easiest way to run this lab is definitely through the use of a codespace. It has all the tools pre-installed for you. All the steps as well have been tested through the codespace that is included in the repo. The second best alternative is using Visual Studio Code locally with the remote containers option.

The least best option is with a local install of all the tooling. You can get unexpected errors when using this option. Try to avoid it if you can. We still provide it as an alternative for people who really can't use the codespace or remote containers.

## .azcli files will save your day

In case you are using Visual Studio Code, you can record your statements in a file with the _.azcli_ extension. This extension in combination with the [Azure CLI Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli) gives you extra capabilities like IntelliSense and directly running a statement from the script file in the terminal window. 

When using this extension you can keep a record of all the steps you executed in an _.azcli_ file and quickly execute these statements through the `Ctrl+'` shortcut. Check out the extension, it will save you time in the lab!

## On error perform these steps

There are a couple of places in the lab where the steps you need to execute include easy to miss steps. In case of any error the default way to recover from the error is:

1. re-check whether you executed each step.

1. Check all YAML indentation.

1. Check whether you saved all the files that have changes.

1. Check the logs of the specific failing app.

   ```bash
   az containerapp logs show -g $RESOURCE_GROUP -n <APP_NAME> 
   ```

### In case you made a coding error

In case you see you made a coding error, you will need to rebuild and redeploy the specific failing microservice.

To rebuild and redeploy a failing microservice:

1. Navigate to the root of the application and rebuild the specific microservice.

   ```bash
   cd ~/workspaces/java-on-aca/src
   mvn clean package -DskipTests -rf :spring-petclinic-<microservice-name>
   ```

1. Update the target container apps instance.

   ```bash
   az containerapp update \
      --name $APP_NAME \
      --resource-group $RESOURCE_GROUP \
      --source ./spring-petclinic-$APP_NAME
   ```

## Not all steps are running smoothly in the codespace (unfortunately)

It might be that some steps do not run smoothly in a codespace on some more locked down environments.

In case you use a subscription that has additional policies that lock down what you are allowed to do in the subscription, this might make some of the steps fail. The currently known failures include:

- Not Authorized on some operations: specifically operations on managed identities and Key Vault might suffer from policy settings on the subscription when you run them from a codespace.

How to recover: re-execute the step in a cloud shell window.

## Persisting environment variables in a GitHub Codespace

- In case you are using a codespace for running this lab, your environment variables will be lost if the codespace restarts. For persisting these environment variables, you can either use the [guidance that GitHub provides for this](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files). We recommend the [single workspace](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files#for-a-single-codespace) approach, since that is the easiest to set up and doesn't require workspace restart.

  You can find a [samplebashrc file](https://github.com/Azure-Samples/java-microservices-aca-lab/blob/main/solution/samplebashrc) in this repository. You will need to update a couple of values in this file for your specific situation.

- Another approach would be to create a dedicated _.azcli_ file where you keep all environment variables. After a workspace restart, you first rerun all the steps in this file and you are good to go again.

  You can find a [sampleENVIRONMENT.azcli file](https://github.com/Azure-Samples/java-microservices-aca-lab/blob/main/solution/sampleENVIRONMENT.azcli) in this repository. You will need to update a couple of values in this file for your specific situation.

- save the environment variables [Save your environment variables]({% link docs/02_lab_launch/0209.md %}#tips-for-next-labs)
