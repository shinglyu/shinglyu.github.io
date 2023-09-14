---
layout: post
title: How to link to external files in Joplin
categories: Web
date: 2023-09-14 22:14:49 +02:00
excerpt_separator: <!--more-->
---
I have been using Joplin for work for two years now, and I love it. Joplin is a free and open source note-taking app that lets you create notes in Markdown format, sync them across devices, and encrypt them for privacy. Joplin is also very flexible and customizable, allowing you to use plugins, themes, templates, and more to suit your needs.

One of the features that I recently discovered in Joplin is linking to local files and folders on my computer. This allows me to access my work documents without storing them in Joplin’s database, which can get too large and slow down the app. It also allows me to organize my files and folders in my own way, and take advantage of file sync services like Dropbox or Amazon WorkDocs. In this blog post, I will show you how to link to local files and folders in Joplin, and how to quickly copy the full file path from your file explorer. 
<!--more-->

## How to link to local files and folders in Joplin

To link to a local file or folder in Joplin, you need to use the `file://` protocol. This protocol tells Joplin to open the file or folder with the default application on your system. For example, if you link to a PDF file, Joplin will open it with your system's PDF viewer. If you link to a folder, Joplin will open it with your system's file explorer.

The syntax for linking to a local file or folder in Joplin is:

```
[Project A Progress Report](file:///home/shinglyu/documents/project_A/progress_report.pdf)
```

or simply

```
file:///home/shinglyu/documents/project_A/progress_report.pdf
```

if you don't need the link text.

When you click on it, Joplin will open the PDF file with the system's PDF viewer. I've tested this on MacOS and Ubuntu.

You can also link to local folders in Joplin using the same file:// protocol. This can be useful if you want to quickly access a folder that contains multiple files or subfolders related to your work. For example, to open the `project_A` folder, you can write

```
[Project A](file:///home/shinglyu/documents/project_A/)
```

When you click on it, Joplin will open the folder with the system's file explorer. On MacOS, it will open Finder, and on Ubuntu, it will open Nautilus.

## How to quickly copy the full file path from your file explorer

One of the challenges of linking to local files and folders in Joplin is to copy the full file path from your file explorer. Here is a trick that I use:

- Select the file or folder in your file explorer (Finder on MacOS or Nautilus on Ubuntu).
- Press Ctrl-C (or Command-C if you are on MacOS) to copy it to your clipboard.
- Open a terminal window and press Ctrl-V to paste it. You will see the full file path.
- Copy this full path and paste it to Joplin, then add the `file://` prefix yourself.
