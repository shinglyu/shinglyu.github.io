---
layout: post
title: "Poor Man's Raycast: Replace Raycast Features Using Only macOS Built-ins"
categories: Productivity
date: 2025-10-17 16:39:00 +01:00
excerpt_separator: <!--more-->
---

I was really into Raycast. The global hotkeys, the instant app launching, the clipboard management – it transformed how I worked on my Mac. But I really don't want to use their AI features. For the AI features it provides, I prefer using my own LLM provider. But I found out it's quite difficult to completely turn it off. With sensitive data flowing through my clipboard and workflows, I might want absolute certainty that nothing leaves my machine. Also Raycast is always in the gray area for corporate IT, and I live in the contstant fear of it being banned by my employer.

That's when I discovered something surprising: I could rebuild almost everything I loved about Raycast using tools that were already on my Mac.

<!--more-->

## What You Can Replace

The core Raycast features I use most frequently are:

- Global hotkeys to launch apps and shell scripts
- Clipboard manager functionality
- Screenshot capabilities

All of these can be achieved using only native macOS tools, giving you the productivity boost without the security concerns (or at least without needing to justify it to my IT deparment).

## Method 1: Global Hotkeys with macOS Shortcuts

The most powerful approach leverages the built-in Shortcuts.app, which has become surprisingly capable in recent macOS versions.

### Setting Up Global Hotkeys

1. **Open the Shortcuts.app** 
2. **Create a new shortcut** by clicking the "+" button
3. **Add your desired action**, such as:
   - Open URL for quick website/web app access
   - Open App with additional AppleScript automation
   - Translate text from clipboard
   - Take screenshot by opening the Screenshot.app
   - Dictate your speech and immediate send the text to some app

### Assigning Keyboard Shortcuts

Then this is the most powerful feature: setting a global Keyboard shortcut without 3rd-party tools like BetterTouchTool or skhd.

1. Click the **(i)** icon on your shortcut
2. Enable **"Use as Quick Action"**
3. Click **"Add Keyboard Shortcut"**
4. Press the keyboard combination you want to use
5. Click outside the input box to save

Now you can trigger these actions instantly with your custom hotkeys.

## Method 2: Shell Scripts as Executable Commands

For more complex automation that's harder to achieve in Shortcuts, you can create shell scripts that integrate seamlessly with Spotlight. Shell scripts are also easier to version control and backup than Shortcuts.

### Creating Executable Scripts

1. Write your shell script as usual.
2. Change the file extension to `.command` instead of `.sh`.
3. Save the file somewhere in your home directory. I keep them in OneDrive so it's automatically synced, and I use git for version control in that folder.
4. Make it executable: `chmod +x ~/Scripts/your-script.command`

### Spotlight Integration

Here's where it gets interesting: Spotlight automatically indexes `.command` files as executable applications. When you search for your script's name in Spotlight, it appears as a runnable program.

**The workflow becomes:**
1. Press **Command-Space** to open Spotlight
2. Type your script name (or even just a few letters)
3. Press **Enter** to execute

This is particularly useful if you want to avoid complex hotkey combinations that might conflict with system defaults. You can also build command-line or TUI based user interface for more complex workflows.

## Method 3: Enhanced Spotlight with Quick Keys

The macOS Tahoe update has significantly improved Spotlight's capabilities. You can now assign quick keys to shortcuts, creating an even more Raycast-like experience.

### Setting Up Quick Keys

You can assign quick keys directly in Spotlight for actions and shortcuts:

1. Press **Command-Space** to open Spotlight
2. Search for the action or shortcut you want to assign a quick key to
3. Click **"Add quick keys"** next to the action
4. Enter the text shortcut you want (e.g., "ft" for FaceTime, "sl" for Slack)

Once assigned, you can type your quick key in Spotlight and it will show the action. You can even add parameters right after the quick key - for example "ft Ashley" to call Ashley directly. This can work alongside the global hotkey method mentioned before. So you can have a 3-tier system for the shortcuts:
* For frequently used shortcuts, assign it a global hotkey + quick keys in Spotlight
* For less-frequently used shortcuts, assign them only quick keys in Spotlight
* For rarely used shortcusts, simply search for the full name in Spotlight
This way you don't need to memorize that many hotkeys, but are still able to access everything when you need to.

### Built-in Clipboard Manager

One of the most exciting additions in macOS Tahoe is the built-in clipboard history feature in Spotlight. You can now access your clipboard history directly without third-party apps:

1. Press **Command-Space** to open Spotlight
2. Press Command-4 to limit your search to only the clipboard history

This feature maintains a history of your copied items, making it easy to access previously copied text, images, and other content. You can learn more about this feature in [Apple's official documentation](https://support.apple.com/en-ng/guide/mac-help/mchl40d5b86b/mac).

## Conclusion

You don't need third-party applications to achieve powerful productivity automation on macOS. Between the Shortcuts app, shell scripts, and enhanced Spotlight search, you can create a robust workflow that rivals commercial alternatives.

This approach is particularly valuable in corporate environments where software restrictions are common, or when you prioritize keeping your automation local and private. The initial setup investment pays off with a system that's both powerful and completely under your control.

Give it a try with one or two automations first. You might find that the "poor man's Raycast" is all you really need.
