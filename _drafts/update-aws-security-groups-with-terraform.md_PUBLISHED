---
layout: post
title: Update AWS Security Groups with Terraform
categories: Web
date: 2020-01-30 16:17:58 +08:00
excerpt_separator: <!--more-->
---

In theory, Terraform is capable of figuring out the dependency between AWS resources and make updates in the correct order. However, AWS security groups often become a source of trouble if you don't understand how Terraform handles it. If you are having issues modifying the security group because they are used by other resources, here are some ways you can mitigate that. 

<!--more-->
If we have the following security group:

```hcl
resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http_traffic"
  vpc_id      = aws_vpc.example.id // not relavent

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
```

This security group has two rules; it allows inbound traffic from the `10.0.1.0/24` IP range on port 80, and allows all outbound traffic. This security group is used by an application load balancer to control the traffic:

```hcl
resource "aws_lb" "example" {
  name               = "example_load_balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_traffic.id] // Security group referenced here

  internal           = true
  subnets            = [aws_subnet.example.*.*.id] // Not relavent
}

```

The architecture looks like this:

![alb-security-group architecture]({{site_url}}/blog_assets/tf-sg/arch.png)

Now if we try to allow another IP range to access this ALB, we add a new ingress rule to the security group:

```hcl
resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http_traffic"
  vpc_id      = aws_vpc.example.id // not relavent

  ingress {
    // omitted
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    // omitted
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress { // New ingress rule
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
}
```

You might see the `terraform apply` runs for a very long time and finally fails with an error:

```
aws_security_group.allow_http_traffic: Still destroying... [id=sg-02e90ca52c7b4484a, 0m10s elapsed]
// ... the same message goes on for 10 minutes
aws_security_group.allow_http_traffic: Still destroying... [id=sg-02e90ca52c7b4484a, 9m40s elapsed]
aws_security_group.allow_http_traffic: Still destroying... [id=sg-02e90ca52c7b4484a, 9m50s elapsed]
aws_security_group.allow_http_traffic: Still destroying... [id=sg-02e90ca52c7b4484a, 10m0s elapsed]

Error: DependencyViolation: resource sg-02e90ca52c7b4484a has a dependent object
    status code: 400, request id: a1814f80-9eea-414c-bbc2-6685b0bf1129
```
## Destroy-before-create v.s. Create-before-destroy
This is actually caused by they way Terraform tries to update the security group. If we look into the `terraform plan` output:

```hcl
  # aws_security_group.allow_http_traffic must be replaced
-/+ resource "aws_security_group" "allow_http_traffic" {
    // ... omitted
}
```

By default, if Terraform thinks the resource can't be updated in-place, it will try first to destroy the resource and create a new one. The `-/+` symbol in the `terraform plan` output confirms that. This is illustrated in the following diagram:


![destroy before create]({{site_url}}/blog_assets/tf-sg/destroy_before_create.png)

However, AWS doesn't allow you to destroy a security group while the application load balancer is using it. So Terraform will be stuck in step 1, trying to destroy the security group until it times out.

The solution is to:
1. create a new security group
2. Re-configure the application load balancer, so it uses the new security group instead of the old one.
3. Now the old security group is not referenced by anyone anymore. We can safely delete it.


![create before destroy]({{site_url}}/blog_assets/tf-sg/create_before_destroy.png)

Terraform has a [`lifecycle`][lifecycle] block that allows you to overwrite how Terraform handles the resource's lifecycle. More specifically, the `create_before_destory` argument is what we are looking for. The [documentation][create_before_destroy] says:

> The `create_before_destroy` meta-argument changes this behavior so that the new replacement object is created first, and then the prior object is destroyed only once the replacement is created.


So if we change our security group resource according to the following snippet, we can get the desired behavior:

```hcl
resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http_traffic"
  vpc_id      = aws_vpc.example.id // not relavent

  ingress {
    // omitted
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    // omitted
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress { // New ingress rule
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  lifecycle {
      create_before_destroy = true
  }
}
```

## Name conflict

If we run `terraform apply` now, we'll get another issue:

```
aws_security_group.allow_http_traffic: Creating...

Error: Error creating Security Group: InvalidGroup.Duplicate: The security group 'allow_http_traffic' already exists for VPC 'vpc-03a1b980a68f57ab3'
    status code: 400, request id: 0ad62c71-99cc-448a-91c0-38fe19a1adaa

  on alb.tf line 1, in resource "aws_security_group" "allow_http_traffic":
  1: resource "aws_security_group" "allow_http_traffic" {
```

The error message is pretty self-explanatory: when Terraform tries to create the new security group, it has the same `name` as the existing one. You'll have to change the `name` of the security group so Terraform can create a new security group with a new name. 

If you run out of ideas for naming, you can consider adding a sequence number to the end of the name, like `allow_http_traffic_1`, `allow_http_traffic_2`, and so on. Or you can automate that with a variable like the commit hash (`allow_http_traffic_${var.commit_hash}`), and let the CI pipeline present the commit hash as a Terraform variable. The drawback of the commit-hash approach is that it will force the security group to be re-created on every commit. If your Terraform code lives alongside the application code in the same repository, that might be a waste of deployment time. Usually, the security group won't change too often, so it'll be easier just to rename them manually.


[lifecycle]:  https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
[create_before_destroy]: https://www.terraform.io/docs/configuration/resources.html#create_before_destroy
