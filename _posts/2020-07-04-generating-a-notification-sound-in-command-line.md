---
layout: post
title: Generating a notification sound in command-line
categories: micro 
date: 2020-07-04 15:05:16 +02:00
excerpt_separator: <!--more-->
---

You want to play a notification sound in a Linux shell script, but don't want to download any sound files (e.g. MP3, WAV, MIDI). Here is a script that generates the sound on-the-fly:

First install [SoX](http://sox.sourceforge.net/), *the Swiss Army knife of sound processing programs*.

```bash
sudo apt-get install sox
```

Then:

```bash
play -n synth 0.3 pluck A3 vol -20dB repeat 2
```

* `play`: the player command from SoX.
* `-n`: Play a "null file".
* `synth 0.3 pluck A3`: Play the A3 (220.00 Hz) sound for 0.3 seconds, with a waveform that simulates a guitar string pluck.
* `vol -20dB`: The default is too loud, reduce the volume by -20dB.
* `repeat 2`: Repeat twice (i.e., total 3 times).

<!--more-->
