# Solution — lab-02-image-inputs

> Try the steps in the lab's `README.md` first — peek here after.

## What Claude actually sees

When you paste a screenshot into Claude Code, the image is attached to your user turn as an `image` content block. The model sees pixels, not the DOM — so its reproduction relies on visual inference: "that shape looks like a rounded button", "that colour is ~warm-brown", "those two pills are equally sized". The generated HTML is Claude's best guess at the markup a designer would have written to produce what it's looking at.

That means the output tracks the mockup's *shape* closely, and its *exact values* loosely:

- Text content, layout structure, rough colours, and relative sizes come out very accurate.
- Pixel-exact hex codes, font weights, shadow blur radii, border-radius in px — you'll get "close to right", not identical.
- Semantic HTML (`<button>` vs `<div role="button">`) depends on the prompt. "Reproduce this" defaults to readable semantics; "match the DOM exactly" is unspecified.

## Prompt shape that works

> Here is a screenshot of a product card. Reproduce it as a single `index.html` file with inline CSS (no framework, no JS). Keep the structure semantic — use `<h1>`, `<p>`, `<button>`. Match the text content exactly; approximate the colours.

Three things make this prompt work:

1. **Single-file constraint.** "No framework, no JS" forecloses a detour into React or a build pipeline.
2. **Text content exactly.** You want the product name and prices to be verbatim; paraphrasing defeats the exercise.
3. **Approximate the colours.** Give Claude permission to eyeball hex codes — asking for pixel-exact produces long digressions and doesn't make the output better.

## When this workflow is the right tool

- **Design hand-offs where the source file is lost.** Client sent a PDF or PNG, no Figma access. Claude converts in minutes.
- **Stack overflow archaeology.** Screenshot of an old dashboard from a bug report → working reproduction in a sandbox.
- **Accessibility audits starting from visuals.** "Give me semantic HTML for this layout" highlights what the screenshot *didn't* encode.

## When it isn't

- **Production-grade fidelity.** If you need pixel-exact, use a design tool's export, not a vision model.
- **Interactive state.** Hover, focus, animation. The screenshot captures one frame; Claude has to invent the rest.
- **Tables with many rows.** Vision models struggle with wide/dense grids — you'll get shape right, cell contents wrong.
