---
layout: post
title: How to create your own private LLM using only AWS CLI
categories: Web
date: 2023-07-03 21:45:51 +02:00
excerpt_separator: <!--more-->
---

In this blog post, I will show you how to use AWS CLI and SageMaker JumpStart to create your own private large language model (LLM) on Amazon SageMaker. You will learn how to deploy a pretrained model from the Hugging Face Transformers library, and how to use it to generate text with custom instructions using AWS CLI.
<!--more-->
## Why privacy is important and how you can have your own LLM on SageMaker
Privacy is a key concern for many users of LLMs, especially when they want to generate text from sensitive or personal data. For example, you may want to write a summary of your medical records, or a creative story based on your own experiences. In these cases, you may not want to share your data or your generated text with anyone else.

One way to ensure privacy is to have your own LLM that runs on your own infrastructure. However, this can be costly and complex, as you need to have enough compute and storage resources to train and deploy a large model. You also need to have the expertise and time to fine-tune and optimize the model for your specific use case.

SageMaker JumpStart simplifies this process by providing pretrained, open-source models for a wide range of problem types. You can incrementally train and tune these models before deployment, using your own data and hyperparameters. You can also access solution templates that set up infrastructure for common use cases, and executable example notebooks for machine learning with SageMaker.

In this tutorial, we will use SageMaker JumpStart to deploy a pretrained model from the Hugging Face Transformers library, which provides state-of-the-art models for natural language processing tasks. We will use the [`falcon-40b-instruct`](https://huggingface.co/tiiuae/falcon-40b-instruct) model, which is a 40-billion parameter model that can generate text with custom instructions.

## Why AWS CLI
Later in the post, we'll use AWS CLI as the main chat interface. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) is a command-line tool that allows you to interact with AWS services from your terminal. It has several advantages over other methods, such as:

* You probably have it installed already if you are using AWS.
* No need to worry about packaging and distribution. AWS CLI handles the details of sending requests and receiving responses from AWS services. You don’t need to write any code or use any libraries to access AWS features.
* No need to handle authentication and authorization. AWS CLI uses your credentials and configuration files to authenticate and authorize your requests. You don't have to expose your LLM API to the internet and handle authentication in your code.
* No need to launch the whole SageMaker Studio environment and notebooks.
* You can use pipes to interact with other command-line tools.

The downside is that it's hard to handle things like memory as in LangChain or other libraries. But if your use case is mostly one-off commands like summarizing and article or write an email draft, it's probably enough.

## Deploying the LLM as a SageMaker Endpoint
To deploy the `falcon-40b-instruct` model using SageMaker JumpStart, you need to have an AWS account with permissions to access SageMaker and other AWS services. You also need to have [SageMaker Studio](https://docs.aws.amazon.com/sagemaker/latest/dg/studio.html) set up and running on your account.

The following steps show how to deploy the model using SageMaker Studio:

* Open SageMaker Studio
* On the left-side panel, click on the Home menu and choose Quick start solutions.
* On the JumpStart landing page, use the search bar to find the `falcon-40b-instruct` model, or browse the Hugging Face category to locate it.
* Click on the Deploy button at the top right of the page. You will see a dialog box that asks you to choose an instance type and a number of instances for your endpoint. The model requires ml.g5.24xlarge instance, which might require a quota increase before you use.
* It might take a few minutes for the model to be deployed. Once the endpoint status is InService, you can start using it to generate text with custom instructions, which we'll discuss next.
For more information about how to use SageMaker JumpStart models, see [SageMaker JumpStart documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jumpstart.html).

## Use the AWS CLI to interact with the LLM
To interact with the LLM, you can use the script provided below. This script takes a text input as an argument, and sends it to the endpoint as a JSON payload. It then prints the generated text to the terminal.

To use the script, you need to have [jq](https://jqlang.github.io/jq/) installed on your machine. You also need to have AWS CLI configured with your credentials and region. This is tested on a MacOS machine, some of the command-line tool implementation might be different for Linux.

The script is as follows:
```bash
#! /usr/bin/env bash
PAYLOAD="
{
  \"inputs\": \""${1}"\",
  \"parameters\": {
    \"do_sample\": true,
    \"top_p\": 0.9,
    \"temperature\": 0.8,
    \"max_new_tokens\":1024,
    \"stop\":[\"<|endoftext|>\", \"</s>\"]
  }
}
"

echo "${PAYLOAD}" | base64 > /tmp/input.json.base64

aws sagemaker-runtime invoke-endpoint\
  --no-cli-pager\
  --endpoint-name "falcon-40b-instruct"\
  --content-type "application/json"\
  --body file:///tmp/input.json.base64\
  /tmp/output.json

echo "Question: ${1}"
echo "Answer:"
echo "+============+"
cat /tmp/output.json ja -r '.[0].generated_text'
echo "+============+"

rm /tmp/input.json.base64
rm /tmp/output.json
```

Let's break down the script and explain what we are doing:

* `PAYLOAD="..."`: This defines a variable called PAYLOAD that contains the JSON payload to send to the endpoint. The payload has two fields: inputs and parameters. The inputs field is the text input that you want to generate text from, and the parameters field is a set of options that control the text generation process. For example, you can specify the sampling method, the temperature, the maximum number of tokens to generate, and the stop tokens that indicate the end of the text. This is highly-dependant on the model, so you need to adjust it if you are using a different model
* `echo "${PAYLOAD}" | base64 > /tmp/input.json.base64`: This encodes the payload as base64 and writes it to a temporary file called `/tmp/input.json.base64`. This is necessary because the endpoint expects a base64-encoded payload as the body of the request.
* `aws sagemaker-runtime invoke-endpoint...`: This invokes the endpoint with the specified name, content type, and body. It also writes the response to a temporary file called `/tmp/output.json`. 
* The next few `echo`s print a easy to read format.
* `cat /tmp/output.json ja -r '.[0].generated_text'`: This reads the response file and uses jq to extract the first generated text from the list. It then prints it to the standard output.
* Finally, we delete the temporary files.

Now, if you invoke the script like so:
```
$ ./invoke.sh "Will AI destroy humanity?"
```

It will generate something like:
```
{ ...(AWS CLI response) }
Question: Will AI destroy humanity?
Answer:
+============+
As an AI language model, I cannot predict the future. However, AI has the potential to create a positive impact on socity, such as improving healthcare, education and sustainability. It is up to humans to ensure that AI is used ethically and responsibly.
+============+
```

## Saving cost
The model uses ml.g4.24xlarge instance, which costs $12.73 per hour in Frankfurt region at the time of writing. To save cost, you can try the smaller `falcon-7b-instruct` model, which requires a smaller instance type. Or you can use [sagemaker-auto-shutdown](https://github.com/aws-samples/sagemaker-auto-shutdown), which can automatically delete your instance on a schedule, so you can, for example, auto-delete the instance during non-office-hours.

## Conclusion
In this blog post, you learned how to use AWS CLI and SageMaker JumpStart to create your own private LLM on Amazon SageMaker. You deployed the `falcon-40b-instruct` model from the Hugging Face Transformers library, and used a script to generate text with custom instructions. You can use this approach to create your own LLM applications with privacy and flexibility.

*Disclaimer: this post is written with the help from generative AI, this is an experiment*
