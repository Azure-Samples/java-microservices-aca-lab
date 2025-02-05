---
title: 'Lab tips and troubleshooting'
layout: home
nav_order: 99
---

# Tips to help you run this lab
{: .no_toc }

Tips in this section include:

- TOC
{:toc}

## Use GitHub Codespaces

As described in the [installation instructions]({% link install.md %}), the best and easiest way to run this lab is to use [GitHub Codespaces](https://github.com/features/codespaces). With the devcontainer.json file provided in the lab's [GitHub repository](https://github.com/Azure-Samples/java-microservices-aca-lab) you can create a codespace that has the required tools pre-installed and configured for you. The steps in this lab have been thoroughly tested with the codespace configuration included in the repo. 

If you're unable to use a codespace, the best alternative is Visual Studio Code with remote containers, which allows you to deploy and work with a preconfigured Docker development environment. 

If you can't use either of these options, you can complete this lab by installing the required tooling on your local environment. However, since it’s impossible for us to test all lab steps with every possible local configuration, we highly recommend using either GitHub Codespaces or the Visual Studio Code with remote containers.

## .azcli files will save your day

If you're using Visual Studio Code, you can record the command-line statements that you execute in a file with the _.azcli_ extension. This extension, combined with the [Azure CLI Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli) extension, gives you extra capabilities, like IntelliSense, and the opportunity to directly run statements from the script file in a terminal window. 

With this extension, you can keep a record in an .azcli file of all the steps that you executed and quickly execute these statements through the `Ctrl+` shortcut. To save time and effort in this lab, be sure to check out the extension.

## On error, perform these steps

There are a couple places in the lab where you can easily to miss steps or incorrectly execute a statement. If you run into errors as a result,  try the following debug steps:

1.	Carefully recheck the lab instructions to make sure that you executed each step.

1.	Confirm that all YAML is correctly indented and lacks formatting errors.

1.	Check to ensure that you saved all the files you modified.

1.	Check the logs for the failing application or service.

   ```bash
   kubectl logs <pod-name>
   ```

### Dealing with code errors

If you find coding issues that lead to errors, fix the issues and then rebuild and redeploy the affected application.

To rebuild and redeploy an application:

1.	Go to the repo's src folder, and rebuild the application that contains the code you fixed.

   ```bash
   cd ~/workspaces/java-microservices-aca-lab/src
   mvn clean package -DskipTests -rf :spring-petclinic-<application-name>
   ```

1. Rebuild the container image for the application. Go to the _acr-staging_ directory, copy over the compiled JAR file, and rebuild the container.

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
   > If you're having issues in Lab 2, remove the line `--build-arg AI_JAR=ai.jar` from the preceding statement. (It's only needed for Lab 3.)

1. Restart the pod.

   ```bash
   kubectl get pods
   kubectl delete pod <pod-name> 
   ```

### Dealing with config errors

If you've made an error in the config repo, you need to fix that error in the repo and then restart the affected service applications to recover:

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

1. If the config server pod is reporting a `CrashLoopBackoff` state, inspect the logs.

   ```bash
   kubectl logs <config-server-pod> 
   ```

1. Restart any pods that depend on the new config.

   ```bash
   kubectl get pods
   kubectl delete pod <config-dependent-pod> 
   ```

### Dealing with errors in the kubernetes/*.yml files

If you've made an error in the kubernetes/*.yml files, take the following steps to recover:

1. Fix the error in the kubernetes/*.yml file.

1. Reapply the YAML file:

   ```bash
   cd ~/workspaces/java-microservices-aca-lab/src/kubernetes
   kubectl apply -f spring-petclinic-<service-name>.yml
   ```

1. Determine whether the failing pod properly starts up.

   ```bash
   kubectl get pods -w
   ```

## If some steps aren't running smoothly in a codespace

If you're using a codespace and running  the labs in a subscription with policies that lock down what you're allowed to do, you might encounter errors when performing certain steps. The currently known failures include:

- Not Authorized on some operations. Specifically, this can happen on operations using managed identities and Azure Key Vault, where policy settings on the subscription prevent you from running them from a codespace.

To recover from this issue, re-execute the failed step [using an Azure Cloud Shell window](https://learn.microsoft.com/en-us/azure/cloud-shell/using-the-shell-window).

## Avoid committing your GitHub Personal Access Token

In Lab 2, you use a hard-coded GitHub PAT token inside the code for the `config-server`. This token will be removed as you implement a more secure database connection method in Lab 4. 

As long as the GitHub PAT is inside `config-server` code, do not commit this code to any GitHub repository. If you accidentally push the GitHub PAT to the repo, GitHub will immediately invalidate it, rendering it unusable, causing your config-server to fail.

If this happens to you, recreate or reissue the PAT and then perform a full rebuild and redeploy of the config-server with the new GitHub PAT.

If you want to commit and push your code changes to GitHub and avoid the issue with the GitHub PAT, make sure to exclude the _application.yml_ file from the config-server.

### If the GitHub PAT still doesn't work for you

In rare scenarios, some users are unable to access private config repos through the PAT experience. If you experience this, to bypass the PAT issue and complete the lab, make your config repo public. Note that your config repo **will contain secret values** for certain lab resources. As always, make sure that you **do not use any password values** that you use elsewhere. 

After making your config repo public, you may also need to restart your config repo pod to get everything up and running again.

## Persist environment variables in a codespace

When you use  a codespace to run this lab, your environment variables will be lost if the codespace restarts. To avoid this issue, follow [GitHub's guidance on persisting variables](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files). We recommend the [single workspace](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files#for-a-single-codespace) approach, since it's the easiest to set up and doesn't require a workspace restart.

You can find a [samplebashrc file](https://github.com/Azure-Samples/java-microservices-aca-lab/blob/main/solution/samplebashrc) in the lab's repository. Before proceeding, you'll need to update this file with the relevant unique values for your environment before proceeding.

Another approach would be to create a dedicated _.azcli_ file to keep your environment variables. After a workspace restart, you first rerun all the steps in this file and then you can proceed.

You can find a [sampleENVIRONMENT.azcli file](https://github.com/Azure-Samples/java-microservices-aca-lab/blob/main/solution/sampleENVIRONMENT.azcli) in this repository. Before proceeding, update this file with the relevant unique values for your environment.
