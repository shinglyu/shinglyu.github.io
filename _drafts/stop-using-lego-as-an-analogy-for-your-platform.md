---
layout: post
title: "Stop Using LEGO as an Analogy for Your Platform"
date: 2026-02-21 00:00:00 +01:00
categories: blog
excerpt_separator: <!--more-->
---

Almost every company I've worked with has had a platform team that, at some point during a quarterly planning meeting or a grand re-org, announced they were going to build a "modular platform—like LEGO." The CTO nods. The roadmap gets updated. Everyone goes home feeling like they've cracked the hardest problem in software engineering. Then, twelve to eighteen months later, the same team is buried in on-call tickets, confused by dependency conflicts, and wondering why no one is actually using what they built.

I've seen this pattern enough times that I've started to think the analogy itself is leading teams in the wrong direction—and when the mental model is off, the execution follows.

<!--more-->

## Why the LEGO analogy is misleading

LEGO is a beautiful system. Every brick snaps into every other brick. The connection interface hasn't changed in decades. You can combine a 1960s brick with one from last year's Star Wars set and it'll just work. It's deterministic, universal, and permanent.

Software APIs are none of those things.

When you tell your organization "we're building a platform like LEGO," you're accidentally promising all of that. Fixed interfaces. Universal compatibility. Plug-and-play composability. And that sets everyone up for disappointment, because what you're actually building is more like a living organism than a toy.

Let me be more concrete about where the analogy specifically breaks down.

### Fixed vs. evolving interfaces

LEGO connectors are immutable physics. A software API is a negotiated contract that has to evolve. Business requirements change. Security standards evolve. You realize six months in that your original abstraction was wrong and you need to break it. In LEGO, you never need to deprecate the stud. In software, versioning and migration paths are the actual work—and the LEGO analogy gives developers no mental model for this.

I've watched platform teams get paralyzed by this. They try so hard to define the "perfect, universal interface" upfront (because that's what LEGO has) that they over-engineer a rigid abstraction that no real use case quite fits. Then they're stuck—changing it means admitting the interface wasn't universal, which breaks the whole metaphor.

### No context or state

Pick up a LEGO brick. It doesn't care where it's been. It has no memory of the structure it was part of last Tuesday. Software modules are the opposite—they're deeply entangled with runtime state, environment variables, the data that's flowing through them right now, and the history of calls that led to this moment.

When your "module" has to handle multi-tenancy, or rate limits, or different behavior based on who's calling it, the neat "snap-in brick" analogy just... dissolves.

### Guaranteed vs. problematic compatibility

Here's the thing about LEGO: it ships with a compatibility guarantee baked into the physical laws of the universe. Software ships with `package.json` and a prayer.

Version conflicts, transitive dependency hell, runtime behavior differences between environments—these aren't edge cases that a good platform team can eventually eliminate. They're just the current reality of software composition. The LEGO analogy obscures this, making teams think compatibility is a solved problem that they just haven't gotten to yet.

### Structural vs. behavioral composition

LEGO creates structures—static arrangements of physical bricks. Software composition is dynamic and behavioral. You're not stacking bricks; you're coordinating running processes that call each other, send messages, emit events, share state, fail independently, and need to be observed.

A house made of LEGO doesn't need a circuit breaker. A distributed service does.

## What the analogy actually distracts you from

This is the part that I think is more costly than just the conceptual mismatch. The LEGO framing actively leads platform teams to focus on the wrong things.

**It distracts from developer experience.** When you're building "bricks," your mental model is about the parts—their shapes, their interfaces, their combinability. You're not thinking about the people who have to use them. A platform is a product. It has users (your developers). Those users need golden paths—opinionated, well-documented, "this is the blessed way to do this" journeys that make the common case easy. A pile of well-designed bricks with no assembly instructions is still just a pile.

I've seen this mistake made repeatedly: a platform team ships a beautifully architected set of modules, writes a 40-page README, and then is confused when adoption is low. Because the cognitive load of figuring out how all these bricks fit together was still on the developer. The platform hadn't actually absorbed any complexity—it had just repackaged it.

Think about how children actually use LEGO. They don't start with a big box of basic bricks and build from first principles. They start with a themed set—a castle, a spaceship, a city fire station—and follow the instructions to build something complete and satisfying. Only later, once they understand what's fun and possible, do they start buying the basic brick boxes and inventing their own creations. Platform teams that skip straight to "here are all the primitives, assemble as needed" have it backwards. Figure out what your developers are actually trying to build first. Interview them. Then work backwards to the abstractions that make sense for their problems—not the ones that feel elegant from the platform team's perspective.

**It distracts from the real job: owning complexity.** The LEGO analogy implies that you can *remove* complexity by breaking things into bricks. You can't. There's a principle sometimes called [Tesler's Law](https://lawsofux.com/teslers-law/)—the Law of Conservation of Complexity—which says complexity doesn't disappear, it just moves.

The platform team's job is to absorb the hard stuff (security, compliance, observability, multi-region failover) so application developers don't have to think about it. That's not modularization; that's encapsulation with serious investment behind it.

**It turns a socio-technical problem into a purely technical one.** Getting a platform adopted across an engineering organization is at least as much about culture and buy-in as it is about API design. Developers are stubborn people (I say this fondly). They'll work around a platform they don't trust or don't understand, even if it's technically superior. Building alignment, doing internal advocacy, understanding why teams resist—this is real work that gets deprioritized when you're busy perfecting your "universal connector."

**Technology moves faster than LEGO plastic.** LEGO can plan a [multi-year transition to renewable materials](https://www.theguardian.com/lifeandstyle/article/2024/aug/28/lego-plans-to-make-half-the-plastic-in-bricks-from-renewable-materials-by-2026) because the physics of their product are stable. Platform teams don't have that luxury. Container runtimes, observability tools, security frameworks, AI-assisted coding—the underlying technologies your platform is built on are evolving constantly, and the developer expectations around them are evolving even faster. If your platform can't keep pace, developers will start requesting exceptions to use the newer tools you don't yet support. And if they can't get exceptions, they'll quietly route around you and build shadow IT. The LEGO analogy gives no mental model for this kind of velocity.

## So what should platform teams actually focus on?

I don't want to just tear down the analogy without offering something better, so here's what I think good platform work actually looks like.

**Lay down design principles before picking components.** It's tempting to jump straight to "we need a logging service, a secrets manager, and a deployment pipeline." Don't. Start by articulating what the platform stands for: loose coupling, secure by default, observable by default, safe migration paths. Get alignment on those principles first. The specific components can come later—and they'll be better for it, because you're not picking tools in a vacuum.

**Start with end-to-end products, then extract common patterns.** Don't begin by designing a "universal logging platform" and then force teams to migrate onto it. Instead, look at what your best-run services already do well. Embed with those teams. Understand their actual workflows end to end. Then, gradually, extract the patterns that show up repeatedly—and formalize those into platform offerings. The platform grows bottom-up from real usage, not top-down from an architect's whiteboard.

**Own the hard stuff.** Security, observability, compliance, cost management—these are your job, not something you push down to application teams through a "configurable module." The value of a platform is that every team using it gets these things for free, without having to think about them. This is harder than building a modular API. It's also far more valuable.

**Measure cognitive load, not just adoption.** Developer satisfaction surveys, time-to-first-deploy, number of support tickets per team—these tell you whether the platform is actually reducing friction. If teams are using your platform but constantly asking for help, you haven't succeeded. You've just moved the complexity from their codebase to your Slack channel.

## A better analogy?

If I had to suggest an alternative, I'd say: think less like LEGO and more like a city's infrastructure. Roads, electricity, water pipes. These are designed to evolve (roads get repaved, pipes get upgraded), they have governance (zoning laws, building codes), they absorb complexity (you don't have to understand how the water treatment plant works to turn on your tap), and their success is measured by what they enable, not by how elegantly they're composed.

It's a less satisfying pitch in a quarterly planning meeting, I'll admit. "We're building the water pipes of engineering" doesn't have the same ring. But I think it's actually closer to what good platform work feels like from the inside.

The teams I've seen succeed at platform engineering weren't the ones chasing the most elegant modular architecture. They were the ones who understood that their job was to serve developers, absorb complexity, and make change safe—and who were honest about how hard all of that actually is. No metaphor about interlocking plastic bricks was going to help them do that.

Stop selling LEGO. Start building infrastructure.
