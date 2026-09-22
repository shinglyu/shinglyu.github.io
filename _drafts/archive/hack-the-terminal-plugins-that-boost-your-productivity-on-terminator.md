---
layout: post
title: Hack the Terminal - Plugins That Boost Your Productivity on Terminator
categories: Web
date: 2016-10-15 15:44:03 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---
When I'm working in my terminal (my choice is [Terminator]()), I noticed two things that interrupts my workflow:

1. Searching for error messages: When my compiler complains or some program crashed with a error message, I usually 1) Select and copy the error message, 2) Open [Firefox](), 3) Paste the error message into the search box, 4) Search! It's a pretty tedious process, can't we just right-click and search Google like we do in Firefox?

#TODO: Firefox right click search
2. When I use search tools like `find`, `grep`, `ag`, or the blazingly fast [`ripgrep`]() (`grep` written in [Rust]()), I want to quickly open the found file in `vim`, but then I have to select, copy and paste the filename like I did in search. 

Thankfully, with some great Terminator plugins, we can streamline these common operations. 
<!--more-->

# Prerequisite

First, the plugins we'll be demonstrating are for [Terminator](), a great terminal emulator with the ability to split screens and many more. If you are on a Debian-based system, you can install it by 

<% highlight bash %>
sudo apt-get install terminator
<% endhighlight%>

The second thing is to understand how Terminator plugins work. A plugin is a python file put in the `~/.config/terminator/plugins`. If you haven't installed any plugin yet, it may not exist yet, simply create it by running

<% highlight bash %>
mkdir -p ~/.config/terminator/plugins
<% endhighlight%>

# Search Plugin

The [Search Plugin] adds a right-click menu item to Google search your selected text.
#TODO: search plugin pic
![search plugin]()

To install this plugin, click on the "raw" button and right click on the page, select "Save page as ..." to save the file (keep the file extension `.py`) in the `~/.config/terminator/plugins` folder. Then restart Terminator so the new plugin got pick up. Then you need to go to the "Preference" in the right-click menu, go to the "Plugins" tab and enable the "SearchPlugin"

Now if you select any text then right click, you'll see a "Search Google for ..." option available! When you see a error message you don't understand, you can easily select and search without much hassle.

# Editor Plugin
When we use tools like `grep`, `find`, `ag`, `ripgrep` or `git status`, etc., we might see a list of filenames. If we want to open any one of them, the only way is to copy the path, then paste it to your editor (or type `vim` in the terminal and paste the file name after it). This really slows down your workflow, because you have to accurately select the path name with your mouse, then do a lot of window switching and copy-pasting. But terminator has a built-in feature that identifies URLs, and when you right-click on them, you have the option to open it directly in the browser. So why can't we do the same for file pathes? Good news! There is one already, it's called the [`terminator-editor-plugin`].

The installation is the same as the previous one. You download the file ([direct link]())and put it in the `~/.config/terminator/plugins` folder. But before you can use it, there are some configurations you should check out. First, restart your Terminator, so the new plugin is loaded and the default configuration are created. Then we need to open the file `~/.config/terminal/config`. In the file, you should find a section like this:

<% highlight bash %>
[plugins]
  [[EditorPlugin]]
      ...
<% endhighlight%>

First, you need to set the editor in the `command` field. The default is `gvim`, but you can change to any editor command you like, for example I choose to open a new terminal and open `vim` in it with this setting:


<% highlight bash %>
command = "terminator -x vim {filepath}"
<% endhighlight%>

Second, you need to specify what pattern (regular expression) qualifies as a file path. By default, the regular expression `match = ([^ \t\n\r\f\v:]+?):([0-9]+)` matches a filename followed by a colon and a line number, which is the pattern for `grep -rn`'s output. But I like something more general, so I choose to use 


<% highlight bash %>
match = ([^ \t\n\r\f\v:]+?\.(sh|html|py|css|js|txt|xml|json|h|cpp|rs))[ \n: ](([0-9]+)*)
groups = file line
<% endhighlight%>

This matches any file path ended with extensions like `sh`, `html`, `py`, etc. and optionally followed by a colon-separated line number. Notice that we have two [match groups]() (regular expression surrounded by brackets), the `groups` setting assign them to `file` and `line`, which will appear as `{filepath}` and `{line}` in the `command` settings respectively (We choose not to use the `{line}` variable in my `command`)

Now we are ready! Restart the Terminator window and try a `grep` search, we can now right click on the link and open it in `vim`!

## Conclusion

In this post, I introduced how to install and setup two extremely useful Terminator plugins: the search plugin and editor plugin. If you are interested in improving them, you might consider sending pull requests to their GitHub repositories. Or if you are interested in writing your own Terminator pluing, you might consider reading this [guide](http://www.tenshu.net/2010/04/writing-terminator-plugins.html). 

