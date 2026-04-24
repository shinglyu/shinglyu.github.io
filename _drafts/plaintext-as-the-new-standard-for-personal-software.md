---
layout: post
title: "Why AI-Generated Personal Software Should Default to Plaintext"
categories: blog
date: 2026-04-14 20:24:19 +0000
excerpt_separator: <!--more-->
tags: [AI, plaintext, personal-software, vibe-coding, hledger, obsidian, event-sourcing]
---

A few weeks ago I was vibe-coding a personal CRM with an AI assistant. Nothing fancy — just something to log my communication with people at work: who I talked to, what we discussed, when to follow up. The AI cheerfully scaffolded the whole thing: a Python backend, a SQLite database, tables for contacts and interactions, a schema with migration scripts.

I stared at the output for a moment. A contacts table with foreign keys. For notes I could have kept in a text file.

There's nothing wrong with what the AI generated — it's following established software engineering instincts. But those instincts were built for a different kind of software. For SaaS apps with millions of users and thousands of concurrent writes, yes, you need a database. For a personal CRM on one machine used by one person? I'm not so sure.

My thesis: **plaintext files are the right default storage format for AI-generated personal software**, and we should be nudging AI assistants toward that default more deliberately.

<!--more-->

## What I mean by "personal software"

I'm talking about single-user, single-machine apps generated (or heavily assisted) by AI — what people are calling [vibe coding](https://en.wikipedia.org/wiki/Vibe_coding). A budget logger. A reading list. A habit tracker. A daily journal. A tool that scratches a very specific itch that no off-the-shelf app quite scratches.

These apps share something important: they generate a small amount of data. One person's habits, finances, or notes over years of use rarely amounts to more than a few megabytes. Compare that to a SaaS product where database indexing, sharding, and ACID guarantees genuinely matter. The scale is completely different. Personal software doesn't need the infrastructure of a bank.

I already had a vague sense of this from using [Obsidian](https://obsidian.md/) — notes as plain Markdown files, synced, searchable, no proprietary database. But the pattern really crystallized for me when I encountered [hledger](https://hledger.org/). Here was a financial tool where your entire account history lived in a text file, and deterministic CLI tools read that file to produce reports. That made the principle concrete. I wrote more about that experience in [my hledger post](https://shinglyu.com/blog/2026/03/18/hledger-and-ai.html) — the whole [plaintext accounting](https://plaintextaccounting.org/) philosophy is built on exactly this observation: a plain file is enough.

## LLMs and text: a natural fit

Here's something people sometimes overlook: LLMs are trained on text. Markdown, CSV, JSON, TOML, plain prose — that's the native habitat. When your storage format is also text, the AI can read it, modify it, summarize it, and reason about it without needing an ORM, a database driver, or an API layer. It just reads the file.

Compare that to working with a SQLite database. To interact with it, the LLM needs to introspect the schema, write correct SQL, handle query errors, parse results. That's a lot of indirection for something that could just be a text file.

I do want to be honest about a limitation here: LLMs aren't great at structured filtering or querying. Ask an AI to "find all transactions over $100 in March" in a large file and it might struggle in ways that a SQL `WHERE` clause would not. That's a real trade-off. But for personal apps, the queries are usually simple enough — or the dataset small enough — that the LLM reading the whole file works fine. "What did I eat this week?" is not a complex aggregation query.

The sweet spot I've found: let the LLM handle reading and writing the text, but pair it with a deterministic CLI tool that can check for formatting errors and syntax. The LLM brings understanding; the CLI brings reliability. I'll come back to this in the hledger section.

## The practical case for plaintext

Let me walk through why this matters beyond just "it's simpler."

### Version control — not backup, but something valuable

Drop a plaintext file in a git repo and you immediately get versioning, time travel, and the potential for branching. The ability to see exactly how your data looked three months ago, diff two versions, roll back a bad edit.

For a personal finance journal, this is genuinely useful. If the AI makes a mistake while adding entries, `git diff` shows you exactly what changed.

One clarification worth making: version control is not a backup. It doesn't protect you from a hard drive failure. But it gives you something different — a full audit trail of how your data evolved over time.

### Portability and no lock-in

Text files open in any editor on any OS. This sounds obvious but it matters a lot when the "app" is AI-generated code that might break after a dependency update. If the app breaks, you still have your data — in a format you can open in Notepad if you have to.

And if you want to migrate to a different tool? That becomes a format conversion problem, not a database migration problem. If you ever want to switch from [hledger](https://hledger.org/) to [Beancount](https://beancount.github.io/), for instance, it's mostly just text transformation. An AI can build that conversion script. Or you can rebuild the whole app with different functionality — the data stays the same. That's a completely different proposition from exporting a proprietary database format.

### Sync is already solved — mostly

[Syncthing](https://syncthing.net/), Dropbox, OneDrive, ResilioSync — file synchronization is a solved problem. For a personal app you want on multiple machines, you don't need to build a backend, set up user accounts, or deploy cloud infrastructure. The file just syncs.

This is a bigger deal than it sounds for non-technical vibe coders. A lot of people can generate a working app with AI these days — but maintaining a cloud database is a different skill entirely. You're looking at Docker or a managed cloud-native database (RDS, Cloud SQL, etc.), deployment pipelines, connection strings, cloud costs, and endless debugging when something in the infrastructure breaks. And if you misconfigure access controls — easy to do when you're hacking on a personal project — you can accidentally expose your personal data to the internet. Avoiding a database means avoiding all of that. For a personal tool, that tradeoff is almost always worth it.

That said, sync has a real limitation: conflict resolution. If the same file is updated on two machines before they sync, you can end up with a conflict. For data that changes quickly and in parallel across devices, this gets messy. [Obsidian](https://obsidian.md/) runs into this too — their free tier lets you use any file sync tool or git, but they upsell [Obsidian Sync](https://obsidian.md/sync) specifically because it handles conflicts better. For most personal apps this isn't a problem (you edit your CRM on one machine at a time), but it's worth knowing it's a real edge case.

### Auditability

You can read your own data without the app. For most personal apps this is nice-to-have. For apps where AI is generating or modifying the data, it's essential. If an AI assistant is writing entries to your budget journal, you want to be able to open the file and check. Plaintext makes it trivial to spot errors or hallucinations.

## Tools that got this right

### The gold standard: hledger

[hledger](https://hledger.org/) is a plaintext accounting tool where your entire financial history lives in a journal file that looks like this:

```text
2026-01-15 Grocery Store
    expenses:food          $52.30
    assets:checking

2026-01-17 Power Company
    expenses:utilities     $89.00
    assets:checking
```

That's it. The source of truth. The CLI tools read the file and produce deterministic, auditable reports. This is a great complement to the indeterminism of LLMs — if an AI assistant helps you record transactions, you can always open the journal file and verify each entry manually. No schema to understand, no query to write. Just text.

Here's where the LLM + deterministic CLI combination really shines. You let the LLM draft or modify entries in the journal — it understands the format naturally. Then you run `hledger check` or just `hledger balance` as a sanity pass. The CLI doesn't just check formatting; it checks business rules too. Unbalanced accounts? It'll tell you. Incorrect balance assertion? It'll tell you. The LLM brings flexibility and natural language understanding; the CLI brings strict, reliable validation. Neither is sufficient alone. Together they're genuinely useful.

The whole plaintext accounting ecosystem (see [plaintextaccounting.org](https://plaintextaccounting.org/)) is built around this philosophy.

### Obsidian — text files with a smart index layer

[Obsidian](https://obsidian.md/) stores notes as Markdown files on disk. It also builds an internal index for faster queries — the graph view, backlinks, search. But the index is a cache. The Markdown files are the truth. If Obsidian disappeared tomorrow, your notes would still be there, readable in any text editor.

Many AI agent frameworks — and agent "brains" — already use Obsidian as the view and editor layer. The agent writes to plaintext files; Obsidian renders them and lets you navigate the knowledge graph. It's a clean separation of concerns: plaintext for storage, index for performance, rich UI for browsing.

This is a pattern worth copying. Use plaintext as storage, build indexes as a performance optimization — not as the primary store.

## Patterns that plaintext makes natural

### Event sourcing — an interesting option

Plaintext opens the door to event sourcing — it's not the default, but it's a surprisingly natural fit. Instead of updating state in place, you just append new entries. Each line is an immutable fact. State is derived by replaying the log.

Consider a personal CRM as an example. One way to model it is stateful: a contacts table where you update the "last contacted" timestamp in place each time you talk to someone. That works fine. But another way is event-based: just append a line every time an interaction happens. Something like:

```text
2026-01-15 Alice - coffee chat, discussed Q1 roadmap
2026-01-17 Bob - quick sync on hiring plan
2026-01-20 Alice - follow-up email, sent proposal
```

When you want to know when you last talked to Alice, you scan the log. When you want to see all your interactions this month, you filter by date. The state is always derivable. Nothing is ever overwritten.

The event-based approach has a nice property for AI assistants: append-only is more reliable than in-place editing. An LLM doesn't need to surgically find the right line to modify — it just appends a new entry. There's much less chance of corrupting existing data.

### AI-built indexes at write time

Andrej Karpathy (OpenAI co-founder and former Tesla AI Director) has advocated for a plaintext-first approach to personal knowledge bases: store everything as Markdown files in folders, manage it with git, and use standard tools like grep for search. In a [2020 tweet](https://twitter.com/karpathy/status/1279425930683709442) he wrote: "The thing about plaintext is that it is future proof, search/index-able, script-able, diff-able, portable, not a proprietary format, hackable, and never locks you in to any tool." That philosophy applies directly to personal software.

More recently, he published a [GitHub gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) describing an "LLM wiki" pattern that takes this further. Instead of RAG — chunking documents, generating embeddings, running vector search at query time — the LLM incrementally builds and maintains a persistent wiki of Markdown files as you add sources. The key enabler is a single `index.md` file: a catalog of all wiki pages with one-line summaries. The LLM reads the index first to find relevant pages, then drills in. As the gist puts it: "This works surprisingly well at moderate scale (~100 sources, ~hundreds of pages) and avoids the need for embedding-based RAG infrastructure." No vector database. No embeddings pipeline. Just text files and an index.

I've been trying to build something in this direction — an index that gets updated alongside plaintext files as you write them — but haven't had concrete results yet. The text file stays as source of truth. The index is a derived artifact you can throw away and rebuild. This isn't something you need on day one — but it's a natural evolution of the plaintext approach.

### What if data grows too large?

For most personal apps, it won't. But if it does, traditional query engines are enough. You don't need to abandon plaintext — you just add an index layer.

[SQLite with FTS5](https://www.sqlite.org/fts5.html) (full-text search) can index a plaintext file for efficient querying. [sqlite-vec](https://github.com/asg017/sqlite-vec) adds semantic and vector search on top of SQLite. You can find this pattern in how AI agent frameworks design their memory systems — storing facts in plaintext, indexing them in SQLite for fast retrieval. The text file stays as the source of truth; SQLite is just the index layer.

## When plaintext is the wrong answer

Plaintext isn't the right answer for everything.

If your app genuinely needs complex queries — many-to-many relationships, full-text search over huge corpora, graph queries, geospatial lookups — you probably want a real database. If data volume genuinely grows beyond what's manageable as text (a personal analytics app ingesting thousands of events per day, say), then the calculus changes. And if you need ACID transactions and concurrent writes, plaintext can't help you there.

The argument isn't "never use databases." It's "don't reach for a database by default when plaintext is sufficient." For most personal apps, plaintext is more than sufficient.

## The default I'd recommend

Next time you vibe-code a personal app, push back when the AI reaches for SQLite. Ask: "Can this data fit in a text file?" Honestly, the answer is usually yes.

Plaintext + git + file sync is a low-complexity stack that covers a surprising amount of ground. It's auditable, portable, easy to back up, trivial to sync, and works beautifully with AI assistants that are trained on text.

I think the best AI-generated personal software will look more like [hledger](https://hledger.org/) than like a mini-SaaS. Small, auditable, portable, and honest about what it is. If you want to see what this looks like in practice for personal finance, check out [my earlier post on using hledger with AI](https://shinglyu.com/blog/2026/03/18/hledger-and-ai.html).
