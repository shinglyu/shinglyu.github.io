---
layout: post
title: Beginner's guide to git rebasing and squashing
categories: Web
date: 2016-11-08 14:29:17 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

I wrote this post on the [Servo wiki][servo-wiki] to help beginners getting started with rebasing and squashing, two of the most terrifying operations you'll face if you are not familiar with git. I'm cross posting this here for people working on other projects.

Big thanks to [Wafflespeanut][waffle] who proofread the post, any error you found here is my own.

---

Suppose you've created a pull request following the [checklist][checklist], but the reviewer asks you to fix something, do a rebase or squash your commits, how exactly do you do that? If you have some experience with git, you might want to check the [GitHub workflow][gh-workflow] for a quick overview. But if you are not familiar with git enough, we'll teach you how to do these common operations in detail.

<!--more-->

# Fixing review comments

Once you reviewer reviewed your patch, he/she might leave some comments asking you to fix something. So you edit the source code, then you will probably do something like this.

1. `git add <the file you fixed>` then `git commit`, write a commit message telling people what you've fixed. (You might also check out the `--fixup` option for `git commit` in the [workflow doc][gh-workflow].)
2. Simply `git push` to the same remote branch which you've created the PR with. The GitHub pull request page will pick up your changes, and hide those review comments you've fixed.

If your fix is trivial, and you have a single commit ready for merge, then you can consider using `git commit --amend` to add the change directly to your last commit. Then, all you need to do is `git push -f` to force push to the branch at your fork.

# Rebasing

Sometimes, if someone merged new code while your patch is still in review, git might not be able to figure out how to apply your patch on top of the new code. In this case, our [bors-servo][bors] bot will notify you with a helpful message:

> ☔️ The latest upstream changes (presumably #12345) made this pull request unmergeable. Please resolve the merge conflicts.

... and the GitHub UI will say "This branch has conflicts that must be resolved". This is when you need a rebase. Here, we'll explain the power of rebasing with a simple example.

Suppose the `servo/servo` tree is like this before you start working on a bug, in which `R` is the latest commit:

```
P -> Q -> R (<= remote servo/servo)
```

You create a new branch from `R`, then you add your own fixes `X` and `Y`:

```
P -> Q -> R   (<= remote servo/servo)
           \
            .--> X -> Y (<= your local branch)
```

But if someone merged their PR `S` before you, and he/she modified the code which you had also been working on, then git might fail to know how to merge the changes from both of you. So, we should fix this by ourselves.

```
P -> Q -> R ---> S
           \
            .--> X -> Y
```


But you **cannot** do that with a `git pull`, because it will create a [merge commit][mergecommit], which will mess up the git history. A `git pull` will make the tree look like this, in which the `M` commit contains stuff from your `X`, `Y` and `S`

```
P -> Q -> R ---> S -------.
           \               \
            \               v
             .--> X -> Y -> M
```

We want to fix this by rebasing, which means re-attach our changes `X` and `Y` to the new root `S`, like so:

```
P -> Q -> R -> S
                \
                 .--> X -> Y
```

Here is how we do it:

1. Let's assume your `servo` repo is cloned from your own fork, (if you run `git remote -v`, you can see the `origin` points to something like `git@github.com:<your username>/servo.git` rather than `git@github.com:servo/servo.git`).
2. You need to create a new remote called 'upstream' that points to the `servo/servo` branch, so we can download the latest code. Run `git remote add upstream git@github.com:servo/servo.git`
3. Now let's download the latest code from `servo/servo`, but don't try to merge them: `git fetch upstream`.
4. Now we can rebase our `X` and `Y` on top of the latest change, run `git rebase upstream/master`.
5. Git might ask you to fix conflicts. We'll get into that now.

## Fixing conflicts

First run `git status`, it will tell you which file was `both modified`. Open those files one by one in them, you'll see lines like this:

```
<<<<<<<<<<< HEAD
use std::cmp::{max, min};
===========
use std::cmp::{max, PartialEq};
>>>>>>>>>>> Your Commit
```

This means that in the commit `S`, the author wants to add `min` to the `use` line, but in your commit you want to add `PartialEq`. (Lines between the `<<<` and `===` are the version on `servo/servo`; the lines between `===` and `>>>` are your local version.) A way to fix this is to include both, so you can delete all the lines from the `>>>` to `<<<`, and replace them with the correct code:

```
use std::cmp::{max, min, ParitalEq};
```

After you fixed all the conflicts, you can run `git add <the files you edited>`, then `git rebase --continue`. You might need to repeat this action multiple times until every conflict is resolved. (In case you messed up, you can always run `git rebase --abort` to start over).

# Squashing

Once the reviewer approves your PR, he/she might ask you to "squash" the commits. There are a lot of reasons for this. If you have a lot of `fixup` commits, and you merge all of them directly into `servo/servo`, the git history will be bloated (which is something we don't want). Or, if your recent commit fixes your previous commit in the same PR, then you could've simply rebased it (we prefer fixing the mistakes made by you).

Anyway, using the last example, if your change consists of two commits `X` and `Y`, we want to squash them into a single commit `Z`.

```
P -> Q -> R
           \
            .--> X -> Y
```

```
P -> Q -> R
           \
            .--> Z
```

To achieve this, we can use the `git rebase -i` command.

1. First we need to identify the last commit before the ones you want to merge, which is `R` in our example. Run `git log` and remember the hash of `R`.
2. Run `git rebase -i <hash of R>`, this will bring up your default text editor with a content like:


        pick 7de252c X
        pick 02e5bd1 Y

        # Rebase 170afb6..02e5bd1 onto 170afb6 (2 command(s))
        #
        # Commands:
        # p, pick = use commit
        # r, reword = use commit, but edit the commit message
        # e, edit = use commit, but stop for amending
        # s, squash = use commit, but meld into previous commit
        # f, fixup = like "squash", but discard this commit's log message
        # x, exec = run command (the rest of the line) using shell
        # d, drop = remove commit
        #
        # These lines can be re-ordered; they are executed from top to bottom.
        #
        # If you remove a line here THAT COMMIT WILL BE LOST.
        #
        # However, if you remove everything, the rebase will be aborted.
        #
        # Note that empty commits are commented out


3. Keep the first commit as `pick`, and change all the other `pick` to `squash` (or `s` for short):


        pick 7de252c X
        squash 02e5bd1 Y

        # Rebase 170afb6..02e5bd1 onto 170afb6 (2 command(s))
        ...


4. Now save and quit the text editor, the rebase will run until the end. You might meet conflicts like you do in rebasing. Fix then using the same method described in the previous section.
5. After the rebase is finished, the editor will pop-up again, now you can write the commit message for the new commit `Z`.
6. `git push -f` to push the squashed commit to GitHub (and update the PR).

If you made any mistake right after you run step 2, you can abort by deleting every line in the text editor then save and exit. If you mess up fixing the conflicts, you can also run `git rebase --abort` to reset everything and start over.

# Ask for help

Working on git for a personal project is very different from collaborating on giant open-source projects like Servo. So, if this guide doesn't solve your problem, feel free to ask your reviewer in the pull request or ask people on IRC ([#servo][irc] on irc.mozilla.org).


[checklist]: https://github.com/servo/servo/blob/master/CONTRIBUTING.md
[gh-workflow]: https://github.com/servo/servo/wiki/Github-workflow
[bors]: https://github.com/bors-servo
[mergecommit]: https://www.atlassian.com/git/tutorials/merging-vs-rebasing/workflow-walkthrough
[irc]: http://chat.mibbit.com/?server=irc.mozilla.org&channel=%23servo

[checklist]: https://github.com/servo/servo/blob/master/CONTRIBUTING.md
[gh-workflow]: https://github.com/servo/servo/wiki/Github-workflow
[bors]: https://github.com/bors-servo
[mergecommit]: https://www.atlassian.com/git/tutorials/merging-vs-rebasing/workflow-walkthrough
[irc]: http://chat.mibbit.com/?server=irc.mozilla.org&channel=%23servo
[servo-wiki]: https://github.com/servo/servo/wiki/Beginner's-guide-to-rebasing-and-squashing
[waffle]: https://github.com/Wafflespeanut
