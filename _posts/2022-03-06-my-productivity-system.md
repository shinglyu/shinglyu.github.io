---
layout: post
title: My Productivity System
categories: Productivity
date: 2022-03-06 12:10:03 +01:00
excerpt_separator: <!--more-->
---

![my productivity system diagram]({{site_url}}/blog_assets/productivity/productivity_method.svg)
(Right-click on the picture and select *Open image in new tab* to see the diagram in full size.)

After some recent discussion with a friend on note-taking methods, I decided to document my current productivity system for future reference. It is a combination of note-taking, time management, TODO list, project management, and writing combined. It has evolved over the years so I find it interesting to take a snapshot and look back a few years later.

<!--more-->

The system is shown in the diagram above. Let me explain it in detail.

## Getting input
I get news mostly from a few sources: social media, podcast, and RSS (using [Feedly][feedly]). I try to mitigate the information bubble (or *THE ALGORITHM*, whatever you call it) by subscribing to a collection of balanced RSS feeds from multiple news sources, they include news sites from different countries and different political views. For tech it's a combination of news sites, [InfoQ][infoq], [DZone][dzone] and individual thinkers' blog. 

If the article is too long to be read immediately, I'll save them to [Pocket][pocket] to read later. If it's even bigger than that, for example, a long research paper, book, or video course, I'd also save the link to a Kanban board in [Joplin][joplin]. I used to use Trello but it has deteriorated a lot since it was acquired by Atlassian. Therefore I migrated the kanban to Joplin and use a plugin called [Kanban][kanban]. The kanban board collects everything I want to learn in the long term, e.g. books, articles, courses, topics, etc. Sometimes when I read the article stored in Pocket, I get new ideas or references I want to follow up. In that case, I add them to the kanban board as well. 

One small technical detail is that I link Feedly with Pocket using [IFTTT][ifttt]. When I save an article in Feedly using its *Read Later* feature, IFTTT will get triggered and save it to Pocket. Therefore I don't need to break my reading flow. I can just swipe an article to the right in the Feedly app and send it to Pocket directly.

## Digest the information and take notes
Once I have the reading materials ready, I'd spend time reading them. This is denoted by the *Research* box to the left of the diagram. This could include reading, watching videos, doing research on Google, or building proofs-of-concept. I'd document my learnings into a note in a [zettelkasten][zettelkasten] in Joplin. It's basically a folder (or *notebook* in Joplin terminology) that contains all the notes. I also create links between the notes so I can see the connections. I don't strictly follow the [zettelkasten][zettelkasten] method in creating atomic notes for every single idea. I still write some very long notes for topics that have a clear structure. For example, if I'm learning a programming language or framework I'd write a long note that resembles a tutorial or documentation. But for ideas and comments, I try to create small, atomic notes that link to existing ones. 

I keep a separate zettelkasten for my work-related notes because they may contain confidential data. I use the highest security standard for them: client-side encryption, TLS for all communications, server-side encryption. The idea is that when I quit my current job I will just destroy this work zettelkasten to comply with my employer's policy, also to avoid any potential allegation that I leaked trade secrets. 

## Organizing my day job
I currently work as a solutions architect, so my day job is mostly around meeting customers, researching and designing software architecture for them, delivering workshops, and public speaking. To joggle with so many TODO items, I keep them in a physical bullet journal. I prefer pen and paper because they are the fastest and most reliable way of jotting down fleeting thoughts. I use bullet journal mostly as a TODO list and a way to see what I've done. I don't use it as a calendar and I keep everything in either Google calendar (for my personal things) or Outlook calendar (for work-related things). 

I used to love paper calendars, but since I have so many meetings nowadays, it becomes impractical to sync between my paper and digital calendars. A lot of times customers or colleagues will change the meetings last minute so I need the digital calendar to keep the most up-to-date information. I also rely heavily on digital notification so I won't miss any meetings. I also deviate from the "purist" zettelkasten method when I take meeting notes. I keep all my meetings notes with a particular customer in one long note so I can see all my interactions with them in one view.

For small tasks, like replying to an email or looking up the documentation of a particular piece of software, I'll pick them up from my bullet journal when I'm free. But for big topics, like learning machine learning, or keeping myself up-to-date on software architecture trends, I'll block out some time in my calendar so I can do time-boxed research. Of course, if a topic is big enough, I'll add them to my learning kanban.


## Output: writing and speaking
Finally, all the knowledge I collected into the zettelkasten is useless until I generate insights from them. For that, I keep a kanban for any writing ideas that are derived from the zettelkasten. From there I'd write blog posts, social media posts, books, or public speaking content. I'd create an outline note to draft a new piece of content and link to all the other notes that support this idea. The same applies to my work-related output like architectural diagrams or documents. Of course, more ideas and topics of interest would come up during the writing process, and they'll be added to the learning kanban and zettelkasten notes, thus forming a positive cycle.

I have to admit that I didn't use the power of zettelkasten when I wrote my previous two books. I worked in a waterfall manner and it created a lot of pain and friction. After reading the book [How to Take Smart Notes by Sönke Ahrens][notebook] I realized how wrong I was. Now I'm using the zettelkasten method described in the book to prepare for my next book. Hopefully, by the time I propose a new book to a publisher, I'd have all the materials ready.

This is just a high-level overview of how I work. There are many details on how I apply these methodologies and how I set up the software. If you are interested in any of the steps or the software I'm using, please leave a message using the chat or send me a message via any social media channel. I'd love to write more articles on the details.


[dzone]: https://dzone.com/
[feedly]: https://feedly.com/
[ifttt]: https://ifttt.com/
[infoq]: https://www.infoq.com/
[joplin]: https://joplinapp.org/
[kanban]: https://github.com/joplin/plugin-kanban
[notebook]: https://takesmartnotes.com/
[pocket]: https://getpocket.com/
[zettelkasten]: https://en.wikipedia.org/wiki/Zettelkasten
