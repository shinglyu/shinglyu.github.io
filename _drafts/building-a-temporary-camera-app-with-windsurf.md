---
layout: post
title: Building a temporary camera app with Windsurf
categories: Web
date: 2024-12-28 10:19:47 +08:00
excerpt_separator: <!--more-->
---
Note: This post is written with the help from Gemini 2.0 Flash. Let me know if you like the style and tone.

Keeping a pristine photo gallery can be a challenge. I wanted a way to separate my permanent family photos from the everyday snapshots I take—parking spots, receipts, quick notes—things I only need temporarily. I wanted those transient images kept separate, ready for easy cleanup later. I remembered an Android app that did just this, but unfortunately, it's no longer available on the Play Store, leaving me searching for a new solution.
<!--more-->

Initially, I considered building a native Android app myself, or perhaps diving into cross-platform frameworks like Flutter or React Native. However, my main laptop is currently struggling with disk space (and it has a M.2 SATA SSD slot which is probably not worth upgrading...), making it impossible to install Android Studio and the necessary SDKs. To make matters more complicated, I'm currently on vacation and only have access to an older laptop running ChromeOS Flex. This limited my options significantly and ultimately led me to explore a different approach. This led me to explore building a progressive web app using Windsurf. My friends had been raving about it as an AI-powered IDE, a tool that leverages artificial intelligence to streamline and enhance the development process. They described it as a coding companion that could anticipate their needs, suggest code completions, and even automate repetitive tasks. Intrigued by these glowing reviews, I decided to give Windsurf a try and see if it lived up to the hype. I also want to compare it agains Amazon Q Developer and Github Copilot.

In case you don't know what a Progressive Web App, or PWA, is, it's essentially a website that can be "installed" on a device, offering a more app-like experience. PWAs can work offline, send push notifications, and integrate more seamlessly with the operating system than traditional websites. This makes them a great option for lightweight utilities like a temporary camera app. 

## The process

The process of building my temporary camera PWA with Windsurf was surprisingly straightforward, although not without a few hiccups. I started by installing Windsurf within the Linux container on my Chromebook. I did run into an issue with the cursor not displaying correctly, which I suspect is related to GPU drivers within the Linux container, so I'll have to estimate the location of the buttons and click blindly. Despite this minor visual glitch, I pressed on, and I was genuinely impressed by how quickly Windsurf spun up the initial version of my PWA.

One of the most pleasant surprises was Windsurf's "agentic flow." It felt like having a helpful assistant guiding me through the process. The tool intelligently suggested terminal commands based on the current context and even offered to run them automatically. This streamlined the development experience significantly. Windsurf would stop at every terminal command and ask for my permission, it would also pause and ask for my review after a few logically related file changes. This is different from Amazon Q Developer's `/dev` agent, who would do a lot of work, creating folders, generting files, iterate on files, before asking you for review. Sometimes Amazon Q Developer would spend 5 minutes working on a lot of things, but go into the completely wrong direction. The Windsurf flow feels more interactive and you can intervene and guide it earlier.

Below is a screenshot of it suggesting me to run `mkdir` to create the folder before creating the files. This is exactly in line with my own work flow so it feels very natural. 

The first version Windsurf generated is already fully functional! I then went through a few iterations to tweak the visual style to my liking, change the expirate date display to relative time, and show the time the photo is taken. Windsurf did them without much issue. 

## Icon generation

However, it is not perfect. One thing Windsurf didn't seem to recognize that a PWA requires an icon to be installable. This is a fundamental requirement for PWAs, and it was an oversight. In the past, I would have to find an icon generator, generate a few iterations, and carefully resize the images to multiple icon sizes and put the in the right location defined in the `metadata.json`. Since Windsurf doesn't seem to have a image-generating model (I see it uses Claude 3.5 Sonnet), I'm curious about how Windsurf would do if I ask it to generate the icons. Windsurf ended up using ImageMagick, a powerful commandline image manipulation tool, to generate an icon! It writes a long ImageMagick command to darw a bunch of rectangle and circles to create a camera icon. This is something a human cannot do by hand. Also to my surprise, when it detects that the ImageMagic command is not installed, it automatically suggested the Debian installation command and ran it for me. 

## Conclusion

Overall, my experience using Windsurf to create a temporary camera PWA was positive. It’s a promising tool that significantly lowers the barrier to entry for building web applications. While many current AI-powered IDEs seem to be little more than VS Code with a proprietary AI extension, I predict the real competition in this space will be fought on the battleground of agentic user experience and workflow design. As a developer, I'm already familiar with concepts like PWAs and understand their potential, but it makes me wonder how future AI editors will abstract away these underlying complexities for non-developer users. How will these tools empower everyday users to build the apps they envision without needing to understand the technical details? That's the truly exciting frontier, and I'm eager to see how it unfolds.
