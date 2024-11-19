---
layout: post
title: Install Ubuntu 16.04 on ThinkPad 13 (2nd Gen)
categories: Web
date: 2017-07-09 22:18:25 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

_It has been a while since my last post. I've been busy for the first half of this year but now I got more free time. Hopefully I can get back to my usual pace of one post per months._

My old laptop (Inhon Carbonbook, discontinued) had a swollen battery. I kept using it for a few months but then the battery squeezed my keyboard so I can no longer type correctly. After some research I decided to buy the ThinkPad 13 model because it provides descent hardware for its price, and the weight (~1.5 kg) is acceptable.
Every time I got a new computer the first thing is to get Linux up and running. So here are my notes on how to install Ubuntu Linux on it.
 
__TL;DR__: Everything works out of the box. Just remember to turn off secure boot and shrink the disk in Windows before you install.

<!--more-->

# Some assumptions
* I'm using [ThinkPad 13 2nd Gen][thinkpad13] bought in June 2017
* I'm using [Ubuntu Linux 16.04.2 LTS][ubuntu]
* I use Linux as my primary operating system, but still keeps Windows for rare occasions.


# Before Installing Ubuntu
First we need to clean up some disk space for Ubuntu. But if you are going to delete Windows completely you can skip the following steps.

* (In Windows) Right click on the start menu, select "PowerShell (administrator)", then run `diskmgmt.msc`.
* Right click the `C:` disk and select the shrink disk option.

Before we can install Ubuntu, we need to disable the secure boot feature in BIOS.

* Press `Shift`+restart to be able to get into BIOS, otherwise you'll keep booting into Windows.
* Press `Enter` followed by `F1` to go into BIOS during boot.
* Disable Secure Boot.

![BIOS]({{site_url}}/blog_assets/linux_on_tp13/BIOS.JPG)
![secure_boot]({{site_url}}/blog_assets/linux_on_tp13/BIOS_secure_boot.JPG)
![secure_boot_sub_menu]({{site_url}}/blog_assets/linux_on_tp13/BIOS_secure_boot_2.JPG)

UEFI boot seems to work with Ubuntu 16.04's installer, so you can keep all the UEFI options enabled in the BIOS. Download the [Ubuntu installation disk][ubuntu] and use a bootable USD disk creator that supports UEFI, for example [Rufus][rufus].

# Installing Ubuntu

Installing Ubuntu should be pretty straightforward if you've done it before.

* Go to BIOS again and set the USB drive as top priority boot medium.
* Boot into Ubuntu, select "Install Ubuntu".
* Follow the installer wizard.
* Select "Something else" when asked how to partition the disk.
* Create a `linux-swap` partition of 4GB for 8GB of RAM. I followed [Redhat's suggestion][swap], but there are different theories out there, so use your own judgement here.
* Create a EXT4 main disk and set the mount point to `/`
* After the installer finished, reboot. You should see the GRUB2 menu. The Windows options should also work without trouble.

![GRUB2]({{site_url}}/blog_assets/linux_on_tp13/GRUB2.JPG)

# What works?
Almost everything works out of the box. All the media keys, like volume control, brightness and WiFi and Bluetooth toggle is recognized by the built-in Unity desktop. But I am using i3 so I have to set them up myself, more on this later. The USB Type-C port is a nice surprise for me. It supports charging, so you can charge with any Type-C charger. I tested Apple's Macbook charger and it works well. I also tested [Apple's][apple_cable] and [Dell's][dell_cable] Type-C multi-port adapter and both works, so I can plug my external monitor and my keyboard/mouse to it so it works like a docking station.

![media_key]({{site_url}}/blog_assets/linux_on_tp13/media_btn.JPG)

A side note, I'm also glad to find that Ubuntu now use the Fcitx IME by default. Most of the IME bugs I found in previous versions and ibus are now gone.

# What doesn't work?
Not that I'm aware of. The only complaint I have is that the Ethernet and Wi-Fi naming method has changed somehow (e.g. `enp0s31f6` instead of `eth0`). But I believe that is something we can fix by software. People also complain that the power button and the hinge is not very sturdy. But I guess that's the compromise you have to make for the relatively cheap price.

![power_button]({{site_url}}/blog_assets/linux_on_tp13/power_btn.JPG)

# More on setting up media keys for i3 window manager
Since I use the i3 window manager, I don't have Unity to handling all my media keys' functionality. But it's not hard to set them up using the following i3 config:

```
bindsym XF86AudioRaiseVolume exec amixer -q set Master 2dB+ unmute
bindsym XF86AudioLowerVolume exec amixer -q set Master 2dB- unmute
bindsym XF86AudioMute        exec amixer -D pulse set Master toggle # Must assign device "pulse" to successfully unmute

# Only two level of brightness
bindsym XF86MonBrightnessUp    exec xrandr --ouptut eDP-1 --brightness 0.8
bindsym XF86MonBrightnessDown  exec xrandr --ouptut eDP-1 --brightness 0.5
```

The only drawback is that the LED indicator on the mute buttons mighty be out of sync with the real software state.

# Conclusion

Overall, ThinkPad 13 is a descent laptop for its price range. Ubuntu 16.04 works out of the box. No sweat! If you are looking for a good Linux laptop, but can't afford ThinkPad X1 Carbon or Dell's XPS 13/15, ThinkPad 13 might be a good choice.

[thinkpad13]: http://www3.lenovo.com/us/en/laptops/thinkpad/thinkpad-13-series/ThinkPad-13-Windows-2nd-Gen/p/22TP2TX133E
[ubuntu]: http://releases.ubuntu.com/16.04/
[rufus]: https://rufus.akeo.ie
[swap]: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Storage_Administration_Guide/ch-swapspace.html#swap-extending-lvm2
[apple_cable]: https://www.apple.com/shop/product/MJ1L2AM/A/usb-c-vga-multiport-adapter
[dell_cable]: http://www.dell.com/en-us/shop/dell-adapter-usb-3-0-to-hdmi-vga-ethernet-usb-2-0/apd/470-abhh/handhelds-tablet-pcs
