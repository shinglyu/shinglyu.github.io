---
layout: post
title: "Are you yak shaving with AI?"
categories: blog
date: 2026-07-19 14:11:09 +0000
excerpt_separator: <!--more-->
tags: [AI, productivity, agents, yak-shaving]
grammar_checked: false
fact_checked: false
---

Back then, if I wanted to start a side project, I would tell myself I only needed one hour to get going. Then I would open Vim, look at my `vimrc`, tweak a color theme, try a new font, remap a few keys, and somehow five days would disappear before I wrote anything real.

That's **yak shaving**—solving tangential problems instead of the main one. You wanted to build something, but first you had to fix the tooling. Then the tooling felt important enough to keep optimizing.

Now the tools have changed, but the instinct feels very familiar. Instead of tweaking my editor all day, I tweak AI agents. I test the latest model. I rewrite prompts. I build a new harness. I try to make the whole thing fully automatic. Sometimes I even build beautiful infinite loops that produce a lot of logs and spend a lot of tokens, but not much actual value.

The trap is *more seductive now*. I can actually get a prototype in three hours. That's real progress, not fake. But then I notice the prompt could be better. The agent could route tools differently. I could build an evaluation harness. And two days later, I've optimized the machine more than I've used it.

<!--more-->

## Why AI makes yak shaving worse

Here's what's insidious: **AI tools evolve so fast that your optimizations decay rapidly.** 

Take chain-of-thought prompting. A few years ago, it was *the* hot technique. People spent weeks crafting the perfect CoT structure. Then models got smarter, and many started building that process directly into themselves. All those hand-tuned prompts became cargo cult. The skill evaporated.

This happens again and again. Today you're optimizing your agent's tool-calling pattern. Next month, the model's tool-use gets better by default. Today you're designing a fancy memory format. Next quarter, context windows are three times bigger. The harness you built to compensate is already obsolete.

So here's the cruel math: you're spending time yak shaving on machinery that will be outdated faster than ever. You're not just choosing between building vs. optimizing—you're optimizing something with a shrinking half-life.

The smarter models get, the more tempting the meta-work becomes, and the less time you should actually spend on it.

## A conscious choice

I want to be clear: I'm not saying don't build tooling. I'm saying *know when you're doing it*.

Some agent harnesses pay for themselves. Some prompts are genuinely leverage. The problem is that AI makes it unusually easy to blur the line between building the thing and building the machine that helps you build the thing.

The machine always looks useful because the machine *can always produce another layer*. You can ask for a harness. You can ask for eval scripts. You can ask for a prompt optimizer. And every layer looks legitimate while you're building it.

If I spend a weekend improving my agents and prompts, what do I actually have at the end? A working blog post? An app I can use? Or just a more elaborate machine that hasn't produced anything yet?

## The real question

Before you sink time into another loop, another harness, another prompt refinement: **did you ship the actual thing, or only improve the AI workflow around it?**

That's the question I want to keep asking myself.

When we say we're "working with AI," sometimes we're building something real very quickly. Other times we're just doing the 2026 version of editing a `.vimrc` for the fifth time—except the text editor is running in a loop, and the loops are consuming tokens instead of keystrokes.

The tools are faster. The output is real. But the yak is still there.
