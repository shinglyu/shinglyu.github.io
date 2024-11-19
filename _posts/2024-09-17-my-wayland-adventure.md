---
layout: post
title: My Wayland adventure
categories: Web
date: 2024-09-17 23:29:06 +0200
excerpt_separator: <!--more-->
---
My Linux laptop is running the old Ubuntu 20.04 and is going to go out of support next year. I was planning to switch over to [NixOS](https://nixos.org/) but I don't have time right now to do a fresh reinstall and learn NixOS from scratch. That's why I decided to simply upgrade to Ubuntu 24.04 and switch to [Wayland](https://wayland.freedesktop.org/). 

I was using [i3](https://i3wm.org/) on X11, so switching to Wayland means I have to change many of my settings and switch to utilities that supports Wayland. This post is a rundonw of all the changes I've made to switch to Wayland. Overall, I enjoy the smoothness of Wayalnd (abiet barely noticable), and being able to use newer, more polished utiltity tools.
<!--more-->

## Upgrading from Ubuntu 20.04 to 24.04

The upgrade process was smooth, I had to upgrade from 20.04 LTS to 22.04 LTS, then from 22.04 LTS to 24.04 LTS. The built-in upgrade tool `sudo do-release-upgrade` worked without issues. The only thing that didn't work immedately after upgradeing is my [Logseq](https://logseq.com/) AppImage binary. I have to do the following to make it work:

- `sudo apt install libfuse2t64` because it complains about FUSE is missing
- `sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0` because Ubuntu 24.04 implemented new restrictions for AppImage apps, which restricts the use of sandboxes.  See https://github.com/electron/electron/issues/42510. This only applies to current session. You can set it permenantly in `/etc/systctl.conf`

## Switching to Sway

After upgrading Ubuntu, the next step was to switch from i3 to [Sway](https://swaywm.org/), a tiling window manager for Wayland that's very similar to i3. Here's how I set it up:

1. Installation is straightforward:
   ```
   sudo apt install sway
   ```

2. After installation, log out and select the Sway session in the Ubuntu login manager.

3. By default, Sway will load the `~/.i3/config` file. If you encounter an error about the font, simply comment out the font line in the config.

4. To have separate configurations for i3 and Sway:
   ```
   mkdir -p ~/.config/sway
   cp ~/.i3/config ~/.config/sway/config
   ```

5. You can reload the Sway config at any time with:
   ```
   swaymsg reload
   ```

## Configuring Waybar

To replace i3-bar with something more feature-rich, I opted for [Waybar](https://github.com/Alexays/Waybar). Here's how I set it up:

1. Install Waybar `sudo apt install waybar`

2. Add `exec waybar` to your Sway config file.

3. If you encounter an error about the bar needing to run under Wayland, try unsetting the GDK_BACKEND:
   ```
   unset GDK_BACKEND
   ```

4. Waybar is highly configurable. You can find configuration examples and documentation on the [Waybar GitHub wiki](https://github.com/Alexays/Waybar/wiki/Configuration).

Here is an example of how my Sway and Waybar looks like:

![Sway and Waybar screenshot]({{site_url}}/blog_assets/wayland/sway_and_waybar.png)	


## Input Method

For input methods, I found that [ibus](https://github.com/ibus/ibus) doesn't work well with Wayland, so I switched to [fcitx5](https://github.com/fcitx/fcitx5):

1. Install fcitx5 and any language-specific modules you need:
   ```
   sudo apt install fcitx5 fcitx5-chewing
   ```

2. Add `exec fcitx5` to your Sway config.

3. Right-click on the menu bar icon, go to configure, and add your desired input methods to the list.
## Display Management

I have one laptop built-in monitor and 2 external monitors. For managing multiple displays under Wayland, I found [`wdisplays`](https://github.com/artizirk/wdisplays) to be a useful GUI tool:

1. Install wdisplays:
   ```
   sudo apt install wdisplays
   ```

2. Launch it with `wdisplays` command.

![wdisplays screenshot]({{site_url}}/blog_assets/wayland/wdisplays.png)	


3. To make display settings persist after Sway reload, add output configurations to your `~/.config/sway/config`:
   ```
   output "'Lenovo Group Limited XXXXXX YYYYYY'" pos 0 0 res 2560x1440
   output "'LG Display XXXXX'" pos 640 1440 res 1920x1080
   output "'Iiyama North America XXXXX YYYYY'" pos 2560 360 res 1920x1080
   ```
   The single quote in double quote is not a typo, the single quote is part of the name of the monitor.

4. To identify the monitor names, use the names found in `swaymsg -t get_outputs`.
5. The sway output config don't work reliablely (I'm still investigating), so I create a shell script like this and bind it to a hotkey in sway so I can trigger it anytime:

    ```
    sway output "'Lenovo Group Limited XXXXXX YYYYYY'" pos 0 0 res 2560x1440
    sway output "'LG Display XXXXX'" pos 640 1440 res 1920x1080
    sway output "'Iiyama North America XXXXX YYYYY'" pos 2560 360 res 1920x1080
    ```

## Controlling built-in monitor brightness
I use the tool [light](https://gitlab.com/dpeukert/light) to contorl the brightness of my built-in monitor:

```
sudo apt install light
sudo light -A 10 # increase by 10%
sudo light -U 10 # decrease by 10%
```

## autotiling

[Autotiling](https://github.com/nwg-piotr/autotiling) is a script that automatically adjusts the split direction in Sway (or i3) based on the dimensions of the currently focused window. This creates a more intuitive tiling experience, where you get 1 > 1/2 > 1/4 > ... smaller window splits as you open new windows. Here is an example:

![autotiling screenshot]({{site_url}}/blog_assets/wayland/autotiling.png)	


1. Installation:
   As of my writing, autotiling is not available in the standard Ubuntu repositories for versions before 24.10. So we need to install it using pip:

   ```
   pyenv install 3.12
   pyenv global 3.12
   pip install autotiling
   ```

   If you don't use pyenv, you can install it directly with pip, but make sure you're using Python 3.12 or later.

2. Configuration:
   Add the following line to your `~/.config/sway/config` file:

   ```
   exec /home/yourusername/.pyenv/shims/autotiling
   ```

   Make sure to use the full path, as Sway might not pick up the command from your PATH.

3. Usage:
   Once configured, autotiling will work automatically. You'll notice that as you open new windows, they'll be tiled in a way that maintains a balanced layout, alternating between vertical and horizontal splits based on the dimensions of the current window.

## Screenshots

For taking screenshots in Wayland, I use a combination of [`grim`](https://wayland.emersion.fr/grim/), [`slurp`](https://wayland.emersion.fr/slurp/), and [`wl-copy`](https://github.com/bugaevc/wl-clipboard):

    ```
    sudo apt install grim slurp wl-clipboard
    ```
Here are their responsibilities:
* `grim`: screenshot tool
* `slurp`: screen region selection tool
* `wl-copy`: copy to clipboard tool (part of `wl-clipboard` apt packge)

2. Some useful commands:
   - Screenshot all monitors: `grim`
   - Select a region to screenshot: `grim -g "$(slurp)"`
   - Screenshot to clipboard: `grim -g "$(slurp)" - | wl-copy`

3. I created a custom script using `fuzzel` in dmenu mode to provide a nice screenshot selection interface, see the fuzzel section below.

### fuzzel: application launcher and custom menu selector

[Fuzzel](https://codeberg.org/dnkl/fuzzel) is a fast, lightweight application launcher and dmenu replacement designed for Wayland. It's an excellent alternative to tools like rofi or dmenu that were primarily designed for X11.

1. Installation:
   Fuzzel should be available in the Ubuntu repositories:

   ```
   sudo apt install fuzzel
   ```

2. Basic usage:
   To use fuzzel as an application launcher, simply run:

   ```
   fuzzel
   ```

   This will open a prompt where you can start typing the name of the application you want to launch.

![fuzzel]({{site_url}}/blog_assets/wayland/fuzzel.png)	


4. Using fuzzel as a dmenu replacement:
   Fuzzel can also work as a dmenu replacement, allowing you to create custom menus and selection interfaces. Here's an example of how to use fuzzel to create a custom screenshot selection menu:

   ```bash
   #!/bin/bash

   options="Screenshot\nScreenshot to Clipboard\nScreenshot All Windows"

   choice=$(echo -e "$options" | fuzzel --dmenu --prompt="Select Screenshot Option: ")

   case "$choice" in
       "Screenshot")
           grim -g "$(slurp)"
           nautilus ~/Pictures
           ;;
       "Screenshot to Clipboard")
           grim -g "$(slurp)" - | wl-copy
           ;;
       "Screenshot All Windows")
           grim
           nautilus ~/Pictures
           ;;
       *)
           echo "No valid option selected."
           ;;
   esac
   ```

   This script creates a simple menu for selecting different screenshot options using fuzzel in dmenu mode.

Here's a section on using `cliphist` for clipboard management in Wayland:

## Clipboard Management with cliphist

Managing clipboard history in Wayland can be a bit tricky, but [`cliphist`](https://github.com/sentriz/cliphist) provides a robust solution that integrates well with our existing setup. Here's how to set it up and use it effectively:

### Installation

First, install `cliphist` using apt:

```
sudo apt install cliphist
```

### Starting the Clipboard Manager

To start monitoring and storing clipboard content, add the following line to your Sway config file (`~/.config/sway/config`):

```
exec wl-paste --watch cliphist store
```

This command tells `wl-paste` to watch for changes in the clipboard and store them using `cliphist`.

### Using the Clipboard History

I use to use CopyQ for clipboard management. It is Wayland-compatible, but things like global hotkeys don't work, make it less usable on Wayland. I decided to switch to `cliphist`:

1. Installation:
```
sudo apt install cliphist
```

2. Start listing to copies:
```
wl-paste --watch cliphist store
```

3. Select a history item and copy it into the clipboard:

```
bindsym $mod+v exec cliphist list | fuzzel -d | cliphist decode | wl-copy
```

This command does the following:
    1. `cliphist list` shows the clipboard history
    2. `fuzzel -d` presents the list in a dmenu-style interface
    3. `cliphist decode` decodes the selected item
    4. `wl-copy` copies the selected item to the clipboard

Now, when you press your mod key + V, you'll see a fuzzel window with your clipboard history. Select an item to copy it to your clipboard.


## Troubleshooting
### Browser Compatibility

I use Brave Browser, which initially had some input lag issues under Wayland. To resolve this:

1. Launch Brave with these flags:
   ```
   brave-browser --gtk-version=4 --enable-features=UseOzonePlatform --ozone-platform=wayland
   ```

2. The `--gtk-version=4` flag is necessary for enabling fcitx5 input method.

3. You may need to disable the "Quick command" shortcut in Brave (Ctrl + Space) to avoid conflicts with input method switching shortcuts.

### Screen Sharing

Getting screen sharing to work properly under Wayland required some additional setup:

1. Install the necessary package:
   ```
   sudo apt install xdg-desktop-portal-wlr
   ```

2. Ensure the WAYLAND_DISPLAY environment variable is properly set:
   ```
   dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
   ```

3. Restart the relevant services:
   ```
   systemctl --user stop pipewire xdg-desktop-portal xdg-desktop-portal-wlr wireplumber pipewire.socket
   systemctl --user start wireplumber
   systemctl --user start xdg-desktop-portal-wlr
   systemctl --user start xdg-desktop-portal
   ```
### Running old X11 application
If the old X application (e.g. `gparted`) does not launch with error "cannot open display :0", run `xhost +local:`

## Conclusion

Switching to Wayland with Sway has been a mostly smooth experience. While there were some initial hurdles to overcome, particularly with input methods and screen sharing, the end result is a modern, smooth, and customizable desktop environment. The availability of Wayland-compatible tools like Waybar, wdisplays, and fuzzel has made the transition easier and more enjoyable.

There are still a few areas I'm exploring, such as finding a good clipboard manager that works well with Wayland (with auto-expiring for passwords...). Overall, I'm satisfied with the switch and looking forward to further improvements in the Wayland ecosystem.
