# Lab 02 — Image Inputs: Screenshot → HTML

> Section: 12-advanced-features · Difficulty: intermediate · Est: 30 min

## Goal

You reproduce a visual mockup as plain HTML by showing Claude a screenshot. The starter ships `mockup.html` — the visual target rendered in the browser. You open it, screenshot it, paste the screenshot into Claude Code, and ask for matching HTML. Claude writes `output.html`. The verifier checks that the reproduction carries the mockup's concrete text content (product name, price, tag names, button label). This is the single most useful image-input workflow: design exists as pixels, you need it as code.

## Prerequisites

- Claude Code installed and logged in (the model must be a vision-capable one — all current Claude models are)
- Completed: any earlier lab that got you comfortable in a Claude Code session
- Tools: a browser (to render and screenshot the mockup)

## What you'll build

- `starter/output.html` filled in with Claude's generated reproduction, starting from a screenshot you take.
- The generated file must contain the five text strings from the mockup: `Pacific Espresso`, `Medium roast · Single origin`, `$18.50`, `Chocolate`, `Caramel`, and a button labelled `Add to cart`.

## Steps

1. Change into the starter and open `mockup.html` in your browser:
   ```bash
   cd 12-advanced-features/lab-02-image-inputs/starter
   # macOS
   open mockup.html
   # Linux
   xdg-open mockup.html
   # Windows (git bash)
   start mockup.html
   ```
   You should see a product card for "Pacific Espresso". Take a screenshot of just the card (not the whole browser chrome):
   - macOS: ⌘-Shift-4 → drag.
   - Windows: Win-Shift-S → drag.
   - Linux: use your distro's screenshot tool.
2. Launch Claude Code from the starter directory:
   ```bash
   claude
   ```
3. Paste the screenshot into Claude Code (Ctrl-V / ⌘-V) and send this prompt:
   > Here is a screenshot of a product card. Reproduce it as a single `output.html` file with inline CSS, no framework, no JS. Keep the HTML semantic — use `<h1>`, `<p>`, `<button>`. Match the text content exactly; approximate the colours. Write the result to `output.html`.
4. Open `starter/output.html` and compare it side-by-side with the mockup. If the text or structure is off, iterate with Claude:
   > The tag pills in your output look like boxes. The mockup has them as rounded pills with a light-beige background. Fix the CSS so they match.
5. Stop iterating when the shape and text match. Perfect colour fidelity isn't the goal — the verifier only checks text content and overall structure. The solution's `README.md` explains why.

## Verify

```bash
bash ../../scripts/verify-lab.sh 12-advanced-features/lab-02-image-inputs
```

The script confirms `starter/output.html` exists, is non-trivial (not just the stub), and contains every text string from the mockup. It also checks that `mockup.html` is unchanged so your reproduction is the file being graded.

## Solution

See `solution/output.html` for one possible reproduction. `solution/README.md` explains what Claude actually sees when you paste an image, which aspects of a mockup it reproduces faithfully vs approximately, and a prompt shape that works reliably.

## Going further

- Replace the mockup with a screenshot of an existing site (respecting that site's TOS). Ask Claude to also extract a colour palette and a typography scale.
- After getting `output.html`, ask Claude to convert it into a React component (`output.jsx`). The image input is upstream — once HTML exists, the downstream work is pure code.
- Feed Claude *two* mockups — a light and a dark variant — and ask for a CSS-variable theme that produces both.

## References

- [Official docs: Vision](https://docs.claude.com/en/docs/build-with-claude/vision) — how Claude processes images
- [Official docs: Claude Code overview](https://docs.claude.com/en/docs/claude-code/overview) — pasting images into a session
