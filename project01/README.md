# How to Protect Your Server with Multi-Factor Authentication on AWS

## Overview

This guide will help you set up multi-factor authentication (MFA) using Google Authenticator on a bastion host, which serves as a jump server to access an internal private server. This setup increases the security of your AWS infrastructure by adding an extra layer of authentication.

## Architecture
<img width="686" alt="MFA AWS design" src="https://github.com/user-attachments/assets/4dbdcfdd-0b47-417e-ac52-01b848dfdf92">



## Prerequisites

- AWS user credentials (access ID and key)
- Configured AWS credentials on your local machine
- A key pair for the instance

## Setup Environment Using Terraform (Infrastructure as Code)

