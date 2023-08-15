---
layout: post
title: Introducing the llm-chain-mock Driver for Cost-Effective LLM Testing
categories: Web
date: 2023-08-15 22:51:15 +02:00
excerpt_separator: <!--more-->
---
[Llm-chain][llm-chain] is a Rust crate that help you create advanced LLM applications such as chatbots, agents, and more. It supports various drivers, such as [OpenAI][llm-chain-openai], [llama.cpp][llm-chain-llama], and [llm][llm-chain-local], that can connect to different APIs or run models locally. llm-chain allows you to easily switch between different drivers and options without a complete rewrite of your code.

One of the challenges of using llm-chain is the cost associated with invoking the LLMs. Depending on the driver you use, you may incur either an API fee or a compute resource cost for running your own model. The local models usually requires pretty powerful machines, and the setup process might be a little complicated.

<!--more-->

## Introduce the llm-chain-mock driver

To help you test your llm-chain without running a real model, I have contributed a new driver called [llm-chain-mock][llm-chain-mock]. This driver does not generate any text at all. It only echos your prompt and parameters back to you. It follows the `executor` API used by other drivers and allows you to test other parts of your chain without incurring any cost.

The llm-chain-mock driver is useful for debugging and prototyping purposes. You can use it to check if your prompt is formatted correctly, if your options are valid, if your chain logic is working as expected, etc. You can also use it to measure the performance overhead of your chain without being affected by the network latency or the model complexity.

Here is a simple example of how to use the llm-chain-mock driver to generate text using a mock model. You can find the most up to date version of this example on [GitHub][github-demo].

```rust
use llm_chain::executor;
use llm_chain::options::Options;
use std::{env::args, error::Error};

use llm_chain::{prompt::Data, traits::Executor};

extern crate llm_chain_mock;

/// This example demonstrates how to use the llm-chain-mock crate to generate text using a mock model.
///
/// Usage: cargo run --release --package llm-chain-mock --example simple
///
#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn Error>> {
    let raw_args: Vec<String> = args().collect();
    let prompt = match &raw_args.len() {
      1 => "Rust is a cool programming language because",
      2 => raw_args[1].as_str(),
      _ => panic!("Usage: cargo run --release --example simple")
    };

    let exec = executor!(mock)?;
    let res = exec
        .execute(Options::empty(), &Data::Text(String::from(prompt)))
        .await?;

    println!("{}", res);
    Ok(())
}
```

If you run this example with no arguments, the example code will use a default prompt "Rust is a cool programming language because".

You should see this output:

```
As a mock large language model, I'm here to help you debug. I have recieved your prompt: "Rust is a cool programming language because" with options "Options { opts: [] }"
```

As you can see, the mock driver simply returns your prompt in a fixed template. 

I hope that this new driver will help you develop and test your llm-chain more easily and efficiently. If you have any feedback or suggestions, please let me know on [GitHub][llm-chain].

[llm-chain]: https://github.com/sobelio/llm-chain
[llm-chain-openai]: https://github.com/sobelio/llm-chain/tree/main/crates/llm-chain-openai
[llm-chain-llama]: https://github.com/sobelio/llm-chain/tree/main/crates/llm-chain-llama
[llm-chain-local]: https://github.com/sobelio/llm-chain/tree/main/crates/llm-chain-local
[llm-chain-mock]: https://github.com/sobelio/llm-chain/tree/main/crates/llm-chain-mock
[github-demo]: https://github.com/sobelio/llm-chain/blob/main/crates/llm-chain-mock/examples/simple.rs
