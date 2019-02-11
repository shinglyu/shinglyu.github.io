---
layout: post
title: Automated Git Bisection for Web APIs
categories: Web
date: 2019-02-11 21:17:09 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

Intro
<!--more-->

Git bisection
Setup the server
Run git bisect run

## Running automated `git bisect`

Git bisect provides the [`git bisect run`][bisectrun] command to automatically test your commits with the given command.  Just like a manual bisect run, the process starts like this:

* `git checkout master`: assuming we our master branch is now broken. Let's checkout to the master branch first.
* `git bisect start`: let's start the bisection
* `git bisect bad`: tell git that the current commit, which is the latest commit of master branch (i.e. HEAD), is broken
* `git checkout HEAD~4 && git bisect good`: We know that 4 commits ago it was working just fine. So let's checkout to the know good commit and mark it as good. This step usually takes some guessing. You might need to checkout back a few commits, test, and repeat if the commit is still broken.
* `git bisect run ./bisect-test.sh`: Now run the test script `bisect-test.sh` on commits between the `good` and `bad` commits. As the name suggest it uses a [binary search][binarysearch] algorithm so it roughly takes log_ n_  steps.

The `./bisect-test.sh` scripts contains the following:

```
#!/usr/bin/env bash

# Deploy your service or run a local dev server
# ...

# Test it with curl
curl http://127.0.0.1:5000
```

If your server needs a deployment or restart to run the new code, you can do it in the script before running cURL. But since we are running the development server that will automatically reload when the code changes, we can ignore this step.

## Make cURL return non-zero return code when getting HTTP errors

If you run the above `bisect-test.sh`, you'll probably get the wrong result. This is because even if cURL receives a 4xx or 5xx error, it will still return `0`. For example if we run it on an API that gives 500 internal server error:

```
> ./bisect-test.sh
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <title>Exception // Werkzeug Debugger</title>
# cURL prints out the Flask error page in raw HTML, omitting the rest...

> echo $?
0  # cURL still returns 0
```

To fix this, notice that in curl's manpage:

>       -f, --fail
>              (HTTP) Fail  silently  (no  output  at  all)  on  server errors. This is mostly done to better enable scripts etc to better deal with failed  attempts.  In  normal  cases when  an  HTTP  server  fails  to deliver a document, it returns an HTML document stating so  (which  often  also describes  why  and  more).  This flag will prevent curl from outputting that and return error 22.
>
>              This method is not fail-safe  and  there  are  occasions where  non-successful  response codes will slip through, especially when  authentication  is  involved  (response codes 401 and 407).

So if we change the command to

```
curl http://127.0.0.1:5000 --fail
```

curl will return 22 if it encounters 4xx and 5xx, and stop printing the whole response body.

```
> ./bisect-test.sh
curl: (22) The requested URL returned error: 500 INTERNAL SERVER ERROR
> echo $?
22
```

There are a few small extra tweaks we can add to make the process even smoother. If your server takes time to restart, and your restart script is not synchronous, you'll need to add some `sleep` before you run curl. Also if you don't want to see the HTTP response body got print out, you and redirect both STDOUT and STDERR to `/dev/null`:

```
curl http://127.0.0.1:5000 --fail > /dev/null 2>&1
```

So let's see a complete demo.  If we have a git history like this, where we know the broken commit is `9e7ba9ce`:

```
commit db8c76eebab77ac57556a56bf04ee099abf44da9
Author: Shing Lyu <shing.lyu@gmail.com>
Date:   Mon Feb 11 20:39:21 2019 +0100

    A commit after the broken one

commit 9e7ba9cec5334c346955c77e4d5936c6cf0770a2
Author: Shing Lyu <shing.lyu@gmail.com>
Date:   Mon Feb 11 20:36:50 2019 +0100

    THE broken commit

commit 06886574b12ea2c9b5a3939ca47cf39f8acc6b1c
Author: Shing Lyu <shing.lyu@gmail.com>
Date:   Mon Feb 11 20:35:53 2019 +0100

    A good commit

commit c589afddcc9f34a246f05d159395be84e3a7a013
Author: Shing Lyu <shing.lyu@gmail.com>
Date:   Mon Feb 11 20:34:17 2019 +0100

    Added install script and pip script

commit 6f34e2db053f49e476b769b6e356ebeea96e1a36
Author: Shing Lyu <shing.lyu@gmail.com>
Date:   Mon Feb 11 20:30:10 2019 +0100

    Created a simple hello world server
```

Then we can run the bisection.

```
> git bisect start                                                    ✭
> git bisect bad                                                      ✭
% git checkout 6f34e2db053f49e476b769b6e356ebeea96e1a36               ✭
Note: checking out '6f34e2db053f49e476b769b6e356ebeea96e1a36'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at 6f34e2d... Created a simple hello world server
> git bisect good                                                     ✭
Bisecting: 1 revision left to test after this (roughly 1 step)
[06886574b12ea2c9b5a3939ca47cf39f8acc6b1c] A good commit
> git bisect run ./bisect-test.sh                                     ✭
running ./bisect-test.sh
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[9e7ba9cec5334c346955c77e4d5936c6cf0770a2] THE broken commit
running ./bisect-test.sh
9e7ba9cec5334c346955c77e4d5936c6cf0770a2 is the first bad commit
commit 9e7ba9cec5334c346955c77e4d5936c6cf0770a2
Author: Shing Lyu <shing.lyu@gmail.com>
Date:   Mon Feb 11 20:36:50 2019 +0100

    THE broken commit

:100644 100644 07d3bb96e5798526577b6ab8a02788effd25ff67 a44ca012a675b80023f0e82381e8e76aef879527 M	server.py
bisect run success
```

## For badly designed APIs that always returns 200 OK

If you are unlucky and need to work on a badly designed 


The above 
## for always 200 APIs: (! grep)
## Auto bisect

[bisectrun]:  https://git-scm.com/docs/git-bisect#_bisect_run


