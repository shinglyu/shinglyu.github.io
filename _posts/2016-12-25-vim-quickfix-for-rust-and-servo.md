---
layout: post
title: Vim QuickFix for Rust and Servo
categories: Web
date: 2016-12-25 21:00:00 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---
While working on a compiled language like Rust, a typical workflow is compile -> find the errors in the compiler message -> find the file containing the error -> edit -> re-compile. But usually there are lots of errors scattered around the compiler log, and to identify the filename and line number, and manually open the file to the correct line in an editor is a tedious job. Vim's [quickfix][quickfix] streamline the process by collecting the errors into the split panel in vim, and allow you to navigate through the errors using the `:cnext` (next error) and `:cprev` (previous command). While you navigate to an error, the corresponding source file will be opened in the main vim window and jump directly to the line where the error is.

![quickfix-1.png]({{site_url}}/blog_assets/quickfix-rust/quickfix-1.png)


<!--more-->
When you run `:make` inside vim, vim will execute the external compile tool (default: `Makefile`'s `make`'), then the compiler output will be parsed to extract the file name, line number, etc. By default, vim understands `Makefile`-based projects with C/C++ compiler output. But you can change the behavior by setting the `makeprg` (defines what `:make` does) and the `errorformat` (error message parsing pattern). (You can run `:help options` and read "22 running make and jumping to errors" for detail.)

# rust.vim
The good news is: you don't need to write the `makeprg` and `errorformat` yourself. The [rust.vim][rustvim] vim plugin will do that for you. Installation is pretty simple, based on which vim plugin manager you use, you'll find the instruction on the project's [GitHub README][readme]. I use [Vundle][vundle], so I add the following line to my `~/.vimrc`:

{% highlight bash %}
Plugin 'rust-lang/rust.vim'
{% endhighlight %}

Then run `:PluginInstall` in vim.

Now for ordinary Rust project which uses `cargo`, you can set the compiler as `cargo` by `:compiler cargo`. Then if you run `:make build`, vim will execute `cargo build` for you.

![cargo-build.png]({{site_url}}/blog_assets/quickfix-rust/cargo-build.png)
![cargo-error.png]({{site_url}}/blog_assets/quickfix-rust/cargo-error.png)
 
You can also pass other parameters like you'd to `cargo`, e.g. `:make test` will run `cargo test`.

After the compilation finished, you will see the source code being loaded, but you don't see the error message. That's because we haven't open the quickfix panel yet. Now type `:copen` then you'll see a list of errors like this:

![quickfix-1.png]({{site_url}}/blog_assets/quickfix-rust/quickfix-1.png)
![quickfix-2.png]({{site_url}}/blog_assets/quickfix-rust/quickfix-2.png)

The vim main window will load the source file where the first error is pointing to. After you finish fixing it, you can use `:cnext` command to jump to the next one.

# Servo
This all works very well for `cargo`-based Rust projects, but what if you are working on Servo, which uses `mach` as the build tool? The solution is simple, you still run `:compiler cargo` to get the `errorformat` setup. But then you run `:set makeprg=./mach` to make `:make` run `./mach` instead of `cargo`.

If you want to avoid typing the commands every time you restart vim, you can set them in your `~/.vimrc`, but if you work on Servo and other `cargo`-based Rust projects at the same time, you can actually set a per-directory based configuration. For example, you can put a `.vimrc` (`.nvimrc` if you use [NeoVim][neovim]) in your Servo directory like so:

{%highlight bash%}
compiler cargo
set makeprg=./mach

autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
{%endhighlight%}

The last two lines makes quickfix window show up automatically right after the compilation. You can omit them if you want.

Vim will not load the local `.vimrc` file by default to avoid running malicious `.vimrc`s. You need to enable them in your global `~/.vimrc` file by adding these lines:

{%highlight bash%}
set exrc 
set secure
{%endhighlight%}

That's it! Now you can have different compiler setup in different projects.

[quickfix]: http://vimdoc.sourceforge.net/htmldoc/quickfix.html
[rustvim]: https://github.com/rust-lang/rust.vim
[readme]: https://github.com/rust-lang/rust.vim#installation
[vundle]: https://github.com/VundleVim/Vundle.vim
[neovim]: https://neovim.io/

