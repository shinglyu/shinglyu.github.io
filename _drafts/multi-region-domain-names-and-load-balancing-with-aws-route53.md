---
layout: post
title: AWS Route 53 load balancing with Terraform
categories: Web
date: 2019-01-16 00:00:00 +01:00
excerpt_separator: <!--more-->
---

We are going to build an REST API that is deployed to multiple AWS regions, which has one public-facing URL, which is load balanced through Route 53. There are some additional requirements:

* API is done using API Gateway + Lambda
* The same API is deployed to multiple AWS regions. To demonstrate this we'll deploy to EU Frankfurt (eu-central-1) and N.Virginia, US (us-east-1).
* The API in each region will get a public facing URL for easy debugging. So there will be `https://api-eu.example.com` and `https://api-us.example.com` pointing to the API gateway in each region.
* There will be a global URL, `https://api.example.com` which points to the underlying `https://api-eu.example.com` and `https://api-us.example.com` endpoints.
* The global URL will do a 50%-50% active-active load balancing to each region. So 50% of the traffic will go to each region.
* The health of the regional APIs are monitored, if one of it goes down, all the traffic will be routed to the other alive one.
* Everything is deployed with Terraform

# Prerequisites

There are some AWS resources that needs to be created beforehand, but they are out of the scope of this post so we'll leave it out for now. You can consult the Terraform or AWS documentation to create them.

* A [domain name][domain_name] and [hosted zone][hosted_zone]
* [AWS Certificate Manager][acm]

Write down their [ARNs (Amazon Resource Names)][arn] and keep them handy, because we're going to need them very soon.

# Creating the API gateway with a hello world lambda
In this part we are going to create a REST API with API gateway and a simple lambda. This part is inspired by [this guide][lambda_guide]. If you are already familiar with how to do this, you can skip to the next section.

For easy testing, we want our API to tell us which region it is in. So we create a simple Node.js-based lambda like so:

```
# main.js
'use strict'

exports.handler = function(event, context, callback) {
  # Region name is the forth part of the lambda function ARN
  const region = context.invokedFunctionArn.split(':')[3];
  var response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8'
    },
    body: `<p>Hello world! I\'m in ${region}</p>`
  }
  callback(null, response)
}
```

This will display something like this in the browser:

#TODO: pic

To deploy this lambda by Terraform, we create the following resource in our terraform config:

```
# lambda.tf

resource "aws_lambda_function" "example" {
  function_name = "report_region"
  filename = "lambda.zip"
  handler = "main.handler"  # Call handler in main.js
  runtime = "nodejs6.10"

  role = "${aws_iam_role.lambda_exec.arn}"  # We'll get back to this
}
```

And since lambda need permission to execute, we'll add a [IAM][iam] role for it:

```
resource "aws_iam_role" "lambda_exec" {
  count = "${var.create_global_resources ? 1 : 0}"
  name = "example_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
```

To create the API Gateway, first we create the `aws_api_gateway_rest_api` resource:

```
# api_gateway.tf

resource "aws_api_gateway_rest_api" "example" {
  name        = "report_region"
  description = "Reports the region it is in so we can test Route53"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
```

Notice that we created a "regional" endpoint instead of an "edge-optimized" one, that's because we want to handle the DNS names and routing by ourselves. If we choose the "edge-optimized" endpoint, AWS will do all that for us magically in [CloudFront][cloud_front].

Then, to actually trigger the lambda function when the API is called, we create the gateway method and gateway intergration for it:

```
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.example.invoke_arn}"
}
```

We use the `root_resource_id` as the path, so the user can just call the root path `/` to trigger the API (i.e. call `https://api.example.com/` instead of `https://api.example.com/<api_path>`).

Finally, we deploy this API with the following config:

```
resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "dev"
}
```

But we miss one permission setting to allow the API gateway to invoke the lambda, so let's add the `aws_lambda_permission` as follows:

```
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.example.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.example.execution_arn}/*/*"
}
```

Now our APIs are ready to go, but they only get an auto-generated URL like `https://8gz2uzemsx.execute-api.eu-central-1.amazonaws.com/dev/`. We are going to give them a more friendly name in the next section.

# Creating regional URLs

The auto-generated URLs are not very user-friendly. Although technically we don't need an human-friendly URL for each region, but they are still helpful in testing and debugging. So we are going to create a DNS record for `https://api-<region>.example.com` for the API gateway in each region.

To give API a custom URL, we need two parts: the API Gateway Custom Domain Name and the DNS record. The AWS Gateway Custom Domain Name, as the name suggests, will give a custom domain name to the API. There is also a concept called Base Path Mapping under the custom domain name, which will map a path in the url to an API and stage. This is useful when you want to put multiple APIs under one domain name. For example https://api.example.com/account-dev can be mapped to the dev stage of the account API, while https://api.example.com/payment can be mapped to the production stage of the payment API. But for our case we only need to use the root path `/` and map that to our one and only API. So we can create a setting like this:

```
resource "aws_api_gateway_domain_name" "regional" {
  domain_name = "${replace(local.regional_hostname, "/[.]$/", "")}"

  regional_certificate_arn = "<YOUR regional ACM ARN>"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "regional" {
  # The path, if not specified, is `/` by default
  api_id      = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "${aws_api_gateway_deployment.example.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.regional.domain_name}"
}
```

A few pitfalls to avoid in the `aws_api_gateway_domain_name` are

* The domain name should not contain the trailing `.`, that's why we use `replace()` to trim it.
* You need to put your ACM ARN in the `regional_certificate_arn`, and the ACM needs to be in the same region as your API Gateway resource.
* Remember to specify that the API is "regional".

But this alone will not make your URL available to people on the internet. You need to create a DNS record 


The DNS record will give users on the internet to resolve `https://api-eu.example.com` into some 



Create API gateway and lambda
Regional domain names
Health check
Global domain names
Load balancing
Create global resources

<!--more-->

[hosted_zone]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html
