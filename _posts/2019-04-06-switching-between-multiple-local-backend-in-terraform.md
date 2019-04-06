---
layout: post
title: Switching Between Multiple Local Backends in Terraform
categories: Web
date: 2019-04-06 20:39:24 +02:00
excerpt_separator: <!--more-->
---

Terraform has many [backend][backend] types. The [`local` backend][local] stores the state on the local filesystem, so it's ideal for quick local testing. By it's not very obvious how to have multiple local backend and state, and how to easily switch between them. One use case for this is when you deploy the same set of resources to multiple AWS regions. Let's say we want to create two API gateways and their corresponding DNS records to two regions. We use the [`aws_route53_record`][aws_route53_record] resource to deploy them:

```
resource "aws_route53_record" "api" {
  name    = "${var.api_url}"
  type    = "A"
  # the rest are omitted
}
```
And we want to set `var.api_url` to `api-eu.example.com` and `api-us.example.com` for Europe and US regions in two separate `tfvars` file.

Then if you try to apply them sequentially like so:

```
terraform init
terraform apply -var-file=eu.tfvars
terraform apply -var-file=us.tfvars
```

You'll notice that the second apply will try to destroy your `api-eu.example.com` record, and replace it with an `api-us-example.com` record. This is because the states are the same, and the resource name is the same between two apply attempts, so terraform think you want to destroy the existing record and create a new one. There is also a problem when you try to destroy resources. Because the resources have the same name, so if you destroy them in one region, you won't be able to destroy then in the other one. Because terraform assumes everything is already gone.

<!--more-->

# The solution
To workaround this, you need two separate state for each region, so the resources can be tracked separately.  One hacky way is the combine the [`TF_DATA_DIR`][tf_data_dir] environment variable and the `local` backend. By default, the terraform data are stored in the local folder called `.terraform`. Using `TF_DATA_DIR` we can specify where to store the data. So theoretically we can do the following:

```
TF_DATA_DIR=.terraform-eu terraform init
TF_DATA_DIR=.terraform-us terraform init
```

to create two separate environment in the `.terraform-eu` and `.terraform-us` folder to hold our separate states.
But this setup won't work as we expected because by default terraform stores the state in a file `terraform.tfstate` outside of the `.terraform-<region>` folders, in your project root.

Therefore we need to specify the `local` backend in our `.tf` file, which will force the terrafrom state to be saved in the `TF_DATA_DIR` folder. Create a file named `backend.tf` and copy paste the following into it:

```
terraform {
  backend "local" {}
}
```

Then if you run `TF_DATA_DIR=.terraform-eu terraform init`, the state file will be created at `./.terraform-eu/terraform.tfstate`.

So a complete workflow will be like

```
# Apply the EU configurations
TF_DATA_DIR=.terraform-eu terraform init
TF_DATA_DIR=.terraform-eu terraform plan -var-file=eu.tfvars -out eu.plan
TF_DATA_DIR=.terraform-eu terraform apply eu.plan

# Create a separate US state and apply it independently from EU
TF_DATA_DIR=.terraform-us terraform init
TF_DATA_DIR=.terraform-us terraform plan -var-file=us.tfvars -out us.plan
TF_DATA_DIR=.terraform-us terraform apply us.plan

# Destroy will also work independently
TF_DATA_DIR=.terraform-eu terraform destroy -var-file=eu.tfvars
TF_DATA_DIR=.terraform-us terraform destroy -var-file=us.tfvars
```

# The built-in `workspace`

There is a less hacky way of doing this. Terraform has a built-in "[workspace][workspace]" feature. By running 

```
terraform init
terraform workspace new eu
```

It will create a workspace named `eu`, which is tracks its state separately from other workspaces. So you can achieve the same behavior as above using the following command:

```
terraform init

terraform workspace new eu  # Switched to workspace eu directly
terraform plan -var-file=eu.tfvars -out eu.plan
terraform apply eu.plan

terraform workspace new us
terraform plan -var-file=us.tfvars -out us.plan
terraform apply us.plan

terraform workspace select eu  # Switch back to workspace eu
terraform destroy -var-file=eu.tfvars

terraform workspace select us
terraform destroy -var-file=us.tfvars
```

The workspaces are stored in `terraform.tfstate.d/<workspace_name>`, similar to what we've done using `TF_DATA_DIR`.

# Conclusion

Terraform resources are tracked using the states, if you want to keep track of two separate deployments (e.g. same setup for different regions), you need separate states to avoid problems. Terraform supplies a built-in way to create independent state environments (i.e. workspace). But you can also achieve the same goal using the `TF_DATA_DIR` environment variable. 

So when do you need to use the `TF_DATA_DIR` hack instead of the built-in workspace? One scenario is when you use CI pipelines. You might create two CI pipeline for deploying to EU and US. Your CI stages may run in isolated environment so their state will not conflict. Creating workspaces inside those CI stages will just add extra complexity. If you are only testing it locally occasionally, you can apply the `TF_DATA_DIR` trick locally and keep your CI script simple.

[workspace]: https://www.terraform.io/docs/state/workspaces.html
[backend]: https://www.terraform.io/docs/backends/
[local]: https://www.terraform.io/docs/backends/types/local.html
[aws_route53_record]: https://www.terraform.io/docs/providers/aws/r/route53_record.html
[tf_data_dir]: https://www.terraform.io/docs/configuration/environment-variables.html#tf_data_dir
