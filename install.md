---
title: Install
layout: home
nav_order: 2
---

# Installation
{: .no_toc }

For running this lab with all the needed tooling, there are 3 options available:

- TOC
{:toc}

   {: .important }
   > All the steps of this lab have been tested in the [GitHub CodeSpace](#using-a-github-codespace). This is the preferred option for running this lab!

## Using a GitHub Codespace

The [git repository of this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) contains a dev container for Java development. This container contains all the needed tools for running this lab. In case you want to use this dev container you can use a [GitHub CodeSpace](https://github.com/features/codespaces) in case your GitHub account is enabled for Codespaces.

1. Navigate to the [GitHub repository of this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) and select **Fork**.

   {: .note }
   > In case you are using a GitHub EMU account, it might be you are not able to fork a public repository. In that case, create a new repository with the same name, clone the original repository, add your new repository as a remote and push to this new remote.

1. Make sure your own username is indicated as the fork `Owner`

1. Select **Create fork**. This will create a copy or fork of this project in your own account.

1. Navigate to the newly forked GitHub project.

1. Select **Code** and next **Codespaces**.

1. Select **Create a codespace**.

   Your codespace will now get created in your browser window. Once creation is done, you can start executing the next steps of the lab.

## Using Visual Studio Code with remote containers

The [git repository of this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) contains a dev container for Java development. This container contains all the needed tools for running this lab. For this option you need the following tools to be installed on your local system:

- Visual Studio Code available from [Visual Studio Code Downloads](https://code.visualstudio.com/download)
- Git for Windows available from [Git Downloads](https://git-scm.com/downloads), or similar on another OS.
  - **Note**: If needed, reinstall Git and, during installation, ensure that the Git Credential Manager is enabled.
- [Visual Studio Code Remote Containers option](https://code.visualstudio.com/docs/remote/containers). 
- [docker](https://docs.docker.com/get-docker/).

{: .note }
> Following the installation of Git, ensure to set the global configuration variables `user.email` and `user.name` by running the following commands from the Git Bash shell (replace the `<your-email-address>` and `<your-full-name>` placeholders with your email address and your full name):

   ```bash
   git config --global user.email "<your-email-address>"
   git config --global user.name "<your-full-name>"
   ```

To get started follow the below step by step instructions: 

1. Navigate to the [GitHub repository of this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) and select **Fork**.

1. Make sure your own username is indicated as the fork `Owner`

1. Select **Create fork**. This will create a copy or fork of this project in your own account.

   {: .note }
   > In case you are using a GitHub EMU account, it might be you are not able to fork a public repository. In that case, create a new repository with the same name, clone the original repository, add your new repository as a remote and push to this new remote.

1. On your lab computer, in the Git Bash window, run the following commands to clone your fork of the spring-petclinic-microservices project to your workstation. Make sure to replace `<your-github-account>` in the below command:

   ```bash
   mkdir workspaces
   cd workspaces
   git clone https://github.com/<your-github-account>/java-microservices-aca-lab.git
   ```

1. When prompted to sign in to GitHub, select the **Sign in with your browser** option. This will automatically open a new tab in the web browser window, prompting you to provide your GitHub username and password.

1. In the browser window, enter your GitHub credentials, select **Sign in**, and, once successfully signed in, close the newly opened browser tab.

1. In workspaces folder double check that the spring petclinic application got cloned correctly. You can use the repository in your workspaces folder to regularly push your changes to.

   {: .note }
   > However in one of the lab steps you will put a GitHub PAT token in one of the configuration files, make sure to **not** commit this PAT token, since it will immediately get invalidated by GitHub. Once invalidated your next lab steps will fail. You can use the [LabTips]({% link tips.md %}) to recover from this.

1. Navigate into the `java-microservices-aca-lab` folder that got created and open the project with Visual Studio Code

   ```bash
   cd java-microservices-aca-lab
   code .
   ```

1. With the [Visual Studio Code Remote Containers plugin](https://code.visualstudio.com/docs/remote/containers) installed, you can now open the project in a remote container. This will reopen the project in a docker container with all the tooling installed.

## Install all the tools on your local machine

{: .note }
> Only use this option in case you feel comfortable with installing a lot of tooling on your local workstation. Also note that it is impossible for us to test all lab steps with all possible local configurations. The above 2 install options have the absolute preference for running this lab! So basically: proceed at your own risk.

{: .note }
> This lab contains guidance for a Windows workstation. Your workstation should contain the following components:

- Visual Studio Code available from [Visual Studio Code Downloads](https://code.visualstudio.com/download)
  - Java and Spring Boot Visual Studio Code extension packs available from [Java extensions for Visual Studio Code](https://code.visualstudio.com/docs/java/extensions)
- Git for Windows available from [Git Downloads](https://git-scm.com/downloads), or similar on another OS.

{: .note }
> If needed, reinstall Git and, during installation, ensure that the Git Credential Manager is enabled.

- Apache Maven available from [Apache Maven Project downloads](https://maven.apache.org/download.cgi)

{: .note }
> To install Apache Maven, extract the content of the .zip file by running `unzip apache-maven-3.8.5-bin.zip`. Next, add the path to the bin directory of the extracted content to the `PATH` environment variable. Assuming that you extracted the content directly into your home directory, you could accomplish this by running the following command from the Git Bash shell: `export PATH=~/apache-maven-3.8.5/bin:$PATH`.

- Java 17 and the Java Development Kit (JDK) available from [JDK downloads](https://aka.ms/download-jdk/microsoft-jdk-17.0.13-windows-x64.msi)

{: .note }
> To install JDK on Windows, follow the instructions provided in [JDK Installation Guide](https://learn.microsoft.com/java/openjdk/install#install-on-windows). Make sure to use the `FeatureJavaHome` feature during the install to update the `JAVA_HOME` environment variable.

- Install Azure CLI version 2.60.0 or higher from [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#install-azure-cli)

   Install the CLI extensions:

   ```bash
   az extension add --name containerapp --upgrade --allow-preview true
   az extension add --name serviceconnector-passwordless --upgrade
   ```

   Register the namespaces:

   ```bash
   az provider register --namespace Microsoft.App
   az provider register --namespace Microsoft.OperationalInsights
   ```

{: .note }
> If needed, upgrade the Azure CLI version by launching Command Prompt as administrator and running `az upgrade`.

{: .note }
> Following the installation of Git, ensure to set the global configuration variables `user.email` and `user.name` by running the following commands from the Git Bash shell (replace the `<your-email-address>` and `<your-full-name>` placeholders with your email address and your full name):

   ```bash
   git config --global user.email "<your-email-address>"
   git config --global user.name "<your-full-name>"
   ```

Once all these tools are installed, to get started you need to:

1. Navigate to the [GitHub repository of this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) and select **Fork**.

   {: .note }
   > In case you are using a GitHub EMU account, it might be you are not able to fork a public repository. In that case, create a new repository with the same name, clone the original repository, add your new repository as a remote and push to this new remote.

1. Make sure your own username is indicated as the fork `Owner`

1. Select **Create fork**. This will create a copy or fork of this project in your own account.

1. On your lab computer, in the Git Bash window, run the following commands to clone your fork of the spring-petclinic-microservices project to your workstation. Make sure to replace `<your-github-account>` in the below command:

   ```bash
   mkdir workspaces
   cd workspaces
   git clone https://github.com/<your-github-account>/java-microservices-aca-lab.git
   ```

1. When prompted to sign in to GitHub, select the **Sign in with your browser** option. This will automatically open a new tab in the web browser window, prompting you to provide your GitHub username and password.

1. In the browser window, enter your GitHub credentials, select **Sign in**, and, once successfully signed in, close the newly opened browser tab.

1. In workspaces folder double check that the spring petclinic application got cloned correctly. You can use the repository in your workspaces folder to regularly push your changes to.

1. Navigate into the _java-microservices-aca-lab_ folder and open it with Visual Studio Code

   ```bash
   cd java-microservices-aca-lab
   code .
   ```
