---
layout: post
title: WebRender Overview
categories: Web
date: 2016-07-21 17:49:29 +08:00
excerpt_separator: <!--more-->
---

Rational for Web Dev
  60 fps full screen animation without understanding implementation
Issues with the old approaches
  * CPU
  * Layers
  * Immediate mode

How WebRender solves them
  * CPU -> GPU
  * Layers dirty bit => Redraw every frame
  * Immediate => Retained mode, more optimization
How it works
* GPU programming primer
* CPU does batching and optimization
* What shaders do
* Text Rendering


Status
  * Not default on, not passing CI yet

Future WebRender2
Open end questions:
  * Bad GPU driver? Emulated GPU using CPU
