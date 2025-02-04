---
title: 'Lab Tips and troubleshooting'
layout: home
nav_order: 99
---

# Tips to help you run this lab
{: .no_toc }

An overview of the tips in this section:

- TOC
{:toc}

## Use GitHub Codespaces

As described in the [Installation instructions]({% link install.md %}), the best and easiest way to run this lab is to use a [GitHub Codespaces](https://github.com/features/codespaces). Using the devcontainer.json file provided for the [GitHub repository for this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) you can create a codespace with all the required tools pre-installed and configured for you to use. All the steps in this lab have been tested thoroughly using the codespace configuration included in the repo. 

If you're unable to use a codespace, the best alternative is to use Visual Studio Code with remote containers, which will allow you to deploy and use a preconfigured development environment using Docker. 

In a scenario where you can't use either of these options, you can complete this lab by installing the required tooling on your local environment. However, as it’s impossible for us to test all lab steps with all possible local configurations we highly recommend using either the GitHub Codespaces or the Visual Studio Code with remote containers option if you can.

## .azcli files will save your day

If you're using Visual Studio Code, you can record command line statements you execute in a file with the _.azcli_ extension. This extension combined with the [Azure CLI Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli) extension gives you extra capabilities like IntelliSense and directly running a statement from the script file in a terminal window. 

When using this extension you can keep a record of all the steps you executed in an _.azcli_ file and quickly execute these statements through the `Ctrl+'` shortcut. Please check out the extension, as it can save you time and effort in the lab!

## On error perform these steps

There are a couple places in the lab where you can easily to miss steps or incorrectly execute a statement. If you run into errors as a result,  try the following debug steps:

1. Carefully re-check the lab instructions to make sure you executed each step.

1. Confirm that all YAML is correctly indented and otherwise lacks formatted errors.

1. Check to ensure you've saved all files that you've modified.

1. Check the logs for the failing application or service.

   ```bash
   kubectl logs <pod-name>
   ```

### Dealing with code errors

If you find coding issues that lead to errors, you will need to fix the issues and then rebuild and redeploy the affected application.

To rebuild and redeploy a failing application:

1. Navigate to the repo's src folder and rebuild the application containing the code you fixed.

   ```bash
   cd ~/workspaces/java-microservices-aca-lab/src
   mvn clean package -DskipTests -rf :spring-petclinic-<application-name>
   ```

1.  Rebuild the container image for the application. Navigate to the _acr-staging_ directory, copy over the compiled jar file and rebuild the container.

   ```bash
   cd staging-acr
   rm spring-petclinic-<application-name>-$VERSION.jar
   cp ../spring-petclinic-<application-name>/target/spring-petclinic-<application-name>-$VERSION.jar spring-petclinic-<application-name>-$VERSION.jar
   
   docker build -t $MYACR.azurecr.io/spring-petclinic-<application-name>:$VERSION \
       --build-arg ARTIFACT_NAME=spring-petclinic-<application-name>-$VERSION.jar \
       --build-arg APP_PORT=8888 \
       --build-arg AI_JAR=ai.jar \
       .

   docker push $MYACR.azurecr.io/spring-petclinic-<application-name>:$VERSION
   ```

   {: .note }
   > If you're having issues in lab 2, remove the line `--build-arg AI_JAR=ai.jar` from the above statement. This is only needed for lab 3.

1. Restart the pod.

   ```bash
   kubectl get pods
   kubectl delete pod <pod-name> 
   ```

### Dealing with config errors

If you've made an error in the config repo, you'll need to fix that error in the repo and then restart the affected service applications to recover:

1. Fix the error in the config repo, save the file, and then commit to push the changes:

   ```bash
   git add .
   git commit -m 'your commit message'
   git push
   ```

1. Restart the config server pod:

   ```bash
   kubectl get pods
   kubectl delete pod <config-server-pod> 
   ```

1. Wait for the config server to be properly up and running again:

   ```bash
   kubectl get pods -w
   ```

1. If config server pod is reporting a `CrashLoopBackoff` state, inspect the logs.

   ```bash
   kubectl logs <config-server-pod> 
   ```

1. Restart any pods that depend on the new config.

   ```bash
   kubectl get pods
   kubectl delete pod <config-dependent-pod> 
   ```

### Dealing with errors in the kubernetes/*.yml files

If you've made an error in the kubernetes/*.yml files, perform the following steps to recover:

1. Fix the error in the kubernetes/*.yml file.

1. re-apply the yaml file:

   ```bash
   cd ~/workspaces/java-microservices-aca-lab/src/kubernetes
   kubectl apply -f spring-petclinic-<service-name>.yml
   ```

1. Check whether the failing pod starts up properly.

   ```bash
   kubectl get pods -w
   ```

## If some steps not are running smoothly in a codespace

If you're using a codespace and running  the labs in a subscription that has policies that lock down what you are allowed to do, you might encounter errors when trying to perform certain steps. The currently known failures include:

- Not Authorized on some operations. Specifically, this can happen on operations using managed identities and Key Vault where policy settings on the subscription prevent you from running them from a codespace.

To recover from this issue, re-execute the failed step [using an Azure Cloud Shell window](https://learn.microsoft.com/en-us/azure/cloud-shell/using-the-shell-window).

## Don't commit your GitHub PAT token

In Lab 2 you will use a hard-coded GitHub PAT token inside the code for the `config-server`. This token will be removed as you implement a more secure database connection method in lab 4. 

As long as the GitHub PAT token is inside the code of the `config-server`, do not commit this code to any GitHub repository. If you accidentally push the GitHub PAT token to the repo, GitHub will immediately invalidate it, rendering it unusable. This will make your config-server fail!

If this accidentally happens to you, you'll need to recreate or re-issue the PAT token and perform a full rebuild and redeploy of the config server with the new GitHub PAT.

If you want to commit and push your code changes to GitHub, make sure to exclude the _application.yml_ file from the config-server to avoid this issue.

### If the GitHub PAT still doesn't work for you

In rare scenarios we've seen some users unable to access private config repos through the PAT experience. If this happens to you, we want you to continue through the lab without the PAT method failing on you. 

In this case, and for the sake of completing the lab, you can go ahead and make your config repo public to bypass this PAT issue. Note your config repo **will** contain secret values for certain resources of the lab. Make sure you do **not** use any password values that you use anywhere else (which you shouldn't be doing anyways).

After making your config repo public, you may also need to restart your config repo pod to get everything up and running again.

## Persisting environment variables in a GitHub Codespace

If you are using a codespace for running this lab, your environment variables will be lost if the codespace restarts. To persist these  variables, you can follow the [guidance that GitHub provides](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files). We recommend the [single workspace](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files#for-a-single-codespace) approach, as that is the easiest to set up and doesn't require a workspace restart.

You can find a [samplebashrc file](https://github.com/Azure-Samples/java-microservices-aca-lab/blob/main/solution/samplebashrc) in the lab's  repository. You'll need to update this file with the relevant unique values for your environment before proceeding.

Another approach would be to create a dedicated _.azcli_ file where you keep all environment variables. After a workspace restart, you first rerun all the steps in this file and you can proceed.

You can find a [sampleENVIRONMENT.azcli file](https://github.com/Azure-Samples/java-microservices-aca-lab/blob/main/solution/sampleENVIRONMENT.azcli) in this repository. You'll need to update this file with the relevant unique values for your environment before proceeding.
