---
layout: post
title: "ADR as Event Sourcing: Rethinking Software Architecture Documentation in the Age of AI"
categories: Architecture
date: 2026-02-07 00:00:00 +01:00
excerpt_separator: <!--more-->
---

Does any organization actually have good, up-to-date software architecture documentation? I've worked with enough teams to know the answer is almost always "no." Most architecture docs become outdated the moment they're written. Engineers don't have time to maintain documentation while shipping features. Traditional Architecture Decision Records (ADRs) are often written after decisions are made, not during the decision-making process. And when you're busy, you simply forget to document parts of your architecture, leaving it spotty and unreliable. With Generative AI, I think we should treat ADRs more like event sourcing—capturing decisions as they happen, not reconstructing them from memory weeks later.

<!--more-->

## The Fundamental Problem with Architecture Documentation

Documentation is treated as a separate activity from decision-making, and that's where everything breaks down. Writing ADRs requires dedicated time that teams rarely have. By the time an ADR gets written, the context and nuances are often lost. People forget the alternatives that were considered, why certain options were rejected, and what constraints influenced the final decision.

The result? Documentation lags behind reality, making it unreliable. Teams stop trusting their own docs. New engineers joining the team have no reliable source of truth about why things are the way they are. Architecture debt accumulates invisibly because there's no record of what the intended design was supposed to be.

## The Core Idea: Treat ADRs Like Event Sourcing

What if we treated ADRs more like event sourcing? In event sourcing, we capture events as they happen, not after the fact in big batches like in dedicated document writing timeslots. Architecture decisions happen in real-time during meetings, Slack or Zoom conversations, and design discussions. Instead of writing comprehensive docs later, we should capture the decision stream as it flows.

This includes both the event stream layer (individual ADRs capturing each decision) and a snapshot layer (the current state of the architecture)—I'll explain this two-layer approach in detail shortly.

### How Generative AI Enables This Shift

AI fundamentally changes what's possible:

- **Real-time transcription and extraction**: AI can transcribe meeting discussions and extract architecture decisions in real-time. Modern LLMs can clean up transcriptions based on context, making the quality better than ever before—even though we've had speech-to-text for a long time. Those casual hallway conversations where the most important decisions get made? While always-on AI-enabled recorders could capture them (though I'm not comfortable with that approach), even without such tools, being able to quickly talk into a recorder and transcribe it is a faster way to capture knowledge while it's still fresh.

- **Automatic analysis of chat conversations**: Chat conversations (like those in Slack, Zoom, and similar tools) can be automatically analyzed for architectural implications. When someone says "we should switch to event-driven architecture for this," AI can flag it and create an ADR draft.

- **Immediate post-meeting generation**: ADRs can be generated immediately after meetings while context is still fresh. No more "I'll write that up next week" that never happens. Combined with my [previous post about the busy parent setup](https://shinglyu.com/ai/2026/01/29/my-remote-vibe-coding-setup.html), the AI can start the work in the background on the cloud while you go to the next meeting—so you don't have the excuse that you have back-to-back meetings.

This solves the "not enough time to write" problem—AI does the writing. Humans make the decisions and provide oversight, but the administrative burden of documentation disappears.

### The Two-Layer Approach

The event sourcing model has two layers, and we should adopt the same structure for architecture documentation:

**Event stream layer**: Individual ADRs capturing decisions as they happen (the events). Each meeting, each design discussion, each significant conversation generates an ADR. These are immutable records of what was decided, when, and why.

**Snapshot layer**: Current state of architecture, updated based on ADRs (the projection). This is the "big picture" document that answers "what does our architecture look like right now?" It should be automatically updated by AI based on accumulated ADRs.

If we're unsure about the current architecture status, we can infer it from all ADRs combined—like event sourcing replay, where you reconstruct current state from event history. With AI, this reconstruction work (which was previously hard manual work) can now be done much more efficiently.

## Implementation: Making It Work in Practice

### Project Kickoff: Establish Guiding Principles First

Before any AI-generated ADRs, you need a foundation. At project kickoff, you must document high-level ideas, business values, and guiding principles. This can be done with AI help based on meeting transcripts, but it's a critical step.

Why is this so important? Without these guiding principles, AI writing ADRs may assume something completely wrong. If the AI doesn't know that your team values "simplicity over features" or "prefer boring technology," it might generate ADRs that completely miss the point. These guiding principles ensure all subsequent ADRs align with your project vision.

### Capturing the Decision Stream

Once you have your foundation, you can start capturing decisions:

- **Meeting transcriptions**: Automatically convert meeting recordings to ADR drafts. I tried Microsoft Teams transcription but found it terrible at handling names in my European workplace with non-English names everywhere. The quality can vary significantly, so choose your transcription tool carefully.

- **Chat monitoring**: Deploy a bot that monitors architecture-related conversations in chat tools (Slack and Zoom are common examples). When people discuss technical decisions, the bot can flag them and suggest creating an ADR.

- **Pull request discussions**: PR conversations often contain architectural decisions—"we're switching from REST to GraphQL for this API." These can be analyzed and captured automatically.

- **Design review notes**: Your design reviews already produce notes. AI can automatically structure these as ADRs instead of leaving them as unstructured meeting minutes.

### How to Write Good ADRs with AI

When generating ADRs with AI, follow these best practices:

- **Keep ADRs immutable**: Don't edit existing ADRs. Instead, add new ADRs to overwrite past decisions. This preserves the full history and lets you trace how decisions evolved over time.

- **Prompt for conciseness**: Instruct the AI to write as concisely as possible. The more it writes, the more likely it will hallucinate and the harder it becomes to review. ADRs should be short and sweet—focused on the decision, the context, and the alternatives considered.

- **Use prompt templates or subagent instructions**: Turn your ADR generation guidelines into reusable prompt templates or subagent instructions. This ensures consistency across all generated ADRs and makes it easier to maintain quality standards.

## Future Directions

### Formal Method Verification with AI (During Design Phase)

TLA+ (Temporal Logic of Actions) is a formal specification language created by Leslie Lamport, the inventor of Paxos and LaTeX. It's used to design, model, and verify concurrent and distributed systems. Unlike unit tests that check whether your code works, TLA+ can catch design flaws *before any code is written*—things like deadlocks, race conditions, and invariant violations.

The problem is that TLA+ has a steep learning curve. Most teams don't have the expertise. But with AI:

- AI can generate TLA+ code from architecture design documents
- Tools like TLA+ can verify your architecture and algorithm correctness
- Design flaws get caught before implementation begins
- Formal methods become accessible to teams without specialized expertise
- Understanding long error traces generated by TLA+ can be challenging, but AI can turn those error traces into human-understandable explanations

Imagine describing your distributed system's design in plain English, and AI produces a TLA+ spec that proves whether your design can deadlock. That's the future we're heading toward.

### AI-Powered Architecture Review (When Architecture Is Being Submitted)

Before an ADR gets merged, AI can review it:

- **Standards and security compliance**: AI checks new ADRs against organization standards and security policies. Does this decision align with our security requirements? If you're in healthcare or finance, certain architectural patterns are required by regulation. Rules like "all data must be encrypted at rest" or "no single points of failure" can be automatically enforced before changes are merged.

- **Cross-organizational validation**: Before approving a new design, AI checks if similar patterns exist elsewhere in the organization. Maybe another team already solved this problem.

- **CI/CD design validation**: Add a CI/CD step that checks the proposed architecture against standards and emerging patterns using an AI agent, catching issues before implementation begins.

### Automated Architecture Compliance Checks (During Implementation)

Once code is being written, AI ensures implementation matches design:

- **Code vs. architecture comparison**: AI compares actual codebase against documented architecture. If your ADR says "we use three-tier architecture" but your code has business logic in the UI layer, the system flags it.

- **Pre-commit code review**: Before code is committed, AI checks for architecture compliance. This prevents drift before it happens.

- **Continuous validation**: In your CI/CD pipeline, architecture compliance becomes a build step, just like tests.

### Cross-Organizational Architecture Intelligence (Throughout All Phases)

AI with access to internal documentation across the organization can:

- **Find reusable components**: Before proposing a new design, AI checks if other teams have built something similar. Maybe the payment team already has a retry mechanism you can reuse.

- **Discover shared patterns**: See patterns that work well across different teams and contexts. This prevents duplicate efforts and promotes consistency.

- **Surface similar past decisions**: When making a decision, AI can show you how other teams handled similar problems, complete with their ADRs and lessons learned.

- **Build knowledge graphs**: Over time, AI builds an organizational architecture knowledge graph showing relationships between systems, decisions, and patterns.

I've noticed that AI with access to internal documentation can really quickly help me find other designs that share the same characteristics. This saves enormous amounts of time and prevents teams from reinventing wheels.

### Digital Twin for Architects

Historically, there are few architects in an organization and they are spread thin. People often have questions about how and why an architecture was designed a certain way. Product managers have questions about how much effort or change it takes to adapt old technology to new features. 

By building a RAG (Retrieval-Augmented Generation) system based on all the architecture documents, you can build a chatbot that multiplies the architecture team's capacity. This digital twin can answer routine questions, explain design decisions, and provide guidance—freeing up actual architects to focus on strategic work.

## Benefits and Implications

### Reduced Documentation Burden

Architects focus on making decisions; AI handles documentation. Real-time capture means no loss of context. Documentation stays synchronized with reality because there's no manual step that can be skipped.

### Better Decision Quality

When AI can surface similar past decisions for context, decision quality improves. You're not making choices in a vacuum—you can see what worked and what didn't for similar problems. Cross-organizational patterns become visible, and consistency across teams improves naturally.

### Faster Onboarding and Knowledge Transfer

New team members can replay ADR history to understand architectural evolution. They see not just the current state, but *how* it got that way. Context and reasoning are preserved, not just final decisions. 

This is especially valuable for decisions that seem arbitrary or like workarounds—there might be historical reasons why it's designed that way. It also works the other way around: some decisions are thought to be set in stone, but in fact they were just random choices someone made in the past and can be easily changed. AI can answer questions about why things are the way they are, making knowledge transfer almost instantaneous.

### Proactive Architecture Governance

Instead of discovering architectural problems during incident post-mortems, you catch issues early through automated compliance checks. This avoids costly policy violations or security issues that are detected too late. Technical debt accumulation is prevented because drift is detected immediately. Best practices are enforced consistently, without relying on manual code review to catch everything.

## Challenges and Considerations

There are real challenges to address:

### Privacy and Sensitivity

Meeting transcriptions can contain sensitive information. You need proper access controls and data governance. Not all discussions should be automatically documented—some conversations need to stay private.

Here's a big one: in high-stake meetings with heated debates, you don't want the AI to mark somebody as irrational or label them as a troublemaker. That's a huge political risk. AI-generated meeting summaries need to be neutral and factual, avoiding any language that could be used politically within the organization.

### AI Accuracy and Hallucination Risks

Generated ADRs need human review and approval. AI can get things wrong—it might misinterpret a decision or miss important nuance. Critical decisions should still have human oversight. You need to balance automation with accountability.

The key is treating AI as a documentation assistant that drafts ADRs, not as the decision maker. Humans decide, AI documents.

### Cultural Change Required

Teams need to trust AI-generated documentation. That's a significant shift from the current model where humans write everything. People need to shift from "writing docs" to "reviewing AI-generated docs." This requires organizational buy-in and process changes.

Some engineers will be skeptical. They'll want to write their own ADRs. That's fine—the AI-assisted workflow should be an option, not a mandate. Let teams adopt it when they're ready.

### Tool Integration and Infrastructure

Most enterprises are still in a stage where they buy several disconnected AI solutions. Integration is a big hassle, especially when you need to connect across different vendors—chat tools like Slack or Teams, wikis, Confluence, SharePoint, and meeting software. Enterprises usually don't allow you to just build ad-hoc API integrations with AIs they don't fully control.

Version control is critical for AI—it allows rollback and auditable history. But version control systems like Git are not that user-friendly to non-technical users. Architects should be comfortable with version control tools to fully leverage this workflow.

There's also the question of AI model access and cost. Running these systems requires API access to capable AI models, which has ongoing costs.

## Conclusion: The Path Forward

The shift from manual documentation to AI-assisted event-driven ADRs is more than a productivity hack—it's a fundamental rethinking of how we approach architecture work. By adopting an event sourcing mindset, we capture decisions as they happen. AI serves as the documentation assistant, not the decision maker. We maintain both the event stream (ADRs) and the snapshot (current architecture), giving us both history and current state.

The future of architecture work with AI means more time for actual design and decision-making, less time on administrative documentation tasks, and better quality decisions through AI-powered insights and compliance checks.

My recommendation: start experimenting with AI-powered ADR workflows. Don't try to build the entire system at once. Start small—transcribe one meeting and generate an ADR from it. See how it works for your team. Then build incrementally: add compliance checks, cross-organizational search, formal verification. Share your learnings with the community.

We're at the beginning of a major shift in how architecture work gets done. The teams that figure out how to effectively combine human decision-making with AI-powered documentation and governance will have a significant advantage. The question isn't whether this will become standard practice—it's how quickly your organization will adapt.
