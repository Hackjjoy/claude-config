---
name: visual-doc
description: Build single-file, highly-readable visual HTML documents in the warm "clay & cream" Anthropic-inspired style — using Fraunces+Inter typography, sage/amber/clay color coding, rounded cards, numbered flow steps, and inline SVG illustrations. Output is a self-contained .html file ready to open in a browser. Use when the user asks for a visual document, explainer page, system overview, workflow diagram, design doc, onboarding doc, or visual reference. Triggers on "visual doc", "비주얼 문서", "explainer page", "design document", "workflow doc", "onboarding doc", "system overview as html", "/visual-doc".
---

# visual-doc — readable visual HTML documents

Produce a single `.html` file that explains a system, workflow, or concept with the same visual language as the reference template at `template.html` in this skill folder. Goal: **maximum readability** — generous whitespace, strong typographic contrast, and color-coded categorization so a reader can scan structure in seconds.

## When to use

Trigger this skill when the user asks for:
- A visual / illustrated explainer of a workflow, system, or process
- A design or onboarding document that needs to look polished, not Markdown-plain
- A repository overview, ownership-boundary doc, scenarios walkthrough, etc.
- A doc with diagrams or step-by-step flows where plain text would be hard to scan

Do NOT use for:
- Slide decks (use a slide tool)
- Editable Notion/Confluence pages (write Markdown instead)
- Plain README updates

## Output contract

- **One self-contained HTML file**, default path `docs/<topic>.html` (or wherever the user names it).
- All CSS embedded in `<style>`. No build step. No JS framework.
- Only external dependency: Google Fonts (`Fraunces`, `Inter`, `JetBrains Mono`).
- All illustrations are inline SVG — never raster images.
- Renders without a network connection except for fonts (the page degrades gracefully to system fonts).

## Design system (do not deviate)

### Color palette
```
--bg: #FAF9F5         cream background
--bg-2: #F3EEE3       warm panel
--surface: #FFFFFF    cards
--ink: #1F1B16        primary text
--ink-2: #3D372F      secondary text
--ink-dim: #6E665B    body dim
--ink-mute: #9A9286   captions / meta
--line: #E5DCC9       hairlines
--line-2: #D9CDB6     stronger hairlines

--clay: #D97757       primary accent (italic, eyebrows, system/harness)
--clay-deep: #B85A3D
--clay-soft: #F4D9CB
--clay-tint: #FBEDE3

--sage: #6B8E6F       category A (e.g. Developer / left side)
--sage-soft: #D9E4D9
--sage-tint: #ECF2EC

--amber: #C68B3A      category B (e.g. Backend / right side)
--amber-soft: #F0DEBC
--amber-tint: #F7EBD2

--code-bg: #F5EFE0
```

**Use color semantically, not decoratively.** Pick one role for each accent up front (e.g. clay = system/automation, sage = role A, amber = role B) and apply it consistently across hero, role cards, flow pills, ownership boundary, and chips. A reader should learn the legend once and then recognize it anywhere on the page.

### Typography
- Headers: `'Fraunces'` (serif), weight 500, italic for emphasis and section numbers
- Body: `'Inter'` (sans), weight 400/500/600, line-height 1.6, base 15px
- Code: `'JetBrains Mono'`, slightly smaller (12.5–13px) with `--code-bg` background
- **Italic Fraunces accents** are the signature move — use them for: hero word ("an *enterprise tool*"), section numbers (`01`, `02`), captions, footer signature

### Spacing & shape
- Page wrap: `max-width: 1200px; padding: 56px 36px 120px;`
- Card radius: 14px (small), 18px (large hero/scenario/boundary)
- Section spacing: `margin-top: 80px;`
- Cards have 1px `--line` borders and white surface; never use heavy shadows
- Decorative top border on cards (3px solid accent) signals category

### Decorative texture
Subtle radial gradients on `body::before` give the page warmth — keep this even on minimal docs:
```css
body::before {
  content: ""; position: fixed; inset: 0; pointer-events: none; z-index: 0;
  background-image:
    radial-gradient(circle at 12% 18%, rgba(217,119,87,.06), transparent 38%),
    radial-gradient(circle at 88% 70%, rgba(107,142,111,.05), transparent 42%);
}
.wrap { position: relative; z-index: 1; }
```

## Document structure

A finished document follows this arc:

1. **Hero** — eyebrow + serif headline (with one italic clay-colored phrase) + lede + 1–2 role/scope cards on the left, a hand-drawn-feeling SVG illustration on the right
2. **Sections** — each `<section>` opens with `<h2>` (optionally with `.num` italic prefix and `.tag` pill), followed by a `.sub` paragraph (max 760px) explaining intent
3. **Content blocks** — pick from the component cookbook below; do not invent new card shapes unless the user explicitly asks
4. **Footer** — single line + italic clay signature

Always use semantic HTML (`<header>`, `<section>`, `<footer>`, `<h2>`, `<h3>`, `<h4>`). Never put structural content in divs alone.

## Component cookbook

Copy these patterns from `template.html`. The most reusable ones:

| Component | Use for | Class hooks |
|---|---|---|
| `.eyebrow` | Pre-headline label above hero | clay text, uppercase, with leading dash |
| `.role` cards | 1–4 stakeholder/role descriptions | `.role.d` (sage), `.role.b` (amber); 2-col grid |
| `.req` cards | Requirements / prerequisites with icon | 3-col grid; icon + name + meta + desc + tags |
| `.card` + `pre.tree` | Folder or repo layout with semantic coloring | wrap a `<pre class="tree">` with `.hl` / `.accent-clay` / `.accent-sage` / `.accent-amber` / `.com` spans |
| `.stack` / `.tech` | Tech stack tiles | 4-col grid, circular icon, name + 1-line desc |
| `.access-grid` + `.access-table-wrap` | Permission/access matrix | 3 colored cards above a comparison table |
| `.boundary` | Two-side ownership / before-after | left zone + arrow + right zone, sage vs amber |
| `.overview` | TOC / scenario index | 3-col cards with italic numbers, link to in-page anchors |
| `.scenario` + `.flow` | Step-by-step walkthrough | sticky SVG illus on left + numbered steps on right |
| `.step` (inside `.flow`) | Single step in a flow | numbered pill (`.pill.d/.b/.s`) + body card with title, who-pill, copy, code, chips |
| `.rails` / `.rail` | Guardrails / constraints / rules | 3-col grid, icon + name + desc |
| `.who` pills | Inline role tags | `.who.d` sage, `.who.b` amber, `.who.s` clay |
| `.chip` / `.chip.warn` / `.chip.ok` | Mono-font tags inside step bodies | for artifacts, durations, file paths |
| `.brief-grid` | Inline highlighted note inside a step | clay left border, soft cream bg |

## SVG illustration guidance

The hand-drawn feel is a load-bearing part of the brand. When making illustrations:

- Use the palette colors only — no off-palette hues
- 1.6–2px stroke weight on `--ink` (`#1F1B16`) for outlines
- `stroke-linecap="round"` and `stroke-linejoin="round"` everywhere
- Soft tinted ellipse "clouds" as background (`opacity: 0.35–0.7`)
- Dashed strokes (`stroke-dasharray="3 3"` or `"5 3"`) for flows, transitions, "in-progress"
- Dotted texture pattern for fills (`<pattern id="dots">` with small circles on `--line`)
- Italic Fraunces SVG `<text>` for captions inside illustrations
- Sparkles (`+` cross with optional diagonals) as accent decorations
- Faces stay tiny and friendly — two dots + curved mouth, that's it
- Each SVG is wrapped with a `.caption` italic Fraunces line below

If you can't draw something cleanly, use a single emblematic icon (folder, gear, sprout, zip package) over a soft tinted ellipse rather than a complex scene.

## Workflow

1. **Confirm scope**. Ask the user (in one batched message) for: the topic, primary audience, the 2–3 categories that should map to sage/amber/clay, and the rough section list. Do not invent these.
2. **Copy the template**. Start from `template.html` in this skill folder — keep the `<style>` block as-is, replace only the body content.
3. **Draft sections in order**: hero → overview/TOC → content sections → footer. Keep each `.sub` paragraph under 4 lines.
4. **Color discipline**: every accent class in the doc must reflect the legend established in step 1. If a category doesn't fit one of the three accents, prefer a neutral card over inventing a new color.
5. **Illustrations last**. Build content first; add SVG illustrations once the structure is settled. A good doc can ship with 1–2 SVGs, not one per section.
6. **Self-review checklist** before handing back:
   - [ ] Single `<h1>` in hero, all other section headers are `<h2>` / `<h3>`
   - [ ] One italic Fraunces phrase in the hero headline
   - [ ] Every accent color is used semantically and consistently
   - [ ] No section is wall-of-text — break into cards/steps/chips
   - [ ] Responsive collapse works (test at 800px width)
   - [ ] No broken anchors, no missing `</section>`
   - [ ] Footer signature line present

## Readability rules (the bar)

- **Scan first, read second.** A reader skimming card titles and pill labels should grasp the doc's shape without reading paragraphs.
- **One idea per card.** If a card has more than 3 sentences of body copy, split it.
- **Code where it helps, prose where it doesn't.** File paths, commands, and config keys belong in `<code>`. Avoid mixing inline code into running narrative.
- **Vertical rhythm.** Section gaps (80px), card gaps (14–18px), inline gaps (6–10px). Do not collapse these to fit more content — add a section instead.
- **No emoji.** This style does not use emoji. Use SVG icons or Fraunces italic accents instead.
- **No dark mode.** This palette is cream-on-warm by design. Do not invert.

## Reference files

- `template.html` — full working boilerplate with all CSS and one example of every component. Copy this as the starting point for new docs.
- `components.md` — quick-reference snippets for each component (paste-ready HTML).

## Anti-patterns (do not do these)

- Replacing the cream background with white or gray — kills the warmth
- Adding a fourth accent color — the three-color legend is the readability device
- Sans-serif headers — the serif/sans contrast is what makes the page feel editorial
- Tall hero illustrations that push the lede below the fold
- Generic stock SVG icons (Material/Heroicons style) — they break the hand-drawn feel
- Multi-column running text — this is a card-grid layout, not a magazine
- Collapsible accordions / tabs — everything is on the page, scannable
