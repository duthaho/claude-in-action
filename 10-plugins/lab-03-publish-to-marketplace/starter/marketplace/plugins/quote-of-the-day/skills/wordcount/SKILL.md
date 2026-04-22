---
name: wordcount
description: Use when the user asks for a word count, word frequency, or how many words are in a file (keywords: word count, wordcount, how many words, count words, word frequency). Reads the file the user points to and reports the word count.
---

# Word Count

Count the words in a file the user specifies.

## Procedure

1. Identify the file path the user mentioned. If no path is given, ask for one — do not guess.
2. Read the file with the Read tool.
3. Split the content on whitespace. A "word" is a non-empty token between whitespace runs.
4. Reply with exactly one line: `<N> words in <path>`.

## Constraints

- Do not output anything else.
- If the file is empty, reply `0 words in <path>`.
- If the file cannot be read, reply `cannot read <path>`.
