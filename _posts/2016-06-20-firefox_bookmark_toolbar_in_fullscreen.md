---
layout: post
title:  "Show Firefox Bookmark Toolbar in Fullscreen Mode"
categories: Web
tags: ['mozilla']
date:   2016-06-20 19:05:00 +08:00
excerpt_separator: <!--more-->
---

By default, the bookmark toolbar is hidden when Firefox goes into fullscreen mode. It's quite annoying because I use the bookmark toolbar a lot. And since I use [i3 window manager](https://i3wm.org), I also use the fullscreen mode very often to avoid resizing the window. After some googling I found this [quick solution](https://support.mozilla.org/zh-TW/questions/1039009) on SUMO (Firefox commuity is awesome!). 

![before]({{site_url}}/blog_assets/bookmark_bar/before.png)

The idea is that the Firefox [chrome](https://developer.mozilla.org/en-US/docs/Glossary/Chrome) (not to be confused with the Google Chrome browser) is defined using [XUL](https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XUL). You can adjust its styling using CSS. The user defined chrome CSS is located in your [Firefox profile](https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data). Here is how you do it:

<!--more-->

* Open your Firefox [profile folder](https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XUL), which is `~/.mozilla/firefox/<hash>.<profile_name>` on Linux. If you can't find it, you can open `about:support` in your Firefox. and click the "Open Directory" button in the "Profile Directory" field.

![before]({{site_url}}/blog_assets/bookmark_bar/about_support.png)

* Create a folder named `chrome` if it doesn't exist yet.
* Create a file called `userChrome.css` in the `chrome` folder, copy the following content into it and save.


<pre><code>
@namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"); /* only needed once */

/* full screen toolbars */
#navigator-toolbox[inFullscreen] toolbar:not([collapsed="true"]) {
   visibility:visible!important;
}
</code></pre>

* Restart your Firefox and Voila!

![before]({{site_url}}/blog_assets/bookmark_bar/after.png)
