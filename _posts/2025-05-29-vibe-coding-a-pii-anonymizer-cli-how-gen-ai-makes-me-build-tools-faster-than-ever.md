---
layout: post
title: "Vibe coding a PII Anonymizer CLI: how gen AI makes me build tools faster than ever"
categories: ai
date: 2025-05-29 00:27:17 +02:00
tags: [cli, privacy, ai, python, tool-building, vibe-coding]
---

I use AI chatbots and agents extensively in my daily workflow. Sometimes I need to provide them with documents converted to markdown, but I don't want to give away too much personal information. [Markitdown](https://github.com/microsoft/markitdown) is an excellent tool for converting PDFs and Word documents to markdown, but I lacked a CLI tool that could redact PII from the output. There are existing tools out there, and cloud services too, but I wanted something completely offline that wouldn't raise any IT security team's eyebrows. Then I stumbled upon [Microsoft's Presidio library](https://github.com/microsoft/presidio), which can anonymize Personally Identifiable Information (PII) easily. So I decided to flex my vibe coding muscles and code a CLI myself.

## The Solution: PII Anonymizer CLI

My result is the [PII Anonymizer CLI](https://github.com/shinglyu/pii-anonymizer-cli). 

### The Core Workflow

The workflow is beautifully simple:

```bash
# Basic anonymization
echo "Contact John Doe at john.doe@example.com" | anonymize
# Output: Contact <PERSON> at <EMAIL_ADDRESS>

# Perfect integration with markitdown for document processing
cat confidential_report.pdf | markitdown | anonymize > clean_report.md
```

That second example is the real magic. You can take any PDF document, convert it to markdown, strip out the PII, and end up with clean content that's safe to share with AI tools. With some shell scripting you can clean up a folder of Word and PDF documents in no time. 

### What Makes This Tool Powerful

The tool stands out for several key reasons that make it genuinely useful in practice.

Everything runs locally with zero cloud dependency - no data leaves your machine. This addresses the fundamental privacy concern that sparked the project in the first place. When you're dealing with sensitive documents, the last thing you want is to send them to yet another third-party service, even for the purpose of privacy protection.

Under the hood, it uses Microsoft's Presidio engine, which provides enterprise-grade detection that catches context-aware PII that simple regex patterns would miss. Although the accuracy depends on the model used, it still gives a good baseline for normal use cases. The Presidio library uses the spaCy natural language processing (NLP) engine by default. You can choose from many languages and sizes (see the full list of models [here](https://spacy.io/models)). This multi-language support was crucial for my workflow, because I have to deal with documents in English, Traditional Chinese and Dutch.

Perhaps most importantly, the tool follows UNIX philosophy by playing nicely with pipes, making it composable with existing tools. You can convert PDF to markdown with markitdown before piping into this CLI. Or you can pipe the output to `sed` to further remove special names (e.g. name of a company or product under NDA) that are not caught by Presidio.

### Installation

Installation is straightforward:

```bash
git clone https://github.com/shinglyu/pii-anonymizer-cli.git
cd pii-anonymizer-cli
uv tool install .  # The binary `anonymize` becomes available
```
### Multiple I/O Modes

Although piping is the default, you can also pass input and output files as parameters.

```bash
# Pure pipe workflow
cat logs.txt | anonymize > clean.txt

# File-to-file processing
anonymize --input data.md --output clean.md

# Mixed approaches for complex pipelines
find . -name "*.log" | xargs cat | anonymize | gzip > anonymized_logs.gz
```

## What I learned vibe coding this tool

Whenever I build a new project, I always like to use the opportunity to try new tools. I used this opportunity to try GitHub Copilot's agent mode. Later during the development, Claude 4 came out so I also tested Claude 4. 

### The Initial Build

GitHub Copilot + Claude 3.7 gave me a pretty solid foundation. I explicitly asked it to use Test Driven Development (TDD) and use `uv` as the Python package manager. The AI generated good unit tests and an initial CLI with an object-oriented design that cleanly separated the main anonymizer engine from the CLI interface.

I encourage you to [read the source code on GitHub](https://github.com/shinglyu/pii-anonymizer-cli) since it's quite simple and demonstrates the clean separation between concerns.

### Evolution to Claude 4

Initially, I chose the `en_core_web_sm` model because it's small and easy to test. But later I needed support for other languages and wanted to experiment with bigger models.

At that point, Claude 4 became available. I switched to Cline + Claude 4 and asked it to add the `--model` parameter and automatic model downloading when missing. It handled the job well without much intervention from me.

### Taking Vibe Coding to the Extreme

To really push the boundaries of vibe coding, I asked the AI to look back at what had changed and handle `git add` and `git commit` for me. Surprisingly, it remembered this instruction and tried to perform git operations every time it made changes.

I was surprised that Cline marks git operations as "safe" commands and auto-approves them. I still prefer to do git commits when I have manually tested the code and am happy with the progress. Even Claude 4 doesn't try hard enough to test its own code so I don't feel comfortable letting it commit multiple broken commits.

Finally, before publishing, I asked Cline to review the entire project, add more tests, and ensure the README was clean and concise. With this extra push it actually added a few error handling cases and built a good result. 

### Key Observations

**TDD limitations**: Claude 3.7 still doesn't master TDD. Most of the time, it dives right into coding without running tests first. When it needs to test, it usually forgets about the unit test and does some manual integration test by running the CLI itself against test input files. I had to ask it to run unit tests every time.

**Interface changes**: GitHub Copilot agent mode doesn't show diffs by default anymore, making the development process more "vibe-y" but sometimes less transparent. But my friend [Pahud Hsieh](https://www.linkedin.com/in/pahud) points out it's a trend most AI coding tools are moving towards.

**Package manager confusion**: Copilot doesn't quite grasp how `uv` works for distributing Python scripts. It provided several alternative installation methods in the README, sometimes redundantly.

**Claude 4 vs 3.7**: Since the task was relatively simple, I didn't feel Claude 4 was dramatically more powerful than 3.7, but subjectively it seemed to make fewer mistakes overall.

## The Bigger Picture: Why This Matters

While people still debate whether vibe coding can handle complex production-grade programming, I think AI coding agents already show great value at building small, focused tools that are easy to reason about and review.

### Overcoming Development Friction

I've noticed that I now write more one-off scripts and tools than ever before. In the past, I had many ideas for script tools that would solve daily annoyances, but I was consistently put off by the development overhead.

Scaffolding the project always felt like a chore - setting up directory structure, build files, dependency management, and all the boilerplate that comes before you can write the first line of actual functionality. This initial friction often killed good ideas before they got started.

Language-specific challenges created another barrier. Jumping between shell, Python, or Rust means I often forget or mix up syntax and idioms. Shell scripting is particularly difficult to get right and lacks proper testing frameworks, making it unreliable for anything beyond trivial automation. But AI nowadays can write pretty robust shell scripts, and can do end-to-end testing without a fuss. 

CLI interface design presented its own complexity. Crafting good interfaces and ensuring everything is properly parameterized takes thought and effort. I'm usually too lazy and end up hard-coding things, which makes tools less usable when parameters inevitably need changing later. 

Output formatting and making things look professional with proper coloring seemed like polish that could wait, but actually contributes significantly to whether a tool feels finished and usable. Documentation and publishing good READMEs to the web rounds out the work needed to make a tool truly useful to others.

With vibe coding, I can now build a useful tool and go through roughly 5 iterations in 30 minutes of spare time. This significantly improves my productivity.

## Future Work

There are several directions I'd like to explore:

### Consistent Entity Tracking

I want to add unique labels to entities, like `<PERSON_1>`, `<PERSON_2>`, so we know all instances of `<PERSON_1>` in an article refer to the same person. However, previous attempts resulted in some weird looking nested entities, which is documented but I have not yet read through.

### Extension Opportunities

There are several directions where the tool could evolve to become even more useful. Custom entity types would allow support for employee IDs, customer codes, and domain-specific identifiers that organizations need to protect but aren't covered by standard PII categories.

Presidio also offers different anonymization methods, like redact (remove PII), mask ("John Doe" => "J*** D**"), hash (take the sha256 of the value), encrypt (encrypt with a cryptographic key, which is reversible). They are not that relevant to my use case, but can maybe be exposed as parameters for completeness.

With these extra parameters, having YAML/JSON config files would enable complex workflows where different entity types get different treatments, or where certain patterns should be preserved or handled specially based on context.

## Conclusion

For me, building the PII Anonymizer CLI was both a practical solution to a real problem and an experiment in AI-assisted development. The tool successfully bridges the gap between Microsoft's excellent Presidio library and the command-line workflows that I actually use. The result is a tool that does exactly what it promises: takes text in, removes PII, and outputs clean text. It composes naturally with other tools, requires no configuration, and solves a real problem that many developers face in the age of AI-assisted workflows.

More broadly, the project demonstrates that vibe coding with AI tools has reached a level of maturity where building small, focused utilities is not just possible but genuinely productive. The key is choosing the right scope - tools that are complex enough to be useful but simple enough to be easily understood and validated.
