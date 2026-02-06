---
name: free-3d-assets
description: Download CC0/free 3D assets from PolyHaven and Sketchfab into Blender. Use when user needs free textures, HDRIs, or 3D models for games. Triggers on "download free asset", "CC0 texture", "free 3d model", "polyhaven", "sketchfab asset".
---

# Free 3D Assets Downloader

Download CC0 and free 3D assets directly into Blender from multiple sources.

## Available Sources

| Source | Asset Types | License | Status Check |
|--------|-------------|---------|--------------|
| PolyHaven | HDRIs, Textures, Models | CC0 | `mcp__blender__get_polyhaven_status` |
| Sketchfab | 3D Models | Various (filter downloadable) | `mcp__blender__get_sketchfab_status` |

## Workflow

### 1. Check Integration Status

Before downloading, verify the source is enabled:

```
mcp__blender__get_polyhaven_status
mcp__blender__get_sketchfab_status
```

### 2. Search for Assets

**PolyHaven** (CC0 - always free):
```
mcp__blender__search_polyhaven_assets(asset_type, categories)
```
- `asset_type`: hdris, textures, models, all
- `categories`: optional filter (get list with `get_polyhaven_categories`)

**Sketchfab** (requires API key):
```
mcp__blender__search_sketchfab_models(query, downloadable=True)
```

### 3. Preview (Sketchfab only)

```
mcp__blender__get_sketchfab_model_preview(uid)
```

### 4. Download and Import

**PolyHaven**:
```
mcp__blender__download_polyhaven_asset(
    asset_id="asset_name",
    asset_type="textures",  # hdris, textures, models
    resolution="2k",        # 1k, 2k, 4k
    file_format="jpg"       # optional
)
```

**Sketchfab**:
```
mcp__blender__download_sketchfab_model(
    uid="model_uid",
    target_size=1.0  # size in meters for largest dimension
)
```

### 5. Apply Textures

After downloading a PolyHaven texture, apply to object:
```
mcp__blender__set_texture(object_name, texture_id)
```

## PolyHaven Asset Types

### HDRIs (944 assets)
Environment lighting and backgrounds. Categories: outdoor, indoor, studio, nature, urban.

### Textures (737 assets)
PBR materials. Categories: wood, metal, concrete, fabric, ground, brick, stone.

### Models (409 assets)
3D objects. Categories: furniture, plants, rocks, props.

## Common Patterns

### Game Environment Setup
1. Download HDRI for lighting: `download_polyhaven_asset("kloofendal_48d_partly_cloudy", "hdris", "2k")`
2. Download ground texture: `search_polyhaven_assets("textures", "ground")` then download
3. Download props: `search_polyhaven_assets("models", "rocks")` then download

### Character Props from Sketchfab
1. Search: `search_sketchfab_models("sword medieval", downloadable=True)`
2. Preview: `get_sketchfab_model_preview(uid)`
3. Download with size: `download_sketchfab_model(uid, target_size=1.2)` # 1.2m sword

## Resolution Guide

| Use Case | Recommended |
|----------|-------------|
| Game assets (mobile) | 1k |
| Game assets (PC) | 2k |
| Rendering/preview | 4k |

## Tips

- PolyHaven is 100% CC0 - no attribution required
- Sketchfab models have varying licenses - check before commercial use
- Always set `downloadable=True` when searching Sketchfab
- Use `target_size` for Sketchfab to get proper scale in Blender
