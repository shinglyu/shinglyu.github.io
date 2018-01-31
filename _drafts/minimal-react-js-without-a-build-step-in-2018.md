---
layout: post
title: Minimal React.js Without A Build Step in 2018
categories: Web
date: 2018-01-31 21:39:50 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

Back in 2016, I wrote a post about how to write a React.js page without a build step. If I remember correctly, at that time the official React.js site have very little information about running React.js without [Webpack][webpack], [in-browser Babel transpiler][babel] is not very stable and they are deprecating `JSXTransformer.js`. After the post my focus turned to browser backend projects and I haven't touch React.js for a while. Now after 1.5 years, when I try to update one of [my React.js project][itinerary-viewer], I notice that the official site now has a clearer instruction on how to use React.js without a build step. So I'm going to write an update the post here.
<!--more-->

## 1. Load React.js from CDN instead of npm
You can use the official minimal HTML template [here][html_template]. The most crucial bit is the importing of scripts:

```html
<script src="https://unpkg.com/react@16/umd/react.development.js"></script>
<script src="https://unpkg.com/react-dom@16/umd/react-dom.development.js"></script>
<script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
```

If you want better error message, you might want to add the [`crossorigin`][crossorigin] attribute to the `<script>` tags, as suggested in the [official document][cdn_links]. Why the attribute you ask? As describe in [MDN][crossorigin], this attribute will allow your page to log errors on CORS scripts loaded from the CDN.

If you are looking for better performance, load the `*.production.min.js` instead of `*.development.js`.

## 2. Get rid of JSX
I'm actually not that against JSX now, but If you don't want to include the `babel.min.js` script, you can consider using the `React.createElement` function. Actually all JSX elements are syntatic sugar for calling `React.createElement()`.  Here are some examples:


```html
<h1>Hello Word</h1>
```



can be written as

```js
React.createElement('h1', null, 'Hello World')
```

And if you want to pass attributes around,  you can do

```html
<div onClick={this.props.clickHandler} data={this.state.data}>
  Click Me!
</div>
```

```js
React.createElement('div', {
                      'onClick': this.props.clickHandler, 
                      'data': this.state.data
                    }, 
                    'Click Me!')
```

Of course you can have nested elements:

```html
<div>
  <h1>Hello World</h1>
  <a>Click Me!</a>
</div>
```

```js
React.createElement('div', null, 
  React.createElement('h1', null, 'Hello World')
  React.createElement('a', null, 'Click Me!')
)
```

You can read how this works in the [official documentation][without-jsx].

3. Split the React.js code into separate files

In the official [HTML template][html_template], they show how to write script directly in HTML like:

```html
<html>
  <body>
    <div id="root"></div>
    <script type="text/babel">

      ReactDOM.render(
        <h1>Hello, world!</h1>,
        document.getElementById('root')
      );

    </script>
  </body>
</html>
```

But for real-word projects we usually don't want to throw everything into one big HTML file. So you can put everything between `<script>` and `</script>` in to a separate JavaScript file, let's name it `app.js` and load it in the original HTML like so:

```html
<html>
  <body>
    <div id="root"></div>
    <script src="app.js" type="text/babel"></script>
  </body>
</html>
```

The pitfall here is that you must keep the `type="text/babel"` attribute if you wants to use JSX. Otherwise the js script will fail when it first reaches a JSX tag, resulting an error like this:

```
SyntaxError: expected expression, got '<'[Learn More]        app.js:2:2
```

# The Benefits

Using this method, you can start prototyping by simply copying a HTML file. You don't need to install Node.js, NPM and all the NPM modules that quickly make your small proof-of-concept page bloat.

Secondly, this method is compatible with the [React-DevTools][devtool]. Which is available in both Firefox and Chrome. So debugging is much easier.

Finally, It’s super easy to deploy the program. Simply drop the files into any web server (or use GitHub pages). The server doesn’t even need to run Node and NPM, any pure HTTP server will be sufficient. Other people can also easily download the HTML file and start hacking. This is a very nice way to rapidly prototype complex UIs without spending an extra hour setting up all the build steps (and maybe waste another 2 hour helping the team setting their environment).


[html_template]: https://reactjs.org/docs/try-react.html#minimal-html-template
[cdn_links]: https://reactjs.org/docs/cdn-links.html
[crossorigin]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-crossorigin
[without-jsx]:https://reactjs.org/docs/react-without-jsx.html
[devtool]: https://github.com/facebook/react-devtools


