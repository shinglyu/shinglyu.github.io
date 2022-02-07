---
layout: post
title: Check MongoDB index usage statistics
categories: micro
date: 2020-06-10 18:57:50 +02:00
---

Run this command to get the usage of each index:

```
db.<collection>.aggregate( [ { $indexStats: { } } ] )
```

This is useful for figuring out which index is underutilized. You can find an example output in the [documentation](https://docs.mongodb.com/manual/reference/operator/aggregation/indexStats/).

