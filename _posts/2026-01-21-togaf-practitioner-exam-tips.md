---
layout: post
title: "TOGAF Practitioner exam tips: A strategic approach to passing"
categories: Enterprise-Architecture
date: 2026-01-21
excerpt_separator: <!--more-->
---

The TOGAF Practitioner exam can be challenging, but with the right strategy, you can significantly improve your chances of success. Unlike the Foundation exam which tests knowledge recall, the Practitioner exam tests your ability to apply TOGAF principles in realistic scenarios. Here's a battle-tested approach that helped me pass the exam.

<!--more-->

## Start with the questions, not the scenario

This might sound counterintuitive, but one of the most effective strategies is to **read the questions first** before diving into the scenario. Here's why this works:

The scenarios are often long and filled with unnecessary details. By understanding what the questions are asking for first, you can filter out the noise when you eventually read the scenario.

**Use the digital scratchpad**: For each question, write down your rationale to choose or not choose a particular answer in the digital scratchpad. This helps you:
- Organize your thoughts.
- Keep track of why you eliminated certain answers.
- Review your reasoning if you have time at the end.

## Eliminate obviously wrong answers

Each question will have 4 answer choices. Your first pass should focus on eliminating answers with obvious errors. Here are the most common red flags:

**Wrong deliverable or ADM phase**: Watch out for answers that suggest:
- Working on the wrong deliverable for the current ADM step.
- Performing ADM phases in the wrong order (e.g., doing Phase B before Phase A).

TOGAF is very particular about the sequence of activities. If an answer suggests skipping phases or doing them out of order, it's likely wrong.

**Anti-patterns that TOGAF doesn't like**: The exam will test whether you understand TOGAF's philosophy, not just its mechanics. Eliminate answers that suggest:

- **Jumping straight into architecture design**
  - ❌ Immediately starting technical architecture design without consulting stakeholders
  - ✅ Engaging stakeholders first to understand their concerns and requirements

- **Trying to control implementation teams**
  - ❌ Directly managing or controlling implementation teams
  - ✅ Stakeholders direct and control the implementation teams, not you (the architect)

- **Making decisions for stakeholders**
  - ❌ Making an architecture decision first, then "presenting" it to stakeholders
  - ✅ Presenting options and letting stakeholders make the decision

- **Making technical decisions**
  - ❌ Counterintuitively, the TOGAF exam is testing your knowledge about the process (e.g., ADM), so any answer that makes a technical decision (e.g., "You decide to tackle this at the infrastructure level instead of the application level", "You decided to use software X") is likely wrong.
  - ✅ Follow the ADM phases, deliver your TOGAF deliverables to the stakeholders, and they'll decide.

- **Premature proof-of-concepts**
  - ❌ Doing proof-of-concept work in early phases like Phase A (Architecture Vision).
  - ✅ A proof-of-concept is seldom the right answer in TOGAF.

- **Prioritizing vendors over stakeholders**
  - ❌ Working primarily with vendors and partners (e.g., consulting them first for solutions, or choosing from existing vendors)
  - ✅ Working with stakeholders first; vendors are a secondary concern

- **Postponing critical concerns**
  - ❌ Leaving important topics like risk management to the last step
  - ✅ Addressing risks and concerns throughout the process, using the techniques TOGAF mentions

## Compare the remaining answers

After elimination, you should have 2-3 answers left. Now it's time to compare them carefully.

**When two answers are similar**, prefer the one that emphasizes:
- **Business value** over technical excellence
- **Long-term value** over short-term gains
- **Addressing stakeholder concerns** comprehensively
- **Letting stakeholders decide** instead of making decisions for them

**Comprehensiveness matters**:
- ✅ Prefer: "Develop deliverable X considering P, Q, and R".
- ❌ Over: "Develop deliverable X".
- The more comprehensive answer is usually correct, especially if it addresses more stakeholder concerns.

## Take notes on key questions

As you work through the questions, keep track of:
- **ADM phase conflicts**: If two answers suggest different ADM phases, note that you need to check which phase you're actually in when you read the scenario later.
- **Unfamiliar deliverables**: If an answer mentions a deliverable type you don't remember, write it down to look up in the scenario.
- **Scenario dependencies**: If answers mention specific decisions, these are probably referenced in the scenario; check them later.

## Use the reference PDFs to verify your understanding

The TOGAF Practitioner exam is open-book, which means you have access to the TOGAF reference documentation. Use this to your advantage:

**When to search the PDFs**:
- **Unfamiliar terminology**: If an answer mentions a deliverable, artifact, or term you don't recognize, search for it in the PDFs.
- **Verify deliverable outputs**: If you're unsure whether a particular deliverable is supposed to be the output of a specific ADM phase, look it up.
- **Check ADM phase activities**: If two answers suggest different phases for an activity, verify which phase that activity actually belongs to.
- **Confirm relationships**: Check how different deliverables, phases, and stakeholder groups relate to each other.

**Search efficiently**: Don't waste time reading through entire chapters. Use **Ctrl+F** (or **Cmd+F**) to search for specific terms:
- Deliverable names (e.g., "Architecture Vision", "Architecture Requirements Specification").
- ADM phase names (e.g., "Phase B", "Business Architecture").
- Key concepts you're uncertain about.

The goal is to quickly confirm or refute your understanding, not to learn new material during the exam.

## Now read the scenario strategically

Once you've done your first pass on the questions, it's time to read the scenario—but not all of it.

**Skip the filler content**: Most scenarios start with boilerplate text like:
- "You are employed as an Enterprise Architect...".
- "Your organization uses TOGAF...".
- "TOGAF has helped your organization...".
- "Your EA sponsor is the CIO...".
- "Your organization has project management, operations, etc.".

**Skip all of this.** It's filler and rarely relevant to the questions. Similarly, the background story of the organization (industry, products, history) is usually not important unless it directly relates to a stakeholder concern. New events happening to the company (e.g., mergers and acquisitions, reorganization, reacting to serious cyberattacks) are usually relevant.

**What to look for in scenarios**: Focus your attention on these critical elements:
- **Current ADM phase**: Which stage of the ADM are you in? This is crucial for eliminating wrong answers.
- **Completed deliverables**: What deliverables have already been delivered? This tells you what work is done and what's still needed. You can eliminate the answers that re-do the finished deliverables without adding value.
- **Approvals and decisions**:
  - What has been approved (e.g., you might see "Request for Architecture Work was approved by the architecture board")?
  - What decisions have stakeholders already made (e.g., "The board has decided to consolidate different applications across sites to a centralized application")?
  - **Important**: Don't overturn stakeholder decisions; follow them.
- **Stakeholder concerns**: What are stakeholders worried about?
  - Cyberattacks and security?
  - Risk management?
  - Consolidating fragmented applications landscape?
  - Cost reduction?
  - Regulatory compliance?

## Use scenario information to refine your answers

Armed with information from the scenario, go back to your remaining answer choices and:
- **Check coverage**: Does the answer touch on every single stakeholder concern mentioned in the scenario?
- **Prefer comprehensive answers**: If one answer addresses more concerns than another, it's likely the better choice—even if the other answer is also technically correct.
- **Verify alignment**: Does the answer align with decisions and approvals mentioned in the scenario?
- **Confirm the ADM phase**: Does the answer make sense for the current phase of the ADM? Some wrong answers will jump too far ahead into future ADM phases or ask you to go back to phases you've already finished. 

## Final tips

- **Trust the process**: This elimination-based approach is more reliable than trying to find the "perfect" answer immediately
- **Don't second-guess yourself too much**: If you've followed the elimination process and have a clear rationale, stick with your answer. The TOGAF answers are all quite literal. Trying to read too much between the lines or interpret them based on real-world experience will backfire
- **Time management**: The Practitioner exam has 8 complex scenarios. Quickly select the best possible answer based on reading the answers alone—this gives you confidence of at least a 3/4 chance to get more than one point per question (the grading is 5-3-1-0). Then you can have more time to read the scenario and check the reference material for each question
- **Review time**: Save 15-20 minutes at the end to review flagged questions using your scratchpad notes

## Conclusion

The TOGAF Practitioner exam tests your ability to apply architecture principles in realistic, complex scenarios. By reading questions first, systematically eliminating wrong answers based on TOGAF anti-patterns, and strategically reading scenarios for key information, you can approach the exam with confidence.

Remember: TOGAF values stakeholder engagement, proper sequencing, comprehensive planning, and letting the business drive decisions. Keep these principles in mind, and you'll be well-equipped to identify the best answers.

Good luck with your exam!
