---
layout: post
title: "Automating Weekly Research with GitHub Agentic Workflows"
categories: blog
date: 2010-01-01 00:00:00 +08:00
excerpt_separator: <!--more-->
tags: [GitHub-Actions, AI, automation, github-copilot, gh-aw]
---

Many AI platforms — OpenAI, Anthropic — offer "scheduled tasks" or "scheduled agents" that run automatically. Sounds great, until you realise the configuration lives in some web UI, completely outside your version control. You can't review changes in a pull request, you can't roll back, and you can't easily share or reproduce your setup. The automation tooling conversation also seems to have been taken over by no-code platforms — n8n, Zapier, or just asking a chatbot — which work fine until you want something more structured and closer to how software is actually built.

I'm already paying for GitHub Copilot. I wanted scheduled AI automation that's already included, version-controlled in Git, auditable, and running in a real development environment with full CLI access. Turns out [GitHub Agentic Workflows](https://github.com/github/gh-aw) (`gh-aw`) ticks all those boxes.

<!--more-->

## What is gh-aw?

GitHub Agentic Workflows is a GitHub tool [announced on the GitHub blog](https://github.blog/ai-and-ml/automate-repository-tasks-with-github-agentic-workflows/) that lets you write automation as plain Markdown. The key thing is that you describe what you want in natural language — no YAML logic, no scripting. The `gh aw` CLI then compiles your Markdown into a GitHub Actions workflow. When the workflow runs, GitHub Actions spins up a GitHub Copilot CLI instance inside a controlled sandbox, with a network firewall, minimal permissions, and restricted outputs. The natural language prompt is what the agent actually reads and follows.

A few things I appreciate about it:

- **Natural language first**: you describe the task in plain English. The agent figures out the steps.
- **Triggers you already know**: `schedule`, `workflow_dispatch`, PR events — same as regular GitHub Actions
- **Network allowlist**: you explicitly declare which domains the agent can reach. This is a firewall, not just a suggestion. If the domain isn't listed, the agent can't reach it.
- **Safe outputs**: the agent can only do a restricted set of things on GitHub — `create-pull-request`, `add-comment`, etc. It can't push directly to main or do anything destructive.

## Setting it up

**Step 1**: Install the extension.

```bash
gh extension install github/gh-aw
```

**Step 2**: Initialise the repository.

```bash
cd your-repo
gh aw init
```

This creates a few files:

- `.github/agents/agentic-workflows.agent.md` — registers an `agentic-workflows` custom agent in GitHub Copilot, enabling interactive workflow authoring directly from Copilot Chat on github.com or the mobile app
- `.gitattributes` — marks generated `.lock.yml` files so Git handles them correctly
- VS Code settings and MCP server configuration — gives Copilot access to `gh-aw` tools when authoring locally

Once the files are committed and pushed, you and your team can create or edit workflows straight from Copilot Chat on github.com or the GitHub app:

```
/agent agentic-workflows Create a new workflow that...
```

Or if you prefer working in your editor or CLI coding agent (VS Code, Claude, Codex), use the `create.md` prompt:

```
Create a workflow for GitHub Agentic Workflows using https://raw.githubusercontent.com/github/gh-aw/main/create.md
The purpose of the workflow is...
```

**Step 3**: Go to your repo's Settings → Secrets and variables → Actions and set `COPILOT_GITHUB_TOKEN` to a personal access token with the right scopes. Without this, Copilot can't authenticate to do anything useful.

The key commands you'll use day-to-day:

```bash
gh aw init                    # initialise the repo
gh aw compile <name>          # recompile after editing the .md
gh aw logs <name>             # check recent run logs
gh aw audit <run-id>          # inspect a specific run in detail
```

## Writing the weekly research workflow

This is where it gets interesting. I wanted a workflow that runs every Friday and pulls together recent news across a few topics I care about: cloud infrastructure, software architecture, security, AI agents, and the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/). The output lands in my Obsidian vault as a markdown note, via a pull request so I can review it before merging.

I started from the [example in githubnext/agentics](https://github.com/githubnext/agentics/blob/main/docs/weekly-research.md) and adapted it. This is what I came up with for `.github/workflows/weekly-research.md`:

```markdown
//===== .github/workflows/weekly-research.md =====
---
description: |
  Weekly research on cloud, architecture, security, AI agents, and MCP.
  Creates a pull request with a markdown report each Friday.

on:
  schedule: weekly on friday around 3:00
  workflow_dispatch:

permissions: read-all

network:
  allowed:
    - defaults
    - github
    - "thenewstack.io"
    - "martinfowler.com"
    - "infoq.com"
    - "security.googleblog.com"
    - "aws.amazon.com"
    - "cloud.google.com"
    - "nvd.nist.gov"

safe-outputs:
  create-pull-request:
    title-prefix: "[weekly-research] "
    draft: false
    labels: [weekly-research]

tools:
  github:
    toolsets: [all]
  web-fetch:

timeout-minutes: 15

engine: copilot
---

You are a research assistant helping me stay current on software engineering topics.

Research the following topics and find 3-5 noteworthy items per topic from the past week:

1. Cloud infrastructure (AWS, GCP, Azure announcements, new services, pricing changes)
2. Software architecture patterns and system design
3. Security vulnerabilities, patches, and best practices
4. AI agents and agentic frameworks — cap at 2-3 items maximum
5. Model Context Protocol (MCP) — new servers, specs, tooling

Before writing anything, check the most recent file in `Projects/WeeklyResearch/` in this
repository to avoid duplicating items from last week.

Output a single Obsidian-compatible Markdown file with this structure:

---
title: Weekly Research YYYY-MM-DD
date: YYYY-MM-DD
tags: [weekly-research]
---

# Weekly Research [date]

## Cloud infrastructure
...

## Architecture
...

## Security
...

## AI agents
...

## MCP
...

<details>
<summary>Research metadata</summary>

List the sources you consulted and any domains you could not reach because they
were not on the network allowlist. Record those blocked domains here so I can
decide whether to add them next week.

</details>

Save the file as `Projects/WeeklyResearch/YYYY-MM-DD.md` and open a pull request.
```

A few things worth explaining here. `gh-aw` uses a natural-language fuzzy schedule syntax — `weekly on friday around 3:00` — rather than a cron expression. The `around` keyword tells the system to pick a time within a ±1 hour window to spread load; if you need a precise time, you can use a standard cron expression instead. All times are UTC by default; to schedule in your local time use the `utc+N`/`utc-N` notation (e.g. `around 8:00 utc+8` for 8am Hong Kong time). The network allowlist is explicit. I'd rather be strict and occasionally miss a source than have the agent roaming freely. The `<details>` block for research metadata is something I added after a few runs — it keeps the main note clean while still giving me visibility into what the agent actually looked at and what it couldn't reach.

Once you've written the file, compile it:

```bash
gh aw compile weekly-research
```

This generates `.github/workflows/weekly-research.lock.yml`. Commit *both* files together. If you only commit the `.md`, the old lock file stays and your changes don't take effect.

## The problems I hit

I'd be lying if I said this all worked first try. Here's what actually happened.

**Problem 1: `create-discussion` silently failed.** The default template uses `create-discussion` as the safe output, which I forgot to update. The workflow ran, Copilot generated the research, and then… nothing. No discussion appeared. It turned out GitHub Discussions wasn't enabled on my repo. I switched to `create-pull-request` instead, which has the added bonus of giving me a review step before the content merges.

**Problem 2: schedule changes didn't take effect.** I edited the `.md` to change the time and committed it, but the workflow kept running at the old time. I'd simply forgotten to compile — the old `.lock.yml` was still the one GitHub Actions was reading. Remember to always run `gh aw compile` after editing the `.md`, and check that the lock file actually changed. (Worth knowing: this only applies to frontmatter changes like triggers, schedule, and network rules. If you're only tweaking the prompt body, those changes are loaded at runtime and take effect without recompilation.)

**Problem 3: AI topics dominated and duplicates crept in.** After a few weeks, the notes were heavy on AI agent news (there's a lot of it) and I kept seeing the same projects mentioned across consecutive weeks. Two fixes helped. First, reordering the topics list and explicitly capping AI items at 2–3. Second, adding the deduplication instruction to read the previous week's note before generating anything new. It's not perfect, but it's a lot better.

**Problem 4: the timing was off.** The schedule is in UTC. I'd set `around 8:00` and forgotten about that, so the report was arriving later than I expected. Adjust to your timezone and double-check.

**Problem 5: the web UI allowlist and the workflow firewall are different things.** Under the GitHub Copilot section in repository settings, there's a domain allowlist where you can add URLs. I added my domains there expecting the network firewall to honour them — but the agent still couldn't reach those domains. It turns out the allowlist in the repo settings and the `network.allowed` field in the workflow frontmatter are separate. The `network.allowed` field is what actually controls what the agent can reach during a specific workflow run. Once I moved the domains there, everything worked.

## Ideas for what else you can automate

The gh-aw community has been exploring what other workflows fit this pattern. A few ideas that work well with this approach:

**Scheduled tech debt cleanup.** Every Monday morning, scan the repo for `TODO` and `FIXME` comments, outdated dependencies, deprecated API usages, and open a PR with a summary. Not to auto-fix everything — just to keep it visible.

**Smarter dependency bumping.** Weekly, check for new versions of key dependencies and open a PR. Similar to Dependabot, but because it's AI-driven it can also summarise breaking changes and explain *why* this upgrade matters. That context is usually what I want before I actually merge.

**Security scanning with CVE awareness.** A scheduled workflow that checks your dependencies against [NVD](https://nvd.nist.gov/) or [OSV](https://osv.dev/), and opens GitHub Issues for anything critical. This is a nice example of a hybrid approach: the static scanner does the CVE lookup (fast, deterministic, cheap), and the LLM step interprets the results — which CVEs actually affect your version, what the severity means in context, and what to do about it. That's a better fit for what each tool is actually good at, rather than asking an LLM to do everything end-to-end.

**Architecture compliance.** If you maintain ADRs (Architecture Decision Records), you could have a weekly workflow read them, look at what code was merged that week, and flag anything that might violate a recorded decision. (I wrote about [ADR-driven code review]({% post_url 2026-03-01-ai-adr-code-review %}) before — this would be the automated version of that.)

**Documentation freshness check.** Compare recent code diffs to documentation files. If a function signature changed but the docs weren't updated, flag it. Open a PR with suggested doc patches. This is the kind of work that's easy to forget and easy to automate.

The common thread: these are all tasks you *know you should do* but rarely do consistently because they require manual effort. Wrapping them in a scheduled agentic workflow turns "I should check this sometime" into "it runs every Monday and opens a PR."

## Conclusion

What I find most useful about `gh-aw` isn't the savings — it's the model. Your automation lives in the same repository as your code. It goes through the same PR review. It can be rolled back with `git revert`. For a developer, this is just how things should work. Most automation tooling has drifted toward no-code drag-and-drop interfaces, which is fine if you're non-technical, but if you're a developer you probably want something you can version, diff, and debug like any other file.

The hybrid approach also matters more than it looks at first. You don't have to feed everything to the LLM. For something like security scanning, run a static tool to get structured CVE data, then hand that to the agent to interpret and triage. For dependency bumping, let the package manager find the updates, let the agent explain the changelogs. This kind of split — deterministic tools for the structured parts, LLM for interpretation and communication — is cheaper, more reliable, and usually produces better output than an LLM-only flow trying to do everything.

If you try it, start with something low-stakes. A weekly research digest is perfect. The worst that happens is the agent writes a slightly odd note and you close the PR. Once you've tuned your prompts, you'll find yourself reaching for it whenever you have a recurring task that involves reading, summarising, or checking something.
