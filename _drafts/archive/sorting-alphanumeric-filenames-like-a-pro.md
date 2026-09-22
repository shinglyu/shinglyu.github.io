---
layout: post
title: Sorting Alphanumeric Filenames Like A Pro
categories: Web
date: 2016-12-25 19:50:39 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

Recently I've been working on the reftest[reftest] in Gecko (on a Ubuntu Linux machine). The test is split into several chunks and run parallel to save time. In order to analyze all the test failures, I wrote a script to download the logs from each chunk. Unfortunately, the log files are named in the pattern: `log_1.json`, `log_2.json`, ..., `log_14.json`, `log_15.json`. When I run `ls` (actually `ls -1` to list the files in one column), I got:

{% highlight bash %}
log_10.json
log_11.json
log_12.json
log_13.json
log_14.json
log_15.json
log_1.json
log_2.json
log_3.json
log_4.json
log_5.json
log_6.json
log_7.json
log_8.json
log_9.json
{% endhighlight %}

Notice that 10 to 15 are listed before 1 to 9, which what I expect (1 to 15). (The order on your system may be different (1, 10, 11, ..., 14, 15, 2, 3, 4, ...), this is related to the locale, we'll get back to this later.) Piping it to GNU `sort` (all the commands I use are from Ubuntu's default) doesn't help either:

{% highlight bash %}
ls -1 | sort # Same output
{% endhighlight %}

Why is that? It's because `ls` and `sort` doesn't interpret the number within the filename as numbers, instead they compare the strings charter by charter (ordered by their ASCII order). So how can we solve it? 
<!--more-->

`sort` has a numeric sort mode, but it doesn't work when we mix alphabets and numbers together.

{% highlight bash %}
# sort
# -n, --numeric-sort
#        compare according to string numerical value
ls -1 | sort -n # Sort in numeric order, doesn't work either
{% endhighlight %}

The solution is to use something called _version sort_, or _natural sort_ or _human sort_. If you look into the manpage of `ls` and `sort`, you'll find:

{% highlight bash %}
# ls
-v     natural sort of (version) numbers within text
# sort
-V, --version-sort
       natural sort of (version) numbers within text
{% endhighlight %}

However these parameters are not portable, they exist in the GNU coreutils version, but may not exist in BSD/OSX versions.

By running 

{% highlight bash %}
ls -v -1
{% endhighlight %}

or

{% highlight bash %}
# Assume the filenames are in a file
cat filenames.txt | sort -V
{% endhighlight %}

, we can get

{% highlight bash %}
log_1.json
log_2.json
log_3.json
log_4.json
log_5.json
log_6.json
log_7.json
log_8.json
log_9.json
log_10.json
log_11.json
log_12.json
log_13.json
log_14.json
log_15.json
{% endhighlight %}

The version sort can also handle more complex version number patterns like `log_1.10.23.json`. So take good use of it.

## Python
I also see the same problem a lot while working on machine learning or test framework projects in Python. So here is a python version from Ned Batchelder's [blog post][humansort]. 

{% highlight python %}
import re

def tryint(s):
    try:
        return int(s)
    except:
        return s

def alphanum_key(s):
    """ Turn a string into a list of string and number chunks.
        "z23a" -> ["z", 23, "a"]
    """
    return [ tryint(c) for c in re.split('([0-9]+)', s) ]

def sort_nicely(l):
    """ Sort the given list in the way that humans expect.
    """
    l.sort(key=alphanum_key)
{% endhighlight %}

The essence of this method is the `alphanum_key()` function, which splits the input string into chunks of string and numbers. Then it calls `tryint()` on each chunk. If the chunk is indeed an integer, the `int()` function in `tryint()` will successfully turn it into an int, otherwise it will stay as a string. The next and final piece of magic is the `key` argument in `list.sort()`. The [`key` argument][keyarg] specifies a function to be called on each item of the array before comparison. The comparison will be done using the return value of the `key` function instead of the items themselves. Since we return a list of characters and numbers, python will compare the lists position by position (sort by the item at index 0 first, then index 1, etc.). This will give us the natural order we want.

## Side Note: Locale Collation Rules

You may notice that the first `ls` and `sort` result I presented is a little bit weird. If the characters are sorted by ASCII number, why would `log_10.json` go before `log_1.json`? If we look at the first different character:

{% highlight bash%}
log_10
log_1.
{% endhighlight%}

Since `.` in [ASCII][ascii] is `56` and `0` is `60`, we would expect `1.` to be before `10`? But actually `.` and `_` are ignored in sorting because of our locale setting, so we are actually sorting

{% highlight bash %}
log10json
log1json
#   ^ 0 is before j
{% endhighlight%}

To control this behavior, we can use the [`LC_COLLATE`][lc] environment variable:

```
LC_COLLATE
    This variable determines the locale category for character collation. It determines collation information for regular expressions and sorting, including equivalence classes and multi-character collating elements, in various utilities and the strcoll() and strxfrm() functions. Additional semantics of this variable, if any, are implementation-dependent.
```

If you want to compare all the characters (including the special characters that are ignored), you can use `LC_COLLATE=C`, then it will compare with the ASCII numbers as we expected:

{% highlight bash %}
log_1.json
log_10.json
log_11.json
log_12.json
log_13.json
log_14.json
log_15.json
log_2.json
log_3.json
...
{% endhighlight %}


[ascii]: https://en.wikipedia.org/wiki/ASCII?oldformat=true#Printable_characters
[lc]: http://pubs.opengroup.org/onlinepubs/7908799/xbd/envvar.html
[unicodecoll]: http://unicode.org/reports/tr10/
