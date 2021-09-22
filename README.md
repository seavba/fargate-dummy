# <b>HTTPS Application in AWS ECS Fargate</b>

## <b>Repo description</b>

This provides a simple Infrastructure for a HTTPS application in AWS. The HTTPS application runs over NGINX containers in AWS Fargate.

The Infrastructure deployed consists on:

- ECS: Containers provided in a Fargate Cluster from a Fargate task executed by the corresponding Fargate service. The docker image is being pulled from ECR registry. See ```variables``` section below
- ALB: Application load balancer pointing to ECS num_containers listening by 443 port.
- ACM: A validated Certificate for HTTPS listener in the ALB.
- Route53:
    - DNS record as an alias of ALB dns name. This way, the Application URL can be customised.
    - DNS record for certifcate validation

Security groups, target groups, IAM policies, VPC and so on, are already provided by this repo.

<img src="./images/diagram.png" alt="Diagram" />
<br/>

## Files and Folder structure

- <b>app:</b> Directory for the application files. In this repo it's a simple html file

- <b>iac:</b> Directory for terraform code

- <b>Dockerfile:</b> Dockerfile for creating NGINX image

- <b>[.github/workflows/aws.yml](https://github.com/seavba/fargate-dummy/blob/master/.github/workflows/aws.yml):</b> Github action for building, pushing and deploy a new image docker and its containters.
<br/>

## CI / code

This repo contains a github action triggered by every pushing or merging done in the master branch. The github actions steps are:

- Build the docker image
- Push the docker image
- Update task definition
- Deploy the new containers using the rolling deployment strategy.

## Getting Started

#### Pre-requisites

- AWS CLI must be already configured. If not, try [Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

- The Terraform code has been wrote with Terraform v0.15.3.


#### Deploy

Once Dummy docker image has been created, for providing such infrastructure, it's needed to run:

```
cd /your/repo/path
git clone  git@github.com:seavba/fargate-dummy.git
cd fargate-dummy/iac && terraform init && terraform apply -auto-approve
```


#### Variables
All the variables to be customised (if needed) can be found in [variables.tf](https://github.com/seavba/fargate-dummy/blob/master/variables.tf) file.

> :warning: Important to change domain_name and zone_name variables, otherwise the deployment will fail.


###### Output Variables
After deployment, as output variables are shown:
```
Outputs:
url = "Enjoy you dummy box https://dummybis.ssans.es"
```
> :warning: The URL shown in the output message is the Application link. It can be test it in any browser.


#### Destroy Infrastructure

```
cd /your/repo/path
cd fargate-dummy/iac && terraform destroy -auto-approve
```


## Demo

Play the following video and enjoy:

[![Watch the video](https://img.youtube.com/vi/1zc09DMztMI/0.jpg)](https://www.youtube.com/watch?v=1zc09DMztMI)


## Webgraphy

The following websites helped me to understand better how to implement the solution:

- [Building, deploying, and operating containerized applications with AWS Fargate](https://aws.amazon.com/es/blogs/compute/building-deploying-and-operating-containerized-applications-with-aws-fargate/)

- [Terraform](https://www.terraform.io/)
