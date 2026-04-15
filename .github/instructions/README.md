# GitHub Copilot Instructions

This directory contains path-specific instruction files (`.instructions.md`) for GitHub Copilot that provide general context about this repository.

> **Note**: Custom agents (writer, editor, fact-checker, grammar-checker, publisher, social-media-marketer) are defined as `.agent.md` files in `.github/agents/`.

## Files in This Directory

### general.instructions.md
General repository context applied to all files (`applyTo: '**'`). Describes the blog workflow and draft review requirements.

### writer.instructions.md
Detailed writing style guide for Shing Lyu's blog, applied to all files (`applyTo: '**'`). Referenced by the `writer` agent in `.github/agents/writer.agent.md`.

## Available Agents

Specialized agents are defined in `.github/agents/` and can be invoked by Copilot:

### Content Creation Agents

#### `.github/agents/writer.agent.md`
**Purpose**: Create blog posts in Shing Lyu's writing style

**When to use**:
- Converting ideas to full drafts
- Expanding outlines into complete posts
- Ensuring consistent voice and style across posts

**See also**: `.github/WRITING_STYLE_ANALYSIS.md` for detailed analysis methodology

#### `.github/agents/grammar-checker.agent.md`
**Purpose**: Check for spelling, grammar, and punctuation errors

**When to use**:
- Before moving drafts to human review
- As part of the publishing checklist
- After making significant edits

#### `.github/agents/editor.agent.md`
**Purpose**: Ensure style and formatting consistency

**When to use**:
- After grammar checking
- Before fact checking
- To verify heading hierarchy and code formatting

#### `.github/agents/fact-checker.agent.md`
**Purpose**: Verify technical claims and check for sensitive information

**When to use**:
- Before publishing (blocking check)
- After editing is complete
- When including technical specifications or version-specific features

**Note**: This is a **blocking check** - posts with unresolved factual errors should not be published

### Publishing Agents

#### `.github/agents/publisher.agent.md`
**Purpose**: Move posts through the publishing workflow

**When to use**:
- Publishing from `_drafts/` to `_posts/`
- Managing the full publication pipeline
- Coordinating other agents in sequence

**Workflow**: drafts → grammar check → editing → fact check → publish → social media

#### `.github/agents/social-media-marketer.agent.md`
**Purpose**: Create social media posts to promote published articles

**When to use**:
- After a post is published
- To create LinkedIn, Facebook, or Mastodon content
- Generating promotional material

## Publishing Workflow

The complete workflow for publishing a blog post:

```
ideas/ → _drafts/ → human_review/ → _posts/
```

### Step-by-step Process

1. **Idea to Draft** (`writer` agent)
   - Input: Idea notes or outline in `ideas/`
   - Output: Full draft in `_drafts/`

2. **Grammar Check** (`grammar-checker` agent)
   - Input: Draft in `_drafts/`
   - Output: Corrected draft

3. **Style Edit** (`editor` agent)
   - Input: Grammar-checked draft
   - Output: Style-consistent draft

4. **Fact Check** (`fact-checker` agent) ⚠️ BLOCKING
   - Input: Edited draft
   - Output: Factually verified draft
   - Note: STOP if errors found

5. **Publish** (`publisher` agent)
   - Input: Verified draft in `_drafts/`
   - Output: Published post in `_posts/` with proper filename
   - Actions: Move file, update frontmatter, commit changes

6. **Promote** (`social-media-marketer` agent)
   - Input: Published post URL
   - Output: Social media post text in the chat

## File Naming Conventions

### Draft Files
- Location: `_drafts/`
- Format: `my-post-title.md` (no date prefix)

### Published Posts
- Location: `_posts/`
- Format: `YYYY-MM-DD-post-slug.md`
- Example: `2024-01-15-introduction-to-rust.md`

## Front Matter Requirements

All posts must include:

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD HH:MM:SS +TZ
categories: blog
tags: [tag1, tag2]  # Optional
excerpt_separator: <!--more-->
---
```

Use "blog" for the category to simplify the path for future posts. Do not change existing posts for backward compatibility.

## Contributing to Instructions

When updating instruction files in this directory:

1. Maintain the YAML front matter with `applyTo:` specifying the appropriate glob pattern
2. Follow the existing structure and format
3. Update this README if adding new files

When adding or updating agents, edit the `.agent.md` files in `.github/agents/`.

## Related Documentation

- `.github/WRITING_STYLE_ANALYSIS.md` - Detailed writing style analysis
- `.clinerules/workflows/publish.md` - Complete publishing workflow
- `.github/instructions/general.instructions.md` - General repository context
- `.github/agents/` - Custom agent definitions

## Questions?

For questions about these instructions or the workflow:
1. Check the individual instruction files in `.github/instructions/` and agent files in `.github/agents/` for detailed guidelines
2. Review the writing style analysis document
3. Examine published posts in `_posts/` as examples
4. Reach out to the repository maintainer
