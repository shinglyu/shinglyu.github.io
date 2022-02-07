---
layout: post
title: How to import serde's custom derive macors properly?
categories: micro 
date: 2020-06-24 23:05:05 +02:00

---

**TL;DR Follow the [official documentation](https://serde.rs/derive.html)**

A little bit of history:

* Before Rust 2018, you do:

```rust
extern crate serde;
#[macro_use] extern crate serde_derive; // Imports the procedural macros

#[derive(Serialize, Deserialize)]
struct Foo;
```

* But Rust 2018 introduced [new way of doing this](https://doc.rust-lang.org/edition-guide/rust-2018/macros/macro-changes.html#procedural-macros):

```rust
use serde_derive::{Serialize, Deserialize}; // Imports the procedural macros

#[derive(Serialize, Deserialize)]
struct Foo;
```

* However, the `serde` crate [re-exports the `serde_derive::{Serialize, Deserialize}` macros](https://github.com/serde-rs/serde/issues/797), hidden behind the feature flag `derive`. So if you enable the `derive` feature you can get both the `Serialize`/`Deserialize` traits and procedural macros (i.e., the custom derive) from the `serde` crate by one single `use`:

```rust
// Cargo.toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }

// src/main.rs or lib.rs
use serde::{Serialize, Deserialize}; // Imports both the traits and procedural macros

#[derive(Serialize, Deserialize)]
struct Foo;
```

* You can choose not to use the `derive` feature. But you'll run into [this issue](https://github.com/serde-rs/serde/issues/1441) if any of your dependencies enables the `derive` feature. You can either:
  * Just enable `derive` (recommended).
  * Use `serde::ser::Serialize` and `serde::de::Deserialize` to get the **trait** and keep using `serde_derive::{Serialize, Deserialize}` to get the **procedural macros**.
