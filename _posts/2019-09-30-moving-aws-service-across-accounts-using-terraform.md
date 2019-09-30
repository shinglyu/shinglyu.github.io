---
layout: post
title: Moving AWS Service across accounts using Terraform
categories: Web
date: 2019-09-30 14:39:00 +02:00
excerpt_separator: <!--more-->
---
Recently I was assigned the task to move our REST API hosted on AWS to a new account. The organization I worked for is moving to a one-account-per-team (or a few closely related teams) approach, as opposed to one account shared by all teams. Having one account per team helps reduce the clutter in the accounts because you only see your resources. It also helps the platform/SRE team to control the cost in a more fine-grain manner. Since we have everything in AWS, it also reduces the chance that we hit AWS resource limits. 

The service we built is all provisioned using Terraform. They are tested and deployed with Drone CI tool. I'll discuss key points to considerations when migrating accounts across accounts.
<!--more-->

## Change the account number in Terraform
Assuming we are moving from AWS account `111111111111` to `222222222222`. The first and easiest thing is to change all occurrences of the string `11111111111` to `222222222222` in your Terraform code. We can easily change them all by `sed` or any search-and-replace functionality from an IDE. 

```
sed -i 's/111111111111/222222222222/g' *.tf
```

This changes your `provider` and anything that references the AWS account.  It can be much easier if you already have the account configured dynamically in Terraform variables or locals.

```
provider "aws" {
  region              = "eu-central-1"
  profile             = "222222222222" // or better, "${var.aws_profile}"
  allowed_account_ids = ["222222222222"]
}
```

## Rename the S3 buckets and domain names
S3 bucket names need to be globally unique. If you already have a bucket named "my-awesome-bucket" in one account, you'll not be able to use any other account. We all know that naming is hard. An easy way to avoid thinking up a new name for S3 every time you change account is to prefix your S3 bucket with the account ID. So the bucket in the old account should be "111111111111-my-awesome-bucket", and in the new account: "222222222222-my-awesome-bucket". 

Another resource that needs to be globally unique is the domain name. You might want to invest in a new domain name so you can run the old and new service under different domain names, this can help you quickly switch traffic between the two. If you do consider moving the hosted zone to a new account, follow this [guide][r53-guide].


## Update IAM permissions 
Most of your IAM permissions should be changed when you do a string replacement. However, there might be some shared resources that require to be granted access manually. For example, we have a separate AWS profile that hosts our ECR repo. Both the old and new account needs to pull Docker images from the shared ECR in the shared account. In this case, we need to grant access to the new account in ECR.

## Change the CI pipeline
If you deploy the service via CI pipelines, you'll need to update your pipeline to deploy everything to the new account. My organization is using Drone, more specifically the [`drone-terraform`][drone-terraform] plugin to run Terraform `plan` and `apply`. Since we are changing accounts, we need to make sure the pipeline is deploying to the new one. The `drone-terraform` plugin has a parameter `role_arn_to_assume`, which is the IAM role ARN the plugin will assume when running the Terraform commands. We need to update this to a role in the new account, so drone has access to everything in the new account. For example, the new drone step might look like:

```
pipeline:
    deploy-terraform
      actions:
          - "apply"
      image: "jmccann/drone-terraform:5"
      role_arn_to_assume: "arn:aws:iam::222222222222:role/drone-role"
```

Another thing to consider is to disable specific steps that block the deployment. Unless your pipeline is built perfectly from the beginning, there might be some steps (e.g., integration test, additional Terraform deployment) added later. These steps might assume that some resources already exist, and it's very likely that you'll have circular dependencies between steps. To break this chicken-and-egg tie, you usually need to disable one step, force deploys the rest, and add the step back.


##  Terraform remote states

The above all sounds like easy search-and-replacing. However, the real headache comes from [remote states][remote state]. When you use an S3 backend, the terraform state will be stored as `terrafom.tfstate` files in S3. The remote state is an excellent way to avoid hard-coding things. For example, you can provision fundamental infrastructures like VPC, ECS cluster and Route53 hosted zones by Terraform (version-controlled in another repository), and have your web service Terraform referencing the VPC ID, ECS cluster name or Router53 hosted zone ID using a `data terraform_remote_state` resource.

When migrating accounts, you need to double-check if those remote states are still available in the same location. Taking a remote state stored in S3 for VPC as an example:

```
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region  = "eu-central-1"
    profile = "222222222222"
    bucket  = "222222222222-tfstate"
    key     = "shared/vpc.tfstate"
  }
}
```
We'll need to make sure the Terraform that provisions the VPC are deployed to the new account, and the remote state exists in S3.  Then we need to update the profile, bucket, and key accordingly. 

Sometimes we might also want to clean up some tech debt in these infrastructure Terraform code when we migrate accounts. Then you need to be careful if the data format in the remote state has changed, and change the way we reference it accordingly. For example, in our old VPC Terraform, we used to output the VPC ID for each region in separate outputs. In the `tfstate` file it will look like:

```
{
    "modules": [
        {
            "path": [ "root" ],
            "outputs": {
                "eu-central-1_vpc_id": {
                    "type": "string",
                    "value": "vpc-00000000000000001",
                },
                "us-east-1_vpc_id": {
                    "type": "string",
                    "value": "vpc-00000000000000002",
                }
            }
        }
    ]
}

```

We reference them in the old Terraform code using `${data.terraform_remote_state.vpc.eu-central-1_vpc_id}` and `${data.terraform_remote_state.vpc.outputs.us-east-1_vpc_id}`. But in the new account we choose to do it differently and expose the VPC IDs using a `map`:

```
{
    "modules": [
        {
            "path": [ "root" ],
            "outputs": {
                "vpc_id": {
                    "type": "map",
                    "value": {
                        "eu-central-1": "vpc-00000000000000001",
                        "us-east-1": "vpc-00000000000000002"
                    }
                }
            }
        }
    ]
}
```

In this case we need to reference them by `${data.terraform_remote_state.vpc.outputs.vpc[var.aws_region]}`, where `var.aws_region` contains the region name.

If the remote state we want to reference is not migrated to the new account yet, we need to think about whether it's worthwhile to reference the remote state in the old account. Alternatively, you can copy-paste the actual value and hard-code it to the new Terraform while you work on the infrastructure migration. Here are some pros and cons.

* Reference the remote state in the old account
  * Pros:
    * More dynamic
    * Does not break if you update settings in the old account
  * Cons:
    * Requires setting up cross-account permissions to read the remote state
    * More dependent on the old account
    * Might forget to update it when decommissioning the old account
* Hard code the old value into the new Terraform
  * Pros:
    * Simple and easy
    * The new Terraform code only contains resources in the new account
  * Cons:
    * Less dynamic
    * You need to update the value manually if you want to update the setting in the old account.

One example for this is we set up our PagerDuty service using Terraform in our old account. The output is a PagerDuty API endpoint URL, which we can send alerts to. Since we want to use the same PagerDuty service, we don't want to create a deploy a new PagerDuty service in the new account. In the end, we choose to hard-code the PagerDuty API endpoint in our Terraform code while we work on moving the PagerDuty over to the new account.

## Conclusion

Moving to a new account with Terraform should be pretty straightforward. That's the purpose of Infrastructure-as-code after all. By search-and-replace the account ID in your Terraform code and CI configuration, you should be able to move most of the things over. A few caveats you should be careful is the resources that need to have a globally unique name, like S3 bucket or Route53 domains. Also remember to check if the remote state is created in the new account, and check if they have the same path and format.

[drone-terraform]: https://github.com/jmccann/drone-terraform
[remote state]: https://www.terraform.io/docs/state/remote.html
[r53-guide]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-migrating.html
