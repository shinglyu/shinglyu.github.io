---
layout: post
title: Counting your contribution to a git repository
categories: Web
date: 2018-12-25 12:00:27 +01:00
tags: mozilla
excerpt_separator: <!--more-->
---
Sometimes you may wonder, how many commits or lines of code did I contributed to a git repository? Here are some easy one liners to help you count that.

<!--more-->

# Number of commits

Let's start with the easy one: counting the number of commits made by one user.

The easiest way is to run

```bash
git shortlog -s
```

This gives you a list of commit counts by user:

```
2  Grant Lindberg
9  Jonathan Hao
2  Matias Kinnunen
65  Shing Lyu
4  Shou Ya
1  wildsky
1  wildskyf
```

(The example comes from [shinglyu/QuantumVim][quantumvim].)

If you only care about one user you can use

```bash
git rev-list HEAD --author="Shing Lyu" --count 
```

, which prints `65`.

Let's explain how this works: 
* `git rev-list HEAD` will list the commit objects in `HEAD`
* `--author="Shing Lyu"` will filter out only the commits made by the author Shing Lyu
* `--count` counts the number of commits. You can pipe it to `| wc -l` instead.

# Count the line of insertion and deletions by a user

Insertion and deletions are a little bit tricker. This is what I came up with:

```bash
git log --author=Shing --pretty=tformat: --numstat | grep -v '^-' | awk '{ add+=$1; remove+=$2 } END { print add, remove }' 
```

This might seem a little bit daunting, but we'll break it up into steps:

* `git log --author="Shing Lyu"` list the commits by Shing Lyu, in the following format:

      commit 6966b2c969cbf62029792221bf124ed75ee2c640
      Author: Shing Lyu 
      Date:   Sat Nov 18 17:01:25 2017 +0100

          Added Ctrl+z to close all system tabs

      commit f4710cc3a2efdc63c7caf3ec04d504912ad20a93
      Author: Shing Lyu 
      Date:   Sat Nov 18 15:58:20 2017 +0100

          Bump version and diable jpm packaging


* `--numstat` will give us the line added and removed per file per commit:

      commit 6966b2c969cbf62029792221bf124ed75ee2c640
      Author: Shing Lyu 
      Date:   Sat Nov 18 17:01:25 2017 +0100

          Added Ctrl+z to close all system tabs

          1       0       README.md
          10      0       manifest.json
          6       1       package.sh
          35      0       vim-background.js
          4       1       vim.js

      commit f4710cc3a2efdc63c7caf3ec04d504912ad20a93
      Author: Shing Lyu 
      Date:   Sat Nov 18 15:58:20 2017 +0100

          Bump version and diable jpm packaging

          1       1       manifest.json
          3       3       package.sh

* We don't really need the commit, Author, Date and commit message fields, so we use an empty formatting string to get rid of them: `--pretty=tformat:`

      1       0       README.md
      10      0       manifest.json
      6       1       package.sh
      35      0       vim-background.js
      4       1       vim.js
      1       1       manifest.json
      3       3       package.sh

* If you add some non-text files, e.g. png image files, the insertion/deletion count might be represented as `- - foo.png`. Therefore we filter them out with `grep -v '^-'`. If you are not familiar with `grep`, `-v` means reverse match (i.e. find those lines that does NOT match the patter). The pattern `^-` means lines staring with a `-`. (This part is optional if you pipe to `awk`, `awk` seems to ignore non-numeric character while doing the math.)

* Finally we pipe it to `awk` for summing. Even if you are not familiar with `awk`, this part is pretty self-explanatory:

  ```bash
awk '{ add+=$1; remove+=$2 } END { print add, remove }'
  ```

  We add column one (`$1`) to the variable `add`, and column two (`$2`) to the variable `remove`, then we print them out. This gives us an output like so:

      936 260 

# Other alternatives

There are many other off-the-shelf scrips that will help you calculate contribution statistics. Like [git-quick-stats](https://github.com/arzzen/git-quick-stats), [git-fame](https://github.com/casperdcl/git-fame) and [git-fame-rb](https://github.com/oleander/git-fame-rb). But if you only want a quick-and-easy solution please give it a try.

[quantumvim]: https://github.com/shinglyu/QuantumVim
