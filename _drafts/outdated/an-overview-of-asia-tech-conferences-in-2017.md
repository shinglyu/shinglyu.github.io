---
layout: post
title: An Overview of Asia Tech Conferences in 2017
categories: Web
date: 2017-01-21 15:38:50 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

I've been attending and even talking at tech conferences for some time. One of the challenge is to keep track of when those conference will take place. Also there is no single list of all conferences I’m interested. There are [some website][conf_dir] that collects them, but they often missed some community-organized events in Asia. Or there are some community-maintained [list of open source conferences][os_list] (Thanks Barney!), but they don’t include for-profit conferences.

Therefore I build a simple website that collects all conferences I know in Asia, focusing on open source software, web, and startup:

[https://asia-confs.github.io/asia-tech-confs/](https://asia-confs.github.io/asia-tech-confs/en/)
<!--more-->

#The Technology Stack
Since I don’t really need dynamic-generated content, I use the [Jekyll][jekyll] static site generator. For the look and feel, I use the [Material Design Lite][mdl] (MDL) CSS framework. (I did try other material design frameworks like [Materialize][materialize] or [MUI][mui], but MDL is the most mature and clean one I can find.)

One of the challenge is to provide the list in different languages. I found a [plugin-free way][i18n] to make Jekyll support I18N (Internationalization). The essence is to create language specific sub-directories like `en/index.md` and `zh_tw/index.md`. Then put all language specific string in the `index.md` files. One pitfall is that by adding another level of directory, the relative paths (e.g. path to CSS and JS files) might not work, so you might need to use absolute path instead. For Traditional and Simplified Chinese translation, I’m too lazy to maintain two copy of the data. So I use a [JavaScript snippet][cn_tw] to do the translation on-the-fly.  

# How to Contribute

If you know any conference, meetup or event that should be on the list, please feel free to drop and email to [asia.confs@gmail.com](mailto:asia.confs@gamil.com). Or you can create a pull request or file and issue to our [GitHub repo][gh]. 

Enjoy the conferences and Happy Chinese New Year!

[conf_dir]: http://lanyrd.com/
[os_list]: https://wordpress.lokidea.com/blog/1531/
[jekyll]: https://jekyllrb.com/
[mdl]: https://getmdl.io/
[i18n]: https://github.com/mrzool/polyglot-jekyll
[cn_tw]: http://blog.markplace.net/trackback.php?id=150
[gh]: https://github.com/asia-confs/asia-tech-confs
[materialize]: http://materializecss.com/
[mui]: https://www.muicss.com/

