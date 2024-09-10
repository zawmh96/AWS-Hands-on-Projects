# How to Protect Your Bastion Host with Multi-Factor Authentication on AWS

## Overview

This guide will help you set up multi-factor authentication (MFA) using Google Authenticator on a bastion host, which serves as a jump server to access an internal private server. This setup increases the security of your AWS infrastructure by adding an extra layer of authentication.

## Architecture Diagram
<img width="686" alt="MFA AWS design" src="https://github.com/user-attachments/assets/4dbdcfdd-0b47-417e-ac52-01b848dfdf92">



## Prerequisites

- AWS IAM user credentials (access ID and key) and IAM Role
- Configured AWS credentials on your local machine
- A key pair for the instance

## Setup Environment Using Terraform (Infrastructure as Code)

### Initialize the directory
```
terraform init
```

### Format and validate the configuration
```
terraform fmt
terraform validate
```

### Create AWS infrastructure
```
terraform plan
terraform apply
```

## Setup MFA using Google Authenticator on Bastion host

### Setup the Google Authenticator on Linux Bastion host

#### Install Google Authenticator under ec2-user
```
sudo amazon-linux-extras install epel
sudo yum install google-authenticator
```

#### Install qrencode-libs to perform mult-factor authentication using QR code
```
sudo yum install qrencode-libs
```

#### Setup google authenticator and enter "y"
```
google-authenticator
```
```
Do you want authentication tokens to be time-based (y/n) y

#Scan QR code via mobile phone

Do you want me to update your "/home/ec2-user/.google_authenticator" file? (y/n) y

Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y


By default, a new token is generated every 30 seconds by the mobile app.
In order to compensate for possible time-skew between the client and the server,
we allow an extra token before and after the current time. This allows for a
time skew of up to 30 seconds between authentication server and client. If you
experience problems with poor time synchronization, you can increase the window
from its default size of 3 permitted codes (one previous code, the current
code, the next code) to 17 permitted codes (the 8 previous codes, the current
code, and the 8 next codes). This will permit for a time skew of up to 4 minutes
between client and server.
Do you want to do so? (y/n) y


If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting? (y/n) y
```

#### Create a file “google-auth” under /etc/pam.d/ and set parameter for sshd
```
#Create a file
sudo vi /etc/pam.d/google-auth

#%PAM-1.0
auth        required      pam_env.so
auth        sufficient    pam_google_authenticator.so try_first_pass
auth        requisite     pam_succeed_if.so uid >= 500 quiet
auth        required      pam_deny.so

#Edit “sshd” file under /etc/pam.d
sudo vi /etc/pam.d/sshd

#auth       substack     password-auth # Comment out
auth       substack     google-auth  # Add

#Edit sshd_config file under /etc/ssh
sudo vi /etc/ssh/sshd_config

ChallengeResponseAuthentication yes  #Change no to yes
AuthenticationMethods publickey,keyboard-interactive #Add
```

#### Restart sshd service
```
sudo systemctl restart sshd.service
```

#### Logging into the Bastion server along with MFA using SSH-Agent Forwarding Method
Refer how to setup **SSH-Agent Forwarding**
```
$ ssh -A Bastion                          
(ec2-user@13.113.249.191) Verification code: 
Last login: Sat Jun 22 15:19:47 2024 from g136.124-44-37.ppp.wakwak.ne.jp
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/


#Login into Internal Private server via Bastion host(Jump host)

[ec2-user@ip-10-10-1-50 ~]$ ssh -A ec2-user@10.10.2.50
Last login: Sat Jun 22 14:14:30 2024 from 10.10.1.50
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

[ec2-user@ip-10-10-2-50 ~]$ 
```
