# Game UI Patterns

Detailed UI component patterns for web games.

## Buttons

### Standard Game Button
```css
.game-btn {
  padding: 12px 24px;
  font-family: var(--font-display);
  font-size: 14px;
  border: none;
  border-radius: 4px;
  background: var(--color-primary);
  color: var(--color-text);
  cursor: pointer;
  transition: transform 0.1s ease, box-shadow 0.1s ease;
  box-shadow: 0 4px 0 var(--color-secondary);
}

.game-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 0 var(--color-secondary);
}

.game-btn:active {
  transform: translateY(2px);
  box-shadow: 0 2px 0 var(--color-secondary);
}
```

### Pixel Button
```css
.pixel-btn {
  padding: 8px 16px;
  font-family: 'Press Start 2P', monospace;
  font-size: 12px;
  background: var(--color-primary);
  color: white;
  border: 4px solid;
  border-color: #fff #666 #666 #fff;
  cursor: pointer;
  image-rendering: pixelated;
}

.pixel-btn:active {
  border-color: #666 #fff #fff #666;
}
```

## Health Bars

### Classic Bar
```css
.health-bar {
  width: 200px;
  height: 20px;
  background: var(--color-danger);
  border: 2px solid #000;
  border-radius: 4px;
  overflow: hidden;
}

.health-bar-fill {
  height: 100%;
  background: linear-gradient(180deg, #4CAF50 0%, #2E7D32 100%);
  transition: width 0.3s ease;
}
```

### Segmented Hearts
```css
.hearts-container {
  display: flex;
  gap: 4px;
}

.heart {
  width: 24px;
  height: 24px;
  background: var(--color-danger);
  clip-path: path('M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z');
}

.heart.empty {
  background: var(--color-muted);
}
```

## Score Display

### Arcade Style
```css
.score-display {
  font-family: 'Press Start 2P', monospace;
  font-size: 16px;
  color: var(--color-accent);
  text-shadow: 2px 2px 0 #000;
  letter-spacing: 2px;
}

.score-label {
  font-size: 10px;
  color: var(--color-text);
  margin-bottom: 4px;
}
```

### Animated Counter
```css
.score-counter {
  font-variant-numeric: tabular-nums;
  transition: transform 0.1s ease;
}

.score-counter.bump {
  transform: scale(1.2);
}
```

## Dialog/Modal

### Game Dialog
```css
.game-dialog {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: var(--color-surface);
  border: 4px solid var(--color-primary);
  border-radius: 8px;
  padding: 24px;
  min-width: 300px;
  box-shadow: 0 0 0 4px rgba(0,0,0,0.5);
}

.dialog-title {
  font-family: var(--font-display);
  font-size: 18px;
  text-align: center;
  margin-bottom: 16px;
}

.dialog-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.7);
  backdrop-filter: blur(4px);
}
```

## Menu Layouts

### Main Menu
```css
.main-menu {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 40px;
}

.game-title {
  font-family: var(--font-display);
  font-size: 48px;
  text-shadow: 4px 4px 0 var(--color-secondary);
  margin-bottom: 40px;
}

.menu-btn {
  width: 200px;
  text-align: center;
}
```

### Pause Menu
```css
.pause-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.8);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
}

.pause-title {
  font-family: var(--font-display);
  font-size: 32px;
  color: var(--color-text);
}
```

## Notifications/Toasts

### Achievement Popup
```css
.achievement {
  position: fixed;
  top: 20px;
  right: 20px;
  background: var(--color-surface);
  border: 2px solid var(--color-accent);
  border-radius: 8px;
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  animation: slideIn 0.3s ease, slideOut 0.3s ease 2.7s;
}

@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@keyframes slideOut {
  from { transform: translateX(0); opacity: 1; }
  to { transform: translateX(100%); opacity: 0; }
}
```

## Visual Effects

### Screen Shake
```css
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

.shake {
  animation: shake 0.1s ease-in-out 3;
}
```

### Damage Flash
```css
@keyframes damageFlash {
  0%, 100% { filter: none; }
  50% { filter: brightness(2) saturate(0) sepia(1) hue-rotate(-50deg) saturate(6); }
}

.damage {
  animation: damageFlash 0.1s ease 2;
}
```

### Collect Particle
```css
@keyframes collectPop {
  0% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.5); opacity: 0.8; }
  100% { transform: scale(0); opacity: 0; }
}

.collect-effect {
  animation: collectPop 0.3s ease-out forwards;
}
```

## Loading States

### Pixel Loader
```css
.pixel-loader {
  width: 64px;
  height: 16px;
  background: var(--color-surface);
  border: 2px solid var(--color-primary);
  position: relative;
  overflow: hidden;
}

.pixel-loader::after {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: 30%;
  background: var(--color-primary);
  animation: load 1s ease-in-out infinite;
}

@keyframes load {
  0% { left: -30%; }
  100% { left: 100%; }
}
```
