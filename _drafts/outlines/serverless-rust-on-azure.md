* This is the first post a my new series severless rust on Azure
* We start simple by following the Azure tutorial  https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-other?tabs=rust%2Clinux, with my notes on the caveats an tweks I've made
* I have been doing AWS for the past 6 years, so I'll be hihglight the difference from lambda 
* You can find the code on github: https://github.com/shinglyu/serverless-rust-on-azure
* Short motivation: why rust on serverless
    * General benefits:
        * Rust provides strong compile-time guarantees for memory safety, type safety, and thread safety, preventing common bugs like null pointer dereferences, data races, and buffer overflows without needing a garbage collector.

        * These safety guarantees are enforced by concepts like ownership, borrowing, and the borrow checker, which statically verify correct use of memory and concurrency before runtime, giving developers confidence in code correctness and security.

        * Rust clearly separates Safe Rust, which enforces these guarantees, from Unsafe Rust, which allows manual low-level control but is explicitly marked and isolated, making unsafe operations traceable and minimizing risk to the overall program safety
    * Fast cold starts: Rust compiles to native code with no runtime or garbage collector, enabling cold start times as low as 50–75 ms, much faster than interpreted languages like Python or JavaScript.

    * Low memory usage: Rust's efficient use of memory reduces resource consumption, lowering serverless execution costs and making it ideal for resource-constrained environments.

    * High performance: Near-native execution speed improves throughput and reduces execution time, which directly cuts serverless billing costs based on compute duration.

    * Memory safety: Rust’s compile-time ownership and borrowing system eliminates many runtime bugs and security vulnerabilities, crucial for serverless functions processing untrusted input.

    * Small, compact binaries: Rust produces tiny deployment artifacts, enabling faster uploads, less cold start overhead, and compatibility with restrictive platforms like Lambda@Edge.

    * Async-first concurrency support: Rust’s async/await syntax and modern runtimes efficiently handle simultaneous events, optimizing serverless concurrency models.

    * Incremental migration: Serverless architecture promotes modular, small functions—Rust's interoperability allows rewriting individual functions incrementally without large-scale rewrites.

    * Sustainability and cost efficiency: By reducing compute and memory consumption, Rust aligns well with green computing goals in pay-per-use serverless environments.

    * Good tooling support: Tools like cargo-lambda streamline building, deploying, and debugging Rust-based serverless functions, improving developer experience.

    * Compatibility with containers and WASI: Rust works well in containerized serverless platforms and emerging lightweight WebAssembly runtimes, broadening deployment options.

* **Prerequisites and Setup**
    * Install Azure Functions extension on VSCode
    * Using Rustc 1.88.0 (specify version for consistency)
    * Install Azure Function Core Tools for local testing
        * Follow this [guide](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=linux%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-python)
        * On Ubuntu: Add apt repository and install with `apt install`

* **Creating Your First Function (Tutorial Steps)**
    1. **Create local project**: Use VS Code command palette to create new Azure Functions project
        * Select "Custom Handler" as language
            * Explain what custom handler is, and mention it can also support go
        * Choose "HTTP trigger" template
        * Name function "HelloRust"
        * Set authorization level to "Anonymous"
    
    2. **Create and build the function code**:
        * Initialize Rust project: `cargo init --name handler`
        * Add dependencies to Cargo.toml (warp, tokio)
        * Write the Rust handler code in src/main.rs
            * This is basically a simple HTTP server using Warp framework
            * **Critical caveat**: Need to change the `wrap_path()` path in the example code to match `/api/HelloRust` name
        * Build the binary: `cargo build --release`
        * Copy handler to project root: `cp target/release/handler .` so the Azure Function extension can find it and deploy it correctly later
    
    3. **Configure function app**:
        * Update host.json with custom handler settings
        * Set defaultExecutablePath to "handler"
        * Enable enableForwardingHttpRequest: true
            * Explain what this is
    
    4. **Test locally**:
        * To use the `func` tool for testing Azure Functions locally, you need Azure Function Core Tools
        * **Common error fix**: If you get "The value of version property in extensionBundle section of host.json file is invalid or missing"
            * Add the version number for the `extensionBundle` setting in `host.json`:
                ```json
                "extensionBundle": {
                    "id": "Microsoft.Azure.Functions.ExtensionBundle",
                    "version": "[4.0.0, 5.0.0)"
                },
                ```
        * Test locally with `func start`
        * Verify with curl:
            ```bash
            curl http://localhost:7071/api/HelloRust\?name\=Shing -v
            ```
        * Expected output:
            ```
            HTTP/1.1 200 OK
            Content-Length: 65
            Date: Mon, 21 Jul 2025 14:45:46 GMT
            Server: Kestrel
            
            Hello, Shing. This HTTP triggered function executed successfully.
            ```
    
    5. **Prepare for Azure deployment**:
        * Compile for Linux target: `rustup target add x86_64-unknown-linux-musl`
            * I'm already on linux, but my default is stable-x86_64-unkonwn-linux-gnu, 
            * Using the musl target produces statically linked binaries that run on virtually any Linux system, avoiding issues with missing or incompatible system libraries. In contrast, the unknown-linux-gnu (glibc) target often results in dynamically linked binaries that may require compatible versions of glibc on the host, limiting portability.
        * Build for Linux: `cargo build --release --target=x86_64-unknown-linux-musl`
        * Configure .cargo/config for cross-compilation
        * **Linker issues**: If your linker `ld` is set to linuxbrew's linker, use the system one instead:
            ```bash
            export PATH="/usr/bin:$PATH"
            cargo build
            ```
        * Update .funcignore to exclude target folder
    
    6. **Deploy to Azure**:
        * Sign in to Azure via VS Code
        * Create function app in Azure (Premium plan, Linux, Custom handler)
            * The tutorial suggest premium hosting plan, but it's not actually serverless because you pay for the underlying instance by hour. I don't need the advanced features like pre-warmed instances and auto scaling for this hello world example, so I chose the app service plan (a.k.a. dedicated plan in the documentation) instead. 
            * Explain the hierarchy of Function App > App, and the underlying App Service Plan 
                * Draw a mermaid diagram showing this
                * An Azure Function App is a container or unit of deployment and management in Azure Functions. Within a Function App, you can have multiple individual functions—each a small piece of code triggered by different events like HTTP requests, timers, or messages.

                * These multiple functions inside one Function App share the same compute resources and configuration, making deployment and scaling easier to manage collectively.

                * Underneath the Function App, there is an underlying infrastructure called the App Service Plan (if you use a Dedicated or Premium plan). The App Service Plan represents a set of compute resources (VM instances with CPU, memory, networking) that run your apps, including Function Apps and Web Apps.

                * This infrastructure has instances (virtual machines) allocated to it. Your Function App runs on these instances, sharing those resources with other apps that might be in the same App Service Plan. You pay for these instances based on their size and count, regardless of how many functions run inside your Function App.
                * Mention that to match AWS Lambda pricing model you should use consumption plan
                * Flex consumption plan don't support custom handler, so no Rust
        * Function App settings used in the example:
            * Name: hello-rust
            * Runtime stack: custom
            * Operating System: Linux
            * SKU: Basic
            * Memory: 1.75 GB
            * Storage account: Auto-generated 
            * Hosting plan: App Service
            * Basic authentication: Disabled
            * Application Insights: Not enabled
        * Deploy project to function app by opening the command palette and run deploy
        * Test the function in the Azure portal
    
* **What's next**
    * **Use cases to explore:**
        * API with CosmosDB
            * API versioning patterns
        * Blob storage (e.g. image upload) - Shows SDK usage
        * Blob event trigger (e.g. image compression)
        * Timer triggers for scheduled tasks
        * Complex event driven architectures: queues, durable functions
        * Rust frontend hosted on Azure Blob + CDN
            * CORS configuration
    
    * **Non-functional requirements:**
        * **Observability**: logging, metrics, tracing
        * **Scaling**: auto-scaling strategies and considerations
        * **Security**: 
            * API authentication mechanisms
            * HTTPS enforcement
            * Secret handling in Key Vault
            * Blocking direct Function App access by requiring function keys from API Management
        * **CI/CD**: GitHub Actions, blue/green deployment and rollbacks
        * **Cold start measurement** and optimization techniques
        * **Disaster Recovery**:
            * Multi-region API Management
            * Traffic Manager for multi-region failover
            * CosmosDB multiple write regions
