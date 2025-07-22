---
layout: post
title: Why the % Sign Breaks Your Website (And How to Fix It)
categories: Web
date: 2025-07-22 22:53:00 +02:00
excerpt_separator: <!--more-->
---

A frontend developer friend recently reached out to me for help. Her React app was mysteriously breaking, and she couldn't figure out why. After some investigation, we discovered the culprit: a single `%` character in a URL was causing the entire application to crash.

When you see a URL (Uniform Resource Locator), it often contains characters like letters, numbers, and some special symbols. However, not all characters are allowed directly inside a URL because some have special meanings, and some fall outside the allowed range of characters. This is where percent-encoding comes into play.

<!--more-->

## What is Percent-Encoding?

Percent-encoding (also called URL encoding) is a way to represent any character in a URL using only safe ASCII characters. It works by replacing certain characters with a `%` sign followed by two hexadecimal digits that represent the ASCII byte value of the character.

The two digits after `%` are hexadecimal, meaning they range from `0-9` and `A-F` (not decimal).

For example: the space character ` ` has ASCII code 32 in decimal, which is 20 in hexadecimal. So space becomes `%20` in percent-encoding.

## Why Do We Need Percent-Encoding?

Certain characters in URLs have special roles (like `/` separates path segments, `?` starts query parameters, `#` identifies a fragment) or may not be allowed at all. Encoding them avoids confusion. Also, some characters might not be allowed in URLs or may cause technical problems (non-ASCII or control characters).

For example:

- `%` itself must be encoded as `%25` because it is used as the "escape" character.
- Characters like `:` `%3A`, `/` `%2F`, `?` `%3F`, (space) `%20`, and many more have standardized encodings.

## How Does It Work?

1. If a character is allowed in a URL and doesn't need escaping, it stays as is.
2. If it needs escaping, it's replaced by `%` + two hexadecimal digits corresponding to that character's ASCII code.

**Example:** The string "Hello world!" becomes `Hello%20world%21` because space is `%20` and `!` is `%21`.

## What Happens with Invalid Percent-Encoding?

A `%` sign must always be followed by two hexadecimal digits to represent a valid encoded byte. If you have a dangling or incomplete percent-encoding sequence—like a `%` at the end of a URL or `%G1` (where `G` is invalid in hex)—this makes the URI invalid.

For instance, a URL like:

```
https://www.microsoft.com/&test=%
```

contains a trailing `%` which is not followed by two hex digits, making it an invalid URI. Servers typically respond to such invalid URIs with an HTTP 400 (Bad Request) error.

Other servers may instead respond with an HTTP 404 (Not Found) if they interpret the URL differently or handle errors differently. For example:

```
https://www.google.com/&test=%
```

might return a 404 error instead.

## How Does This Affect Frontend Frameworks?

Frontend routing libraries such as React Router rely on valid URLs to parse and manage navigation. If they encounter invalid percent-encoding (like a `%` not followed by two hex digits), JavaScript APIs in the browser may throw errors such as:

```
URIError: malformed URI sequence
```

This happens because JavaScript's `decodeURIComponent` function expects valid percent-encoded strings and will fail on invalid sequences.

## What Can Frontend Developers Do?

As a frontend developer, you have a few options to handle this proactively, though each comes with its own trade-offs:

**Option 1: Proactive encoding** - Use `encodeURIComponent()` before adding any user input to URLs. This ensures that special characters like `%` are properly encoded before they cause problems.

**Option 2: Defensive decoding** - Wrap `decodeURIComponent()` calls in try-catch blocks to gracefully handle malformed URI sequences instead of letting them crash your application.

## Key Takeaways

- Always ensure `%` characters in URLs are properly encoded as `%25` or followed by valid hex digits
- Test your URLs thoroughly, especially when dealing with user-generated content
- Handle URI encoding errors gracefully in your frontend applications
- Remember that different servers may respond differently to invalid URIs
