---
layout: post
title: Make LastPass Work Across App and Website
categories: Web
date: 2017-10-16 20:59:46 +02:00
tags: mozilla
excerpt_separator: <!--more-->
---

__The Problem__: My stock broker outsourced their Android app to a third-party company, so LastPass treat the desktop website and Android app as different sites. Although I can save them separately in LassPass, their password won’t synchronize with each other.
<!--more-->

__The Solution__: LassPass do have [a way][merge] to “merge” two sites into one, but the UI for doing so is not in the password vault page nor in the individual site’s configuration. Instead, the list of “equivalent” sites are under your account settings. 



Here are the procedure to merge them:

1. Log-in to your LastPass desktop website. (I didn’t found the setting in the mobile app.)
2. Click your account icon on the top right and go to settings.
![account settings]({{site_url}}/blog_assets/lastpass/account_settings.png)
3. In your account settings, choose the "Equivalent Domains" tab.
![equivalent domains settings]({{site_url}}/blog_assets/lastpass/equivalent.png)
4. Here you can add to the list of equivalent sites. For example my broker’s desktop site is using the domain “capital.com.tw”, but its app uses “mitake.com”, which is the outsource company that built the app. So I’ll add them into one entry so they are treated as equivalent.
![my_site]({{site_url}}/blog_assets/lastpass/my_site.png)


5. Ta-dah! Now I can login to both the app and desktop site using the same LastPass entry.

__Side note__: Why I decided to use a password manager?

I avoid using a password manager for quite a while. I always believe it’s a bad idea to have a single point of failure. But after listening to a presentation by the security expert in my company, I decided to give it a try. The presenter mentioned that although LassPass had suffered from a few breaches in the past, the main password vault was never compromised, and they were very transparent about how and what had happened. So after I moved to Amsterdam and had to register tons of new online services, I simply can’t come up with a good algorithm to design my password that works across all sites. The risk of LastPass being completely hacked is relatively low comparing to my one password used across all sites being breached. If I use one password across all sites, then the level of security I get is equal to the security level of the weakest site I use (e.g. [Yahoo][yahoo]?), so I would rather bet on LastPass. 

[merge]: https://lastpass.com/support.php?cmd=showfaq&id=1256
[yahoo]: http://www.telegraph.co.uk/technology/2017/10/03/yahoo-says-3-billion-accounts-affected-2013-data-breach/
