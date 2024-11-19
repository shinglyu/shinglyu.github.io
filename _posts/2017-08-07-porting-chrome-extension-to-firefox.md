---
layout: post
title: Porting Chrome Extension to Firefox
categories: Web
date: 2017-08-07 14:37:22 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

Three years ago, I wrote the [FocusBlocker][oldfb] to help me focus on my master thesis. It's basically a website blocker that stops me from checking Facebook every five minute. But is different from other blockers like [LeechBlock][leechblock] that requires you to set a fixed schedule. FocusBlocker lets you set a quota, e.g. I can browse 10 minutes of Facebook then block it for 50 minutes. So as long as you have remaining quota, you can check Facebook anytime. I'm glad that other people find it useful, and I even got my first donation through AMO because of happy users.

Since this extension serves my need, I'm not actively maintaining it or adding new features. But I was aware of Firefox's [transition from the legacy Add-on SDK to WebExtension API][transition]. So before WebExtension API is fully available, I started to migrate it to Chrome's extension format. But I didn't got the time to actually migrate it back to Firefox, until a user emails me asking for a WebExtension version. I looked into the statistics, the daily active user count drops from ~1000 to ~300. That's when I rolled up my sleeve and actually migrated it in one day. (Although later I found out that the drop is not entirely due to users upgrading to newer Firefox, is because of [this change][stats].) Here is how I did it and what I've learned from the process.

<!--more-->

![daily_user.png]({{site_url}}/blog_assets/webext/daily_user.png)

# What needs to be changed
To evaluate the scope of the work. We need to first look at what APIs I used. The FocusBlocker Chrome version uses the three main APIs:

* `chrome.tabs`: to monitor new tabs opening and actually block existing tabs.
* `chrome.alarm`: Set timers for blocking and unblocking.
* `chrome.storage.sync`: To store the settings and persist the timer across browser restarts.

It's nice that these APIs are all supported (at least the parts I used) in Firefox, so I don't really need to modify any JavaScript code.

I loaded the manifest directly in Firefox's `about:debugging` page (you can also consider use the convenient [`web-ext`][web-ext] command line tool), but Firefox rejects it.

![about_debugging.png]({{site_url}}/blog_assets/webext/about_debugging.png)

That's because Firefox requires you to set a unique `id` for each extension(Not required if you use `web-ext run`. You can read more about the `id` requirement [here][id_req]), and you should (but not mandatory) also set a minimal version of Firefox on which the extension works, like so:

```
"applications": {
  "gecko": {
    "id": "focusblocker@shing.lyu",
    "strict_min_version": "48.0"
  }
},
```

There is one more modification need. In my Chrome extension I used the old [`options_page` setting][options_page] setting to set the preference page. But Firefox only support the newer [`options_ui`][options_ui]. You can also apply browser's system style for your settings page, so the UI looks like part of the Firefox setting. Firefox generalized the name from `chrome_style` to `browser_style`. So this is what I need to add to my `manifest.json` file (and remove the `options_page` setting):

```
"options_ui": {
  "page": "options.html",
  "browser_style": true
},
```


![about_addon.png]({{site_url}}/blog_assets/webext/about_addon.png)
![browser_style.png]({{site_url}}/blog_assets/webext/browser_style.png)

That's all I need to port the extension from Chrome to Firefox. Super easy! The WebExtension team really did a good job on making the extensions compatible. In case you are curious, you can find the full source code of FocusBlocker on [GitHub][github].

# Publishing the extension on AMO

To publish the extension on [addons.mozilla.org][amo], you need to zip all the files in a zip and upload it. Here are some tips for passing the review more easily. 

* If you already have a legacy extension listed, upload the WebExtension-API-backed extension to replace it, so your user will have an easier time upgrading.  (I chose to upload a separate listing, which is not recommended by the Add-on team.)
* Don't pack any unnecessary file into the zip, exclude all the temporary test files from the zip.
* Remove or comment out all the `console.log()` calls. Although it's not a strict requirement, but it will make the review process much smoother.
* If you use any third party library, consider including (i.e. "vendoring") the file into the zip, or at least upload the source for review.
* If you've upload one version and you'd like to make some modifications or fix, you need to bump the version number, no matter how small the change is.

Firefox is planning to completely roll out the new format in version 57 (around November, 2017). So if you have a legacy Firefox extension, or a Chrome extension you want to convert, now is a perfect timing.

__If you want to try out the new FocusBlocker, please head to the [install page][amofb]. You can also find the Chrome version [here][chromefb].__

__Edit (2017/8/30)__: Andreas from the Mozilla Add-on team points out a few errors, I've modified the original text to reflect that:

* Do NOT create a new version of the extension on AMO, upload and replace your legacy extension using the same listing.
* The user drop is related to https://blog.mozilla.org/addons/2017/06/21/upcoming-changes-usage-statistics/
* The `web-ext run` should work without an ID
* `strict_min_version` is not mandatory

[web-ext]: https://developer.mozilla.org/en-US/Add-ons/WebExtensions/Getting_started_with_web-ext
[id_req]: https://developer.mozilla.org/en-US/Add-ons/WebExtensions/WebExtensions_and_the_Add-on_ID
[options_page]: https://developer.chrome.com/extensions/options
[options_ui]: https://developer.mozilla.org/en-US/Add-ons/WebExtensions/manifest.json/options_ui
[amo]: https://addons.mozilla.org
[oldfb]: https://addons.mozilla.org/en-US/firefox/addon/focusblocker/?src=userprofile
[leechblock]: https://addons.mozilla.org/en-US/firefox/addon/leechblock/
[transition]: https://blog.mozilla.org/addons/2015/08/21/the-future-of-developing-firefox-add-ons/
[github]: https://github.com/shinglyu/focusblocker
[amofb]: https://addons.mozilla.org/en-US/firefox/addon/focusblocker-new/
[chromefb]: https://chrome.google.com/webstore/detail/focusblocker/bejdhniafighghjelnmhhcgongokdhbi?hl=en-US
[stats]: https://blog.mozilla.org/addons/2017/06/21/upcoming-changes-usage-statistics/
