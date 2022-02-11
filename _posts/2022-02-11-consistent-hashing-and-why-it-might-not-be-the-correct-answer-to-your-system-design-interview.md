---
layout: post
title: Consistent Hashing and why it might not be the correct answer to your system design interview
categories: Web
date: 2022-02-11 10:44:44 +01:00
excerpt_separator: <!--more-->
---
I've conducted many system design interviews in the past. Whenever I brought up the topic of database sharding, the candidates almost always shout out "Yes, yes I know! Consistent hashing!". If you probe them further, they will draw this classic ring diagram on the whiteboard.

![Consistent Hashing Diagram](https://upload.wikimedia.org/wikipedia/commons/7/71/Consistent_Hashing_Sample_Illustration.png)
<a href="https://commons.wikimedia.org/wiki/File:Consistent_Hashing_Sample_Illustration.png">WikiLinuz</a>, <a href="https://creativecommons.org/licenses/by-sa/4.0">CC BY-SA 4.0</a>, via Wikimedia Commons

But if you have read Martin Kleppmann's great book [*Designing Data-Intensive Applications*][dataintensive], you might notice a sidenote:

> ..., this particular approach (Consistent hashing, as defined by Karger et al.) actually doesn't work very well for databases, so it's rarely used in practice (the documentation of some databases still refers to consistent hashing, but it is often inaccurate).

Then why is every system design interview study guide tell you otherwise? Let's dive into this topic in this post.

<!--more-->

The original consistent hashing algorithm was proposed by Karger et al in the 1997 paper [*Consistent hashing and random trees: distributed caching protocols for relieving hot spots on the World Wide Web*][karger]. As the title suggests, it's an algorithm for *distributed caching on the World Wide Web*. In other words, it was designed for Content Delivery Network (CDN). This design goal dictated a few design decisions, for example, it need to support the removal of arbitrary nodes. When a cache node stops responding, it is OK to simply remove it from the cluster and reroute the keys to other nodes. The other nodes can easily repopulate the cache key-value. But in a database (i.e. data **storage** application), we usually don't re-shard the cluster if one node is temporarily down, because the cost of moving data between nodes is high, even with the help of consistent hashing. Instead, we would have multiple replicas for a single shard or use other methods to ensure each shard remains available. So the resharding only happens when the planned capacity changes, not when an arbitrary node is temporarily down. Therefore, if we can drop this requirement of supporting the removal of arbitrary nodes, we might be able to find more efficient algorithms.

Also, in practice, we use a technique called "virtual nodes". A physical node might be mapped to multiple virtual nodes on the ring to achieve a fairer spread of keys among nodes. But in a large-scale system with thousands of nodes, if each node has to be mapped to hundreds or even thousands of virtual nodes, these metadata would take up a lot of memory.

To address these problems, Google proposed an alternative algorithm in 2014, called [*jump consistent hash*][jump]. The algorithm is very simple. The pseudo-code takes only 5 lines. It has a much better key distribution and no memory overhead compared to the original consistent hashing. And it's much faster! You can read the [paper][jump] to see the benchmark and how it achieves these results with a relatively simple algorithm.

One downside of jump consistent hash is that it only outputs a shard number, instead of an arbitrary shard ID. Therefore, you can only add or remove nodes at the higher end of the shard number range and cannot remove arbitrary nodes. But as we explained earlier, this is a concern for CDN, and has no impact on database sharding use cases. 

So to summarize, the original consistent hashing by Karger et al introduced a powerful mechanism for CDN scaling. It was used by some early databases like Amazon's original Dynamo paper. But today, you have newer algorithms that are better suited for database sharding use cases. If you are interested in database sharding/partitioning in general, read Chapter 6 of [*Designing Data-Intensive Applications*][dataintensive] by Martin Kleppmann. If you are interested in the comparison of con of consistent hashing algorithms, you can read this [blog post][comparsion] by Damian Gryski.


[dataintensive]: https://dataintensive.net/
[karger]: https://dl.acm.org/doi/10.1145/258533.258660
[jump]: https://arxiv.org/abs/1406.2294
[comparsion]: https://dgryski.medium.com/consistent-hashing-algorithmic-tradeoffs-ef6b8e2fcae8
