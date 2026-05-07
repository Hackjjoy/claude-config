# visual-doc — component cookbook

Paste-ready HTML snippets for the components defined in `template.html`. The full `<style>` block lives in `template.html`; copy that as the boilerplate, then drop these snippets into the body. Class names match the template.

---

## Hero

```html
<header class="hero">
  <div class="hero-text">
    <div class="eyebrow">Eyebrow Label</div>
    <h1>A clear noun phrase, with <em>one italic accent</em>,<br>that ends a thought.</h1>
    <p class="lede">
      One or two sentences explaining what this document is and why a reader
      should keep going. <strong>Bolded fragment</strong> calls out the most
      important phrase.
    </p>
    <div class="scale-stat">Optional metric or scope tag</div>

    <div class="roles">
      <div class="role d">
        <div class="ico"><!-- 32x32 SVG, sage stroke --></div>
        <div>
          <h3>Category A</h3>
          <p>One-line description of who this is and what they own.</p>
        </div>
      </div>
      <div class="role b">
        <div class="ico"><!-- 32x32 SVG, amber stroke --></div>
        <div>
          <h3>Category B</h3>
          <p>One-line description of the second role.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="hero-art">
    <svg viewBox="0 0 460 380" xmlns="http://www.w3.org/2000/svg"><!-- illustration --></svg>
  </div>
</header>
```

---

## Section header

```html
<section>
  <h2>Section title</h2>
  <p class="sub">One short paragraph (max 4 lines) saying what this section covers and why.</p>
  <!-- content -->
</section>
```

With italic numbered prefix and tag pill (used for scenarios):

```html
<h2><span class="num">01</span>Section title <span class="tag">qualifying tag</span></h2>
```

---

## Requirements grid (3 columns)

```html
<div class="reqs">
  <div class="req">
    <div class="req-ico"><!-- 26x26 SVG --></div>
    <div class="req-body">
      <div class="req-name">Name <span class="req-meta">version</span></div>
      <div class="req-desc">One-sentence description with <code>inline-code</code> if useful.</div>
      <div class="req-tags">
        <span class="who d">Category A</span>
        <span class="who b">Category B</span>
      </div>
    </div>
  </div>
  <!-- repeat .req -->
</div>
```

---

## Repo / folder tree

```html
<div class="repo">
  <div class="card">
    <h4>Reference: <code>example/</code></h4>
    <p class="muted">One-line caption.</p>
<pre class="tree">example/
├─ <span class="accent-amber hl">file.toml</span>     <span class="com"># comment</span>
├─ src/
│  └─ <span class="accent-sage hl">entry.js</span>    <span class="com"># comment</span>
└─ README.md</pre>
  </div>
</div>
```

`<pre>` must start at column 0 to preserve indentation. Available span classes inside `pre.tree`: `.hl` `.accent-clay` `.accent-sage` `.accent-amber` `.com`.

---

## Tech / primitive tiles (4 columns)

```html
<div class="stack">
  <div class="tech">
    <div class="ico"><!-- 30x30 SVG --></div>
    <div class="name">Name</div>
    <div class="desc">One-line desc with <code>code</code>.</div>
  </div>
  <!-- repeat -->
</div>
```

---

## Access / permission grid + comparison table

```html
<div class="access-grid">
  <div class="access-card deploy">
    <div class="ac-icon"><!-- SVG --></div>
    <h4>Right name</h4>
    <div class="ac-who">Persona label</div>
    <p>Two-sentence description of the right and who holds it.</p>
  </div>
  <!-- .access-card.content (sage), .access-card.view (amber) -->
</div>

<div class="access-meta">
  <div class="access-table-wrap">
    <table>
      <thead>
        <tr><th>Right</th><th>Persona A</th><th>Persona B</th><th>Persona C</th></tr>
      </thead>
      <tbody>
        <tr>
          <td>Row label</td>
          <td><span class="check">&#10003;</span></td>
          <td><span class="dash">&#8211;</span></td>
          <td><span class="dash">&#8211;</span></td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="auth-note">
    <h4>Side-note title</h4>
    <div class="kv">
      <div class="kv-row">
        <span class="kv-label">Key</span>
        <span class="kv-val">value</span>
      </div>
    </div>
    <p>Caveats and provisioning notes.</p>
  </div>
</div>
```

---

## Ownership boundary (left ↔ right)

```html
<div class="boundary">
  <div class="zone d">
    <div class="zone-icon"><!-- SVG, sage stroke --></div>
    <h4>Side A title</h4>
    <div class="who-line">Category A — owns X</div>
    <ul>
      <li><code>path/file</code> short note</li>
      <li>another item</li>
    </ul>
  </div>
  <div class="arrow">
    <svg width="60" height="28" viewBox="0 0 60 28" fill="none" stroke="#9A9286" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
      <path d="M5 14 L 50 14"/>
      <path d="M44 8 L 52 14 L 44 20"/>
    </svg>
  </div>
  <div class="zone b">
    <div class="zone-icon"><!-- SVG, amber stroke --></div>
    <h4>Side B title</h4>
    <div class="who-line">Category B — owns Y</div>
    <ul><li>...</li></ul>
  </div>
</div>
```

---

## Overview / TOC cards (3 columns, anchored)

```html
<div class="overview">
  <a href="#scenario-1" class="overview-card" style="text-decoration:none">
    <div class="ov-num">01</div>
    <div class="ov-title">Scenario name</div>
    <div class="ov-desc">One-sentence summary that gives away the punchline.</div>
    <div class="ov-tags">
      <span class="who d">Category A</span>
      <span class="who s">System</span>
    </div>
  </a>
  <!-- repeat -->
</div>
```

---

## Scenario with sticky illustration + numbered flow

```html
<section id="scenario-1">
  <h2><span class="num">01</span>Scenario title <span class="tag">qualifying tag</span></h2>
  <p class="sub">One-paragraph framing of this scenario.</p>

  <div class="scenario">
    <div class="illus">
      <svg viewBox="0 0 280 320" xmlns="http://www.w3.org/2000/svg"><!-- illustration --></svg>
      <div class="caption">italic caption</div>
    </div>

    <div class="flow">
      <div class="step">
        <div class="gutter"><div class="pill d">1</div><div class="line"></div></div>
        <div class="body">
          <div class="title">Step name <span class="who d">Category A</span></div>
          <p>What happens. Use <code>inline code</code> for files and commands.</p>
          <div class="brief-grid">
            <div><strong>Worth touching on</strong>optional inline highlighted note.</div>
          </div>
          <div class="artifacts">
            <span class="chip">artifact</span>
            <span class="chip warn">caveat</span>
            <span class="chip ok">success state</span>
          </div>
        </div>
      </div>

      <div class="step">
        <div class="gutter"><div class="pill s">2</div><div class="line"></div></div>
        <div class="body">
          <div class="title">System step <span class="who s">System</span></div>
          <p><span class="cmd">/some_command arg</span> describe what it does.</p>
        </div>
      </div>

      <!-- last step: omit .line div to drop the connector -->
      <div class="step">
        <div class="gutter"><div class="pill b">3</div></div>
        <div class="body">
          <div class="title">Final step <span class="who b">Category B</span></div>
          <p>Closing action.</p>
        </div>
      </div>
    </div>
  </div>
</section>
```

Pill colors: `.pill.d` sage (Category A), `.pill.b` amber (Category B), `.pill.s` clay (System / automation). Match the `who` pill on the same step.

---

## Guardrails / rules grid

```html
<div class="rails">
  <div class="rail amber">
    <div class="rico"><!-- 20x20 SVG --></div>
    <div>
      <div class="name">Rule name</div>
      <div class="desc">One-sentence rationale with <code>code</code>.</div>
    </div>
  </div>
  <!-- variants: .rail (clay), .rail.sage, .rail.amber -->
</div>
```

---

## Footer

```html
<footer>
  <div>One-line summary or pointer to the reference implementation.</div>
  <div class="signature">
    <svg width="16" height="16" viewBox="0 0 16 16" fill="#D97757">
      <path d="M8 0 L 9.5 5 L 14.5 6 L 10.5 9 L 12 14 L 8 11 L 4 14 L 5.5 9 L 1.5 6 L 6.5 5 Z"/>
    </svg>
    crafted in clay &amp; cream
  </div>
</footer>
```

---

## Inline elements quick reference

| Snippet | Use |
|---|---|
| `<span class="who d">Label</span>` | Category A pill (sage) |
| `<span class="who b">Label</span>` | Category B pill (amber) |
| `<span class="who s">Label</span>` | System / automation pill (clay) |
| `<span class="chip">text</span>` | Mono tag inside step bodies |
| `<span class="chip warn">text</span>` | Caveat chip (clay-tint) |
| `<span class="chip ok">text</span>` | Success chip (sage-tint) |
| `<code>identifier</code>` | Inline code with code-bg |
| `<span class="cmd">/run thing</span>` | Inline command (same look as code) |
| `<em>...</em>` inside `<h1>` | Italic clay-deep accent in hero |

---

## SVG illustration recipes

### Hand-drawn folder
```svg
<g>
  <path d="M90 110 L 200 110 L 215 125 L 370 125 L 370 145 L 90 145 Z"
        fill="#D97757" stroke="#B85A3D" stroke-width="2" stroke-linejoin="round"/>
  <rect x="90" y="140" width="280" height="170" rx="8"
        fill="#FFFFFF" stroke="#1F1B16" stroke-width="2.2"/>
</g>
```

### Soft tinted background ellipse
```svg
<ellipse cx="140" cy="160" rx="125" ry="140" fill="#FBEDE3" opacity="0.5"/>
```

### Dashed flow arrow
```svg
<path d="M0 0 L 0 30" stroke="#1F1B16" stroke-width="1.8" fill="none"
      stroke-linecap="round" stroke-dasharray="4 3"/>
<path d="M-5 24 L 0 32 L 5 24" stroke="#1F1B16" stroke-width="1.8"
      fill="none" stroke-linecap="round" stroke-linejoin="round"/>
```

### Sparkle accent
```svg
<g transform="translate(380, 70)" stroke="#D97757" stroke-width="1.8"
   stroke-linecap="round" fill="none">
  <path d="M0 -8 L 0 8"/>
  <path d="M-8 0 L 8 0"/>
  <path d="M-5 -5 L 5 5" opacity="0.6"/>
  <path d="M5 -5 L -5 5" opacity="0.6"/>
</g>
```

### Tiny friendly face
```svg
<circle cx="15" cy="19" r="1.2" fill="#1F1B16"/>
<circle cx="25" cy="19" r="1.2" fill="#1F1B16"/>
<path d="M15 25 Q 20 28 25 25" stroke="#1F1B16" stroke-width="1.3"
      fill="none" stroke-linecap="round"/>
```

### Italic Fraunces caption inside SVG
```svg
<text x="20" y="76" text-anchor="middle" font-family="Fraunces, serif"
      font-style="italic" font-size="11" fill="#4F6F53">Label</text>
```
