---
layout: post
title: Caveats in Terraforming WAF V2 for CloudFront
categories: micro 
date: 2020-06-23 20:55:16 +02:00
---

If you want to add a WAF V2 ([`aws_wafv2_web_acl`][wafv2]) to a CloudFront distribution ([`aws_cloudfront_distribution`][cloudfront]) using Terraform, there are a few caveats:

* On `aws_wafv2_web_acl`:
  * Use `scope = "CLOUDFRONT"`.
  * Use the AWS provider in us-east-1 region. (Although in the AWS Console it will still be listed under "Global".)

* On `aws_cloudfront_distribution`:
  * You can use `web_acl_id - aws_wafv2_web_acl.<name>.arn`. Be careful that even though the name is `id`, but you need to pass the ARN instead. This [bug][bug] only happens in V2.
  * The IAM user/role you use to execute `terraform apply` must have the `waf:GetWebACL` permission.

[wafv2]: https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html
[cloudfront]: https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
[bug]: https://github.com/terraform-providers/terraform-provider-aws/issues/13902

