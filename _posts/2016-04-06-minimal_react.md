---
layout: post
title:  "Minimal React.js Without A Build Step"
categories: web
date:   2016-04-06 21:55:00 +08:00
excerpt_separator: <!--more-->
---

__Update: There is an updated post [here]({{site_url}}/web/2018/02/08/minimal-react-js-without-a-build-step-updated.html). Check it out! It has more up-to-date data and more information about how to use 3rd-party libraries.__

Nowadays, starting a frontend project means setting up a complex build system with preprocessors, transpliers, compressors, packagers, and many more. Don't you missed the day when you can just write `<script src=”./jquery.js”/>` and start coding? I love to build prototype or small tools using HTML and React.js, but the build system thing is killing me (the [official documentation](https://facebook.github.io/react/docs/getting-started.html) suggest you use browserify and babel). So I'm going to show you how to build a minimal react page without any of those distractions.
<!--more-->

I'm not oppose to build systems. The frontend community is reinventing (or re-discovering?) the software engineering best practices, this is a good thing. But for most small prototypes, a full build system is usually a overkill. It raise the architectural complexity unnessarily. And JavaScript was desinged for the browser, now you have to compile it before you can run it in the browser? It just feels wrong!

Now I'm going to show you how to bulid a minimal React project without Node, npm, browserify, webpack and babel.


### 1. Load React.js from CDN instead of `npm`

Insteal of running 


<pre>
<code>
npm install --save react react-dom
</code>
</pre>

write these lines to your main html file

<pre>
<code>
&lt;script src="https://fb.me/react-0.14.8.min.js">&lt;/script>
&lt;script src="https://fb.me/react-dom-0.14.8.min.js">&lt;/script>
</code>
</pre>


### 2. Get rid of JSX

Did you notice that we didn't include the babel in-browser transpiler (Previously `JSXTrasnformer.js`)? [JSX](https://facebook.github.io/react/docs/jsx-in-depth.html) is one of the key reason React apps needs a build step. The build/transformation step also makes the code hard to debug. In fact creating the DOM using React's JS API `React.createElement()` is not as hard as you might think. Here are some example:


<pre>
<code>
&lt;h1>Hello Word</h1>
</code>
</pre>



can be written as

<pre>
<code>
React.createElement('h1', null, 'Hello World')
</code>
</pre>

And if you want to pass attributes around,  you can do


<pre>
<code>
&lt;div onClick={this.props.clickHandler} data={this.state.data}>
  Click Me!
&lt;/div>
</code>
</pre>

<pre>
<code>
React.createElement('div', 
                    {
                      'onClick': this.props.clickHandler, 
                      'data': this.state.data
                    }, 
                    'Click Me!')
</code>
</pre>

Of course you can have nested elements:

<pre>
<code>
&lt;div>
  &lt;h1>Hello World&lt;/h1>
  &lt;a>Click Me!&lt;/a>
&lt;/div>
</code>
</pre>

<pre>
<code>
React.createElement('div, null, 
  React.createElement('h1, null, 'Hello World')
  React.createElement('a', null, 'Click Me!')
)
</code>
</pre>

### 3. Importing modules
    
  This is probably the most tricky part.  Most of the React.js modules out there follows [CommonJS](https://webpack.github.io/docs/commonjs.html) syntax. To be honest, I don't have a good solution for this.  For very simple prototypes, I just expose everything in the global scope. I still split the JavaScript into multiple files so I can refactor them into ES6 modules when it's ready.

### 4. CSS Styles

As far as I know, the React community promotes the use of [inline style](https://facebook.github.io/react/tips/inline-styles.html),  but I still prefer separate stylesheets.



## The Benefits

First, we reduce the number of dependencies;  Not just the number of npm packages, but we are also less prone to Node and NPM version incompatibilities. Given the recent [left-pad](http://www.haneycodes.net/npm-left-pad-have-we-forgotten-how-to-program/) incident and my previous experience with Node.js Gaia Integration Tests for B2G, I believe this will save you from a lot of trouble.

Secondly,  since is all pure JavaScript, You can easily debug the program using browser's built-in debuggers. You don't have to install any add-on or use any source mapping tools. 

Finally, It's super easy to deploy the program. Simply drop the files into any web server (or use GitHub pages). The server doesn't even need to run Node and NPM, any pure HTTP server will be sufficient. Your cowokers or contributors can also start hacking by opening the html file. The greatly reduce the learning curve, because everybody prefers different building tools, and you often run into trouble your Node and NPM environments are different. 

## Try it out
You can check out the template [here](https://github.com/shinglyu/minimal-react).

Here are two sites built using this template:

* [shinglyu/github-dashboard](https://shinglyu.github.io/github-dashboard/)
* [yodalee/github-bbs](https://yodalee.github.io/github-bbs.html)
