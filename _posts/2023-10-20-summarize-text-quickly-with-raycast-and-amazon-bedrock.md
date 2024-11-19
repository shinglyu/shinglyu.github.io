---
layout: post
title: Summarize Text Quickly with Raycast and Amazon Bedrock
categories: Web
date: 2023-10-20 21:47:37 +02:00
excerpt_separator: <!--more-->
---
[Raycast][raycast] has become an indispensable tool in my workflow. The ability to quickly automate tasks and create custom integrations boosts my productivity daily. One common need I have is getting key summaries from long blocks of text. For example, summarize a long blog article I'm too lazy to read. Or quickly understand what is going on based on a long email thread. While there are pre-built Raycast AI extensions, I prefer to use [Amazon Bedrock][amazon-bedrock] for privacy and security. 

In the past, I used to copy the text and paste it into an AI chatbot, but this context switching was cumbersome and interrupted my flow. Raycast is a more natural way to summarize a piece of text I just copied. 
<!--more-->

## Creating a Raycast Script Command
Here are the key steps I followed to create the summarization script in Raycast:

1. Open Raycast and search for "Create Script Command"
2. Select "Python" as the language
3. Give the script a title "Summarize text with Bedrock"

A script will be created and here is what I wrote:

```python
#!/Users/shinglyu/.pyenv/versions/3.11.4/bin/python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Summarize text with Bedrock
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Text to be summarized" }

# Documentation:
# @raycast.description Summarize text with Bedrock
# @raycast.author Shing Lyu
# @raycast.authorURL https://shinglyu.com

import sys
import boto3
import json

client = boto3.client('bedrock-runtime', region_name='us-east-1')
prompt = f"""

Human: Summarize the following text:
---
{sys.argv[1]}
---

Assistant:"""

try:
    response = client.invoke_model(
        body = bytes(json.dumps({
            "prompt": prompt,
            "max_tokens_to_sample": 2048,
            "temperature": 1.0,
            "top_k": 250,
            "top_p": 1,
            "stop_sequences": [
            "\\n\\nHuman:"
            ],
            "anthropic_version": "bedrock-2023-05-31"
        }), 'utf-8'),
        modelId = "anthropic.claude-v2",
        # modelId = "anthropic.claude-instant-v1",
        contentType = "application/json",
        accept = "application/json"
    )
    response_text = response['body'].read().decode('utf8').strip()
    response_json = json.loads(response_text)
    completion = response_json['completion']
    print('\033[97;40m' + completion + '\033[0m')
except Exception as e:
    print('Error invoking endpoint')
    print(e)
    sys.exit(1)
```

## Using pyenv for Isolation
I use pyenv to manage my Python versions. By default Raycast points to the system python version so it won't have the packages I need.

I set 3.11.4 as the pyenv global version:

```bash
pyenv global 3.11.4
```
With this set, I could install packages globally:

```bash
pip install boto3
```

Then, I changed the shebang to point to pyenv:

```
#!/Users/shinglyu/.pyenv/versions/3.11.4/bin/python3
```

## Walkthrough of the code
The code is pretty straightforward. I accepted one text argument (`sys.argv[1]`), which is the text that need to be summarized. Then I constructed a prompt for the [Anthropic Claude v2][claudev2] model. The prompt will look like this:

```
Human: Summarize the following text:
---
This is a long article that needs to be summarized bla bla bla...
---

Assistant:
```

This format about "Human:" and "Assistant:" is required by the Claude v2 model. Then we use the AWS Python SDK to invoke Amazon Bedrock API, get the response, and print it out after parsing. 

You need valid AWS credentials for the API call to work. Follow the [boto3 documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html) to set it up. I use the shared credentails file method, but you can use anyone from the documentation.

Because I use the dark theme on macOS, the default font color is a dim gray. So in the final `print()` I added ANSI color codes to make it bright white on black background.

Here are some screen shots of it summarizing the [*Amazon Bedrock Is Now Generally Available*][bedrock-ga-post] blog post.

![prompt]({{site_url}}/blog_assets/raycast-bedrock/prompt.jpg)
![response]({{site_url}}/blog_assets/raycast-bedrock/response.jpg)


## What can you tweak?
There are a few ways to customize and tweak this summarization script:

### Use Claude Instant for Faster Summarization
The claude-instant-v1 model provides faster summarization compared to claude-v2, with slightly lower quality. If you just need key points quickly, claude-instant is a good option.

Update the model ID field:

```python
    response = client.invoke_model(
        body = # ...
        modelId = "anthropic.claude-instant-v1",
        # ...
    )
```

Customize the Prompt
You can tailor the prompt to do different things. For example, composing an email, reply to a message, generate brainstorming ideas. Or you can just leave the prompt empty and let the users input what they want:

```
Human: {sys.argv[1]}

Assistant:
```

This way you make it into a general purpose chatbot, but much easier to access.

Raycast provides immense flexibility to build custom scripts that streamline your workflows. For my common need of summarizing text, I was able to create a simple Python script leveraging Amazon Bedrock API. Now with just a keyboard shortcut, I can get key summaries without leaving my editor or switching contexts.

[raycast]: https://www.raycast.com/
[amazon-bedrock]: https://aws.amazon.com/bedrock/
[claudev2]: https://aws.amazon.com/bedrock/claude/
[bedrock-ga-post]: https://aws.amazon.com/blogs/aws/amazon-bedrock-is-now-generally-available-build-and-scale-generative-ai-applications-with-foundation-models/
