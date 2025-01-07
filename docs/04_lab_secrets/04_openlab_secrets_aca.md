---
title: 'Lab 4: Connect to a database with managed identity'
layout: default  
nav_order: 6  
has_children: true
---

# Lab 04: Connect to a database securely by using managed identity

## Introduction

You now have your copy of the Spring Petclinic Microservices application running in Azure. However, there are application secrets, such as your database connection string, in your configuration repository, and you’d like a better way to protect these secrets.

In this lab, you’ll implement a more secure way to protect your application secrets by connecting the application to your database with managed identities and [Azure Service Connector](https://learn.microsoft.com/azure/service-connector/overview).

## What you’ll cover

As you work through this lab, you’ll learn how to:

-   Create a database administrator account.
-   Update the application dependencies to enable passwordless connectivity.
-   Create service connections from your microservices to the database server.

The following diagram illustrates how your application’s architecture should look after you’ve completed this lab.

![lab 4 overview](../../images/acalab4.png)

## Duration

**Estimated time:** 30 minutes

{: .note }
> This lab assumes that you successfully completed the previous lab and are using the same lab environment, including your command-line session, with the relevant environment variables already set.
