---
layout: post
title: Lessons learned in writing my first book
categories: Web
date: 2020-04-05 10:42:16 +02:00
tags: mozilla
excerpt_separator: <!--more-->
---

![book cover][bookcover]<br>

You might have noticed that I didn't update this blog frequently in the past year. It's not because I'm lazy, but I focused all my creative energy on writing this book: [Practical Rust Projects][apress]. The book is now available on [Apress][apress], [Amazon][amazon] and [O'Reilly][oreilly]. In this post, I'll share some of the lessons I learned in writing this book.

<!--more-->

Although I've been writing Rust for quite a few years, I haven't really studied the internals of the Rust language itself. Many of the Rust enthusiasts whom I know seem to be having much fun appreciating how the language is designed and built. But I take more joy in using the language to build tangible things. Therefore, I've been thinking about writing a cookbook-style book on how to build practical projects with Rust, ever since I finished the video course [Building Reusable Code with Rust][videocourse].

Out of my surprise, I received an email from Steve Anglin, an acquisition editor from Apress, in April 2019. He initially asked me to write a book on the [RustPython][rustpython] project. But the project was still growing rapidly thanks to the contributors. I've already lost grip on the overall architecture, so I can't really write much about it. So I proposed the topic I have in mind to Steve. Fortunately, the editorial board accepted my proposal, and we decided to write two books: one for general Rust projects and one for web-related Rust projects.

Since this is my first time writing a book that will be published in physical form (or as The Rust Book put it, "dead tree form"), I learned quite a lot throughout the process. Hopefully, these points will help you if you are considering or are already writing your own book.

## The Pomodoro Technique works!
It might be tempting to write a waterfall-style book writing plan, something along the lines of "I'll write one section per day". But there is a fundamental flaw with this approach: not all sections are of the same length and difficulty. A section about how to setup software might be very mechanical and easy to write, but a section about the history of a piece of software might take you days of research. Therefore, you can't reliably predict how long it will take to finish a chapter, resulting in fear of starting and procrastination.

I find the Pomodoro Technique to be a constructive alternative in structuring my writing plan. The Pomodoro Technique is a time management method where you break your work into 25 minutes intervals and rest in between. Instead of saying, "I'll finish this chapter by today", say "I'll do 2 Pomodoro sessions (25 x 2 = 50 min) today". This way, no matter if you are making good progress or not, you know you are committing enough effort into the book writing project. A good side effect is that once I started writing, I got into the flow and ended up writing more Pomodoro sessions then I planned.

## An Outline is important
I usually write freely without and outline when I write my blog. But writing a book is a completely different thing. An outline will help you structure the content much better and avoid missing important topics. I usually start with a very high-level chapter outline, then add a section outline before I start writing each section. It's nice to write the outline for all the chapters before starting. When you are writing Chapter 1 and suddenly have an idea about something in Chapter 3, you can quickly add that to the Chapter 3 outline as a reminder. 

Example code is a crucial part of a programming book. It's also beneficial to list down each step in the outline while you develop the example code. Because if you write all the example code in one go, you'll forget about many steps that are not in the final code when you revisit it. For example,  

* Installing an external dependency
* Important trail-and-error you went through 
* Informative compiler errors and warnings

These are all key points that need to be mentioned, but they don't show up in the final code. Although you can dig that up by going through the git history, it's still easier to write them down during development.

## Version control and LaTex

Version control is not only for code. The draft will go through multiple reviews and revise passes. You'll usually have to revise the previous chapter while you are writing the next one. So use a format that is `diff`-friendly is very helpful. I use an unofficial LaTex template provided by Apress, with my own modifications. There are some random LaTex tips:

* A professional production team lays out my page for softcover prints. So the image positioning from LaTex will not be the final one. But it's still crucial to place the image after they are referenced. So I sometimes need to use `\clearpage` to force the image to appear on the next page.
* I render the draft on A4 paper, but the final book is narrower and has a 65 character limit on the source code line length. Therefore, the production team has to wrap the code lines in many places. But since they are not Rust experts, they sometimes wrap the line in a non-idiomatic way. So it's worth checking with your editor what is the source code width limit.
* Take advantage of shell scripts to help you with writing. I created scripts for:
  * Scan the LaTex code to find missing code listing files or images.
  * Linting the code examples. 
  * Linting common grammatical or style errors.

## Use a grammar checker, multiple times
I'm not a native English speaker, so I use `aspell` and Grammarly to check my grammar (disclaimer: Grammarly does not sponsor me). GNU Aspell is an open-source spell checker for the command line. Although it mostly checks for spelling, not grammar, its command-line interface and keyboard control is much more efficient than clicking the mouse. So I use Aspell to fix apparent typos. Then I copy-paste the LaTex source code into Grammarly's web interface for a more thorough grammar check. However, many of the latex annotations like `\texttt{code formatting}` breaks the sentence, so Grammarly misses some sentences. So after the first round of Grammarly check, I render the LaTex code into PDF and use the `pdftotext` command to extract the rendered text from the PDF. I then run Grammarly through this text again.

Of course, to fix this problem once and for all, improving the writing skill is critical. I came across this [Google Technical Writing Course][googlecourse] after I finish this book, which helped me a lot in the writing process of my second book. 

## Get the book now

In this post, I focused on a few practical tips about book writing. I can maybe write another post about my LaTex setup and my observation about the Rust ecosystem. Leave a message using the "Message me" at the bottom right to let me know if that will be interesting to you.

Please grab a copy of the book at the book store of your choice and let me know what you think: 

* [Apress][apress]
* [Amazon][amazon]
* [O'Reilly][oreilly]

[bookcover]: /blog_assets/book_cover.jpg
[videocourse]: https://www.packtpub.com/application-development/building-reusable-code-rust-video
[apress]: https://www.apress.com/gp/book/9781484255988
[amazon]: https://www.amazon.com/Practical-Rust-Projects-Computing-Applications/dp/1484255984
[oreilly]: https://learning.oreilly.com/library/view/practical-rust-projects/9781484255995/
[googlecourse]: https://developers.google.com/tech-writing
[rustpython]: https://github.com/RustPython/RustPython
