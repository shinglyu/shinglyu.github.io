---
layout: post
title: Chatting with your website visitors through Chatra
categories: Web
date: 2018-08-13 20:59:29 +02:00
tags: mozilla
excerpt_separator: <!--more-->
---

**Update (May 31, 2025):** *I've removed the Chatra chat widget from my website today. While it was a useful tool, I found that many users mistakenly thought it was AI-powered and would be quite rude when interacting with what they assumed was a chatbot. If you need to reach out, please feel free to contact me via email listed at the bottom of this website instead.*

---

When I started the blog, I didn't add a message board below each article because I don't have the time to deal with spam. Due to [broken windows theory][broken_window], if I leave the spam unattended my blog will soon become a landfill for spammers. But nowadays many e-commerce site or brand sites have a live chatting box, which will solve my problem because I can simply ignore spam, while interested readers can ask questions and provide feedbacks easily. That's why when my sponsor, [Chatra.io][chatra], approached me with their great tool, I fell in love with it right away and must share it with everyone.

<!--more-->

# How it works
First, signup for a free account [here][signup], and you'll be logged into a clean and modern chat interface. 

![first login page][chat_page]

You'll get a JavaScript widget snippet (in the "Set up & customize" page or email), which you can easily place onto your site (even if you don't have a backend, like this site). A chat button will immediately appear on your site. Your visitor can now send you messages, and you can choose to reply them right away or followup later using their [web dashboard][web], [desktop][app] or [mobile app][app].

![chat box][chat_box]


# What I love about Chatra

### Easy setup and clean UI
As you can see, the setup is simply pasting a block of code into your blog template (or use their app or plugin for [your platform][cms]), and it works right away. The chat interface is modern and clean, you can "get it" within no time if you ever used any chat app.

### Considerations for bloggers who can't be online all day
You might wonder, "I don't have an army of customer service agents, how can I keep everyone happy with only myself replying messages?". But Chatra already considered that for you with [messenger mode][messenger], which can receive messages 24/7 even if you are offline. A bot will automatically reply to your visitor and ask for their contact details, so you can follow up later with an email. Every live or missed message can be configured to be sent to your email, so you can check them in batch after a while. Also messaging history are preserved even if the visitor left and come back later, so you get the context of what they were saying. It's also important to to set expectations for your visitor, to let them know you are working alone and can't reply super fast. That brings us to the next point: customizable welcome messages and prompts. 

### Customizable and programmable
Almost everything in Chatra is customizable. From the welcome message, chat button text, to the automatic reply content. So instead of saying "We are a big team and we'll reply in 10 mins, guaranteed!", you can instead say something along the line of "Hi, I'm running this site alone and I'd love to hear from you.  I'll get back to you within days". Besides customizing the look and feel and tone of speech, you can also setup triggers that automatically initiate a chat when criteria meet. For example we can send a automated message when a visitor reads the article for more then 1 minute. Of course you can further customize the experience using the [developer API][api].

![trigger setup page][trigger]

### Out-of-the-box Google Analytics integration
One thing I really care about is understanding how my visitors interact with the site, and how I can optimize the content and UX to further engage them. I did that through Google Analytic. Much to my amazement, Chatra detected my Google analytics configuration and automatically send relevant events to my [Google Analytic tracking][google_analytics], without me even setting up anything. I can directly create [goals][goal] based on the events and track the conversion funnel leading to a chat. 

# Pricing and features
Chatra has a [free][plan] and a [paid plan][plan], and also a 2-week trial period that allows you to test everything before paying. The number of registered agents, connected websites and concurrent chats is unlimited in all plans. 
The free plan has basic features, including mobile apps, Google Analytics integration, some API options, etc., and allows 1 agent to be online at a time, which is sufficient enough for a one-person website like mine. But you can have several agents taking turns chatting: when one goes offline, another connects. And even if the online spot is already taken, other agents can still access the dashboard and read chats. 

The paid plan starts at $15 per month and gives you access to all features, including automatic triggers and visitors online list, saved replies, typing insights, visitor information, integration with services like Zapier, Slack, Help Scout and more, and allows as many agents online as paid for. Agents on the paid plan can also take turns chatting, so there’s no need to pay for all of them.

# Conclusion

All in all, Chatra is a nice tool to further engage your visitors. The free plan is generous enough for most small scale websites. In case you scales up in the future, their paid plan is affordable and pays for itself after a few successful sales. So if you want an easy and convenient way to chat with your visitors, gain feedback and have more insights into your users, you should give Chatra a try with this [link][signup] now.

[api]: https://chatra.io/help/api/?partnerId=3Leg7HgLErPj4Fy6v
[broken_window]: https://en.wikipedia.org/wiki/Broken_windows_theory
[chatra]: https://chatra.io/?partnerId=3Leg7HgLErPj4Fy6v
[cms]: https://chatra.io/help/cms/?partnerId=3Leg7HgLErPj4Fy6v
[goal]: https://support.google.com/analytics/answer/1012040 
[messenger]: https://chatra.io/messenger/?partnerId=3Leg7HgLErPj4Fy6v
[signup]: https://app.chatra.io/?enroll=&partnerId=3Leg7HgLErPj4Fy6v
[app]: https://chatra.io/apps/?partnerId=3Leg7HgLErPj4Fy6v 
[plan]: https://chatra.io/plans/?partnerId=3Leg7HgLErPj4Fy6v
[web]: https://app.chatra.io/?partnerId=3Leg7HgLErPj4Fy6v
[google_analytics]: https://chatra.io/help/analytics/?partnerId=3Leg7HgLErPj4Fy6v

[chat_page]: {{site_url}}/blog_assets/chatra/chat_page.png
[chat_box]: {{site_url}}/blog_assets/chatra/chat_box.png
[trigger]: {{site_url}}/blog_assets/chatra/trigger.png
