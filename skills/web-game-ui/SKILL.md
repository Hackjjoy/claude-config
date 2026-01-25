---
name: web-game-ui
description: Design and implement clean, beautiful web game UI/UX. Use when creating game menus, HUDs, inventories, dialogs, buttons, health bars, scoreboards, or any game interface elements. Triggers on "game UI", "game menu", "HUD design", "game interface", "game button", "health bar", "inventory UI".
---

# Web Game UI/UX Design

Create polished, responsive game interfaces using modern CSS and HTML. Focus on visual appeal, usability, and game-feel.

## Design Principles

### Visual Hierarchy
- **Primary actions**: Large, high-contrast, prominent position
- **Secondary actions**: Medium size, lower contrast
- **Info displays**: Clear but non-intrusive

### Game-Specific UX
- Immediate visual feedback on interactions
- Smooth transitions (150-300ms)
- Clear state indication (hover, active, disabled)
- Sound-ready class hooks for audio integration

### Color Psychology for Games
| Element | Recommended Colors |
|---------|-------------------|
| Health/Life | Red, Pink gradients |
| Energy/Mana | Blue, Cyan gradients |
| XP/Progress | Yellow, Gold gradients |
| Success | Green, Emerald |
| Danger/Warning | Orange, Red |
| Rare/Epic | Purple, Violet |
| Legendary | Gold with glow |

## UI Component Patterns

### Buttons

```css
.game-btn {
  position: relative;
  padding: 12px 32px;
  font-family: 'Press Start 2P', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.15s ease;
  box-shadow:
    0 4px 0 var(--btn-shadow-color),
    0 6px 12px rgba(0,0,0,0.3);
}

.game-btn:hover {
  transform: translateY(-2px);
  box-shadow:
    0 6px 0 var(--btn-shadow-color),
    0 8px 16px rgba(0,0,0,0.35);
}

.game-btn:active {
  transform: translateY(2px);
  box-shadow:
    0 2px 0 var(--btn-shadow-color),
    0 3px 6px rgba(0,0,0,0.25);
}

.game-btn--primary {
  --btn-shadow-color: #1a5f2a;
  background: linear-gradient(180deg, #4ade80 0%, #22c55e 100%);
  color: #052e16;
}

.game-btn--danger {
  --btn-shadow-color: #7f1d1d;
  background: linear-gradient(180deg, #f87171 0%, #ef4444 100%);
  color: #450a0a;
}
```

### Health/Progress Bars

```css
.game-bar {
  position: relative;
  height: 24px;
  background: linear-gradient(180deg, #1f2937 0%, #111827 100%);
  border-radius: 12px;
  border: 2px solid #374151;
  overflow: hidden;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.5);
}

.game-bar__fill {
  height: 100%;
  border-radius: 10px;
  transition: width 0.3s ease;
  position: relative;
}

.game-bar__fill::after {
  content: '';
  position: absolute;
  top: 2px;
  left: 4px;
  right: 4px;
  height: 6px;
  background: linear-gradient(180deg, rgba(255,255,255,0.4) 0%, transparent 100%);
  border-radius: 4px;
}

.game-bar--health .game-bar__fill {
  background: linear-gradient(180deg, #f87171 0%, #dc2626 50%, #b91c1c 100%);
}

.game-bar--mana .game-bar__fill {
  background: linear-gradient(180deg, #60a5fa 0%, #3b82f6 50%, #2563eb 100%);
}

.game-bar--xp .game-bar__fill {
  background: linear-gradient(180deg, #fbbf24 0%, #f59e0b 50%, #d97706 100%);
}
```

### Panels/Cards

```css
.game-panel {
  background: linear-gradient(180deg,
    rgba(30, 41, 59, 0.95) 0%,
    rgba(15, 23, 42, 0.98) 100%
  );
  border: 2px solid #334155;
  border-radius: 16px;
  padding: 24px;
  box-shadow:
    0 0 0 1px rgba(255,255,255,0.05),
    0 20px 40px rgba(0,0,0,0.5),
    inset 0 1px 0 rgba(255,255,255,0.1);
}

.game-panel__title {
  font-size: 18px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 2px;
  color: #f1f5f9;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 2px solid #334155;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}
```

### Inventory Slots

```css
.inventory-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));
  gap: 8px;
}

.inventory-slot {
  aspect-ratio: 1;
  background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
  border: 2px solid #334155;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.15s ease;
  position: relative;
}

.inventory-slot:hover {
  border-color: #60a5fa;
  box-shadow: 0 0 12px rgba(96, 165, 250, 0.3);
}

.inventory-slot--rare {
  border-color: #a855f7;
  box-shadow: 0 0 8px rgba(168, 85, 247, 0.3);
}

.inventory-slot--legendary {
  border-color: #fbbf24;
  box-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
  animation: legendary-glow 2s ease-in-out infinite;
}

@keyframes legendary-glow {
  0%, 100% { box-shadow: 0 0 12px rgba(251, 191, 36, 0.4); }
  50% { box-shadow: 0 0 20px rgba(251, 191, 36, 0.6); }
}

.inventory-slot__count {
  position: absolute;
  bottom: 2px;
  right: 4px;
  font-size: 12px;
  font-weight: 700;
  color: #f1f5f9;
  text-shadow:
    1px 1px 0 #000,
    -1px -1px 0 #000,
    1px -1px 0 #000,
    -1px 1px 0 #000;
}
```

### Modal/Dialog

```css
.game-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.2s ease;
}

.game-modal {
  background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
  border: 2px solid #475569;
  border-radius: 20px;
  padding: 32px;
  max-width: 480px;
  width: 90%;
  box-shadow:
    0 0 0 1px rgba(255,255,255,0.1),
    0 25px 50px rgba(0,0,0,0.6);
  animation: modalSlideIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(-20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}
```

### HUD Layout

```css
.game-hud {
  position: fixed;
  inset: 0;
  pointer-events: none;
  padding: 16px;
  z-index: 100;
}

.game-hud > * {
  pointer-events: auto;
}

.hud-top-left {
  position: absolute;
  top: 16px;
  left: 16px;
}

.hud-top-right {
  position: absolute;
  top: 16px;
  right: 16px;
}

.hud-bottom-left {
  position: absolute;
  bottom: 16px;
  left: 16px;
}

.hud-bottom-right {
  position: absolute;
  bottom: 16px;
  right: 16px;
}

.hud-bottom-center {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
}
```

### Score/Stats Display

```css
.game-stat {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: rgba(15, 23, 42, 0.9);
  border: 2px solid #334155;
  border-radius: 8px;
  font-family: 'Orbitron', 'Segoe UI', monospace;
}

.game-stat__icon {
  width: 24px;
  height: 24px;
}

.game-stat__value {
  font-size: 20px;
  font-weight: 700;
  color: #fbbf24;
  text-shadow: 0 0 8px rgba(251, 191, 36, 0.5);
}

.game-stat__value--animate {
  animation: scorePop 0.3s ease;
}

@keyframes scorePop {
  0% { transform: scale(1); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}
```

## Typography

### Recommended Font Pairings

**Pixel/Retro:**
```css
@import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap');
font-family: 'Press Start 2P', cursive;
```

**Futuristic/Sci-Fi:**
```css
@import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&display=swap');
font-family: 'Orbitron', sans-serif;
```

**Fantasy/RPG:**
```css
@import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700&display=swap');
font-family: 'Cinzel', serif;
```

**Clean Modern:**
```css
@import url('https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;600;700&display=swap');
font-family: 'Rajdhani', sans-serif;
```

## Animation Utilities

```css
/* Pulse for attention */
.pulse {
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}

/* Float for items */
.float {
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

/* Shake for damage/error */
.shake {
  animation: shake 0.4s ease;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  20%, 60% { transform: translateX(-4px); }
  40%, 80% { transform: translateX(4px); }
}

/* Glow for highlights */
.glow {
  animation: glow 2s ease-in-out infinite;
}

@keyframes glow {
  0%, 100% { filter: drop-shadow(0 0 4px currentColor); }
  50% { filter: drop-shadow(0 0 12px currentColor); }
}
```

## Workflow

1. **Identify UI needs**: Menu, HUD, inventory, dialog, etc.
2. **Choose style**: Match game aesthetic (pixel, modern, fantasy, sci-fi)
3. **Select components**: Pick relevant patterns from above
4. **Customize colors**: Adjust to game's color palette
5. **Add interactions**: Hover, active, disabled states
6. **Test responsiveness**: Ensure mobile/tablet compatibility
7. **Optimize**: Remove unused CSS, combine animations

## Best Practices

- Use CSS custom properties (variables) for theming
- Prefer `transform` and `opacity` for animations (GPU accelerated)
- Use `rem`/`em` units for scalable UI
- Include reduced-motion media query for accessibility
- Add touch-friendly sizes (min 44px tap targets)
- Use semantic HTML elements where possible
