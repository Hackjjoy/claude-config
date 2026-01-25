---
name: tpose-character
description: Generate T-pose character images from reference images for 3D modeling. Use when user wants to create T-pose sprites, prepare characters for 3D modeling, or convert character art to modeling references. Triggers on "generate tpose", "create t-pose", "character for 3d modeling".
---

# T-Pose Character Generator

Generate consistent T-pose character images from reference images for 3D modeling.

## Workflow

### Step 1: Analyze References

Read all images in `data/reference/` folder and identify for each character:
- Skin tone (dark/tan/fair)
- Hair color and style
- Eye color
- Outfit (top, bottom, shoes)
- Accessories

### Step 2: Art Direction

Consult with **web-game-art-director** skill to:
1. Establish consistent art style (Anime-Adjacent, Genshin Impact style)
2. Assign character names based on visual personality
3. Confirm color palette

### Step 3: Generate T-Pose

Use **nanobanana** skill for each character with this prompt template:

```
single anime style female character in T-pose,
[ethnicity] woman, [skin tone] skin,
[hair description], [eye color] eyes, [expression],
wearing [top] and [bottom] and [shoes],
slim athletic body, 7 head tall proportions,
both arms extended straight horizontally at shoulder level,
palms down, legs together standing straight,
front view, full body from head to toe,
cel-shaded, clean black outlines, flat anime colors,
cute anime girl style similar to Genshin Impact
```

**Command:**
```bash
cd ~/.claude/skills/nanobanana && node scripts/generate-image.mjs "<prompt>" <output_path>
```

**Output path format:** `data/tpose/tpose_{name}_v{version}.png`

### Step 4: Quality Check

Review each image against these criteria:

| Check | Pass Criteria |
|-------|---------------|
| T-Pose | Arms at exactly 90 degrees horizontal |
| Proportions | 7 head tall, matches other characters |
| Art Style | Anime cel-shaded, clean outlines |
| Completeness | Full body visible head to feet |
| Background | Transparent, no color residue |
| View | Single front view only |

### Step 5: Iterate

If quality check fails:
1. Increment version (v1 -> v2 -> v3...)
2. Adjust prompt to fix specific issue
3. Regenerate and re-check

## Prompt Fixes for Common Issues

| Issue | Prompt Addition |
|-------|-----------------|
| Chibi proportions | Add "7 head tall proportions, adult body" |
| Multiple views | Add "single front view only, one image" |
| Cut-off body | Add "full body from head to toe visible" |
| Arms not horizontal | Add "arms extended straight out at exactly 90 degrees" |
| Green fringe | Regenerate (rembg artifact, may need manual cleanup) |

## Art Style Spec

| Attribute | Value |
|-----------|-------|
| Style | Stylized Realism (Anime-Adjacent) |
| Reference | Genshin Impact, Blue Protocol |
| Proportions | 7 head tall |
| Face | Large eyes, small nose, soft features |
| Shading | Cel-shaded, clean black outlines |
| Colors | Flat anime colors |

## Output

- **Location:** `data/tpose/`
- **Format:** PNG with transparent background
- **Naming:** `tpose_{character_name}_v{version}.png`
