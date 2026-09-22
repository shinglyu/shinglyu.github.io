---
layout: post
title: Automated Git Bisection for Web APIs
categories: Web
date: 2019-02-11 21:17:09 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

Bug are a hard thing to pin down. Especially if you are working on a big project with a lot of commits being pushed/merged all the time. By the time you found out the master branch is broken, the commit that introduced the bug might already be buried in history. This is when git bisection shines. The man page of `git bisect` says:

> This command uses a binary search algorithm to find which commit in your project’s history introduced a bug. You use it by first telling it a "bad" commit that is known to contain the bug, and a "good" commit that is known to be before the bug was introduced. Then git bisect picks a commit between those two endpoints and asks you whether the selected commit is "good" or "bad". It continues narrowing down the range until it finds the exact commit that introduced the change.

If you do it manually, you'll need to compile your code (if applicable), restart your server and test if it works, then tell git if it's "good" or "bad". But if you have a lot of commits to test, the process soon becomes tedious. A better solution is to use `git bisect run`. You can give `git bisect run` a script that will exit with code `0` if the code is good, and exit with `1` to `127` (except `125`) if the commit is bad. Then `git` will automatically run until it finds the first offending commit.

Usually if you have a high-coverage unit test or integration test, you can `git bisect run` your tests. But if you web API test is still mostly manual, you can still use curl and grep to quickly bisect it.

<!--more-->

## Setting up a test server
For demonstration purpose, we are going to run a simple Python [Flask][flask] server.

```
# server.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    # raise Exception  # Uncomment this to make the server return 500
    return "Hello World!"
```

To run it, we run

```
pipenv install Flask
pipenv shell  # activate the pipenv environment 
FLASK_DEBUG=1 FLASK_APP=server.py flask run
```

We run the flask server with `FLASK_DEBUG=1`, this way the flask development server will reload the server when file changes. Since `git bisect` will keep checking out to different commits, have auto-reload enabled will make the bisection smoother.

## Running automated `git bisect`

The process of running [`git bisect run`][bisectrun] is just like a manual bisect run.

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

If your server needs a deployment or restart to run the new code, you can do it in the script before running cURL. But since we are running the development server that will automatically reload when the code changes, we can ignore this step. You might want to add a short `sleep` here so the flask server have some time to restart.

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
Author: Shing Lyu 
Date:   Mon Feb 11 20:39:21 2019 +0100

    A commit after the broken one

commit 9e7ba9cec5334c346955c77e4d5936c6cf0770a2
Author: Shing Lyu 
Date:   Mon Feb 11 20:36:50 2019 +0100

    THE broken commit

commit 06886574b12ea2c9b5a3939ca47cf39f8acc6b1c
Author: Shing Lyu 
Date:   Mon Feb 11 20:35:53 2019 +0100

    A good commit

commit c589afddcc9f34a246f05d159395be84e3a7a013
Author: Shing Lyu 
Date:   Mon Feb 11 20:34:17 2019 +0100

    Added install script and pip script

commit 6f34e2db053f49e476b769b6e356ebeea96e1a36
Author: Shing Lyu 
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
Author: Shing Lyu 
Date:   Mon Feb 11 20:36:50 2019 +0100

    THE broken commit

:100644 100644 07d3bb96e5798526577b6ab8a02788effd25ff67 a44ca012a675b80023f0e82381e8e76aef879527 M	server.py
bisect run success
```

## For badly designed APIs that always returns 200 OK

If you are unlucky enough to need to work on a badly designed API that always return 200 OK, and put the error message inside the response body, the above trick won't work for you. But do not despair! We still have the reliable `grep` command to help. The question is how to make get return the correct return code?

Let's the API returns 200 OK and the following response body when hitting an error:

```
{
  "message": "Error: Unexpected error happened."
}
```

`grep` will return `0` if some match is found, and `1` otherwise. But we want it to return non-zero when we match something pattern like `Error`. So we can use the `!` operator like so

```
curl http://127.0.0.1:5000 | (! grep ERROR)
```

You might be tempting to use the `-v/--invert-match` flag for `grep`, but this might not work because `grep` works on lines. If any of your line doesn't contain the `Error`, it will be matched and returns 0.

## Conclusion

Git's automated bisection is a powerful tool to pin down the commit that introduced a bug. Without a proper set of automated testing, using curl is your best bet. To correctly pass the exit code to `git bisect run`, you'll need to use the `--fail` option of curl to 




[bisectrun]:  https://git-scm.com/docs/git-bisect#_bisect_run


