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
* In the repository, the Jekyll directories for these stages are `_drafts/` and `_posts/`.

# Draft Review Requirement

When a user assigns a blog idea or issue to an agent, the agent should invoke the `writer` agent to create or update the draft in `_drafts/`.

After the draft has been reviewed in a pull request, the `editor` agent is the review gate. When tagged for a final review, it should:

1. Review style and formatting consistency
2. Invoke the `grammar-checker` subagent for spelling, grammar, and punctuation fixes
3. Invoke the `fact-checker` subagent for factual verification and sensitive-information checks
4. Update the YAML front matter flags once the review is complete:
   - set `grammar_checked: true` after the grammar pass succeeds
   - set `fact_checked: true` after the fact check succeeds
   - leave the relevant flag as `false` if the review is still incomplete or blocked

Drafts created for publication should include these YAML front matter flags, initialized to `false`: `grammar_checked`, `fact_checked`. If the draft comes from a deterministic template or script, rely on that template to include them rather than treating missing flags as a special case.

When adding a draft that is ready to be published, append its filename under the placeholder entry in `.github/workflows/publish.yml` within the `workflow_dispatch.inputs.file_name.options` list.

# Publishing Requirement

Publishing is handled by the deterministic GitHub Actions workflow in `.github/workflows/publish.yml`, which calls `.github/scripts/publish.sh` and `.github/scripts/sync_to_public.sh`. There is no separate publisher agent in this workflow.

# Automation Scripts and Workflows

When writing or editing shell scripts and GitHub Actions workflows in this repo (e.g., under `.github/scripts/` or `.github/workflows/`), prefer a small number of clear, deterministic steps over defensive fallback logic. The author has explicitly rejected scripts with "too many unnecessary fallbacks" in favor of a simple, explicit flow (e.g., require a token rather than silently degrading, fail loudly with a clear message instead of trying multiple recovery paths). Also remove now-unused scripts that duplicate replaced logic instead of leaving them around "just in case."
