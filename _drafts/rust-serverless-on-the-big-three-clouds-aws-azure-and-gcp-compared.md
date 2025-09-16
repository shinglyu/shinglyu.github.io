---
layout: post
title: Rust Serverless on the Big Three Clouds: AWS, Azure, and GCP Compared
categories: Web
date: 2025-09-15 14:39:00 +02:00
excerpt_separator: <!--more-->
---

When you're choosing a cloud platform for your next Rust serverless project, the landscape can be confusing. Each of the big three cloud providers—AWS, Azure, and Google Cloud Platform—offers different levels of maturity and support for Rust in serverless environments. I've spent some time experimenting with two platforms (more on why I'm missing one later), and the differences are more significant than you might expect.

Why does this comparison matter? Rust brings compelling advantages to serverless computing: it runs with low resource requirements and delivers high performance, which translates to improved performance and lower cloud costs. Additionally, Rust eliminates many bugs during compile time, so your code is less like a ticking time bomb that will break during runtime. This means less late night on-call madness and happier developers.


## What I Mean by "Serverless"

Before diving into the comparison, let me clarify what I mean by "serverless" in this context. Many cloud providers give vague definitions, so here's my own practical definition that guided this evaluation.

<!--more-->

True serverless means **pay-as-you-go pricing** where you only pay for what you use, not for idle time. Hourly pricing but with scaling to zero counts as serverless, but less ideal than the per milisecond pricing while the code executes. For programming model, I'm looking at **function-as-a-service** rather than containers. While you can theoretically do anything in containers, in my experience, when you go with containers, developers are easily distracted by all the technical details of how containers work, and they're not focusing on the business logic itself. In that case, you might be better off chasing the hype of full-scale Kubernetes clusters instead. At least your CV looks nicer that way.

For the comparsion, I'm focusing specifically on building REST APIs because this is one of the most common use cases. There are other domains like batch processing on events and data analytics like ETL pipelines, but these use different kinds of code libraries, so I'm not discussing them here. For supporting services like databases, I prefer fully-managed, cloud-native options like DynamoDB or CosmosDB.

## TL;DR: AWS Wins, Azure Struggles, GCP Doesn't Support It

If you're in a hurry, here's the bottom line: AWS has the most mature, generally available SDK for Rust with good tooling around running Rust on Lambda. Azure has a beta SDK that's immature and changes rapidly, and Azure Functions aren't really serverless. GCP doesn't support Rust in Cloud Functions—its FaaS option—and most documentation points to Cloud Run, which is container-based.

## AWS Lambda: The Clear Leader

The reference architecture I tested was API Gateway → Lambda → DynamoDB, which represents a typical serverless web API setup.

AWS stands out because the [AWS SDK for Rust became generally available](https://aws.amazon.com/blogs/developer/announcing-general-availability-of-the-aws-sdk-for-rust/) on November 27, 2023. However, people were experimenting with it much earlier—I wrote about building serverless Rust on AWS in the first edition of my book, [Practical Rust Web Projects](https://www.amazon.com/Practical-Rust-Web-Projects-Building/dp/1484265888), back in 2021.

I had the privilege to work with pioneers like [Russell Cohen](https://github.com/rcoh), who built the AWS Rust SDK, and [Nicolas Moutschen](https://nmoutschen.com/articles/2020/rust-for-serverless-applications/), who wrote extensively about Rust for serverless applications as early as 2020. Their work created a solid foundation with excellent [documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-rust.html) and comprehensive tool support.

The ecosystem includes several key libraries that make Rust on Lambda practical:

- **Cargo Lambda**: A command-line application for working with Lambda functions built with Rust
- **lambda-runtime**: A library that provides a Lambda runtime for applications written in Rust
- **lambda-http**: A library that makes it easy to write API Gateway proxy event-focused Lambda functions in Rust
- **lambda-extension**: A library that makes it easy to write Lambda Runtime Extensions in Rust
- **lambda-events**: A library with strongly-typed Lambda event structs in Rust
- **lambda-runtime-api-client**: A shared library between the lambda runtime and lambda extension libraries that includes a common API client to talk with the AWS Lambda Runtime API

Real companies are using Rust on Lambda in production. [Daniele Frasca](https://www.linkedin.com/in/daniele-frasca/) talked about significant performance improvements and cost savings at [AWS Community Day NL 2022](https://www.old.awscommunityday.nl/rooms/postwagon-2/).

While Rust still doesn't get the first-class citizen treatment like Python or JavaScript from AWS, it's definitely usable in production and has a growing community around it.

## Azure Functions: Promising but Not Ready

The reference architecture I tested was API Management → Azure Functions → CosmosDB. Unfortunately, my experience with Azure was frustrating due to the platform's immaturity.

### SDK Immaturity and Breaking Changes

The [Azure SDK for Rust is only in beta](https://devblogs.microsoft.com/azure-sdk/rust-in-time-announcing-the-azure-sdk-for-rust-beta/) as of February 2025, with only a [hello world example in the documentation](https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-other?tabs=go%2Clinux). Its GitHub repo was [created in January 2017](https://github.com/Azure/azure-sdk-for-rust/commits/main/?since=2017-01-01&until=2017-01-31) but it's still in beta after 10 years. Breaking changes are still common, and I encountered several significant issues.

**Example 1: Rustls Support Nightmare**

When cross-compiling to the linux-musl target for Azure Functions (see my [previous post](https://shinglyu.com/web/2025/07/26/serverless-rust-on-azure-deploying-a-rust-azure-function.html#5-prepare-for-azure-deployment) on why this is needed), the azure_core SDK crate implicitly uses the `reqwest` crate, which defaults to system OpenSSL. Cross-compiling on Ubuntu fails due to missing OpenSSL library headers, so I tried switching to rustls (a pure Rust TLS implementation) for cleaner compilation.

This required disabling default features when using `azure_core`, the core library in the Azure Rust SDK, and manually configuring my own reqwest crate with rustls enabled in azure_core 0.27. However, when importing other crates like `azure_data_cosmosdb` (CosmosDB client) or `azure_identity` (for RBAC identity), they each have their own way of enabling/disabling TLS.

I had to dig through multiple GitHub issues and PRs to understand why: [#2750](https://github.com/Azure/azure-sdk-for-rust/issues/2750), [#2796](https://github.com/Azure/azure-sdk-for-rust/issues/2796), and [#2550](https://github.com/Azure/azure-sdk-for-rust/issues/2550). I even filed a [PR to fix this](https://github.com/Azure/azure-sdk-for-rust/pull/2967), only to be informed by the maintainer that it was already fixed and would be released in the next minor version. 

**Example 2: Silent Breaking Changes**

To fix the rustls issue mentioned above, I checked out the Azure Rust SDK code to my laptop and and point my Cargo.toml to the local copy (which is the not-yet-published 0.28.0), but my code breaks because `DefaultAzureCredential` was [renamed to `DeveloperToolsCredential`](https://github.com/Azure/azure-sdk-for-rust/pull/2873). I had to dig through pull requests to understand what happened. There's no official announcement channel for such significant changes—only bare minimum (and usually outdated) crate documentation.

### Confusing Hosting Plans

Azure Functions offers [five hosting plans](https://learn.microsoft.com/en-us/azure/azure-functions/functions-scale), and they're confusing:

- **Container Apps**: Runs containers, so out of scope for our FaaS discussion
- **Dedicated Plan** and **Premium Plan**: VM-based always-on pricing that can't scale to zero, also out of scope. Confusingly, the Dedicated plan is called "App Service" in the Azure Portal, and the Premium plan is called "Functions Premium"
- **Flex Consumption Plan**: Looks most similar to AWS Lambda but doesn't support custom handlers, so you can't run Rust
- **Consumption Plan**: The only viable option, but it's problematic

### The Consumption Plan Problems

The Consumption Plan appears to offer pay-as-you-go pricing, but Azure leaks its implementation details everywhere. After creating a Consumption Plan Azure Function App, the portal shows it has an App Service Plan (which is suppose to be only for Dedicated Paln or Premium Plan) with a cryptic `Y1` SKU (meaning consumption plan).

If you expect per-function isolation, you'll be disappointed. Running a consumption plan function app consumes 1 VM quota for that region. Configuration changes require restarting the whole VM, causing downtime for all functions.

Most concerning, I'm hitting an issue where bugs in Rust code bring down the entire Azure Function App host. I see "Function host is not running" and all functions cannot respond to requests. That's why the next iteration of my Azure blog series isn't ready yet.

### Incomplete Features

Features aren't complete either. For example, the CosmosDB documentation states:

> NOTE: Currently, the Azure Cosmos DB SDK for Rust only supports single-partition querying. Cross-partition queries may be supported in the future.

But in my testing, it seems to work already. This inconsistency doesn't inspire confidence.

### Not Fully FaaS

You're still building a full Warp web server that runs on the Azure Function host. As I detailed in [my previous post about the "One-Binary, Multiple-Functions Model"](https://shinglyu.com/web/2025/08/10/building-a-database-backed-api-with-serverless-rust-on-azure.html), you're essentially building a full web server on a VM with a black-box Function Host proxying your requests.

This creates uncertainty and makes it harder for humans and GenAI to reason about your architecture, because most AI agents haven't seen enough examples of such setup, and documentation and code examples are also sparse. I had to spend extra effort to "teach" the AI to code it in a way that Azure Function accepts. 

Conclusion: Azure Functions is not ready for production Rust workloads. But once the SDK stablize, and you are happy with the VM-style implementation, it has the potential to become a viable option.

## Google Cloud Platform: Rust Not Supported

GCP's situation is straightforward but disappointing: Cloud Run Functions [don't support Rust](https://cloud.google.com/run/docs/runtimes/function-runtimes), nor custom runtimes. The platform pushes you toward Cloud Run, which is container-based and therefore not serverless by my definition. Cloud Run has a ["deploy from source code"](https://cloud.google.com/run/docs/deploying-source-code) option, which use GCP's buildpacks to automatically detect the language you are using the build the container for you, but sadly it also don't support Rust.

Interestingly, Google released a [GA version (v1.0.0) of their Rust SDK](https://cloud.google.com/blog/topics/developers-practitioners/now-available-rust-sdk-for-google-cloud) on September 10, 2025. The GitHub repository was [created in October 2024](https://github.com/googleapis/google-cloud-rust/commits/main/?since=2024-10-01&until=2024-10-31), making it the last one of the three clouds to make a Rust SDK public, but it reaches general availability ealier than Azure. While I might experiment with Cloud Run later to evaluate the SDK's maturity, it doesn't meet the serverless criteria for this comparison.

For now, GCP simply isn't in the serverless (more specifically, FaaS) Rust game.

## Honorary Mention: Cloudflare Workers

While not one of the "big three," Cloudflare Workers deserves mention. The platform [supports Rust through the workers-rs crate](https://developers.cloudflare.com/workers/languages/rust/) and follows a true serverless model. The crate is [announced on September 9, 2021](https://blog.cloudflare.com/workers-rust-sdk/).  Cloudflare choose to compile the Rust to WebAssembly, which impose certain limits on the supported features (e.g. Async not supported), but probably make it easier for them to support new languages in the future.  The reference architecture would be [Workers → KV storage](https://developers.cloudflare.com/reference-architecture/diagrams/serverless/serverless-global-apis/).

Although I haven't thoroughly tested it yet, Cloudflare Workers looks promising and will be my next experiment while waiting for Azure's blockers to be resolved.

## Comparison Summary

| Platform | SDK Status | Rust Support | True Serverless | Production Ready | Developer Experience |
|----------|------------|--------------|-----------------|------------------|---------------------|
| AWS Lambda | GA (Nov 2023) | Excellent | ✓ | ✓ | Excellent documentation, mature tooling |
| Azure Functions | Beta (Feb 2025) | Limited | ✗ | ✗ | Breaking changes, incomplete features |
| GCP Cloud Functions | GA (Sep 2025) | None | N/A | N/A | N/A |
| Cloudflare Workers | Community | Good | ✓ | Likely | Promising but untested |

**Developer Experience**: AWS provides the best documentation, tooling, and community support. Azure's experience is hampered by frequent breaking changes and incomplete features. GCP simply doesn't participate in this space yet.

**Maturity**: AWS has the most mature platform with real production deployments. Azure is still in beta with significant stability issues. GCP's Rust SDK is the newest (September 2025) but doesn't apply to their FaaS offering.

**Pricing**: AWS Lambda's pay-per-invocation model aligns perfectly with serverless principles. Azure's Consumption Plan appears similar but lacks the isolation and reliability you'd expect due to its VM-based implementation.

**Performance**: Since only AWS is truly usable for production Rust serverless applications, performance comparisons aren't meaningful at this stage.

## Final Recommendations

If you're building a Rust serverless API today, AWS Lambda is your best bet. The platform offers mature tooling, a stable SDK, and proven production use cases. The community is active, and the documentation is comprehensive.

Azure Functions might become viable in the future, but the current beta SDK and platform limitations make it unsuitable for production workloads. The frequent breaking changes and lack of proper function isolation are particularly concerning.

Google Cloud Platform isn't really in the game yet for true serverless Rust development. While their new SDK might be worth watching, the lack of Rust support in Cloud Functions means you'll need to compromise on the serverless model.

Looking ahead, keep an eye on Cloudflare Workers as a potential alternative. Their approach to edge computing and true pay-per-use pricing could make them a compelling option as their Rust support matures.