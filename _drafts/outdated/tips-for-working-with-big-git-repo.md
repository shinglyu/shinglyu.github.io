---
layout: post
title: Tips for Working with Big Git Repo
categories: Web
date: 2017-12-31 09:54:20 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

Although most open source projects uses the [GitHub flow][github_flow], I sometimes have to work with giant [monorepos][monorepo], in which everyone pushes to `master` directly. If you don't handle it with care, it will become slower and slower and becomes impossible to work with.
<!--more-->

# Merge feature branches into master without merge commits
One of the monorepo I works on allows everyone to push directly to the `master` branch. But I prefer to work on my features in separate branches. If I simply run `git merge` to merge the feature branch into `master`, git will create a merge commit, which is really ugly and makes the log really confusing. But there is a way to "merge" it back without creating a merge commit, using the `--ff-only` option. Let's use an example to illustrate it.

Let's say I'm working on a feature in a separate feature branch called `new-feature`, but someone else pushed her code to the master branch, like the following diagram (time goes from the bottom to the top):

![branching]({{site_url}}/blog_assets/monorepo-tips/branching.png)

If we `git checkout master` and run `git merge new-feature`, the resulting diagram will be like this:

![merge commit]({{site_url}}/blog_assets/monorepo-tips/merge_commit.png)

There will be a "Merge branch 'new-feature'" commit, which may not be desirable is your team is expecting a linear git history. It also looks really confusing on GitHub's (or other git web frontend) log view, because GitHub's UI doesn't show the branches clearly, so you'll see the both the merge commit and the commit in the `new-feature` branch in a linear-style log. 

To avoid the merge commit, you can do a cherry-pick to pick the commit from the `new-feature` branch to the `master` branch. But this method doesn't scale if you have multiple commits in the feature branch. The trick here is to use the "fast forward only" option (`--ff-only`) for `git merge`. It will try to apply the patches on top of the `master` branch if possible, but it will not do rebase for you. First you do `git checkout master` and do a `git pull --rebase` to get other people's changes on the remote. Now your local `master` will look like this:

![local master]({{site_url}}/blog_assets/monorepo-tips/master.png)

Then you can `git checkout new-feature` and rebase it on top of the `master` branch: `git rebase master`, this will pull in all the commits from `master` and apply your commit on top of them:

![local feature]({{site_url}}/blog_assets/monorepo-tips/ff.png)

You might have to handle conflicts during `git rebase master`. After the rebase is done, your `master` and `new-feature` branch is almost the same except for the changes you made. Now you can go back to `master` by `git checkout master` and run `git merge --ff-only new-feature`. Your changes will be applied using fast forwarding as if they are written on top of the master branch directly. Now you can push your `master` branch directly with a clean linear history. 

# Keeping git clean and fast
Git saves many information about the repo locally. But many of them get outdated pretty soon. Doing regular cleaning will save you disk space and make it run faster. 

The first step is to avoid pulling branches you don't need. When you do `git pull` (or `git pull --rebase`), all tracked branch will be pulled. In a big monorepo in which people pushes many branches all the time, this will take a lot of time. Instead, use `git pull origin master`, so git will only pull the `master` branch. 

Secondly, you might still have some stale branches, which were removed in the remote, in your local repository. To clean them up, run `git remote prune origin`. You can also run with `--dry-run` to see what will be removed before actually touching the file. 

Finally, git has a nice garbage collection script called `git gc` that cleanup and optimize your local repository. Based on the documentation (`git gc --help`):

> Runs a number of housekeeping tasks within the current repository, such as compressing file revisions (to reduce disk space and increase performance) and removing unreachable objects which may have been created from prior invocations of git add.
>
> Users are encouraged to run this task on a regular basis within each repository to maintain good disk space utilization and good operating performance.

If you haven't run it for a while, it might take a very long time to run. And while running all other git operation will be slow, so schedule it to run while you are not working.

[monnorepo]: https://developer.atlassian.com/blog/2015/10/monorepos-in-git/
[github_flow]: https://guides.github.com/introduction/flow/
