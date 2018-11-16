---
layout: post
title: New Rust Course - Building Reuseable Code with Rust
categories: Web
date: 2018-11-16 22:04:21 +08:00
tags: mozilla
excerpt_separator: <!--more-->
---

My first ever video course is now live on [Udemy][udemy], [Safari Books][safari] and [Packt][packt]. It really took me a long time and I'd love to share with you what I've prepared for you.

# What's this course about?
This course is about the [Rust][rust] programming language, but it's not those general introductory course on basic Rust syntax. This course focus on the code reuse aspect of the Rust language. So we won't be touch every language feature, but we'll help you understand how a selected set of features will help you achieve code reuse.

# What's so special about it?

Since these course is not a general introduction course, it is structured in a way that is bottom-up and help you learn how the features are actually used out in the wild.

<!--more-->

## A bottom up approach
We started from the most basic programming language construct: loops, iterators and functions. Then we see how we can further generalize functions and data structures (structs and enums) using generics. With these tools, we can avoid copy-pasting and stick to the DRY (Don't Repeat Yourself) principle. 

But simply avoiding repeated code snippet is not enough. What comes next naturally is to define a clear interface, or internal API between the modules (in a general sense, not the Rust `mod`). This is when traits comes in handy. Traits help you define and enforce interfaces. We'll also discuss the performance impact on static dispatch vs. dynamic dispatch by using generics and trait object.

Finally we talk about more advanced (i.e. you shouldn't use it unless necessary) tool like macros, which will help do crazier things by tapping directly into the compiler. You can write function-like macros that can help you reuse code that needs lower level access. You can also create custom `derive` with macros.

Finally, with these tools at hand, we can package our code into modules (Rust `mod`), which can help you define a hierarchical namespace. We can then organize these modules into Crates, which are software packages or libraries that can contain multiple files. When you reach this level, you can already consume and produce libraries and frameworks and work with a team of Rust developers.

 
## A guided tour though the `std`

 It's very easy to learn a lot of syntax, but never understand how they are used in real life. In each section, we'll guide you through how these programming tools are used in `std`, or the Rust standard library. Standard libraries are the extreme form of code reuse, you are reusing code that is produced by the core language team. You'll be able to see how these features are put to real use in `std` to solve their code reuse needs.

 We'll also show you how you can publish your code onto [crates.io][cratesio], Rust's package registry. Therefore you'll not only be comfortable reusing other people's crate, but be a valuable contributor to the wider Rust community.

# Conclusion

So this summarized the highlights of this course. If you've already learned the basics of Rust and would like to take your Rust skill to the next level, please check this course out. You can find this course on the following platforms: [Udemy][udemy], [Safari Books][safari] and [Packt][packt].


[udemy]: https://www.udemy.com/building-reusable-code-with-rust/
[safari]: https://www.oreilly.com/library/view/building-reusable-code/9781788399524/
[packt]: https://www.packtpub.com/application-development/building-reusable-code-rust-video
[rust]: https://www.rust-lang.org/
[cratesio]: https://crates.io/
