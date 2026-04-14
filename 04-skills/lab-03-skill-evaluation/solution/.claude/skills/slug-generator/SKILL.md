---
name: slug-generator
description: Use when the user asks for a URL slug, kebab-case identifier, filename-safe version of a string, or slug-ified title. Produces a lowercase, dash-separated, punctuation-stripped version of the input.
---

# Slug Generator

Turn an arbitrary string into a URL-friendly slug.

## Rules

1. Convert the string to lowercase.
2. Replace any run of whitespace with a single `-`.
3. Strip all characters that are not ASCII letters (`a-z`), digits (`0-9`), or `-`.
4. Collapse any run of consecutive `-` into a single `-`.
5. Strip leading and trailing `-`.
6. If the result is longer than 60 characters, truncate it. If truncation lands on a `-`, also strip that trailing `-`.
7. If the result is empty, return the literal string `untitled`.

## Examples

- `"Hello, World!"` → `"hello-world"`
- `"  multiple   spaces  "` → `"multiple-spaces"`
- `"!!!"` → `"untitled"`
