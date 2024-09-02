# Static Website Hosting with S3 and CloudFront 

## Overview
This project demonstrates how to host a static website on AWS using Amazon S3 and Amazon CloudFront. The goal is to create a highly available, scalable, and globally distributed static website with minimal infrastructure management.

## Key Components:
**Amazon S3 (Simple Storage Service):** <br>
Purpose: S3 is used to store the static files for the website, such as HTML, CSS, JavaScript, and images.
Functionality: S3 is a durable and scalable object storage service. In this project, it is configured to serve web content directly to users as a static website. S3 provides a simple and cost-effective way to store and retrieve static assets.<br><br>
**Amazon CloudFront:** <br>
Purpose: CloudFront is a Content Delivery Network (CDN) that caches the website content

## Architecture Diagram
![PJ-02](https://github.com/user-attachments/assets/cba0796c-b26e-4b27-bcf6-c8e5839e8c6c)

### Step-by-Step Guide

#### Step 1: Setup an S3 Bucket
1. Create an S3 Bucket:
- Log in to the AWS Management Console.
- Navigate to the S3 service.
- Click on "Create bucket".
- Provide a unique bucket name (e.g., my-static-website-bucket).
- Choose the AWS region closest to your target audience.
- Click "Create bucket".
- Upload Website Files:

2. Click on your newly created bucket.
- Upload your website files (e.g., index.html, styles.css, scripts.js).
- Make sure your files are correctly organized (e.g., index.html in the root, images in a separate folder).
- Configure Bucket for Static Website Hosting:

3. Go to the "Properties" tab in the S3 bucket.
- Scroll down to "Static website hosting".
- Select "Use this bucket to host a website".
- Specify the index document (e.g., index.html).
- Optionally, specify an error document (e.g., 404.html).
- Note the "Bucket website endpoint" URL provided by AWS.
- Set Bucket Permissions:

4. Go to the "Permissions" tab in the S3 bucket.
- Under "Bucket Policy", add a policy to make the content publicly accessible:
```
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-static-website-bucket/*"
        }
    ]
}
```
#### Step 2: Set Up CloudFront

1. Create a CloudFront Distribution

- **Navigate to the CloudFront service** in the AWS Management Console.
- Click on **"Create Distribution"**.
- Choose **"Web"** under the delivery method.
- For the **origin domain name**, select your S3 bucket (you can choose it from the dropdown).
- Under **"Default Cache Behavior Settings"**, leave the defaults or configure based on your requirements (e.g., restrict viewer access if needed).

2. Configure Origin Settings

- Set the **Origin Path** if your website files are within a specific folder in the S3 bucket (optional).
- Enable **"Compress Objects Automatically"** to reduce the file size for faster loading.

3. Configure Distribution Settings

- Choose the **price class** based on your geographic needs (e.g., "Use Only U.S., Canada, and Europe" or "Use All Edge Locations").
- Set the **default root object** to `index.html` so that requests to the root of your domain serve your main page.
- Enable **logging** (optional) to monitor traffic.

4. Deploy the CloudFront Distribution

- Click **"Create Distribution"**.
- Wait for the distribution to deploy, which may take a few minutes.

5. Update DNS Settings (Optional)

- If you have a custom domain, navigate to **Route 53**.
- Create an **A Record** with your domain name, pointing to the CloudFront distribution’s domain name.
- Alternatively, you can create a **CNAME record** if your DNS provider supports it.

#### Step 3: Test and Deploy

1. Access Your Website

- Once the CloudFront distribution is deployed, you can access your website using the CloudFront URL (e.g., `https://d1234567890abcdef.cloudfront.net`).
- If you set up Route 53, use your custom domain to access the site.

2. Verify CloudFront Caching

- Test the website by accessing it from different geographic locations (use VPN or online tools).
- Check that CloudFront is caching and serving content from the edge locations.
