---
layout: post
title: "[HOWTO] Check MBR Infomation Under Linux"
date: 2012-06-19
tags: [linux, mbr, howto, dd, tutorial]
categories: tech
---

> This was an early technical blog I've written on another blogging platform. The content is probably outdated and my writing style was cringey. But I copied it here anyway for archival purposes.

#### Problem: What is the easy way to see the content of the MBR (Master Boot Record) on a hard disk, say, /dev/hda ?

Answer:



1. Use dd to copy the MBR to a file, open a shell/terminal and type:

   `dd if=/dev/sda of=mbr.bin bs=512 count=1`

This is because MBR is 512KB only.

2. Examine the dumped mbr.bin using command file in linux

   `file mbr.bin`

You should get something like this:

```
mbr.bin: x86 boot sector; partition 1: ID=0x83, starthead 32, startsector 2048, 62914560 sectors; partition 2: ID=0x82, starthead 254, startsector 62916608, 16777216 sectors; partition 3: ID=0x83, starthead 254, startsector 79693824, 293601280 sectors; partition 4: ID=0x83, starthead 254, startsector 373295104, 251846656 sectors, code offset 0x63
```

---

*原文發表於 2012年6月19日*
