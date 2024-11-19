---
layout: post
title: Identify Performance Regression in Servo
categories: Web
date: 2016-07-18 10:00:00 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

Performance has always been a key focus for the Servo browser engine project. But just measure the performance through profilers and benchmarks is not enough. The first impression to a real user is the page load time. Although many internal, non-visible optimizations are important, we still want to make sure our page load time is doing well.

Back in April, I opened this bug [#10452](https://github.com/servo/servo/issues/10452) to start planning the page load test. With the kind advice from the Servo community and the Treeherder people, we finally settled for a test design similar to the Talos test suite, and decided to use Perfherder for visualization.

<!--more-->

## Test Design
[Talos](https://wiki.mozilla.org/Buildbot/Talos) is a performance test suite designed for Gecko, the browser engine for Firefox. It has many different kinds of tests, covering user-level UI testing and benchmarking. But what we really care about is the [TP5](https://wiki.mozilla.org/Buildbot/Talos/Tests#tp5) page load test suite. As the [wiki](https://wiki.mozilla.org/Buildbot/Talos/Tests#tp5) says, TP5 use Firefox to load 51 scrapped websites selected from the [Alexa Top 500](http://www.alexa.com/topsites) sites of its time. Those sites are hand-picked, then downloaded and cleaned to remove all external web resources. Then these web pages are hosted on a local server to reduce network latency impact.

Each page is tested three times for Servo, then we take the medium of the three. (We should test more times, but it will take too long.) Then all the mediums are averaged using [geometric mean](https://en.wikipedia.org/wiki/Geometric_mean). Geometric mean has a great property that even if two test results are of different scale (e.g. 500 ms v.s. 10000 ms), if any one of them changed by 10%, they will have equal impact on the average.

## Visualization

Talos test results for Gecko have been using Treeherder and Perfherder for a while. The former is a dashboard for test results per commit; the latter is a line plot visualization for the Talos results. With the help from the Treeherder team, we were able to push Servo performance test results to the Perfherder dashboard. I had a [blog post](http://shinglyu.github.io/web/2016/05/07/visualizing_performance_data_on_perfherder.html) on how to do this. You'll see screenshots for Treeherder and Perfherder in the following sections.

## Implementation

We created a [python test runner](https://github.com/shinglyu/servo-perf/blob/master/runner.py) to execute the test. To minimize the effect of hardware differences, we run the Vagrant (VirtualBox backend) virtual machine used in Servo's CI infrastructure. (You can find the Vagrantfile [here](https://github.com/servo/saltfs/blob/master/Vagrantfile)). The test is scheduled by [buildbot](http://buildbot.net/) and runs every midnight.

The test results are collected into a JSON file, then consumed by the test result [uploader script](https://github.com/shinglyu/servo-perf/blob/master/submit_to_perfherder.py). The uploader script will format the test result, calculate the average and push the data to Treeherder/Perfherder throught the [Python client](http://treeherder.readthedocs.io/submitting_data.html)

## The 25% Speedup!

A week before the Mozilla London Workweek, we found a big gap in the Perfherder graph. The average page load time changed from about 2000 ms to 1500 ms on June 10th. 

![Improvement graph]({{site_url}}/blog_assets/servo-perf/drop_graph.png)

We were very excited about the significant improvement. Perfherder conveniently links to the commits in that build, but there are 26 commits in between. 

![Link to commits]({{site_url}}/blog_assets/servo-perf/drop_graph_commits.png)

![GitHub commits]({{site_url}}/blog_assets/servo-perf/commits_full.png)

You should notice that there are many commits by the "bors-servo" bot, who is out automatic CI bot that does the pre-commit testing and auto-merging. Those commits are the merge commits generated when the pull request is merged. Other commits are commits from the contributors branch, so they may appear earlier then the corresponding merge commit. Since we only care when the commit gets merged to the master branch, not when the contributor commits to their own branch, we'll only bisect the merge commits by bors-servo.

Buildbot provides a convenient web interface for forcing a build on certain commits. 

![Buildbot force build]({{site_url}}/blog_assets/servo-perf/buildbot_force.png)

You can simply type the commit has in the "Revision" field and buildbot will checkout that commit, build it and run all the tests.

![Buildbot force build zoom in]({{site_url}}/blog_assets/servo-perf/force_zoom.png)

You can track the progress on the Buildbot waterfall dashboard.

![Buildbot waterfall]({{site_url}}/blog_assets/servo-perf/buildbot_waterfall.png)

Finally, you'll be able to see the test result on Treeherder and Perfherder.

![Treeherder]({{site_url}}/blog_assets/servo-perf/treeherder.png)

![Perfherder with bisects]({{site_url}}/blog_assets/servo-perf/bisect_data.png)

The performance improvement turns out to be the result of this [patch](https://github.com/servo/servo/pull/11513) by [Florian Duraffourg](https://github.com/fduraffourg), he use a hashmap to replace a slow list search.

## Looking Forward

In the near future, we'll focus on improving the framework's stability to support Servo's performance optimization endeavor. We'll also work closely with the Treeherder team to expand the flexibility of Treeherder and Perfherder to support more performance frameworks. 

If you are interested in the framework, you can find open bugs [here](https://github.com/shinglyu/servo-perf/issues), or join the discussion in the [tracking bug](https://github.com/servo/servo/issues/10452).

Thanks [William Lachance](https://github.com/wlach) for his help on the Treeherder and Perfherder stuff, and helped me a lot in setting it up on Treeherder staging server. And thanks [Lars Bergstrom](https://github.com/larsbergstrom) and [Jack Moffit](https://github.com/metajack) for their advice throughout the planning process. And thanks [Adrian Utrilla](https://github.com/autrilla) for contributing many good features to this project.
