---
layout: post
title: "[Ubuntu教學] Atheros AR2425/AR5007EG無線網卡驅動"
date: 2008-11-01
tags: [ubuntu, linux, atheros, wifi, drivers, tutorial]
categories: tech
---

> This was an early technical blog I've written on another blogging platform. The content is probably outdated and my writing style was cringey. But I copied it here anyway for archival purposes.

我的ThinkPad R61用的是Atheros 的無線網卡，Ubuntu預設的驅動跑不起來。  
Google一番以後我在Ubuntu Forum中發現了解決的方法  
===============正文開始===============  
1.首先你必須要有有線網路，否則之後的很多軟體都無法取得。  
2.先確認是否有安裝該裝的軟體：build-essential, linux-restricted-modules, subversion, 請在終端機輸入以下指令:  

> sudo apt-get install build-essential  
> sudo apt-get install linux-restricted-modules-$(uname -r)  
> sudo apt-get install subversion

3.如果你有安裝並使用ndiswrapper，記得把他關掉  
4.接下來請到系統>>管理>>硬體驅動程式, 把所有Atheros的驅動程式都勾掉(取消)，然後重開機。  
5.重開機完就可以來安裝新的驅動程式了，在終端機輸入以下指令：  

> svn co https://svn.madwifi.org/madwifi/branches/madwifi-hal-0.10.5.6  
> cd ~/madwifi-hal-0.10.5.6  
> make  
> sudo make install  
> sudo depmod -ae  
> sudo modprobe ath_pci  
> echo ath_hal | sudo tee -a /etc/modules  
> echo ath_pci | sudo tee -a /etc/modules

6.最後再到系統>>管理>>硬體驅動程式把Atheros的驅動程式都勾起來，重開機。  
7.每次更新完kernel之後都要重複以上步驟，建議你不要把下載下來的檔案刪掉，這樣每次更新kernel之後只要輸入以下指令：  

> cd ~/madwifi-hal-0.10.5.6  
> make clean  
> sudo make install

這樣就可以用啦!  

如果還是連不上的話，可以參考http://madwifi.org/wiki/UserDocs/FirstTimeHowTo

---

*原文發表於 2008年11月1日*
