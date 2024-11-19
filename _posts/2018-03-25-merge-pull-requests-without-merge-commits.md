---
layout: post
title: Merge Pull Requests without Merge Commits
categories: Web
date: 2018-03-25 23:46:36 +02:00
tags: mozilla
excerpt_separator: <!--more-->
---

By default, GitHub's pull request (or GitLab's merge request) will merge with a merge commit. That means your feature branch will be merged into the `master` by creating a new commit, and both the feature and master branch will be kept. 
<!--more-->

Let's illustrate with an example:

Let's assume we branch out a feature branch called "new-feature" from the master branch, and pushed a commit called "Finished my new feature". At the same time someone pushed another commit called "Other's feature" onto the master branch.

![branch]({{site_url}}/blog_assets/ff-merge/branching.png)

If we now create a pull request for our branch, and get merged, we'll see a new merge commit called "Merge branch 'new-feature'"

![merge_commit]({{site_url}}/blog_assets/ff-merge/merge_commit.png)


If you look at GitHub's commit history, you'll notice that the UI shows a linear history, and the commits are ordered by the time they were pushed. So if multiple people merged multiple branches, all of them will be mixed up. The commits on your branch might interlace with other people's commits. More importantly, some development teams don't use pull request or merge requests at all. Everyone is suppose to push directly to master, and maintain a linear history. How can you develop in branches but merge them back to master without a merge commit?

Under the hood, GitHub and GitLab's "merge" button uses [the `--no-ff` option][noff], which will force create a merge commit. What you are looking for is the opposite: [`--ff-only`][ffonly] (`ff` stands for [fast-forward][ff]). This option will cleanly append your commits to master, without creating a merge commit. But it only works if there is not new commits in master but not in your feature branch, otherwise it will fail with a warning. So if someone pushes to master and you did a `git pull` on your local master, you need to do a rebase on your feature branch before using `--ff-only` merge. Let's see how to do this with an example:

```bash
git checkout new-feature # Go to the feature branch named "new-feature"
git rebase master
# Now your feature have all the commits from master
git checkout master #Go back to master
git merge --ff-only new-feature
```

After these commands, your master branch should contain the commits from the feature branch, as if they are `cherry-pick`ed from the feature branch. You can then push directly remote. 

```bash
git push
```

If unfortunately someone pushed more code to the remote master while you are doing this, your push might fail. You can pull, rebase and push again like so:

```bash
git pull --rebase && git push
```

[GitHub's documentation][gh-illustration] has some nice illustrations about the two different kind of merges.

Here is a script that does the above for you. To run it you have to checkout to the feature branch you want to merge back to master, then execute it. It will also pull and rebase both your feature and master branch to the most up-to-date remote master during the operation.

```
#!/usr/bin/env bash
CURRBRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ $CURRBRANCH = "master" ]
then
    echo "Already on master, aborting..."
    exit 1 
fi

echo "Merging the change from $CURRBRANCH to master..."
echo "Rebasing branch $CURRBRANCH to latest master"
git fetch origin master && \
git rebase origin/master && \
echo "Checking out to master and pull" && \
git checkout master && \
git rebase origin/master && \
echo "Merging the change from $CURRBRANCH to master..." && \
git merge --ff-only $CURRBRANCH && \
git log | less 
echo "DONE. You may want to do one last test before pushing"
```

It's worth mentioning that both GitHub and GitLab allows you to do the fast-forward (and squash) merge on it's UI. But it's configured on a per-repository basis, so if you don't control the repository, you might have to ask your development team's administrator to turn on the feature. You can read more about this feature in [GitHub's documentation][gh-config] and [GitLab's documentation][gl-config]. If you are interested in squashing the commits manually, but don't know how, check out my [previous post about squashing][squash].


[noff]: https://git-scm.com/docs/git-merge#_fast_forward_merge
[ffonly]: https://git-scm.com/docs/git-merge#_fast_forward_merge
[ff]: https://git-scm.com/docs/git-merge#_fast_forward_merge
[gh-illustration]: https://help.github.com/articles/about-pull-request-merges/
[gh-config]: https://help.github.com/articles/configuring-commit-squashing-for-pull-requests/
[gl-config]: https://docs.gitlab.com/ee/user/project/merge_requests/fast_forward_merge.html#enabling-fast-forward-merges
[squash]: https://shinglyu.github.io/web/2016/11/08/servo-rebase-and-squash-guide.html
