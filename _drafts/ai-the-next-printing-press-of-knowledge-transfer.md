---
layout: post
title: "AI Is the Printing Press of Our Time: A New Golden Age of Knowledge Transfer"
categories: blog
date: 2026-04-24 12:00:00 +0000
tags: [AI, knowledge-transfer, agentic-ai, MCP]
excerpt_separator: <!--more-->
grammar_checked: true
fact_checked: true
---

Ask any developer how they feel about writing documentation and you'll usually get a pained look. We are, as a profession, enthusiastic code writers and reluctant prose writers: the README that still says "TODO: fill this in," the architectural decision that lives in one senior engineer's head and gets re-explained to every new hire, and the comment that just says `// see Slack`. And yet — I've noticed something strange lately. These same documentation-avoiders are now spending hours, sometimes late into the evening, carefully crafting and refining instruction files such as `AGENT.md` (or other repo-level agent instruction files) and `` `.github/copilot-instructions.md` ``, and sometimes reusable skill definitions in folders such as `` `.github/skills/<skill-name>/SKILL.md` ``. Not because their manager asked, but because the agent did something slightly off, and they found themselves, at midnight, editing a natural-language instruction file to be more precise about the third step.

I find this genuinely fascinating: the very people who spent careers avoiding documentation are now crafting it obsessively, compelled by a simple fact—the documentation actually runs.

<!--more-->

## The printing press and the cost of distribution

Gutenberg's movable-type printing press in Europe (c. 1440) didn't automatically create new ideas. What it did was make it dramatically cheaper to reproduce and circulate texts that already existed. Before the press, a single manuscript had to be copied by hand — a process so expensive and slow that most works circulated in only a handful of copies, typically held by monasteries, universities, or wealthy patrons. The church and elites often controlled knowledge not because they were the only people who had ideas, but because they controlled the copying and distribution infrastructure that determined who could access them.

When the press spread, that monopoly weakened. Works such as Luther's 95 Theses (1517) could spread across Europe far faster than hand-copied manuscripts; pamphlets were cheap to print and could be reproduced in many places. The Scientific Revolution and the Enlightenment were accelerated in part because print made it easier to share, compare, and debate ideas.

The parallel to AI rests on this same structural shift: not in knowledge distribution, but in knowledge encoding.

## Why encoding knowledge was so expensive before

Before AI, two primary methods existed for encoding expert knowledge: books and code.

Books have obvious problems. They can't be too long, or no one will buy them or read them. They take one to three years to write — by the time a Kubernetes book reaches the shelves, the tooling has already moved on. They have to be marketable enough for a publisher to take them on, which rules out enormous amounts of domain expertise that is valuable but commercially unattractive. Nobody publishes "How to Run Our Team's Deployment Procedure"—that knowledge remains embedded in people's minds or scattered across Slack threads, departing when they do.

(Video courses and interactive learning platforms exist too, and they're genuinely useful in their own right — but for the purposes of this argument, they share most of the same constraints: they take months to produce, they need a large enough audience to justify the effort, and they go stale quickly. I'm treating them as a variation on the same problem.)

Code has a different set of constraints. Encoding knowledge in software requires engineering skills that most domain experts simply don't have. A doctor, a lawyer, or an accountant can't write a service that captures their reasoning process. And even when engineers are involved, code only handles the deterministic slice of expertise. You can write a linter rule for "no `var` in JavaScript" because that's a binary check. You cannot write a linter rule for "this is a well-structured API given our team's current constraints." The judgment calls — which are often where the most valuable expertise lives — don't map cleanly to code. Add the cost of building, deploying, and maintaining the system, and it becomes clear why most knowledge never gets encoded at all.

## What's different about AI instructions

AI instructions don't have most of those constraints.

They can be as long as the context window can handle — no publisher, no page count, no "will readers buy this?" They're cheap to produce—not merely in monetary terms, but in the cognitive effort required to materialize them. You can do a rough brain dump, ask an AI to help structure it, and have something useful in a few hours.

There's something qualitatively different about AI instructions compared to books, too: they produce value even for an audience of one. A book reaching only 200 readers rarely justifies its production cost; by contrast, a `weekly-research.md` workflow that I execute solo each Friday repays its hour of creation immediately. My [weekly research workflow](https://shinglyu.com/blog/2026/04/15/automating-weekly-research-with-github-agentic-workflows.html) uses GitHub Agentic Workflows to pull together recent news on topics I care about, drops a summary into my Obsidian vault, and opens a pull request for me to review. Nobody else uses it, and that's perfectly fine. The encoding cost was low enough that a personal audience is completely viable.

Domain experts can write them directly, too. A doctor who wants to encode "how I approach diagnosing this symptom cluster" doesn't need to learn Python. They can write a structured natural-language description — such as an `AGENT.md`-style instruction file or a repository instruction file — and an AI agent can work from it. That's a meaningful shift. Most knowledge encoding used to require an engineering intermediary. That intermediary is increasingly optional.

## Non-deterministic rules are now encodable

There's one more dimension where AI instructions outpace code: they can express rules that aren't deterministic.

Consider the challenge of writing code to select "interesting recent developments in AI" for a weekly digest. You could filter by keyword, by publication date, maybe by engagement metrics — but the actual judgment of what's genuinely relevant to a specific person in a specific context can't be reduced to a boolean expression. That kind of filtering requires, well, judgment.

AI instructions can express exactly this. In my weekly research workflow, I describe which topics I want tracked, what level of technical depth I'm looking for, and roughly how I want the summary structured. None of those are deterministic rules — they're preferences, and the agent interprets them. It's the kind of guidance that a thoughtful colleague could follow naturally, but that code never really could.

## The feedback loop books never had

One often-underestimated advantage surfaces here: AI-encoded knowledge is genuinely verifiable in ways books never were.

For books, the signals are all indirect — sales figures, reader reviews, whether someone eventually invited you to give a talk or translate the book into another language. Those tell you something about demand, but they're lagging indicators and they don't tell you what actually worked. For the fuzzy genre of business and management books — the ones full of frameworks and principles that need to be adapted to real situations — it's often genuinely difficult to know whether readers extracted value or just set the book on a shelf after chapter two. The advice might be perfectly sound; whether it was actually useful in practice is a much harder question to answer.

For AI agents, verification starts at the most basic level: did the task succeed? At a minimum, you run the agent and check. From there, you can benchmark against a set of test cases, measure success rates, and pinpoint exactly which step in a workflow fails. With the `gh aw` CLI for GitHub Agentic Workflows, you can inspect recent runs and drill into a specific execution to see how the agent interpreted your instructions — which is something that would previously have required a round of user interviews or a lot of guessing. Logs and audit trails let you observe agent behavior firsthand, rather than relying on indirect signals.

But there's another dimension here that I think is easy to underestimate: when people actively work with these agents and want results, they leave direct feedback. A comment correcting the output. A clarification appended to the instructions. A follow-up message explaining what the agent misunderstood. That feedback is an immediate, actionable signal for improving the instructions — far more direct than wondering, months after a book ships, whether the advice actually landed. I already have this running for my blog writing agent and general-purpose agent: a workflow that reads my feedback on past runs and updates the agent instructions so it won't repeat the same mistake. I'll write more about that in a follow-up post.

## A golden age of knowledge transfer

So here's the parallel I keep coming back to. The printing press didn't create new knowledge — it broke the monopoly on distributing it. The Church and the aristocracy had controlled knowledge not because they were the only ones who possessed it, but because reproduction was expensive enough that they controlled the infrastructure.

AI instructions are doing something similar for knowledge encoding. The bottleneck was never the lack of expertise — it was the cost of getting that expertise out of people's heads and into a form that could be shared, scaled, and executed. Books were too slow to write and too constrained by commercial viability. Code required specialized skills and only handled the deterministic slice. Most expertise just never got encoded.

Now the cost has dropped enough that a single person's workflow is worth encoding. An individual team's architectural decisions are worth encoding. A doctor's diagnostic heuristics, a lawyer's intake process, an accountant's review checklist — all of these are suddenly within reach.

I think we're at the beginning of a period where an enormous amount of expertise that was previously locked in people's heads finally gets encoded, shared, and executed by AI agents. Not because AI invented new knowledge domains. Because it finally made encoding existing knowledge cheap enough to be worth doing.
