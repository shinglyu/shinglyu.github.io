---
layout: post
title: "ADR in code: architecture compliance with AI code reviews"
categories: blog
date: 2026-03-01 18:00:00 +0100
excerpt_separator: <!--more-->
tags: [AI, ADR, code-review, GitHub-Copilot, architecture]
---

In my [previous post about ADR as Event Sourcing]({% post_url 2026-02-07-adr-as-event-sourcing %}), I talked about capturing architecture decisions continuously as they happen, not months later when everyone's forgotten the context. But writing ADRs is only half the battle. The other half is actually *enforcing* them—and that's where most teams fail. ADRs sit in a separate wiki or documentation tool like Confluence or Notion, gradually becoming archaeology rather than law.

What if we could give our AI code reviewer the ADRs as instructions, so it flags violations automatically on every pull request?

<!--more-->

I built a small demo to show exactly this: [shinglyu/ai-adr-review-demo](https://github.com/shinglyu/ai-adr-review-demo). It's a bookstore API in Node.js/TypeScript with three documented architectural decisions, and GitHub Copilot Code Review configured to enforce them on every PR.

The results were more interesting than I expected—especially what happens when you try to *tell* the AI to violate an ADR.

## The demo setup

The bookstore API has three ADRs:

- **ADR-0001**: All resource IDs must be numeric integers (for legacy system compatibility)
- **ADR-0002**: All API responses must be wrapped in `{ "data": ... }` (for future pagination/metadata)
- **ADR-0003**: Business logic must live in `src/services/`, not in controllers (separation of concerns)

Nothing revolutionary—these are the kinds of rules teams agree on during week one and then quietly violate by week four. The interesting part is what makes the AI reviewer aware of them.

## The `.github/copilot-instructions.md` trick

GitHub Copilot Code Review can be customized with a file at `.github/copilot-instructions.md`. This is what I think of as the AI reviewer's "brain"—a plain-text document that tells Copilot how to behave during reviews.

In this demo, the instructions tell Copilot to act as a Senior Software Architect whose primary responsibility is cross-referencing every PR against the ADRs in `docs/adr/`. Here's the core of it:

```markdown
## Role
Act as a **Senior Software Architect** reviewing all pull requests 
for architectural compliance.

## Primary Responsibility
For every pull request, you **must** cross-reference the code changes 
against the Architecture Decision Records (ADRs) located in `docs/adr/`.

## Review Process
1. List all files in `docs/adr/` directory
2. Read each ADR file to understand the architectural rules
3. Cross-reference code changes in the PR against each ADR
4. Flag any violations found
```

And when it finds a violation, it should use this format:

```
🚫 **Architecture Violation: ADR-[NUMBER]**

**Issue:** [Describe what violates the ADR]
**ADR Reference:** `docs/adr/[ADR-FILE].md`
**Rule:** [Quote the specific rule from the ADR]
**Required Action:** [How to fix it]
```

This is a simple idea but a powerful one. The ADRs are already in the repo. The reviewer reads them before every review. No need to maintain a separate checklist or hope that reviewers remember the rules from six months ago.

## Seeing it in action: PR #6

I instructed GitHub Copilot coding agent to open [PR #6](https://github.com/shinglyu/ai-adr-review-demo/pull/6) to add `birthDate` and `deathDate` fields to the `Author` model—a reasonable feature request. (PRs #1–5 were trial-and-error experiments while I was setting up the demo.) But I also slipped in a change: asking the agent to switch the Author ID from `number` to `string` (UUID), with the rationale that "number-based IDs look weird." This simulates a new developer who hasn't read the ADRs and just tells the agent to code things their preferred way.

Copilot caught it. Seven times. Here's one of the inline comments on `src/models/Author.ts`:

> 🚫 **Architecture Violation: ADR-0001**
>
> **Issue:** The `Author` model has changed from using `id: number` to `id: string` (UUID), which violates the established architectural decision.
>
> **ADR Reference:** `docs/adr/0001-numeric-ids.md`
>
> **Rule:** "All primary keys and public resource IDs must use **numeric integers** (e.g., `id: number` in TypeScript, `INTEGER` in databases)."
>
> The ADR explicitly states: "All models in `src/models/` must use `id: number`" and provides an example showing that `id: string` for UUID is incorrect.
>
> **Required Action:** Revert the ID type from `string` back to `number` to maintain compatibility with legacy systems as documented in ADR-0001. If UUID support is truly needed, this would require first updating or superseding ADR-0001 through the proper architectural decision process.

What I find great about this is the last line: *"If UUID support is truly needed, this would require first updating or superseding ADR-0001 through the proper architectural decision process."* The reviewer isn't just saying no—it's explaining the escape hatch. You can change the architecture, but you have to do it explicitly by updating the ADR, not by quietly sneaking it in through a PR.

The PR summary was equally clear:

> This PR attempts to extend the `Author` model with optional `birthDate` and `deathDate` fields for time-period filtering, but fundamentally violates the codebase's architectural standards by changing IDs from numeric integers to UUID strings.

It recognized that the `birthDate`/`deathDate` part was fine—it was the UUID change that was the problem. That kind of nuance is what makes this more useful than a grep-based linter.

## The really interesting one: PR #10

[PR #10](https://github.com/shinglyu/ai-adr-review-demo/pull/10) is where it gets more interesting. I used GitHub Copilot coding agent (the SWE agent) to implement a new feature—book reviews with CRUD and average rating calculation. In the issue, I deliberately told it: "Keep all logic in `src/controllers` for simplicity."

That instruction directly violates ADR-0003, which requires business logic to live in the service layer.

The coding agent pushed back—in the PR description itself:

> **ADR note:** The issue requested keeping logic in controllers, which would violate **ADR-0003**. Business logic and data access are in the service layer per the established architecture.

So it didn't follow the instruction. It implemented the feature correctly, explained why it deviated from my request, and flagged the conflict. I thought I'd push it a bit more, so I left a comment: "@copilot Services is redundant, just do the business logic in controller."

The agent replied:

> Moving business logic into the controller would violate **ADR-0003** (`docs/adr/0003-service-layer.md`), which states:
>
> > **Controllers must NOT contain:**
> > - Direct database queries
> > - Business logic or calculations
> > - Data validation beyond basic type checking
> >
> > **All business logic and data access must be in `src/services/`.**
>
> The average rating calculation, rating range validation (1–5), and all data access are exactly the kind of logic ADR-0003 requires to live in the service layer. I'll keep the current structure to stay compliant. **If you'd like to supersede ADR-0003, please update `docs/adr/0003-service-layer.md` first and I'll refactor accordingly.**

I think that last sentence is the key insight. The agent isn't blindly following my instructions—it's following the documented architecture. If I want to change the architecture, I need to change the ADR first. The ADR is the authority, not the person typing into the chat.

This is a subtle but important shift. In normal AI coding workflows, the human is always in control: whatever you tell the agent to do, it does. But when the ADRs are in the repository and the agent is configured to respect them, the documented architecture becomes a constraint that even the project owner can't casually override.

There's a useful flip side to this too. If you've genuinely discussed a new architectural decision with your team and everyone agrees, you can ask the coding agent to write the code *and* add the new ADR in the same PR. The PR becomes the record of both the decision and its implementation—you get a clear lineage of when the decision was made, what code it produced, and who approved it. Code and ADRs stay in sync by construction.

## Why ADRs in the repository matter

I've seen teams keep ADRs in Confluence, Notion, Google Docs—all sorts of places. The problem with that is AI tools like Copilot can't easily read them. They live in a separate system, outside the code review context.

When ADRs live in the repository (in `docs/adr/`), they become first-class citizens:

- They get reviewed and approved through the same PR process as code
- They show up in git history—you can see when a decision was made and why
- AI reviewers can read them automatically without any integration work
- They're versioned together with the code, so you can check out an old commit and see what the architecture looked like at that point

The `.github/copilot-instructions.md` file is the bridge between the ADRs and the reviewer. It tells Copilot where to look and how to interpret what it finds.

## Setting it up yourself

If you want to try this in your own project, the setup is straightforward:

1. **Create your ADRs** in `docs/adr/` (or wherever you prefer). Use a consistent format—status, context, decision, consequences, compliance.

2. **Add a `.github/copilot-instructions.md`** file that tells Copilot to act as an architecture compliance reviewer. Point it to your ADR directory and give it the violation comment template.

3. **Enable GitHub Copilot Code Review** in your repository settings (Settings → Code security and analysis).

4. **Optional**: Enable GitHub Copilot auto review so Copilot is automatically assigned as a reviewer on every PR, without having to add it manually each time.

The demo repository has all of this set up. Fork it and try opening a PR that violates one of the ADRs—it's a good way to see how the reviewer behaves before rolling it out on a real project.

## Summary

The one thing I'll note: the coding agent (SWE agent) and the code reviewer are different tools, but both respect the `copilot-instructions.md` file. The coding agent proactively avoids violations as it writes code; the reviewer flags them after the fact. Together they create two layers of enforcement.

So to summarize what we've built: ADRs stored in `docs/adr/`, a `.github/copilot-instructions.md` that tells Copilot to act as an architecture compliance agent, and GitHub Copilot Code Review enabled on the repository. That's it. For near-zero setup cost, you get a reviewer that has read every ADR, never forgets them, and is on call for every single PR. For teams with high turnover, or where the architecture has accumulated many small decisions that newer developers don't know about, this is a pretty compelling way to keep things consistent.

Give it a try: [shinglyu/ai-adr-review-demo](https://github.com/shinglyu/ai-adr-review-demo).
