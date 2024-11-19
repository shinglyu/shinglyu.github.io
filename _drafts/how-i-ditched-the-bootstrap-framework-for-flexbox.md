---
layout: post
title: How I Ditched CSS Framework for Flexbox
categories: Web
date: 2017-01-27 21:18:53 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

# Background
If you have visited this blog before September 2016, you should saw a standard website decorated with a CSS framework (I used [Foundation][]). But now if you open the developer tool in your browser, you won't see any CSS framework anymore. Back in September 2016 I migrated the whole site to [CSS Flexbox][], the not-so-new new standard of modern web layout. My site loads faster, is easier to maintain and didn't lose any compatibility. In this post I'll tell you why and how I migrated from a CSS framework to Flexbox.
<!--more-->

Just to clarify, I'm not against CSS frameworks. I use CSS frameworks a lot for fast prototyping (mostly [Bootstrap][] and [MDL][]). They enable you to create a professional-looking (or geek-looking?) website in just minutes. But they have downsides too. First, you end up including a lot of stuff you don't really need (given that you don't bother to create a custom build and just grap the standard edition from a CDN). This makes your page loads slowly and make the code hard to understand. Second, you usually use a lot of `<div>`s with crazy `class`es like "`col-sm-5 col-sm-offset-2 col-md-6 col-md-offset-0`" to layout the page. This makes your HTML unsemantic and bloats the code size. Finally, CSS frameworks usually uses a lot of JavaScript or CSS magic to ease out the difference in browsers, this is important for websites that needs to reach a wide range of audiences. But for a developer-facing blog like this one, I would prefer to promote modern web standards like [flexbox][] and [grid][] to accelerate their spread.

I have known flexbox for quite a while, but couldn't make up my mind to rewrite this blog with it. Early last September (2016), I attended the [View Source conference][] in Berlin. During that conference I heard some very inspiring talks by [Jen Simmons][], [Belen ???][] and [???][], one of the recurring topic is that they urge people to use flexbox and grid instead of using CSS frameworks blindly. They have analyzed why CSS frameworks will be a burden if you use it without thinking (you can click on their name to watch the recording, definitely worth the time!). Also, I took the responsibility to implement [flexbox][] in the [Servo][] browser engine. So I decided to take the rewrite as a exercise to understand [flexbox][] better.

As an aside: If you are interested in tracking or helping with the flexbox implementation in Servo, please check out this [tracking bug][]. It's really fun! I also found some help clarify the W3C specification by submitting a [pull request][] to the specification itself.

# Simplify the page first

First of all, flexbox won't fix all your layout problems. So the best strategy is to simplify the layout as much as possible, before we even turn to flexbox. A typical CSS framework will force you to start with a complex responsive grid. But what I need for my website is just a vertical, linear content flow: title (my name), navigation, content, then footer. Plain old CSS block layout is designed for that. So I removed all the grid and container `<div>`s and use more semantic HTML tags. Take a look at the list of HTML elements [here][], and you'll find a lot of useful tags other then layers of `<div>`s. I use `<header>`, `<nav>`, `<footer>` as their name suggest, and I use `<main>` for the main content section. For the [blog post list][], I put each article in a `<article>` (obviously!), and I use `<p>` and `<section>` for paragraphs in other places. For my [project list][] and [talks list][], the common structure is the title followed by a description, so I choose to use the `<dl>` (description list) element. A `<dl>` consists of multiple `<dt>` and `<dd>` which represent "term" and "description". By doing so I reduced the number of DOM elements from 76 to 44 on my homepage, which is ~42% reduction!. None of the information is missing after the cleanup, so we had 76 - 44 = 32 unnecessary elements on the page.


TODO: link to html tags

# Responsive design with flexbox

"But grids are for responsive design, right? How about mobile first?", you may argue. But a page that simple doesn't need grid to be responsive. ([KISS][] principle is your savior!) A grid can do two things for you: first, it fits the content's width to the device's screen width. Second, for small screens, it can rearrange a horizontal row into a vertical stack. We can easily achieve these, here is how:

First, for the width adjustment, we only need to set the maximum allowed with of our content with `max-width`. When the pages are viewed on a desktop browser, the window width is usually too wide, hence the line will be too long to be readable. So we set the `max-width` to be `600px`. Since we don't limit the minimum width, the content will shrink with the screen on phones. Neat!

Second, we want to dynamically switch between horizontal layout and vertical layout like so:

#(TODO: pic)


My navigation bar and footer are simply `<ul>` lists, who's bullet points are hidden using `list-style-type: none`. 

# (TODO: html for header)
# (TODO: css for header)

We want the list to be stacked vertically on a small screen, but lay out in a horizontal line on big screens.

# (TODO: pic)

We can make the `<ul>` a flex container, and use the `flex-direction: column` to make it stack vertically on small screens.

Next, to dynamically change layout on a big screen (we consider a width > 768px as "big"), we can use [media query]. 

#(TODO: media query code)

For the big screen case, we change the `flex-direction` to `column`, and we set `justify-content: space-between` so the items are spread out evenly.

#(TODO; CSS)

These simple CSS can make our page looks great on both desktop and mobile.

These simple technique can help you build a responsive block layout. But if you are looking for the more complicated [holy grail layout], you can reference this [guide][].


# The result: faster, lighter and easier to maintain

So did these modifications actually work? I load the page before and after the modification with the [WebPagetest.org][webpagetest] tool. We can see that the document complete load time reduced from 1.082s to 0.825s, roughly 24% improvement. Because we don't need the JavaScript libraries and CSSes from the frameworks, the request count reduced from 15 to 10, saving about 237 - 155 = 82 KB of data transfer.

# TODO: time line

Looking at the content breakdown graph, the JavaScript files are mostly eliminated, and the css files are reduced to a minimum. The HTML file size are also reduced because we get rid of a lot of unsemantic container `<div>`s.

# TODO: content breakdown

All in all, getting rid of a CSS framework is a big boost in performance and maintainability. Although we might loose some support on [old browsers][] (mostly IE and browsers before 2014), but the maintainability improvement will offset the loss. So why not take the chance to upgrade your website to the new modern standard, you may find out that you don't actually need a framework!




flexbox game
Flexbox holygrial example
https://philipwalton.github.io/solved-by-flexbox/demos/holy-grail/
How to do flexbox RWD
  flex-direction with media query
  fix the width for readibility
Semantic tags
  - nav
  - dl
  - main
  - article
    - p
    - section
  - address

The result
  - More semantic code
  https://github.com/shinglyu/shinglyu.github.io/commit/c6e406559e2559860e14d96e200d3d420887ecea?diff=split
  - Easier to understand CSS
  - Reduced code size
  - Improved Performance

Resources
  - flexbox guid in css trics
  - flex game
  - solved by flexbox
  - jen simmons
  - Spec


https://developer.mozilla.org/en-US/docs/Web/HTML/Element
https://www.webpagetest.org/
