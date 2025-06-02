---
layout: post
title: "[Ubuntu教學]如何設定ThinkPad的指紋辨識"
date: 2008-09-06
tags: [ubuntu, linux, thinkpad, fingerprint, tutorial]
categories: tech
---

> This was an early technical blog I've written on another blogging platform. The content is probably outdated and my writing style was cringey. But I copied it here anyway for archival purposes.

如果你有一台ThinkPad是有付指紋辨識的  
其實你可以很輕易的在Ubuntu中啟用這個功能  
方法如下：  
  
1.安裝驅動程式，請開啟終端機，輸入以下指令  

> sudo apt-get install thinkfinger-tools libpam-thinkfinger

如你所見，我們安裝的是[ThinkFinger](http://thinkfinger.sourceforge.net/index.php)這個自由軟體  
  
2.接下來輸入這個來啟動吧  

> sudo /usr/lib/pam-thinkfinger/pam-thinkfinger-enable

3.現在我們要讓電腦學會認你的指紋，所以輸入這個  

> sudo tf-tool --acquire

它會要求你刷三次指紋  

> Please swipe your finger (successful swipes 3/3, failed swipes: 0)...

乖乖的刷三下，記得動作慢一點比較不會失敗  
  
4.如果你想確定一下是否成功，可以用以下的指令：  

> sudo tf-tool --verify

它會要求你刷一次，再告訴你是否吻合

---

*原文發表於 2008年9月6日*
