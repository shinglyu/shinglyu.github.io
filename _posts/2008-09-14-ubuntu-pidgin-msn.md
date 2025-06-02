---
layout: post
title: "[Ubuntu教學] 如何讓pidgin 的MSN有個人狀態"
date: 2008-09-14
tags: [ubuntu, linux, pidgin, msn, tutorial]
categories: tech
---

> This was an early technical blog I've written on another blogging platform. The content is probably outdated and my writing style was cringey. But I copied it here anyway for archival purposes.

如果你用pidgin 上MSN，你會看不到其他人的狀態(名字下面灰灰那一行)  
據說也收不到離線訊息  
原因是因為pidgin 裡負責MSN 的外掛版本比較舊  
那要怎麼辦呢？  
只要安裝另外一個外掛msn-pecan就可以了  
這個外掛沒有整合到pidgin 裡，連作者自己都覺得很納悶XD  
  
==========教學開始==========  
1.首先打開終端機，輸入  

> sudo gedit /etc/apt/sources.list

意思是用gedit(也就是文字編輯器)來打開/etc/apt/下的sources.list檔，這個檔案裏面寫的就是安裝套件時的來源位置。  
  
2.打開以後在檔案裏面加入以下兩行：  
  

如果你用8.04 Hardy Heron

> deb http://ppa.launchpad.net/msn-pecan/ubuntu hardy main
> deb-src http://ppa.launchpad.net/msn-pecan/ubuntu hardy main

如果用7.10 Gusty Gibbon  

> deb http://ppa.launchpad.net/msn-pecan/ubuntu gutsy main  
> deb-src http://ppa.launchpad.net/msn-pecan/ubuntu gutsy main

然後按儲存，就可以關掉視窗了。  
  
3.回到終端機，輸入  

> sudo apt-get update

4.接著輸入  
  

> sudo apt-get install msn-pecan  

這樣就安裝完了。  
  
5.接下來請打開你的pidgin，已經開的話請關掉重開  
新增一個帳號 帳號>>管理>>新增  

![Pidgin帳號管理](/blog_assets/ubuntu-pidgin/msn.jpg)

注意！通訊協定請選 WLM  
  

![新增帳號](/blog_assets/ubuntu-pidgin/add.jpg)

資料還是照MSN 的填完吧，之後登入就會看到狀態都跳出來了  
  
來源：[http://code.google.com/p/msn-pecan/wiki/HowToInstall](http://code.google.com/p/msn-pecan/wiki/HowToInstall)

---

*原文發表於 2008年9月14日*
