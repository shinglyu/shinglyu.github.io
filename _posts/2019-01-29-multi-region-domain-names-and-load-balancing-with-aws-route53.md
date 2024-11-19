---
layout: post
title: AWS Route 53 Load Balancing with Terraform
categories: Web
date: 2019-01-29 14:55:00 +01:00
excerpt_separator: <!--more-->
---

Terraform has some great [documentation][route53_doc] on Route 53, but it's a little bit hard to understand how all the resources works together. So to demonstrate, we are going to build an REST API that is deployed to multiple AWS regions, which has one public-facing URL, which is load balanced through Route 53. There are some additional requirements:

* API is done using API Gateway + Lambda
* The same API is deployed to multiple AWS regions. To demonstrate this we'll deploy to EU Frankfurt (eu-central-1) and N.Virginia, US (us-east-1).
* The API in each region will get a public facing URL for easy debugging. So there will be `https://api-eu.example.com` and `https://api-us.example.com` pointing to the API gateway in each region.
* There will be a global URL, `https://api.example.com` which points to the underlying `https://api-eu.example.com` and `https://api-us.example.com` endpoints.
* The global URL will do a 50%-50% active-active load balancing to each region. In other words 50% of the traffic will go to each region.
* The health of the regional APIs are monitored, if one of it goes down, all the traffic will be routed to the other alive one.
* Everything is deployed with Terraform

<!--more-->

# Prerequisites

There are some AWS resources that needs to be created beforehand, but they are out of the scope of this post so we'll leave it out for now. You can consult the Terraform or AWS documentation to create them.

* Buy a [domain name][domain_name] and create a Route 53 [hosted zone][hosted_zone]. For example purpose we assume that we are using `example.com`.
* Setup [AWS Certificate Manager][acm] for your domain.

Write down their [ARNs (Amazon Resource Names)][arn] and keep them handy, because we're going to need them very soon.

# Architecture

Here is a high-level architecture diagram for the example we are going to set up. Don't get intimidated by the complexity, we'll walk through the components one-by-one.

![High-Level Architecture]({{site_url}}/blog_assets/route53_arch.svg)

# Creating the API gateway with a hello world lambda
In this part we are going to create a REST API with API gateway and a simple lambda. This part is inspired by [this guide][lambda_guide]. If you are already familiar with how to do this, you can skip to the next section.

For easy testing, we want our API to tell us which region it is in. So we create a simple Node.js-based lambda like so:

```javascript
// main.js
'use strict'

exports.handler = function(event, context, callback) {
  // Region name is the forth part of the lambda function ARN
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

If we open that URL in the browser we'll see something like this:

```
Hello world! I'm in eu-central-1
```

To deploy this lambda by Terraform, we zip the `main.js` in to a `lambda.zip` file and create the following resource in our terraform config:

```hcl
# lambda.tf

resource "aws_lambda_function" "example" {
  function_name = "report_region"
  filename = "lambda.zip"  # Terrafrom will handle the upload
  handler = "main.handler"  # Call handler in main.js
  runtime = "nodejs6.10"

  role = "${aws_iam_role.lambda_exec.arn}"  # We'll get back to this
}
```

And since lambda need permission to execute, we'll add a [IAM][iam] role for it:

```hcl
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

This IAM role is referenced in the `aws_lambda_function.role`.

To create the API Gateway, first we create the `aws_api_gateway_rest_api` resource:

```hcl
# api_gateway.tf

resource "aws_api_gateway_rest_api" "example" {
  name        = "report_region"
  description = "Reports the region it is in so we can test Route 53"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
```

Notice that we created a "regional" endpoint instead of an "edge-optimized" one, that's because we want to handle the DNS names and routing by ourselves. If we choose the "edge-optimized" endpoint, AWS will do all that for us magically with [CloudFront][cloud_front].

Then, to actually trigger the lambda function when the API is called, we create the gateway method and gateway integration for it:

```hcl
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

```hcl
resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "dev"
}
```

But we miss one permission setting to allow the API gateway to invoke the lambda, so let's add the `aws_lambda_permission` as follows:

```hcl
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

Now our APIs are ready to go, but they only get an auto-generated URL like `https://8gz2uzemsx.execute-api.eu-central-1.amazonaws.com/dev/` when deployed. We are going to give it a more friendly name in the next section.

# A side-note about deployment
To deploy the same set of resources to multiple regions, we use the same terraform files, but we have one `.tfvars` file per region. So when we deploy we have to run `terraform apply -var-files=<region-specific.tfvars>` once per region.  Some resources are global, e.g. Route 53 CNAME records. In that case you need to be careful about only deploying it in one region, otherwise the subsequent `terraform apply` might fail because the resource already exists.

# Creating regional URLs

The auto-generated URLs are not very user-friendly. Although technically we don't need an human-friendly URL for each region, but they are still helpful in testing and debugging. So we are going to create a DNS record for `https://api-<region>.example.com` for the API gateway in each region.

To give API a custom URL, we need two parts: the API Gateway Custom Domain Name and the DNS record. The AWS Gateway Custom Domain Name, as the name suggests, will give a custom domain name to the API. There is also a concept called Base Path Mapping under the custom domain name, which will map a path in the url to an API and stage. This is useful when you want to put multiple APIs under one domain name. For example https://api.example.com/account-dev can be mapped to the dev stage of the account API, while https://api.example.com/payment can be mapped to the production stage of the payment API. But for our case we only need to use the root path `/` and map that to our one and only API. So we can create a setting like this:

```hcl
resource "aws_api_gateway_domain_name" "regional" {
  # var.regional_hostname = api-eu.example.com for eu-central-1
  domain_name = "${replace(var.regional_hostname, "/[.]$/", "")}"

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

But this alone will not make your URL available to people on the internet. You need to create a DNS record. The DNS record will let users on the internet to resolve `https://api-eu.example.com` into the actual API gateway URL AWS is assigned to our API gateway. The terraform code for the DNS record will look like:

```hcl
resource "aws_route53_record" "regional" {
  zone_id = "${data.aws_route53_zone.public_zone.id}"

  name = "${var.regional_hostname}"  # e.g. api-eu.example.com
  type = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.regional.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.regional.regional_zone_id}"
    evaluate_target_health = true
  }
}
```

This will create a [A record][a_record], which maps the `api-eu.example.com` URL to an AWS alias to the API Gateway.

Now if we deploy the API to EU and US regions, we'll have `https://api-eu.example.com` and `https://api-us.example.com` ready.

# Global domain name and load balancing

But having only URLs for each region doesn't make much sense for an API that is used globally. Ideally our API user should only use one URL like `https://api.example.com`, no matter where they are, and it will get routed to either EU or US endpoints based on the load balancing strategy. For demonstration purpose we'll use a very simple [weighted load balancing strategy][weighted], where 50% of the traffic will be routed to EU and the other 50% to US, randomly. You can also use more advanced strategy like [latency-based][latency] or [geolocation-based][geolocation].

To create the global URL, we need to create a [CNAME][cname] record with a `weighted_routing_policy`, We store all the regional URLs we have in a Terraform array variable `deploy_hostnames`.

```hcl
resource "aws_route53_record" "balanced" {
    count = "${length(var.deploy_hostnames)}"
    zone_id = "${data.aws_route53_zone.public_zone.id}"
    name = "${var.global_hostname}"  # e.g. api.example.com
    type = "CNAME"
    ttl = "60"
    set_identifier = "${element(var.deploy_hostnames, count.index)}"
    health_check_id = "${element(aws_route53_health_check.health.*.id, count.index)}"

    records = [
        "${element(var.deploy_hostnames, count.index)}"
    ]
    weighted_routing_policy  {
        weight = 1
    }
}
```

Notice that we use a `count`, this will repeat the block once per element for `var.deploy_hostnames`, which contains the `https://api-eu.example.com` and `https://api-us.example.com`. Also keep an eye on the ``weighted_routing_policy`. We have `weight = 1` so every record will get equal share of the weight. This block will be expanded under the `count` to something like:

```hcl
resource "aws_route53_record" "balanced" {
    name = "api.example.com"
    records = [
        "api-eu.example.com"
    ]
    weighted_routing_policy  {
        weight = 1
    }
    // ...
}

resource "aws_route53_record" "balanced" {
    name = "api.example.com"
    records = [
        "api-us.example.com"
    ]
    weighted_routing_policy  {
        weight = 1
    }
    // ...
}
```

We haven't discuss the `health_check_id` field of the `aws_route53_record` configuration. In order to properly route the traffic, and redistribute the traffic to other regions in case one region goes down, Route 53 need to know if the endpoint in each region is alive or not. Therefore we need to setup a periodic health check to monitor them.

A simple health check can be a ping that checks if the endpoint is responding. Or it can simulate a normal user request and check for the response body (with text search, for example). It can also be a specialized endpoint that triggers a lambda, which in turn verifies the health of other critical resources (e.g. Database, Queue). To keep it simple, we'll just make a request to our API (the root path `/`) and check if it's alive using HTTPS. Here are the Terraform code for it:

```hcl
resource "aws_route53_health_check" "health" {
  count             = "${var.aws_region == "eu-central-1" ? length(var.deploy_hostnames) : 0}" # Only deploy it once
  fqdn              = "${element(var.deploy_hostnames, count.index)}"
  type              = "HTTPS"
  port              = "443"
  resource_path     = "/"  # Make a request to https://api-*.example.com/
  failure_threshold = "5"
  request_interval  = "30"
}
```

This makes a HTTPS call (`type`) to the root path `/` (`resource_path`) every 30 seconds (`request_interval`). AWS will mark this API as dead if the `failure_threshold` is exceeded.
Because the health check is not region specific, to avoid re-creating them when we deploy to multiple regions, we use the `count` hack to make it only run when we deploy to the `eu-central-1` region. When it deploys to `us-east-1` the `count` will be 0 and this block won't run.

One last bit for the global URL setup is the custom domain name. Although we already configured the custom domain name for `https://api-*.example.com`, we didn't setup anything for `https://api.example.com`. When we call the API with `https://api.example.com`, although Route 53 will do the routing to one of the regional endpoint, it will not replace the URL in the HTTPS header to `https://api-*.example.com`, so the API gateway will see a mismatch between the request URL (`https://api.example.com`) and its own custom domain name (`https://api-*.example.com`), thus failing the request. To fix this easily we can add a custom domain name for the global URL:

```hcl
resource "aws_api_gateway_domain_name" "global" {
  # Remember to strip the traling dot
  domain_name = "${replace(var.global_hostname, "/[.]$/", "")}"

  regional_certificate_arn = "${var.regional_certificate_arn}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "global" {
  api_id      = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "${aws_api_gateway_deployment.example.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.global.domain_name}"
}
```

# Testing

Now we are all set! Now deploy the service for both regions and wait for a short while for the DNS record and health check to warm up. To test this setup you can open a browser and go the the global URL `https://api.example.com`. You should be able to see the message "Hello world! I'm in eu-central-1" or "Hello world! I'm in us-east-1" about 50%-50%. If you can only see one region, you can try opening it in an incognito/private tab. You can also disable (or `terraform destroy`) one of the API Gateway in one region and wait for the health check to detect it. Then you'll see all the traffic are routed to the region that is still alive.

# Conclusion

We covered how to create Route 53 load-balancing in Route 53. We first create a hello world API using API Gateway and Lambda. We gave each regional endpoint their own region-specific URL, so it's easier to test and debug. These all have to be created with API gateway custom domains with base path mapping, plus the Route 53 DNS A records. Then we create a global URL CNAME record using Route 53 and let that do weighted routing to our region-specific URLs. Finally we setup health checks to ensure Route 53 is aware of the health of each region, so it can do proper routing in case anyone goes down. All these configurations might be a little be hard to visualize, so it would be helpful to check the AWS web console after you deploy. Or you can try to create this setup manually first using the AWS web console and then compare that to the terraform setup.

[hosted_zone]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html
[a_record]: https://support.dnsimple.com/articles/a-record/
[acm]: https://docs.aws.amazon.com/acm/latest/userguide/setup.html
[arn]: https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
[cloud_front]: https://aws.amazon.com/cloudfront/
[cname]: https://support.dnsimple.com/articles/cname-record/
[domain_name]: https://aws.amazon.com/getting-started/tutorials/get-a-domain/
[geolocation]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-geo
[iam]: https://aws.amazon.com/iam/
[lambda_guide]: https://aws.amazon.com/blogs/compute/building-a-multi-region-serverless-application-with-amazon-api-gateway-and-aws-lambda/
[latency]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-latency
[route53_doc]: https://www.terraform.io/docs/providers/aws/r/route53_record.html
[weighted]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-weighted

