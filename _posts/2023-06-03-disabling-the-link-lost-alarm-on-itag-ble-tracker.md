---
layout: post
title: Disabling the Link Lost alarm on iTag BLE tracker
categories: Web
date: 2023-06-03 16:42:08 +02:00
excerpt_separator: <!--more-->
---

In this blog post, I will share my experience of using an iTag BLE tracker to find my lost TV remote and how I disabled the annoying link lost alarm feature.

# What is an iTag BLE tracker?
An iTag BLE tracker is a small device that can be attached to any object and paired with a smartphone via Bluetooth Low Energy (BLE). It can be used as a key finder, anti-lost alarm, remote shutter, or voice recorder. It has a button that can trigger various actions on the smartphone, such as ringing, taking a photo, or recording a voice memo. It also has a built-in speaker that can beep when the Bluetooth connection is lost or when the button is pressed.

![itag]({{site_url}}/blog_assets/itag/itag.jpeg)

I bought an iTag BLE tracker because I often lose my TV remote in the house, most of the time hidden somewhere by my toddler son. I wanted to use it as a simple device that can help me locate my remote by making a sound when I press the button on my smartphone. I thought it would be a cheap and easy solution for my problem.
<!--more-->

# The official Android app...
However, I soon realized that the official Android app for iTag BLE tracker is garbage. I won't include the link here because I don't want to promote it. It has several issues that make it unusable for me:

* It asks for too many permissions, such as camera, voice recording, file access, location, etc. It just feels creepy.
* It crashes if it doesn’t get all the permissions. It doesn’t handle the permission denial gracefully and just stops working.
* It frequently disconnects and fails to reconnect. It often loses the connection with the iTag device and wouldn't reconnect no matter what.

# The alternative: itracing2?
I was very disappointed with the official app and decided to look for an alternative. I searched online and found an open source app called [itracing2 on GitHub](https://github.com/sylvek/itracing2). It is a fork of another app called itracing that adds some features and fixes some bugs. It claims to be compatible with iTag devices and other similar BLE trackers.

I downloaded and installed itracing2 from F-Droid and paired it with my iTag device. It worked fine and had a simple interface that allowed me to ring the iTag device, see its battery level, and adjust some settings. It also didn’t ask for unnecessary permissions or crash randomly.

# The annoying link lost alarm
One of the settings that itracing2 offers is link lost alarm. This feature makes the iTag device beep when the Bluetooth connection is lost. This is supposed to prevent losing the iTag device or the object attached to it by alerting the user when they go out of range.

However, I don’t need this feature for my use case. I just want to find my TV remote when I lose it in my house. I don’t care if the iTag device is out of range or not. In fact, I want to keep my phone’s Bluetooth off most of the time to save battery and avoid interference with other devices. I only want to turn it on when I need to ring the iTag device.

The problem is that itracing2 doesn’t allow me to disable link lost alarm. There is a setting for it, but it doesn’t work. No matter what value I choose, the iTag device always beeps when the connection is lost. This is very annoying and defeats the purpose of using it as a silent finder.

# Debugging time
After some research, I found a solution to disable link lost alarm on iTag BLE tracker. The trick is to use another app that can write directly to the BLE characteristics of the iTag device. A BLE characteristic is a data point that can be read or written by a BLE client (such as a smartphone) or a BLE server (such as an iTag device). Each characteristic has a unique identifier (UUID) that defines its function and format.

I used an app called [nRF Connect for Mobile](https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp&hl=en) that can scan and connect to any BLE device and show its services and characteristics. A service is a collection of related characteristics that provide a specific functionality.

I followed these steps to disable link lost alarm:

1. Open nRF Connect for Mobile and scan for nearby devices.
2. Find and connect to my iTag device (it has a name like ``ITAG``).
3. There is a service named **Link Loss**, This is what the itracing2 app writes to. It is suppose to turn off the link lost alarm when you write `0x00 (No alert)` to it, but it has no effect. No matter what you write the device still beeps when the bluetooth connection is lost.
  ![link_loss service]({{site_url}}/blog_assets/itag/link_loss.jpeg)
4. Instead, expand the service called **Unknown Service** with UUID `0xFFE0` and the characteristic with UUID `0xFFE2`. This characteristic should have a descriptor called “Set LinkLost Alert”.
    ![Unknown service]({{site_url}}/blog_assets/itag/unknown_service.jpeg)
5. Write a `0` to this characteristic by tapping on the up arrow icon and selecting “UINT8” as the format and “0” as the value.
6. Disconnect from the iTag device and close the app. 

This should disable the link lost alarm on the iTag device. Now it won’t beep when the Bluetooth connection is lost. I can use itracing2 to ring it when I need to find my TV remote.

*Disclaimer: this post is written with the help from generative AI, this is an experiment*
