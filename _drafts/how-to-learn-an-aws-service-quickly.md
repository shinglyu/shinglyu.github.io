---
layout: post
title: How to learn an AWS service quickly
categories: Web
date: 2022-07-22 22:29:20 +08:00
excerpt_separator: <!--more-->
---
In my day job, I have to consult customers on AWS services and design architectures on AWS. That means I have to have a basic understanding of almost every AWS service and be ready to dive deep into any of them on short notice. For that, I have a method for learning an AWS service in the most efficient way possible. 
1. Read the product page.
2. Read the product FAQ.
3. Read the concept section(s) of the documentation.
4. Ask yourself key questions about this service.
5. Watch YouTube videos.
6. Follow a hands-on workshop.
7. Dive deeper.

Let's assume that you need to learn AWS Lambda quickly, here is how you would do it:
<!--more-->

## Read the product page

Search for the product page of AWS lambda: [https://aws.amazon.com/lambda/](https://aws.amazon.com/lambda/). These pages usually summarize the unique selling points and features pretty well. They usually also list some use cases and customer cases.

![product page]({{site_url}}/blog_assets/learn_aws/product_page.png)

## Read the FAQ
The product page usually stays relatively high-level and focuses more on the business value. If you want to learn more about the technical details, read the FAQ page: [https://aws.amazon.com/lambda/faqs/](https://aws.amazon.com/lambda/faqs/). Sometimes the FAQ will also compare services that are similar. You can find the list of FAQs [here](https://aws.amazon.com/faqs/).

![FAQ]({{site_url}}/blog_assets/learn_aws/faq.png)

## Read the concept section(s) of the documentation.
Once you have a basic understanding of why you need the service and how it works. You should try to understand the key concepts of the service. For example, for AWS Lambda, you might want to know the following:
* What is a *function*?
* What is a *trigger*?
* What is a *layer*?
* How does *concurrency* work in AWS Lambda?

Usually, you'll find this in the **Concepts** section of the Developer Guide. You can find the developer guide under the **Resources** tab on the product page. 

![resources]({{site_url}}/blog_assets/learn_aws/resources.png)
![concepts]({{site_url}}/blog_assets/learn_aws/concepts.png)

Search for section titles like "What is [service name]", "Concepts", or "Architecture". These sections usually give you a better idea about the key terminologies and architecture to help you understand other materials faster.

Some services that are end-user-facing might have an Administration Guide and a User Guide instead, for example [Amazon WorkSpaces](https://aws.amazon.com/workspaces/resources/?nc=sn&loc=6&workspaces-blogs.sort-by=item.additionalFields.createdDate&workspaces-blogs.sort-order=desc&workspaces-whats-new.sort-by=item.additionalFields.postDateTime&workspaces-whats-new.sort-order=desc). Assuming that you are developing on AWS, the administration guides are usually more relevant.

## Ask yourself key questions about this service
The documentation (e.g. developer guide, administration guide) is usually very long and goes into very trivial details on how to click a certain button on the console, so reading it cover-to-cover is not the most efficient way. Instead, ask yourself questions and try to find the answers in the documentation. Some of the key questions you should consider are:
* How do I interact with this service? Does it provide a web console? Does it have an API, CLI, or SDK? Does it support industrial standard protocol/interface like JDBC, MQTT, OPC-UA, etc?
* How does it fit into my architecture? Does it integrate with other AWS services or my on-prem system?
* Do I need to manage the underlying infrastructure? Is it fully serverless or do I have to manage the underlying cluster/node?
* What is the pricing model? There is usually a [**Pricing** tab](https://aws.amazon.com/lambda/pricing/) on the product page.
![pricing]({{site_url}}/blog_assets/learn_aws/pricing.png)
* What are the limitations of the service? Is there a maximum throughput/API rate limit? Is there a payload size limit? Is there a limit on the number of resources you can create per AZ/region/account? Are they soft limits (meaning you can increase the limit by talking to AWS support) or hard limits? There is usually a section called "[Service name] Quotas" in the Developer Guide, for example [Lambda Quotas](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html).

## Watch YouTube videos
There are talks about a particular AWS service on YouTube. They are recordings from [AWS re:Invent](https://reinvent.awsevents.com/), [AWS Summit](https://aws.amazon.com/events/summits/) or other events. These talks are usually 30 minutes to an hour long and give a good overview of the service. Most of the time, they also include a short demo and go into the internal architecture of the system. You can find links to these videos in the [**Resources** tab](https://aws.amazon.com/lambda/resources/?aws-lambda-resources-blog.sort-by=item.additionalFields.createdDate&aws-lambda-resources-blog.sort-order=desc) of the product page. For example for AWS Lambda, you can see a **Technical talks** section on that page. Or just search on YouTube and look for the one published by official AWS accounts.

Once you finish the introductory talks, look for video titles like "deep dive", "best practices", or "patterns". These videos will give you more insight into how the service is designed and give you best practices on scaling, resiliency, cost optimization, and security.

## Follow a hands-on workshop

Once you have the theoretical knowledge, it's time to get your hands dirty. You can find a hands-on workshop at [https://workshops.aws/](https://workshops.aws/). Sometimes there will be [public events](https://aws.amazon.com/events/) in which an instructor will walk you through the workshops. But most of them can be run as self-paced workshops. Following the step-by-step hands-on workshop will help you learn the service by actually using it. For example, you can find several workshops on AWS Lambda [here](https://workshops.aws/card/serverless?tag=Lambda).
![workshops]({{site_url}}/blog_assets/learn_aws/workshops.png)

## Dive deeper
Once you have done all the above, you should already have a good understanding of the service. There are many more ways you can dive deep into the service, and most of them are listed on the [**Resources** page](https://aws.amazon.com/lambda/resources/). These resources include, but are not limited to:

* Whitepapers
* Tutorials and blogs
* Reference architectures
* Free/paid training on [AWS Skill Builder](https://explore.skillbuilder.aws/learn)
* Academic papers
* Online courses on 3rd-party platforms, e.g. Coursera, edX, ACloudGuru, Whizlabs, Udemy, etc. 

By following this method, you should be able to learn an AWS quickly. Happy learning!





