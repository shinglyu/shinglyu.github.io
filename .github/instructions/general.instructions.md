---
applyTo: '**'
---

This repository is a blog of Shing Lyu. It's built on Jekyll and hosted on GitHub Pages.

# Workflow

* Each post go through these folders: `ideas` -> `drafts` -> `human_review`-> `posts`
* `ideas`: raw ideas, usually a voice transcription or high-level bullet points
* `drafts`: fleshed-out drafts, with complete sentences and paragraphs
* `human_review`: posts that are ready for a human editor to review for clarity and style
* `posts`: published posts, ready to be served by Jekyll
* Once the post is moved to `posts`, commit all the relevant ideas/drafts/human_review files deletion in the same commit.

# Draft Review Requirement

Before opening a pull request — even for a draft — the following subagents **must** run and pass:

1. **Editor** (`editor` agent in `.github/agents/editor.agent.md`): checks style consistency and formatting uniformity
2. **Fact Checker** (`fact-checker` agent in `.github/agents/fact-checker.agent.md`): verifies technical claims and checks for sensitive information — this is a **blocking** check; stop and fix any issues before opening the PR

