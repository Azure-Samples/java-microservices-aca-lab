---
title: 'Lab 6: Secure MySQL database and Key Vault using a Private Endpoint'
layout: default
nav_order: 8
has_children: true
---

# Lab 08: Secure MySQL database and Key Vault using a Private Endpoint

# Student manual

## Lab scenario

You now have your application deployed into a virtual network and the microservices connection requests from the internet must pass through your Application Gateway instance with Web Application Firewall enabled. However, the apps communicate with the backend services, such Azure Database for MySQL Flexible Server and Key Vault via their public endpoints. In this exercise, you will lock them down by implementing a configuration in which they only accept connections that originate from within your virtual network.

## Objectives

After you complete this lab, you will be able to:

- Lock down the Azure Database for MySQL Flexible Server instance by redeploying it in a subnet
- Lock down the Key Vault instance by using a private endpoint
- Test your setup

The below image illustrates the end state you will be building in this lab.

![lab 8 overview](../../images/lab8.png)

## Lab Duration

- **Estimated Time**: 60 minutes

## Instructions

During this lab, you will:

- Lock down the Azure Database for MySQL Flexible Server instance by redeploying it in a subnet
- Lock down the Key Vault instance by using a private endpoint
- Test your setup

{: .note }
> The instructions provided in this exercise assume that you successfully completed the previous exercise and are using the same lab environment, including your Git Bash session with the relevant environment variables already set.

