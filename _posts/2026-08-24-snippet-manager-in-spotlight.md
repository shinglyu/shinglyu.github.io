---
layout: post
title: "Snippet Manager in Spotlight: Faster Launching with .app Bundles"
categories: Productivity
date: 2026-08-24T00:00:00Z
excerpt_separator: <!--more-->
grammar_checked: true
fact_checked: true
---

In my [previous post about replacing Raycast with macOS built-ins](/productivity/2026/01/09/poor-mans-raycast-replace-app-launcher-features-using-only-macos-built-ins.html), I recommended turning your shell scripts into `.command` files so Spotlight can find and launch them. That trick still works, but after using it for a while I ran into two annoyances: Spotlight is slow to rank `.command` files, and running one pops up a Terminal window even for scripts that don't need to show anything. It turns out there's a better way.

<!--more-->

## The problem with .command files

If you rename a shell script from `.sh` to `.command` and make it executable, Spotlight will treat it as a launchable application. That part works as advertised. What I didn't realize at first is that Spotlight is slow to rank `.command` files: it takes 3-5 seconds after you start typing the name before it matches. Actual apps in your `/Applications` folder show up in the results right away, but a `.command` file lags behind. If you're impatient (I am), you end up typing the name, seeing nothing, and wondering if you made a typo.

The other issue is more about polish than speed. Some of my scripts do their job entirely in the background - copying something to the clipboard, updating a file, sending a notification - and don't need any visible output. But a `.command` file always launches inside Terminal.app, so you get a window popping up, doing its thing, and then (if you added `exit` at the end) closing again. It's a small thing, but it breaks the illusion of a smooth, Raycast-like experience.

## Wrapping scripts in a .app bundle instead

The fix I landed on is to stop using `.command` files and instead compile the script into a proper `.app` bundle using [`osacompile`](https://ss64.com/mac/osacompile.html), the command-line tool that compiles AppleScript into an application. Spotlight indexes `.app` bundles almost instantly, since apps are exactly the kind of thing Spotlight is built to index quickly. There's no more waiting around for your script to appear.

The trick is that the AppleScript doesn't need to reimplement your logic. It's just a thin wrapper that tells Terminal to run your existing shell script:

```applescript
tell application "Terminal"
    activate
    do script "/path/to/your/script.sh; exit"
end tell
```

You compile that with `osacompile -o "Your Script.app" wrapper.applescript`, and now you have an app bundle that Spotlight picks up right away. If your script doesn't need a visible Terminal window at all, you can skip the `tell application "Terminal"` part entirely and just call `do shell script` instead, which runs silently in the background.

## A worked example: snippet manager

To make this concrete, let me walk through a small tool I built: a snippet manager. I keep a growing list of text snippets I'd otherwise have to retype or remember, and I wanted a fast way to fuzzy-search them and copy the result to my clipboard, add a new one on the fly, or edit the list directly. A big one for me is colleagues' names: I work in Europe with people from all over the world, and the spelling of the same name can vary a lot by origin - John can be John in English, Jan in Dutch, German, or Polish, Jann in Breton, Jon in Basque or Scandinavian, or Jón in Icelandic. Rather than trying to memorize every variant, I just keep them as snippets. I also keep internal IDs and cloud resource ARNs that I'd otherwise have to look up every time.

One constraint I set for myself: minimize external dependencies. The fewer third-party tools a script depends on, the less likely it is to get flagged by corporate endpoint protection or EDR software. The one dependency I couldn't avoid is [`fzf`](https://github.com/junegunn/fzf), a command-line fuzzy finder installable via [Homebrew](https://brew.sh/). Since `fzf` is a well-known developer tool that shows up in countless engineering workflows, it's easy to justify to IT if anyone asks - much easier than trying to explain why you installed a full-blown launcher app.

This is what I came up with for the snippet manager itself:

```bash
#===== snippet_manager.sh =====
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SNIPPET_FILE="$SCRIPT_DIR/snippets.txt"

# Function to parse snippets and present them to fzf
search_and_copy() {
    local result query selected_line body

    # Present the whole file to fzf; --print-query gives us the raw typed
    # text as the first line, so we can detect "/add ..." commands even
    # if fzf's fuzzy filter happens to highlight an existing line.
    result=$(fzf --print-query \
        --prompt="Search Snippet: " \
        --header='Enter: copy snippet | /add : add new snippet | /edit: edit snippets file' \
        < "$SNIPPET_FILE") || true

    query=$(printf '%s\n' "$result" | sed -n '1p')
    selected_line=$(printf '%s\n' "$result" | sed -n '2p')

    if [[ $query == /add* ]]; then
        add_snippet "${query#/add }"
    elif [[ $query == "/edit" ]]; then
        edit_snippets
    elif [[ -n $selected_line ]]; then
        # Strip out the part after ' ##' to obtain the body
        body="${selected_line%% ##*}"
        echo -e "$body" | pbcopy
        echo "Snippet copied to clipboard."
    fi
}

# Add a new snippet to the snippet file after user confirmation
add_snippet() {
    local new_body="$1"

    if [[ -z $new_body ]]; then
        echo "Nothing to add: /add requires text after it."
        return
    fi

    # Skip if an identical snippet body already exists
    if grep -qxF -- "$new_body" "$SNIPPET_FILE" 2>/dev/null || \
       grep -F -- "$new_body ##" "$SNIPPET_FILE" >/dev/null 2>&1; then
        echo "Snippet already exists, not adding."
        return
    fi

    read -r -p "Add snippet: \"$new_body\"? [y/N] " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "$new_body" >> "$SNIPPET_FILE"
        echo -e "$new_body" | pbcopy
        echo "Snippet added and copied to clipboard."
    else
        echo "Cancelled."
    fi
}

# Open the snippet file in vim for manual editing
edit_snippets() {
    vim "$SNIPPET_FILE"
}

# Launch the snippet manager
search_and_copy
```

Here's how this works:
* `search_and_copy` feeds the whole `snippets.txt` file into `fzf`, using `--print-query` so I can capture whatever the user typed even if `fzf` also highlights a matching line underneath it.
* If what you typed starts with `/add`, it's treated as a request to add a new snippet rather than search for one.
* If you typed exactly `/edit`, it opens the snippet file in `vim` so you can edit it by hand.
* Otherwise, whatever line you selected gets its body (the part before ` ##`, which I use as a separator for optional metadata) copied to the clipboard with `pbcopy`.

And here's the script that turns this into an app bundle:

```bash
#===== build_app.sh =====
#!/bin/bash
# build_app.sh
#
# Compiles snippet_manager.sh into a Spotlight-launchable "Snippet Manager.app"
# using osacompile. Run this whenever snippet_manager.sh changes and you want
# the .app to pick up the update (the .app is just a thin AppleScript wrapper
# that opens Terminal and runs the .sh file, so most script edits don't
# require a rebuild -- only re-run this if you move/rename the project
# directory or the .sh file itself).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SH_PATH="$SCRIPT_DIR/snippet_manager.sh"
APP_PATH="$SCRIPT_DIR/Snippet Manager.app"
APPLESCRIPT_TMP="$(mktemp -t snippet_manager_wrapper).applescript"

cat > "$APPLESCRIPT_TMP" <<EOF
tell application "Terminal"
    activate
    do script "$SH_PATH; exit"
end tell
EOF

osacompile -o "$APP_PATH" "$APPLESCRIPT_TMP"
rm -f "$APPLESCRIPT_TMP"

echo "Built: $APP_PATH"
```

Notice that `build_app.sh` doesn't embed the snippet manager's logic into the AppleScript at all. It just generates a tiny wrapper that tells Terminal to `do script` on the absolute path of `snippet_manager.sh`, then compiles that wrapper into `Snippet Manager.app` with `osacompile`. Because the wrapper only references the `.sh` file by path, most changes to `snippet_manager.sh` don't require rebuilding the app - you only need to re-run `build_app.sh` if you move or rename the script or its directory. Run `./build_app.sh` once, and from then on, typing "snippet" in Spotlight brings up the app almost instantly.

## Letting AI write the AppleScript for you

I'll admit my AppleScript is pretty rusty - I don't write it often enough to remember the syntax. The good news is that an LLM-based coding assistant can write AppleScript for you just as well as it writes any other language. For example, I asked one to write a script that opens Outlook, switches to calendar view, and creates a new event with as many fields pre-filled as possible. It got me most of the way there without me having to look up `tell application` syntax from scratch.

Where this gets genuinely difficult is with modern Microsoft 365 apps like Teams. These aren't traditional native Mac apps - they're essentially web apps wrapped in an Electron or webview shell - so AppleScript's UI scripting can't see into their internal buttons, fields, or menus the way it can with a native Cocoa app. There's no accessible element tree to inspect. The workaround I found: since the AI can't "see" the UI structure either, I asked it to simulate pressing Tab repeatedly to cycle keyboard focus until it lands on the field or button I need, then send a keystroke or Return to activate it. It's not elegant, but it works when there's no other way to address the control.

## A gotcha with Accessibility permissions

One thing that tripped me up: any AppleScript that does UI scripting (simulating keystrokes, tabbing through fields, and so on) needs Accessibility permissions, which you'd normally grant under **System Settings > Privacy & Security > Accessibility**. The gotcha is that when you launch a freshly compiled `.app` from Spotlight for the first time, macOS sometimes doesn't show the permission prompt at all - it just silently fails to do anything.

The fix is to first launch the app by double-clicking it in Finder. That reliably triggers the correct permission prompt. Once you grant it there, you can go back to launching the app from Spotlight as usual. One quirk worth knowing: in the Accessibility permissions list, the app doesn't show up under the name you gave it - it shows up generically as "applet", since that's the underlying AppleScript runtime. If you have more than one AppleScript-based app, they'll all appear as separate "applet" entries, so you may need to toggle permissions off and on to figure out which one is which.

## Conclusion

With a few extra minutes of setup, you can get automation scripts launching from Spotlight just as fast and cleanly as they would from Raycast, and without a Terminal window flashing on screen for background tasks. The best part is you don't need to ask IT for an exception - `osacompile` and `fzf` are either already on your Mac or a one-line Homebrew install away.
