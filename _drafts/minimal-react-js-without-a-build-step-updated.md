---
layout: post
title: Minimal React.js Without A Build Step (Updated)
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

# Using 3rd-party NPM components

## Modules with browser support
You can find tons of ready-made React components on NPM, but the quality varies. Some of them are released with browser support, for example [Reactstrap][reactstrap], which contains Bootstrap 4 components wrapped in React. In its documentation you can see a "CDN" section with a CDN link, which should just work by adding it to a script tag:

```html
<!-- react-transition-group is required by reactstrap -->
<script src="https://unpkg.com/react-transition-group@2.2.1/dist/react-transition-group.min.js" charset="utf-8"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/reactstrap/4.8.0/reactstrap.min.js" charset="utf-8"></script>
```

then you can find the components in a gloabl variable `Reactstrap`:

```html
<script type="text/babel" charset="utf-8">
  // "Import" the components from Reactstrap
  const {Button} = Reactstrap;

  // Render a Reactstrap Button element onto root
  ReactDOM.render(
    <Button color="danger">Hello, world!</Button>,
    document.getElementById('root')
  );
</script>
```

(In case you are curious, the first line is the [destructing assignment of objects][desctruct] in JavaScript).

Of course it also works without JSX:

```html
<script type="text/javascript" charset="utf-8">
  // "Import" the components from Reactstrap
  const {Button} = Reactstrap;

  // Render a Reactstrap Button element onto root
  ReactDOM.render(
    React.createElement(Button, {'color': 'danger'}, "Hello world!"),
    document.getElementById('root'),
  );
</script>
```

## Modules without browser support
For modules without explicit browser support, you can still try to expose it to the browser with [Browserify][browserify], as described in [this post][browserify-post]. Browserify is a tool that converts a Node.js module into something a browser can take. There are two tricks here:

1. Use the `--standalone` option so Browserify will expose the component under the `window` namespace, so you don't need a module system to use it.
2. Use the `browserify-global-shim` plugin to strip all the usage of `React` and `ReactDOM` in the NPM module code, so it will use the `React` and `ReactDOM` we included using the `<script>` tags.

I'll use a very simple React component on NPM, [simple-react-modal][simplemodal], to illustrate this. First, we download this module to see what it looks like:

```bash
npm install simple-react-modal
```

If we go to `node_modules/simple-react-modal`, we can see a pre-built JavaScript package in the `dist` folder. Now we can install Browserify by `npm install -g browserify`. But we can't just run it yet, because the code uses `require('react')` but we want to use our version loaded in the browser. So we need to install `npm install browserify-global-shim` and add the configuration to `package.json`: 

```javascript
// package.json
"browserify-global-shim": {
  "react": "React",
  "react-dom": "ReactDOM"
}
```

Now we can run 
```bash
browserify node_modules/simple-react-modal \
  -o simple-react-modal-browser.js \
  --transform browserify-global-shim \
  --standalone Modal
```

We'll get a `simple-react-modal-browser.js` file, which we can just load in the browser using the `<script>` tag. Then you can use the Modal like so: 

```html
<script type="text/javascript" charset="utf-8">
  // "Import" the components from Reactstrap
  const Modal = window.Modal.default;

  // Render a Reactstrap Button element onto root
  ReactDOM.render(
    React.createElement(Modal, 
      { 
        'show': true,
        'closeOnOuterClick': true 
      }, 
      React.createElement("h1", null, "Hello")
    ),
    document.getElementById('root')
  );
</script>
```
(There are some implementation detail about the `simple-react-modal` module in the above code, so don't be worried if you don't get everything.)


# The benefits

Using this method, you can start prototyping by simply copying a HTML file. You don't need to install Node.js, NPM and all the NPM modules that quickly make your small proof-of-concept page bloat.

Secondly, this method is compatible with the [React-DevTools][devtool]. Which is available in both Firefox and Chrome. So debugging is much easier.

Finally, It’s super easy to deploy the program. Simply drop the files into any web server (or use GitHub pages). The server doesn’t even need to run Node and NPM, any pure HTTP server will be sufficient. Other people can also easily download the HTML file and start hacking. This is a very nice way to rapidly prototype complex UIs without spending an extra hour setting up all the build steps (and maybe waste another 2 hour helping the team setting their environment).


[html_template]: https://reactjs.org/docs/try-react.html#minimal-html-template
[cdn_links]: https://reactjs.org/docs/cdn-links.html
[crossorigin]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-crossorigin
[without-jsx]:https://reactjs.org/docs/react-without-jsx.html
[devtool]: https://github.com/facebook/react-devtools
[reactstrap]: https://reactstrap.github.io/
[desctruct]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment#Object_destructurig.
[browserify]: http://browserify.org/
[browserify-post]: http://krasimirtsonev.com/blog/article/distributing-react-components-babel-browserify-webpack-uglifyjs
[simplemodal]: https://www.npmjs.com/package/simple-react-modal
