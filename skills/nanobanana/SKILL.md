---
name: nanobanana
description: Generate game asset images with transparent backgrounds using Gemini API. Use when creating sprites, icons, items, characters, textures for games. Triggers on "generate game asset", "create sprite", "make game icon", "generate 2D art", "create game image", "make character sprite", "generate texture sprite".
---

# Nanobanana - Game Asset Image Generator

Generate 2D game assets with Gemini API. Automatically removes background using rembg.

## Quick Start

```bash
node scripts/generate-image.mjs "<subject>" [output.png]
```

Requires:
- `GEMINI_API_KEY` environment variable
- `rembg` installed (`pip install rembg`)

## Workflow

1. User describes the game asset they need
2. Run the generation script with the subject
3. Gemini generates image with green background
4. rembg automatically removes background
5. Final PNG with transparent background is saved

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

## Style Keywords

- `cartoon style` - friendly, colorful
- `pixel art` - retro 8-bit/16-bit
- `flat design` - minimal, clean
- `hand-painted` - textured, artistic
- `cel-shaded` - anime style
