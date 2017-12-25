---
layout: post
title: Taking notes with MkDocs
categories: Web
date: 2017-12-22 10:44:38 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---


I've been using [TiddlyWiki][tiddly] for note-taking for a few years. I use them to keep track of my technical notes and checklists. [TiddlyWiki][tiddly] is a brilliant piece of software. It is a single HTML file with a note-taking interface, where the notes you take are stored directly in the HTML file itself, so you can easily carry (copy) the file around and easily deploy it online for sharing. However, most modern browsers don't allow web pages to access the filesystem, so in order to let [TiddlyWiki][tiddly] save the notes, you need to rely on [browser extensions][tiddly-extension] or Dropbox integration service like [TiddlyWiki in the Sky][in-the-sky]. But they still have some frictions.

So recently I started to look for other alternatives for note-taking. 
<!--more-->
Here are some of the requirements I desire:

1. Notes are stored in non-proprietary format. In case the service/software is discontinued, I can easily migrate them to other tool.
2. Has some form of formatting, e.g. write in Markdown and render to HTML.
3. Auto-generated table of contents and search functionality.
4. Can be used offline and data is stored locally.
5. Can be easily shared with other people.
6. Can be version-controlled, and you won't lose data if there is a conflict.

[TiddlyWiki][tiddly] excels at 1 to 5, and I can easily sync it with Dropbox. However, I often forgot to click "save" in TiddlyWiki, and in some case when I accidentally create some conflict while syncing, Dropbox simply creates two copies and I have to manually merge them. There is also no version history so it's hard to merge and look into the history.

Then I suddenly had an epiphany during shower: all I need is a bunch of Markdown files, version controlled by git, then I can use a static site generator to render them as HTML, with table of contents and client-side search. After some quick search I found [MkDocs][mkdocs], which is a Python-based static-site generator for project documentations. It also have a live-reloading development server, which I really love.

# Using MkDocs

MkDocs is really straight-forward to setup and use (under Linux). To install, simply use `pip` (assuming you have Python and pip installed): 

```
sudo pip install mkdocs
```

Then you can create your document folder using 

```
mkdocs new <project name>
```

The generated folder will have the following structure:

```
<project name>
├── docs
│   └── index.md
└── mkdocs.yml
```

You can then start to write documents in the `docs` folder. You can create subfolders to organize the Markdown files. To view the generated HTML, `cd` into the project folder, then run `mkdocs serve`, the development server will start to serve on port 8000. Opening `127.0.0.1:8000` in your browser then you can see the document. You can also run `mkdocs build` to generate the static HTML into the `sites` folder. The folder can then be hosted using any server.

![MkDocs]({{site_url}}/blog_assets/mkdocs/mkdocs.png)

The `mkdocs.yml` file contains some configuration. For example, you can use the ReadTheDocs theme by adding the line: 

```
theme: readthedocs
```
![readthedocs]({{site_url}}/blog_assets/mkdocs/readthedocs.png)

If you wish to open the generated site locally using the `file://` protocol, you can add this line:

```
use_directory_urls: false
```

When you have a note named `foo.md`, the generated file will be `/foo/index.html`.  If `use_directory_urls` is set to `true`, the URL for linking to the `foo.md` page will be `/foo/`, which is a more modern URL naming convention. But for this routing to work, you must host the files in a web server. If you want to open it locally, you need to set the config to `false` and all the link will be `/foo/index.html` instead.


# Migrating from TiddlyWiki

Moving all the notes from TiddlyWiki to MkDocs is very easy. If you are using TiddlyWiki 5.x+, you can go to "Tools" right under the search box, there is a "export all" button. Export the tiddlers (notes) to CSV. Then you can use the [`tiddly2md`][tiddly2md] script to convert the CSV to individual `.md` files. If your tiddler has UTF-8 titles, you need to add a parameter `encoding='utf-8'` to the `pd.read_csv()` call in the script for it to work.

![export_all]({{site_url}}/blog_assets/mkdocs/tiddly.png)

The exported Markdown files will lose the tag information, so if you are using tag as folder structure like me, you'll have to manually create folders to arrange them. Some tiddlers using the old WikiText format will also be empty (I use Markdown in my TiddlyWiki, but there are some old ones from the old versions). You can use `ls -lS` to see which file has no content and manually fix them. After the `.md` files are in place, run `mkdocs` as usual.

# Conclusion

MkDocs is a pretty simple but powerful tool for note-taking. You get all the benefit of editing the notes using plain text editor, and have them version controlled by git. But you also get a nicely rendered HTML version with search functionality. One thing I miss from TiddlyWiki is the ability to generate a single HTML file containing all the notes. (MkDocs generates a folder of separate HTML, CSS and JS files.) There are some scripts like [mkdocs-combine][mkdocs-combine] that claims to do this using [Pandoc][pandoc], but I haven't tested them. 


[in-the-sky]: https://github.com/Jermolene/TiddlyWiki-in-the-Sky
[mkdocs]: http://www.mkdocs.org/ 
[pandoc]: https://pandoc.org/
[tiddly]:https://tiddlywiki.com/ 
[tiddly2md]: https://github.com/achabotl/tiddly2md
[tiddly-extension]: https://tiddlywiki.com/#%22savetiddlers%22%20Extension%20for%20Chrome%20and%20Firefox%20by%20buggyj
[mkdocs-combine]: https://github.com/twardoch/mkdocs-combine
