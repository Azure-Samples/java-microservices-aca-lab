---
title: Install
layout: home
nav_order: 2
---

# Installation

{: .no_toc }

Before you begin working through the lab, you’ll need to make sure that you have all the required tools installed and configured in your development environment. Additionally, in this same environment, before you start the process of deploying to Azure, you’ll need to have cloned a copy of the example Spring Petclinic Microservices workload code from the GitHub repo.

There are three options for setting up your development environment. Choose *only one* of the following:

- TOC {:toc}

    {: .important }
    > We’ve tested all the steps of this lab in [GitHub Codespaces](#use-github-codespaces), which is the simplest way to get going and the preferred option for running the lab.


## Use GitHub Codespaces

The [GitHub repository for this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) contains a devcontainer.json file configured for Java development. If your account is enabled for [GitHub Codespaces](https://github.com/features/codespaces), you can use this file to create a cloud development environment that contains all of the tools you’ll need to complete this lab.

This approach has the advantage of giving you a fully configured development environment without requiring any software installation or configuration on your local workstation.

To proceed with this option:

1.  Go to [this lab’s GitHub repository](https://github.com/Azure-Samples/java-microservices-aca-lab), and select **Fork**.
1.  Be sure that your own username is indicated as the fork Owner.
1.  Select **Create fork**. This creates a copy (or fork) of this project in your own account.

    {: .note }
    > If you’re using a GitHub Enterprise Managed Users (EMU) account, you might not be able to fork a public repository. In that case, create a new repository with the same name, clone the original repository, add your new repository as a remote, and push to this new remote.

1.  Go to the newly forked GitHub project.
1.  Select **Code** and then select **Codespaces**.
1.  Select **Create a codespace**.

The codespace creation status is displayed in your browser window. After the creation process is complete, you can start using the codespace dev environment to execute the next steps in the lab.

## Use Visual Studio Code with remote containers

The [git repository of this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) includes a dev container for Java development, which has all the needed tools for running this lab. For this option, you need the following tools to be installed on your local workstation.

Alternatively, you can use Docker and the [Visual Studio Code Dev Containers extension](https://code.visualstudio.com/docs/remote/containers) to deploy a preconfigured dev container on your local workstation. Using the same devcontainer.json file in the [Git repository of this lab](https://github.com/Azure-Samples/java-microservices-aca-lab) noted in the GitHub Codespaces option, you can easily configure a Java development container that has all the tools you need to run this lab.

This type of containerized approach allows you to quickly deploy a ready-to-use development environment. However, unlike with the GitHub Codespaces option, you need to perform the following tasks to get this working on your local workstation:

- Install [Visual Studio Code](https://code.visualstudio.com/download).
- Install [Git for Windows](https://git-scm.com/downloads) or the equivalent, if your local workstation is running another operating system.

    {: .note}
    > If needed, reinstall Git and, during installation, verify that the Git Credential Manager is enabled.

    {: .note }
    > After installing Git, run the following commands from the Git Bash shell to set the global configuration variables *user.email* and *user.name* (replace the *\<your-email-address\>* and *\<your-full-name\>* placeholders with your email address and your full name):

    ```bash
    git config --global user.email "<your-email-address>"
    git config --global user.name "<your-full-name>"
    ```

- Install the [Visual Studio Code Remote Containers extension](https://code.visualstudio.com/docs/remote/containers).
- Install [Docker](https://docs.docker.com/get-docker/).

To get started working in the dev container:

1.  Go to [this lab’s GitHub repository](https://github.com/Azure-Samples/java-microservices-aca-lab), and select **Fork**.
1.  Be sure that your own username is indicated as the fork Owner.
1.  Select **Create fork**. This creates a copy (or fork) of this project in your own account.

    {: .note }
    > If you’re using a GitHub Enterprise Managed Users (EMU) account, you might not be able to fork a public repository. In that case, create a new repository with the same name, clone the original repository, add your new repository as a remote, and push to this new remote.

1.  On your lab computer, using a command line window, run the following commands to clone your fork of the spring-petclinic-microservices project to your workstation. Make sure to replace *\<your-github-account\>* in the following command:

    ```bash
    mkdir workspaces
    cd workspaces
    git clone https://github.com/\<your-github-account\>/java-microservices-aca-lab.git
    ```

1.  When prompted to sign in to GitHub, select **Sign in with your browser**. This will automatically open a new tab in the web browser window, prompting you to provide your GitHub username and password.
1.  In the browser window, enter your GitHub credentials and select **Sign in**. After you’ve successfully signed in, close the newly opened browser tab.
1.  In your workspaces folder, verify that the spring-petclinic-microservices application got cloned correctly. You can use this local copy of the repository to regularly push changes back to your fork on GitHub.

    {: .note }
    > In later lab steps, you’ll put a GitHub PAT (Personal Access Token) in one of the configuration files. Make sure you **do not** commit this PAT, since it will immediately get invalidated by GitHub and your next lab steps will fail. To recover from this, refer to the [LabTips]({% link tips.md %}).

1.  Go to the java-microservices-aca-lab folder where you cloned the project, and open the project with Visual Studio Code.

    ```bash
    mkdir workspaces
    cd workspaces
    git clone https://github.com/<your-github-account>/java-microservices-aca-lab.git
    ```

1.  With the [Visual Studio Code Remote Containers extension](https://code.visualstudio.com/docs/remote/containers) installed, you can now open the project in a remote container. This will reopen the project in a Docker container with all the tooling installed.

After you have the Docker container open, you can start executing the rest of the lab.

## Install all the tools on your local machine

If you’re unable to use either GitHub Codespaces or the Visual Studio Code Dev Containers extension, you can configure your local workstation as your development environment. To do so, you must install all the Java and Azure tools that you need to use in this lab.

{: .note }
> Only use this option if you feel comfortable installing a lot of tooling on your local workstation. Also note that it’s impossible for us to test all lab steps with all possible local configurations. We highly recommend using either the GitHub Codespaces or the Visual Studio Code Dev Containers option for running this lab.

{: .note }
> The following guidance assumes that you’re using a Windows workstation. If your workstation is running an alternative operating system, you’ll likely need to adjust the instructions to be sure that all components are properly installed on your machine. Again, only proceed with this option if you’re comfortable configuring a Java development environment on your operating system.

Your workstation should have the following components installed:

- [Visual Studio Code](https://code.visualstudio.com/download)
    - [Java and Spring Boot Visual Studio Code extension packs](https://code.visualstudio.com/docs/java/extensions)
- [Git for Windows](https://git-scm.com/downloads) or the equivalent, if your workstation is running another operating system.

    {: .note}
    > If needed, reinstall Git and, during installation, be sure that the Git Credential Manager is enabled.

    {: .note }
    > After installing Git, run the following commands from the Git Bash shell to set the global configuration variables *user.email* and *user.name* (replace the *\<your-email-address\>* and *\<your-full-name\>* placeholders with your email address and your full name):

   ```bash
   git config --global user.email "<your-email-address>"
   git config --global user.name "<your-full-name>"
   ```

- Apache Maven 3.9.9

    {: .note }
    > To install Apache Maven, extract the content of the .zip file by running unzip apache-maven-3.9.9-bin.zip. Next, add the path to the bin directory of the extracted content to the *PATH* environment variable. Assuming that you extracted the content directly into your home directory, you could accomplish this by running the following command from the Git Bash shell: *export PATH=\~/apache-maven-3.9.9/bin:\$PATH*.

- [Java 17 and the Java Development Kit (JDK)](https://aka.ms/download-jdk/microsoft-jdk-17.0.13-windows-x64.msi)

    {: .note }
    > To install the JDK on Windows, follow the instructions provided in the [JDK Installation Guide](https://learn.microsoft.com/java/openjdk/install#install-on-windows). Make sure to use the *FeatureJavaHome* feature during the install to update the *JAVA_HOME* environment variable.

- Install [Azure CLI version 2.60.0 or later](https://learn.microsoft.com/cli/azure/install-azure-cli-linux?pivots=apt#install-azure-cli).
- Install the Azure CLI Container Apps and Service Connector extensions.

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
    > If needed, upgrade the Azure CLI version by launching Command Prompt as administrator and running *az upgrade*.

After all these tools are installed, you can get started:

1.  Go to [this lab’s GitHub repository](https://github.com/Azure-Samples/java-microservices-aca-lab), and select **Fork**.
1.  Be sure that your own username is indicated as the fork Owner.
1.  Select **Create fork**. This creates a copy (or fork) of this project in your own account.

    {: .note }
    > If you’re using a GitHub Enterprise Managed Users (EMU) account, you might not be able to fork a public repository. In that case, create a new repository with the same name, clone the original repository, add your new repository as a remote, and push to this new remote.

1.  On your lab computer, in the Git Bash shell, run the following commands to clone your fork of the *spring-petclinic-microservices* project to your workstation. Make sure to replace \<your-github-account\> in the following command:

    ```bash
    mkdir workspaces
    cd workspaces
    git clone https://github.com/<your-github-account>/java-microservices-aca-lab.git
    ```

1.  When prompted to sign in to GitHub, select **Sign in with your browser**. This will automatically open a new tab in the web browser window, prompting you to provide your GitHub username and password..
1.  In the browser window, enter your GitHub credentials and select **Sign in**. After you’ve signed in successfully, close the newly opened browser tab.
1.  In your workspaces folder, verify that the spring-petclinic-microservices application was cloned correctly. You can use this local copy of the repository to regularly push changes to your fork on GitHub.
1.  Go to the java-microservices-aca-lab folder where you cloned the project, and open the project with Visual Studio Code.

    ```bash
    cd java-microservices-aca-lab
    code .
    ```