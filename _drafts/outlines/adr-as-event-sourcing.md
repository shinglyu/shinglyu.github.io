# ADR as Event Sourcing: Rethinking Software Architecture Documentation in the Age of AI

## Opening Hook / Motivation
* A provoking question: Does any organization actually have good, up-to-date software architecture documentation?
    * Most architecture docs become outdated the moment they're written
    * Engineers don't have time to maintain documentation while shipping features
    * Traditional ADRs are often written after decisions are made, not during the decision-making process
* The fundamental problem: Documentation is treated as a separate activity from decision-making
    * Writing ADRs requires dedicated time that teams rarely have
    * By the time an ADR is written, the context and nuances are often lost
    * Documentation lags behind reality, making it unreliable
    * Architecture docs are spotty - when you're busy, you forget to write parts of your architecture

## The Core Idea: ADR as Event Sourcing
* What if we treated ADRs more like event sourcing?
    * In event sourcing, we capture events as they happen, not after the fact
    * Architecture decisions happen in real-time during meetings, Slack/Teams conversations, and discussions
    * Instead of writing comprehensive docs later, we should capture the decision stream as it flows
    * This includes both the event stream layer (individual ADRs) and snapshot layer (current architecture state) - will be explained in detail later
* How Generative AI enables this shift
    * AI can transcribe meeting discussions and extract architecture decisions in real-time
    * Chat conversations on Slack/Teams can be automatically analyzed for architectural implications
    * ADRs can be generated immediately after meetings while context is still fresh
    * This solves the "not enough time to write" problem - AI does the writing
* The two-layer approach
    * **Event stream layer**: Individual ADRs capturing decisions as they happen (the events)
    * **Snapshot layer**: Current state of architecture, updated based on ADRs (the projection)
        * Should be automatically updated by AI based on accumulated ADRs
        * If we're unsure about current architecture status, we can infer it from all ADRs combined
        * Like event sourcing replay: reconstruct current state from event history
        * With AI, this reconstruction work (previously hard manual work) can now be done much more efficiently

## Implementation Approaches
* Project kickoff: Establish guiding principles first
    * At project kickoff, need to document high-level ideas, business values, and guiding principles
    * This can be done with AI help based on meeting transcripts
    * Critical foundation: Without these guiding principles, AI writing ADRs may assume something completely wrong
    * Ensures all subsequent ADRs align with project vision
* Capturing the decision stream
    * Meeting transcriptions automatically converted to ADR drafts
    * Slack/Teams bot monitoring architecture-related conversations
    * Pull request discussions analyzed for architectural implications
    * Design review notes automatically structured as ADRs
* Generating ADRs with AI
    * Post-meeting AI processing to extract key decisions
    * Standardized ADR format generation from unstructured conversations
    * Context preservation: who decided what, why, and what alternatives were considered
* Maintaining the architecture snapshot
    * AI-powered updates to architecture documentation based on new ADRs
    * Automated consistency checks between ADRs and current architecture
    * Version control for architecture evolution tracking

## Future Directions: AI-Powered Architecture Governance
The workflow progresses through these stages: design → submission → implementation

* **Formal method verification with AI (during design phase)**
    * What is TLA+: A brief introduction
        * TLA+ (Temporal Logic of Actions) is a formal specification language
        * Used to design, model, and verify concurrent and distributed systems
        * Can catch design flaws before any code is written
        * Not widely known outside formal methods community
    * Using tools like TLA+ to verify architecture and algorithm correctness
    * AI generating TLA+ code from architecture design documents
    * Catching design flaws (deadlocks, race conditions, invariant violations) before implementation
    * Making formal methods accessible to teams without specialized expertise

* **AI-powered architecture review in CI/CD (when architecture is being submitted)**
    * Pre-commit ADR review: AI architect checking new ADRs against organization standards
    * Security compliance checks: Verifying architectural decisions meet security requirements
    * Policy enforcement before changes are merged
    * Cross-organizational pattern validation before approval

* **Automated architecture compliance checks (during implementation)**
    * AI comparing actual codebase against documented architecture
    * Pre-commit code review: AI checking code for architecture compliance
    * Identifying architectural drift before it becomes problematic
    * Suggesting refactoring when code deviates from intended design
    * Continuous architecture validation in CI/CD

* **Cross-organizational architecture intelligence (throughout all phases)**
    * AI with access to internal documentation across the organization
    * Finding reusable components and shared patterns before new design is proposed
    * Preventing duplicate efforts and promoting consistency
    * Identifying similar designs to learn from past decisions
    * Building organizational architecture knowledge graph

## Benefits and Implications
* Reduced documentation burden
    * Engineers focus on making decisions, AI handles documentation
    * Real-time capture means no loss of context
    * Documentation stays synchronized with reality
* Better decision quality
    * AI can surface similar past decisions for context
    * Cross-organizational patterns become visible
    * Consistency across teams improves naturally
* Faster onboarding and knowledge transfer
    * New team members can replay ADR history to understand architectural evolution
    * Context and reasoning preserved, not just final decisions
    * AI can answer questions about why things are the way they are
* Proactive architecture governance
    * Catch issues early through automated compliance checks
    * Prevent technical debt accumulation
    * Enforce best practices consistently

## Challenges and Considerations
* Privacy and sensitivity of meeting transcriptions
    * Need proper access controls and data governance
    * Not all discussions should be automatically documented
    * High-stake meetings with heated debates: AI shouldn't mark people as irrational or troublemakers - huge political risk
* AI accuracy and hallucination risks
    * Generated ADRs need human review and approval
    * Critical decisions should still have human oversight
    * Balance automation with accountability
* Cultural change required
    * Teams need to trust AI-generated documentation
    * Shift from "writing docs" to "reviewing AI-generated docs"
    * Requires organizational buy-in and process changes
* Tool integration and infrastructure
    * Most enterprises still buy several disconnected AI solutions - integration is a big hassle
    * Need seamless integration with existing tools (Slack, Teams, meeting software)
    * Version control is critical for AI - allows rollback and auditable history, but not user-friendly to non-technical users

## Conclusion
* The shift from manual documentation to AI-assisted event-driven ADRs
    * Event sourcing mindset: capture decisions as they happen
    * AI as the documentation assistant, not the decision maker
    * Maintain both the event stream (ADRs) and the snapshot (current architecture)
* The future of architecture work with AI
    * More time for actual design and decision-making
    * Less time on administrative documentation tasks
    * Better quality decisions through AI-powered insights and compliance checks
* Call to action: Experiment with AI-powered ADR workflows
    * Start small: transcribe one meeting and generate an ADR
    * Build incrementally: add compliance checks, cross-organizational search
    * Share learnings with the community
