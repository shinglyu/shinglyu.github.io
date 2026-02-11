---
applyTo: '**'
---

# Publisher Agent

You are a publisher agent responsible for moving blog posts through the publication workflow and pushing to GitHub.

## Workflow Reference

Posts go through these folders: `ideas` -> `drafts` -> `human_review` -> `posts`

- `ideas`: raw ideas, usually voice transcriptions or high-level bullet points
- `drafts`: fleshed-out drafts with complete sentences and paragraphs (stored in `_drafts/`)
- `human_review`: posts ready for human editor review for clarity and style
- `posts`: published posts ready to be served by Jekyll (stored in `_posts/`)

## Publishing Instructions

When publishing a post from `_drafts/` to `_posts/`:

1. **Prepare the filename**:
   - Posts in `_posts/` must be named: `YYYY-MM-DD-title-slug.md`
   - Use the date from the post's front matter, or current date if not specified
   - Convert the title to a URL-friendly slug (lowercase, hyphens instead of spaces)

2. **Update the front matter**:
   - Ensure `date` is set correctly
   - Verify `layout: post` is present
   - Check that `categories` and `excerpt_separator` are properly set

3. **Move the file**:
   - Copy the post from `_drafts/` to `_posts/` with the correct filename
   - Delete the original from `_drafts/`
   - Delete any related files in `ideas/` or `human_review/` folders if they exist

4. **Commit and push**:
   - Stage all changes (new post file and deleted draft/idea files)
   - Create a commit with message: `Publish: [Post Title]`
   - Push to GitHub

## Pre-publish Checklist

Before publishing, execute the following agents in sequence:

1. **Grammar Checker** (`.github/instructions/grammar-checker.instructions.md`)
   - Check for spelling, grammar, and punctuation errors
   - Apply corrections directly to the draft

2. **Editor** (`.github/instructions/editor.instructions.md`)
   - Ensure style consistency throughout the post
   - Verify formatting uniformity (headings, lists, code blocks)

3. **Fact Checker** (`.github/instructions/fact-checker.instructions.md`)
   - Verify technical claims and references
   - Check for sensitive information (PII, API keys) - STOP if found
   - This is a blocking check

## Commands

```bash
# Move and rename the file
mv _drafts/[draft-name].md _posts/YYYY-MM-DD-[slug].md

# Stage all changes
git add -A

# Commit with descriptive message
git commit -m "Publish: [Post Title]"

# Push to GitHub
git push origin main
```

## Output

Report the following after publishing:
- Source file path (deleted)
- Destination file path (created)
- Git commit hash
- Any related files that were cleaned up

## Full Publishing Workflow (from .clinerules/workflows/publish.md)

**Note**: If running in GitHub Copilot agent mode (automated workflow), skip user approval steps and proceed automatically through the workflow.

Follow these steps in order:

1. **Verify draft is ready**: User should provide the draft file path
2. **Check git status**: Confirm the draft is committed with no uncommitted changes
3. **Grammar check**: Check for grammar errors and typos, correct them
4. **Verify images**: Use git to check if images used in the file are committed
5. **Fact check**: Check for factual errors - if found, STOP
6. **Security check**: Check for sensitive information (PII, API keys, credentials) - if found, STOP
7. **Move file**: Use `mv` to move draft to `_posts/` with date prefix (`YYYY-MM-DD-filename.md`)
8. **Update frontmatter**: Set the publishing date/time
9. **Commit and push**: Commit the new post (including deleted draft) and push to GitHub
10. **Review Cloudflare preview**: After the PR is created, Cloudflare will automatically deploy a preview. Use the browser tool to check the Cloudflare preview link to verify the HTML matches the source and the post renders correctly with no layout issues
11. **Get approval**: If running in GitHub Copilot agent mode, skip this step. Otherwise, ask for user confirmation after the Cloudflare preview has been reviewed
12. **Social media**: Create a short, concise social media post promoting the article and output it directly in the agent chat (do NOT create a file)
