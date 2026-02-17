# GitHub Copilot Agent Instructions

This directory contains instruction files for GitHub Copilot agents that help with the blog writing and publishing workflow.

## Available Agents

### Content Creation Agents

#### writer.instructions.md
**Purpose**: Create blog posts in Shing Lyu's writing style

**When to use**:
- Converting ideas to full drafts
- Expanding outlines into complete posts
- Ensuring consistent voice and style across posts

**Key Features**:
- Based on analysis of 40+ pre-GenAI era blog posts (2016-2022)
- Includes specific style patterns, common phrases, and structural templates
- Covers tutorial, conceptual, and review post formats
- Provides examples from actual published posts

**See also**: `.github/WRITING_STYLE_ANALYSIS.md` for detailed analysis methodology

#### grammar-checker.instructions.md
**Purpose**: Check for spelling, grammar, and punctuation errors

**When to use**:
- Before moving drafts to human review
- As part of the publishing checklist
- After making significant edits

#### editor.instructions.md
**Purpose**: Ensure style and formatting consistency

**When to use**:
- After grammar checking
- Before fact checking
- To verify heading hierarchy and code formatting

#### fact-checker.instructions.md
**Purpose**: Verify technical claims and check for sensitive information

**When to use**:
- Before publishing (blocking check)
- After editing is complete
- When including technical specifications or version-specific features

**Note**: This is a **blocking check** - posts with unresolved factual errors should not be published

### Publishing Agents

#### publisher.instructions.md
**Purpose**: Move posts through the publishing workflow

**When to use**:
- Publishing from `_drafts/` to `_posts/`
- Managing the full publication pipeline
- Coordinating other agents in sequence

**Workflow**: drafts → grammar check → editing → fact check → publish → social media

#### social-media-marketer.instructions.md
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

1. **Idea to Draft** (Writer Agent)
   - Input: Idea notes or outline in `ideas/`
   - Output: Full draft in `_drafts/`
   - Agent: `writer.instructions.md`

2. **Grammar Check** (Grammar Checker Agent)
   - Input: Draft in `_drafts/`
   - Output: Corrected draft
   - Agent: `grammar-checker.instructions.md`

3. **Style Edit** (Editor Agent)
   - Input: Grammar-checked draft
   - Output: Style-consistent draft
   - Agent: `editor.instructions.md`

4. **Fact Check** (Fact Checker Agent) ⚠️ BLOCKING
   - Input: Edited draft
   - Output: Factually verified draft
   - Agent: `fact-checker.instructions.md`
   - Note: STOP if errors found

5. **Publish** (Publisher Agent)
   - Input: Verified draft in `_drafts/`
   - Output: Published post in `_posts/` with proper filename
   - Agent: `publisher.instructions.md`
   - Actions: Move file, update frontmatter, commit changes

6. **Promote** (Social Media Marketer Agent)
   - Input: Published post URL
   - Output: Social media posts in `social_media/`
   - Agent: `social-media-marketer.instructions.md`

## File Naming Conventions

### Draft Files
- Location: `_drafts/`
- Format: `my-post-title.md` (no date prefix)

### Published Posts
- Location: `_posts/`
- Format: `YYYY-MM-DD-post-slug.md`
- Example: `2024-01-15-introduction-to-rust.md`

### Social Media Posts
- Location: `social_media/`
- Format: `YYYY-MM-DD-post-slug.md`
- Sections for each platform (LinkedIn, Facebook, Mastodon)

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

## Using These Instructions

### In GitHub Copilot Chat
Reference these instructions when asking Copilot for help:

```
@workspace Using the writer agent instructions, create a blog post about [topic]
```

### In Automated Workflows
These instructions are automatically applied by GitHub Copilot agents when triggered by the publishing workflow.

### In Manual Reviews
Use these instructions as a checklist when manually reviewing posts.

## Contributing to Instructions

When updating agent instructions:

1. Maintain the YAML front matter: `applyTo: '**'`
2. Follow the existing structure and format
3. Include specific examples when possible
4. Test instructions by generating sample content
5. Update this README if adding new agents

## Related Documentation

- `.github/WRITING_STYLE_ANALYSIS.md` - Detailed writing style analysis
- `.clinerules/workflows/publish.md` - Complete publishing workflow
- `.github/instructions/general.instructions.md` - General repository context

## Questions?

For questions about these instructions or the workflow:
1. Check the individual instruction files for detailed guidelines
2. Review the writing style analysis document
3. Examine published posts in `_posts/` as examples
4. Reach out to the repository maintainer
