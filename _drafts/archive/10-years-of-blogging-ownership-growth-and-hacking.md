---
layout: post
title: "10 Years of shinglyu.com"
categories: Web
date: 2026-01-17 12:00:00 +01:00
excerpt_separator: <!--more-->
---

In September 2008, I wrote my first blog post, a humble guide about fixing missing screen resolutions in Ubuntu. Eighteen years and 88 posts later, I'm celebrating a different milestone: the 10th anniversary of moving this blog to its permanent home on shinglyu.com. What started as a way to document Linux troubleshooting tips has evolved into something far more significant: a chronicle of my entire career, from browser hacker to cloud architect, and a testament to the power of owning your own platform.

<!--more-->

## The origin story: from platforms to ownership

### The pre-history

Before there was shinglyu.com, there was Blogger. Like many students in the late 2000s, I started documenting my programming learnings on Google's free blogging platform. Those early posts were raw and practical: [how to set up ThinkPad fingerprint readers on Ubuntu]({{site_url}}/tech/2008/09/06/ubuntu-thinkpad-fingerprint.html), [configuring Atheros wireless drivers]({{site_url}}/tech/2008/11/01/ubuntu-atheros-ar2425ar5007eg.html), and even [how to create a Matrix-style terminal]({{site_url}}/tech/2008/09/06/ubuntu-matrix-terminal.html). I have been playing with Linux live CDs since high school, and started using Ubuntu full-time. This was the era when getting Linux to work on consumer hardware felt like a daily adventure, and every solution was worth sharing.

Between 2011 and 2014, my focus shifted toward academic research. I worked on computer expressive music performance systems and video saliency research, culminating in my master's thesis at National Taiwan University. I even built an ASCII oscilloscope that ran on a Raspberry Pi, as a side-project reqested by an art-major student trying to build his art project. But throughout this period, the blog remained my outlet for technical documentation.

### The Mozilla turning point

Everything changed when I joined Mozilla. Working on the open web alongside passionate advocates for digital freedom made me realize something uncomfortable: I was documenting my technical journey on platforms I didn't control. Google Blogger was convenient, but what happened when Google decided to change the terms of service, or worse, shut it down entirely? The downfall of Taiwan's popular blogging site wretch.cc further amplified this fear.

Mozilla's philosophy of user agency and data ownership rubbed off on me. I started asking myself: if I believe in the open web, shouldn't I practice what I preach? The answer was clear—I needed to own my data.

### The tech stack

In 2016, I migrated everything to Jekyll and GitHub Pages. The choice was deliberate:

- **Jekyll** offered simplicity: just Markdown files and a static site generator. Natively supported by GitHub Pages.
- **GitHub Pages** provided free, reliable hosting with version control built in
- **Markdown** ensured my content remained portable; I could move to any platform or self-host in the future without losing my work

This decision has paid dividends. A decade later, I still have every post I've ever written, in a format I can read and edit without any special software. No vendor lock-in. No dependency on a company's business decisions. Just text files and git commits.

### A design philosophy rooted in print

My experience building the Servo browser engine unexpectedly shaped this blog's design. Working on Servo's CSS engine meant studying the original W3C specifications in depth, understanding how browsers actually interpret and render styles. What I discovered surprised me: CSS and HTML layout have deep roots in printed material design. Concepts like margins, columns, line height, and typographic hierarchy weren't invented for the web; they were inherited from centuries of book and newspaper design.

This insight led me to a conscious decision: I would design my blog's CSS from scratch, drawing on these print-inspired principles rather than adopting popular CSS frameworks. Most frameworks like Bootstrap are designed with "apps" in mind: navigation menus, interactive components, responsive grids for dashboards. But a blog is fundamentally *reading material*, not an application. It should feel more like a well-typeset book than a web app.

So my blog uses simple, clean CSS focused on readability: comfortable line lengths, generous whitespace, a clear typographic hierarchy, and minimal distractions. No framework overhead. No JavaScript-heavy components. Just content designed to be read, the way printed material has been designed for centuries.

## A decade of technical evolution

### The browser era (2015-2018)

My time at Mozilla coincided with one of the most exciting periods in browser engineering. I joined the [Servo project](https://servo.org/), Mozilla's experimental browser engine written entirely in Rust. As a core team member, I helped build a parallel, memory-safe rendering engine that would eventually transform Firefox itself.

The highlight of this era was helping port the Rust-based CSS engine from Servo into Gecko, which became [Firefox Quantum's Stylo engine](https://hacks.mozilla.org/2017/08/inside-a-super-fast-css-engine-quantum-css-aka-stylo/). This wasn't just a technical achievement; it was a change that improved browser performance for hundreds of millions of users worldwide.

During this period, I also co-created [RustPython](https://github.com/RustPython/RustPython), a Python interpreter written entirely in Rust. What started as a side project has grown into one of the most popular Rust projects on GitHub, with tens of thousands of stars. I spoke about it at [FOSDEM 2019](https://fosdem.org/2019/schedule/event/rust_python/) and [COSCUP 2017](https://www.youtube.com/watch?v=9fUdKm3njMo), introducing the intersection of systems programming and scripting languages to new audiences.

Beyond the big projects, I built tools like [FocusBlocker](https://addons.mozilla.org/en-US/firefox/addon/focusblocker/) and [MozITP](https://github.com/Mozilla-TWQA/MozITP), an all-in-one testing package for the Firefox OS ecosystem. These projects reflected my growing obsession with productivity and automation, themes that would define the next chapter of my work.

### The cloud shift (2018-2022)

Leaving Mozilla didn't mean leaving Rust behind. Instead, I carried my systems programming expertise into a new domain: cloud computing. At DAZN and later as a solutions architect at AWS, I discovered that the skills gave me a good foundation to learn the new domain.

This period marked my transition from "local system developer" to "global cloud developer." My blog posts shifted accordingly. Instead of Ubuntu driver guides and open web, I started writing about:

- [Terraform best practices]({{site_url}}/web/2020/02/06/update-aws-security-groups-with-terraform.html): my post on updating AWS security groups with Terraform became one of my most-viewed articles
- [Multi-region architectures]({{site_url}}/web/2019/01/29/multi-region-domain-names-and-load-balancing-with-aws-route53.html) with Route 53
- [CI/CD pipeline optimization]({{site_url}}/devops/2019/02/28/simplify-your-ci-pipeline-configuration-with-jsonnet.html) using Jsonnet

The culmination of this era was publishing [Practical Rust Projects](https://link.springer.com/book/10.1007/978-1-4842-5599-5) in 2020. This book, and its [second edition in 2023](https://link.springer.com/book/10.1007/978-1-4842-9331-7), allowed me to share what I'd learned about building real-world applications with Rust, from games and robots to serverless functions and machine learning.

### Analytics highlights

Looking back at the analytics from the past five years, certain posts have resonated deeply with the community:

- [Counting your contribution to a git repository]({{site_url}}/web/2018/12/25/counting-your-contribution-to-a-git-repository.html)
- [Update AWS Security Groups with Terraform]({{site_url}}/web/2020/02/06/update-aws-security-groups-with-terraform.html)
- [Merge Pull Requests without Merge Commits]({{site_url}}/web/2018/03/25/merge-pull-requests-without-merge-commits.html)
- [Consistent Hashing]({{site_url}}/web/2022/02/11/consistent-hashing-and-why-it-might-not-be-the-correct-answer-to-your-system-design-interview.html)

What strikes me about this data is how utilitarian the top posts are. People find my blog through organic search when they're stuck on specific problems. That's exactly the kind of content I was creating back in 2008—practical solutions to real challenges. Some things haven't changed.

## The productivity hacker's toolkit

If there's one thread that runs through my entire career, it's an obsession with eliminating friction. Whether I was configuring Linux drivers in 2008 or building browser engines at Mozilla, I've always been drawn to customizing my tools and workflows. This isn't about chasing the latest productivity app or following trends. It's about making my computer truly *mine*.

In 2022, I documented [my productivity system]({{site_url}}/productivity/2022/03/06/my-productivity-system.html), covering everything from RSS feeds and Pocket to Joplin zettelkasten notes and bullet journals. The core philosophy: information flows in, gets processed into notes, and eventually emerges as writing or speaking. I've received many questions about my note-taking setup since that post, and I plan to write more detailed guides on how I organize my zettelkasten and integrate it with my writing workflow.

More recently, I've doubled down on this philosophy with [Poor Man's Raycast]({{site_url}}/productivity/2026/01/09/poor-mans-raycast-replace-app-launcher-features-using-only-macos-built-ins.html), rebuilding productivity features using only native macOS tools. The motivation? Growing concerns about AI features in third-party apps that might leak sensitive data. By using built-in Shortcuts and shell scripts, I maintain both efficiency *and* privacy.

### AI as the modern lever

The "gap years" were real. Between 2019 and 2023, family and childcare commitments dramatically reduced my available writing time. My blog output slowed to a trickle. I had plenty of ideas, but translating thoughts into polished posts felt like an insurmountable barrier.

[AI changed everything]({{site_url}}/writing/2025/07/13/how-i-wrote-a-book-with-ai.html). When I decided to write [Learning to Learn AWS](https://leanpub.com/learning-to-learn-aws) in 2025, I adopted a new approach: treating AI as a writing partner rather than a replacement. The ideas, structure, and insights remained mine. AI helped with the mechanical work of turning outlines into prose, allowing me to complete a quality technical book in just 5 months while working only 1-2 hours per week.

This partnership extends to my blog as well. Posts like [Using LLM to get cleaner voice transcriptions]({{site_url}}/ai/2024/01/17/using-llm-to-get-cleaner-voice-transcriptions.html) and [Vibe coding a PII Anonymizer CLI]({{site_url}}/ai/2025/05/28/vibe-coding-a-pii-anonymizer-cli-how-gen-ai-makes-me-build-tools-faster-than-ever.html) document how I've integrated AI into my development workflow. The pattern is consistent: AI handles the tedious parts while I maintain creative control.

### The new balance

The result is sustainable creativity. I'm publishing more than ever, not because I have more time, but because I've found tools that amplify my limited hours. AI doesn't replace the thinking; it removes the friction between thinking and writing.

## The next decade: from "how-to" to "how to think"

### Evolution of content

For years, my most popular content has been practical "how-to" guides, posts that solve specific problems for developers hitting the same walls I once hit. This content will always have a place on my blog.

But I'm also evolving. As I've moved into architecture roles, my perspective has shifted from "how do I solve this problem?" to "how should I think about this class of problems?" My recent post on [Vibe Operations]({{site_url}}/ai/2025/11/07/vibe-operations-the-next-indispensable-trend.html) is an early attempt at this kind of writing: exploring higher-level industry trends and where I see things heading, rather than just solving a specific technical problem. I'll admit it's not my most polished work, but it represents the direction I want to grow. Expect more explorations of architectural thinking and industry trends in the future.

### The continuous hacker

Despite all the evolution, one thing remains constant: I'm still the same productivity hacker who wrote that first Ubuntu resolution guide in 2008. The tools have changed, from Linux drivers to Rust compilers to AI assistants, but the mindset hasn't. I'm always looking for the next lever, the next customization, the next way to make technology work for me rather than the other way around.

Whether it's [Serverless Rust on the Big Three Clouds]({{site_url}}/web/2025/09/16/rust-serverless-on-the-big-three-clouds-aws-azure-and-gcp-compared.html) or [Making AI draw architecture diagrams with AWS icons]({{site_url}}/web/2025/03/24/make-ai-draw-architecture-diagrams-with-aws-icons.html), I'll keep exploring new tools and sharing what I learn. That's the commitment I made to this blog ten years ago, and it's the commitment I'm renewing for the next decade.

## Closing reflections

### Gratitude

First, to those who have followed this blog over the years, whether through RSS, social media, or direct bookmarks: thank you. Your continued readership means the world to me. Knowing that there are people who choose to come back, post after post, is what keeps me writing.

And to everyone who has stumbled upon my posts through organic search: thank you as well. Whether you landed here looking for Terraform tips, Rust guidance, or productivity hacks, I hope you found what you needed. This blog exists because of readers like you who share links, leave comments, and send emails saying "this helped me."

Over the past decade, this platform has documented my journey from Mozilla engineer to cloud architect, from book author to speaker at conferences from Taipei to Amsterdam. But the numbers don't capture what matters most: the connections. The colleagues who recognized me from blog posts. The readers who reached out years later to say a particular guide saved them hours of debugging. The community that formed around shared challenges and shared solutions.

### The invitation

As I enter the next chapter as a software architect, author, and (apparently) productivity hacker, this blog will evolve alongside me. Expect more high-level architectural thinking. More explorations of AI-assisted development. More honest reflections on what works and what doesn't in our rapidly changing industry.

But also expect the same practical utility that's defined this blog since 2008. Some things shouldn't change.

Here's to the next ten years.