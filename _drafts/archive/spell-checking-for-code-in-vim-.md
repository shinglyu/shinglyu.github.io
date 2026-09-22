---
layout: post
title: Spell Checking for Code (in Vim)
categories: Web
date: 2017-08-19 20:09:08 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---
* Introduce the problem
  * Camel Case
  * snake case => vim ok
  * brackets, symbols
  * variable name abbrs
* Architecture
  * tokenizer => handle case and symbols
  * Checking => aspell
  * Highlighting
  * Dictionary building
* Insights
  * Skip frequent words
  * Benchmarking
  * Dictionary building
    * Language keywords
  * Highlighting partial

<!--more-->
