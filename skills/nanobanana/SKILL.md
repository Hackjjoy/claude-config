---
name: nanobanana
description: Generate game asset images with transparent backgrounds using Gemini API. Use when creating sprites, icons, items, characters for games. Triggers on requests like "generate game asset", "create sprite", "make game icon".
---

# Nanobanana - Game Asset Image Generator

Generate 2D game assets with Gemini API, optimized for background removal.

## Quick Start

```bash
node scripts/generate-image.mjs "<subject>" [output.png]
```

Requires: `GEMINI_API_KEY` environment variable

## Workflow

1. User describes the game asset they need
2. Run the generation script with the subject
3. Image is saved with green background for easy removal
4. Use rembg or image editor to remove background

## Prompt Formula

The script automatically builds optimized prompts:

```
{subject}, game asset, 2D sprite, isolated on solid bright green background (#00FF00),
clean sharp edges, no shadows, no reflections, centered composition, single object,
high contrast against background, ready for chroma key removal
```

## Examples

```bash
# Fruit collectible
node scripts/generate-image.mjs "golden banana with sparkle effects, cartoon style" banana.png

# Character sprite
node scripts/generate-image.mjs "cute knight with sword, chibi style, front view" knight.png

# UI icon
node scripts/generate-image.mjs "red health potion bottle, flat design" potion.png

# Magic effect
node scripts/generate-image.mjs "blue fireball with glow, VFX style" fireball.png
```

## Background Removal

After generation, remove the green background:

```bash
# Using rembg (pip install rembg)
rembg i input.png output.png

# Or use online tools: remove.bg
```

## Style Keywords

- `cartoon style` - friendly, colorful
- `pixel art` - retro 8-bit/16-bit
- `flat design` - minimal, clean
- `hand-painted` - textured, artistic
- `cel-shaded` - anime style
