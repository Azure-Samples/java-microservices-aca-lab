---
title: 'Lab Tips and troubleshooting'
layout: default
nav_order: 11
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

1. Check the logs of the specific failing microservice.

   ```bash
   kubectl logs <pod-name>
   ```

### In case you made a coding error

In case you see you made a coding error, you will need to rebuild and redeploy the specific failing microservice.

To rebuild and redeploy a failing microservice:

1. Navigate to the root of the application and rebuild the specific microservice.

   ```bash
   cd ~/workspaces/java-microservices-aks-lab/src
   mvn clean package -DskipTests -rf :spring-petclinic-<microservice-name>
   ```

1.  Rebuild the container image for the microservice. Navigate to the _acr-staging_ directory, copy over the compiled jar file and rebuild the container.

   ```bash
   cd staging-acr
   rm spring-petclinic-<microservice-name>-$VERSION.jar
   cp ../spring-petclinic-<microservice-name>/target/spring-petclinic-<microservice-name>-$VERSION.jar spring-petclinic-<microservice-name>-$VERSION.jar
   
   docker build -t $MYACR.azurecr.io/spring-petclinic-<microservice-name>:$VERSION \
       --build-arg ARTIFACT_NAME=spring-petclinic-<microservice-name>-$VERSION.jar \
       --build-arg APP_PORT=8888 \
       --build-arg AI_JAR=ai.jar \
       .

   docker push $MYACR.azurecr.io/spring-petclinic-<microservice-name>:$VERSION
   ```

   {: .note }
   > In case you have issues in lab 2, remove the line `--build-arg AI_JAR=ai.jar` from the above statement. This is only needed as of lab 3.

1. Restart the pod.

   ```bash
   kubectl get pods
   kubectl delete pod <pod-name> 
   ```

### Config error

In case you made an error in the config repo. Fixing that error in the config repo and restarting services should be enough to recover:

1. Fix the error in the config repo, save the file, commit and push the changes:

   ```bash
   git add .
   git commit -m 'your commit message'
   git push
   ```

1. Restart the config server pod

   ```bash
   kubectl get pods
   kubectl delete pod <config-server-pod> 
   ```

1. Wait for the config server to be properly up and running again

   ```bash
   kubectl get pods -w
   ```

1. In case the config server pod is reporting a `CrashLoopBackoff`, inspect the logs.

   ```bash
   kubectl logs <config-server-pod> 
   ```

1. Restart any pods that depend on the new config.

   ```bash
   kubectl get pods
   kubectl delete pod <config-dependent-pod> 
   ```

### In case there is an error in the kubernetes/*.yml files

1. Fix the error in the kubernetes/*.yml file

1. re-apply the yaml file.

   ```bash
   cd ~/workspaces/java-microservices-aks-lab/src/kubernetes
   kubectl apply -f spring-petclinic-<service-name>.yml
   ```

1. check whether the failing pod starts up properly.

   ```bash
   kubectl get pods -w
   ```

## Not all steps are running smoothly in the codespace (unfortunately)

It might be that some steps do not run smoothly in a codespace on some more locked down environments.

In case you use a subscription that has additional policies that lock down what you are allowed to do in the subscription, this might make some of the steps fail. The currently known failures include:

- Not Authorized on some operations: specifically operations on managed identities and Key Vault might suffer from policy settings on the subscription when you run them from a codespace.

How to recover: re-execute the step in a cloud shell window.

## Don't commit your GitHub PAT token

In Lab 2 you will make use of a hard-coded GitHub PAT token inside the code of the `config-server`. This token will be removed again during the course of lab 4. 

As long as the GitHub PAT token is inside the code of the `config-server`, do not commit this code to any GitHub repository. Once you accidentally push the GitHub PAT token, it will immediately get invalidated by GitHub, and hence it will become unusable. This will make your config-server fail!

In case this accidentally happens to you, you will need to recreate or re-issue the PAT token and perform a full rebuild and redeploy of the config server with the new GitHub PAT.

In case you still might want to commit and push your code changes to GitHub, make sure to exclude the _application.yml_ file from the config-server.

### In case the GitHub PAT really doesn't work for you

Ok, you tried accessing the private config repo through the PAT experience, but unfortunately this keeps on failing for you. We've seen this happen from time to time for some people. No worries, you tried, we are very happy that you did. But it would also be great if you could continue through the lab without this PAT constantly failing on you.

Before executing the below fix, do understand that during the execution of the lab your config repo **will** contain secret values for certain resources of the lab. Make sure your do **not** use any password values that you use anywhere else (you shouldn't do that anyways by the way).

So no worries, make your config repo public and proceed! You may need to also restart your config repo pod to get everything up and running again.

## Persisting environment variables in a GitHub Codespace

In case you are using a codespace for running this lab, your environment variables will be lost if the codespace restarts. For persisting these environment variables, you can either use the [guidance that GitHub provides for this](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files). We recommend the [single workspace](https://docs.github.com/en/enterprise-cloud@latest/codespaces/developing-in-codespaces/persisting-environment-variables-and-temporary-files#for-a-single-codespace) approach, since that is the easiest to set up and doesn't require workspace restart.

You can find a [samplebashrc file](https://github.com/Azure-Samples/java-microservices-aks-lab/blob/main/solution/samplebashrc) in this repository. You will need to update a couple of values in this file for your specific situation.

Another approach would be to create a dedicated _.azcli_ file where you keep all environment variables. After a workspace restart, you first rerun all the steps in this file and you are good to go again.

You can find a [sampleENVIRONMENT.azcli file](https://github.com/Azure-Samples/java-microservices-aks-lab/blob/main/solution/sampleENVIRONMENT.azcli) in this repository. You will need to update a couple of values in this file for your specific situation.
