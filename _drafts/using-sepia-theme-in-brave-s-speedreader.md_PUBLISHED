---
layout: post
title: Using sepia theme in Brave's SpeedReader
categories: Web
date: 2023-07-18 21:48:11 +08:00
excerpt_separator: <!--more-->
---

I like Brave’s [SpeedReader](https://brave.com/research/speedreader-reader-mode-made-fasst-and-private/) feature. It is a new approach to reader modes that removes unnecessary elements from pages it recognizes as articles and displays them in a simplified format as part of the rendering pipeline. Because it's done during rendering, not after the page have rendered (as most reader mode extensions does), it delivers performance gain and reduce the network bandwidth required. 

However, there is one thing that bothers me about SpeedReader. It follows the browser theme, so if you choose dark theme the SpeedReader theme is always white text on black, which is hard to read for me. I prefer a sepia theme for reading articles, as it is more soothing for my eyes. Unfortunately, there is no UI for changing the SpeedReader theme. However, I found this [github issue](https://github.com/brave/brave-browser/issues/23447). It shows that the theme has actually been implemented, but there is no way to access it from the browser settings. If you set the `data-theme` attribute on `document.documentElement` using JavaScript, you can toggle between dark, light and sepia themes.
<!--more-->

So how did I solve this problem? I used a tool called Tampermonkey. Tampermonkey is a browser extension that allows you to run userscripts on websites. Userscripts are small JavaScript programs that can be used to modify web pages, add new features or automate actions. Tampermonkey is available on Chromium-based browsers, so you can use it on Brave.

With Tampermonkey, I created a simple userscript that forces SpeedReader to use sepia theme on any page. Here is the code:

```javascript
// ==UserScript==
// @name         Brave Speedreader Sepia
// @description  Force Brave browser's speedreader to use sepia theme
// @version      0.1
// @match        https://*/*
// @match        http://*/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';
    document.documentElement.setAttribute('data-theme', 'sepia')
})();
```

This userscript runs on every page that starts with `https://` or `http://` (see the `@match` lines) and changes the `data-theme` attribute of the document element to `sepia`. This is how it looks like before and after the change:

![before]({{site_url}}/blog_assets/brave_speedreader/before.png)
![after]({{site_url}}/blog_assets/brave_speedreader/after.png)

In conclusion, I think SpeedReader is a great feature that improves the web browsing experience by making it faster and simpler. However, I wish there was a way to change the theme of SpeedReader without using a third-party tool like Tampermonkey. I hope the Brave team will add this option in the future. Until then, I will keep using my userscript to enjoy reading articles in sepia mode.

