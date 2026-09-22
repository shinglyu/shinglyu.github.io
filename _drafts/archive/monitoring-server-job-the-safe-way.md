---
layout: post
title: Monitoring server job, the safe way
categories: Web
date: 2018-06-30 10:26:51 +08:00
excerpt_separator: <!--more-->
---
Sometimes I have long-running jobs running on remote servers, e.g. test web server, database maintenance script, automated testing, machine learning jobs. In order to see what's happing, I keep the terminal and ssh connection open to see the live log. But there is a high chance that you'll accidentally hit Ctrl-c, close the terminal emulator, or lose the connection completely. You might lose precious time, or worse, lose your data. How can you safely monitor it without such risk?

<!--more-->

# Tmux
One of the must have tool is [tmux][tmux], which stands for "terminal multiplexer". The main functionality of tmux is to split your terminal window into multiple panels, so you can work on many shell on the same screen. But tmux has a nice feature of keeping your program running even if you log out of the ssh session. So normally when you log out or the ssh connection dies, your program will also be killed. But if you run the program in tmux, it will stay alive and you can re-connect to regain control over it.

When you log into your server with ssh. Run `tmux`, then you'll see a new shell with a tmux status bar, which in tmux terminology is a "session", like so:

![tmux.png]({{site_url}}/blog_assets/tmux/tmux.png)

Now, you can run whatever script you want to run 

![tmux_run.png]({{site_url}}/blog_assets/tmux/tmux_run.png)

Now if you want to leave the script running in the background, you can "detach" the session and go back to the shell you started tmux. To detach, press `Ctrl+b`. (In the tmux [manpage], you'll find it referred to as `C-b`.)

![detach.png]({{site_url}}/blog_assets/tmux/detach.png)

If you want to return to the tmux session, attach it with `tmux attach`. If your ssh connection dropped accidentally, you can ssh back to the machine and run `tmux attach` and see your program still running.

## Attach in read-only mode

Even with tmux, you may still accidentally hit Ctrl+c and kill the running application. The trick here is to attach in read-only mode. You can see the log output but will not send any keystroke to the program. To attach tmux in read-only mode, run 

```
tmux attach -r
```

You can still detach it in the normal way using `Ctrl+b`.

There are many more features in tmux, like splitting the window and named sessions. I'll not go into them here but you can find many tutorials on the internet.


# Alternative: good old `tail -f`

Sometimes you are using a shared server which has no `tmux`. An alternative is the [GNU screen][screen] tool, which has being around since 1987. But if you really want to be minimal, you can pipe the output to a file and use `tail -f` to to monitor that file. This will help prevent accidental `Ctrl+c`, but can't save you from connection lost.

Start you program in the background using 

```
./your-program 2>&1 > your-program.log &
```

If you are not familiar with unix, the `2>&1` pipes the `stderr` to `stdout`; the `> your-program.log` pipes the standard output to the file `your-program.log`; the `&` at the end makes the program run in background.

Then to observe the log without the risk of killing the program, use the [`tail`][tail] command with the `--follow` option (or `-f` for short). `tail` prints the lat 10 lines of a file, but `-f` will keep printing new lines when they are appended to the file. So in our case we run

```
tail -f your-program.log
```

And you shall see the logs being printed in real time. 

Sometimes the program seems to be running, but there is no log coming out. This might be because the program is buffering the standard output. Because printing to standard output is a expensive operation, maybe programming language or library will postpone the printing and save them in a buffer instead. Only when the buffer is full enough or the program reaches the end will it actually print out the messages in the buffer.In this case you might want to check how to "flush the buffer" in the programming language or tool you are using.

If you want to regain control of the program you are running, you can use the [`fg`][fg] command to bring the background job to the foreground.


# Summary

In this post we examine how to use `tmux` and its `-r` read-only mode to safeguard your server monitoring from connection lost and accidental Ctrl+c. We also provided an alternative way of piping to file and use `tail -f` in case `tmux` and `screen` are not available. Wish you all have a nice time working on servers.

[fg]: https://www.cyberciti.biz/faq/unix-linux-fg-command-examples-usage-syntax/
[screen]: https://www.gnu.org/software/screen/
[tail]: https://www.gnu.org/software/coreutils/manual/html_node/tail-invocation.html
[tmux]: https://github.com/tmux/tmux/wiki
