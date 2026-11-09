---
layout: post
title: "Temporary Camera: The Android App I Always Wanted, Built with AI"
date: 2026-11-08 00:00:00 +01:00
categories: blog
excerpt_separator: <!--more-->
grammar_checked: false
fact_checked: false
---

I just released [Temporary Camera](https://play.google.com/store/apps/details?id=com.shinglyu.temporarycamera) on Google Play, a tool I've always wanted, built with AI. Here is why I made it and how an old phone, a piece of paper and an AI model got the camera rotation right while I did the dishes.

<!--more-->

## The problem

I often need to take photos that are useful for only a short time: a locker number, a receipt, a parking spot. I don't want those photos cluttering my main gallery forever. Temporary Camera keeps them in a separate place and the photos auto-expire, so they are easy to get rid of.

A few years ago a solo developer published a similar app on Google Play, but it later disappeared. So I built my own.

## Starting as a Progressive Web App

The first version was a Progressive Web App built with AI, maybe one or two years ago. I didn't have the time and energy to set up an Android development environment (I had even run out of disk space to install Android Studio).

The PWA worked well, but with two limitations:

- I stored the photos in IndexedDB, whose storage size is capped and a little unpredictable. Each browser decides the cap differently, and it depends on the remaining space on the device.
- Sometimes the Service Worker cache got cleared. I couldn't open the camera when I needed it most, and had to turn on 5G and reload the web app.

## Moving to Kotlin Multiplatform

I then switched to OpenAI GPT-5.6-Luna to build a native version with Kotlin Multiplatform (KMP), partly because I wanted to learn KMP. The AI worked quickly and used the command line to do most of the compiling and packaging, so I didn't have to juggle Android Studio myself.

It got most of the functionality right, except for rotation. I want the camera preview to work in both portrait and landscape, and the photo to be portrait or landscape depending on the device's orientation when it is taken. Luna kept getting this wrong: either the preview was rotated by 90 degrees, or the saved photo had the wrong orientation.

I briefly switched to Claude Sonnet 5, but it failed to clean up the mess.

## Letting the model test on a real phone

Then I noticed a free preview of a model called `ox-alpha` on OpenCode and gave it a try. It turned out to be GLM-5.3-Flash.

The model asked for adb access. So I took an old phone, connected it to my laptop over USB, and gave the model full control through adb.

I put the phone on a stand and placed a piece of paper in front of the camera. On it I drew a cross and labeled the ends "up", "down", "left" and "right". The model used adb to:

- install the app,
- automate taps,
- take screenshots.

It could then look at the cross in the camera preview and in the captured photo to decide whether the rotation was correct.

I let it test by itself. When I came back from taking a shower and loading the dishwasher, the rotation was completely fixed. I didn't track exactly how long it took, but it was probably around 30 minutes.

Since then I always use a clean spare phone and let the model do the integration testing through adb. It is amazing how much a model can do when it can control and "see" the world.

## Try it

Please [install Temporary Camera](https://play.google.com/store/apps/details?id=com.shinglyu.temporarycamera) and send me feedback. Another app is coming too, and its closed beta testing is showing good results. Stay tuned!
