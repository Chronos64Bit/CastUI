# CastUI

> Glass UI library for Roblox Luau
> Developed by **The Ventryx Company**

CastUI is a frosted-glass UI library built from scratch to replace bulky legacy libraries (like Rayfield), with a modular architecture and zero telemetry.

---

## Key Features

- Deep frosted glass surfaces (`0.15` opacity), subtle 1px translucent borders, glowing accents, and modern typography.
- Performance:
  - Pre-cached `TweenInfo` presets (zero GC churn during hot loops).
  - Single-pass instance constructor (`Creator.New`).
  - Automatic memory cleanup and proper connection disconnects.
  - In-memory Lucide icon database (no HTTP latency on render).
- Architecture:
  - Modular source files organized by domain in `src/`.
  - Python bundler (`build.py`) that compiles everything into a standalone `dist/CastUI.lua` and `main.lua`.
- Elements:
  - Windows (draggable, minimizable, mobile floating toggle button, global keybind).
  - Tabs (sidebar navigation, Lucide icons, active indicator pills).
  - Buttons (hover glow, click micro-animations, description, icons).
  - Toggles (smooth pill switch with animated thumb).
  - Sliders (interactive drag bar + editable text input box).
  - Dropdowns (single & multi-select with search and check indicators).
  - Text Inputs (focus ring, numeric filter, finished-only mode).
  - Keybinds (interactive key recording, hold/toggle modes).
  - Colorpickers (real-time HSV canvas + hue bar + hex input).
  - Sections & Paragraphs (styled headers and informational cards).
  - Toast Notifications (progress countdown bar, dismiss timer, action buttons).
  - Key System Modal (glass auth dialog, key validation, auto-save to disk).
  - Configuration Engine (JSON flag saving/loading via executor filesystem).

---

## Repository Structure

```
cast/
├── src/                          # Modular Luau Source Code
│   ├── Init.luau                 # Entrypoint exporting public CastUI API
│   ├── Services.luau             # Safe cloneref service wrapper & gethui resolver
│   ├── Theme.luau                # Modern Glass tokens & reactive theme system
│   ├── Icons.luau                # Pre-indexed Lucide icon asset mapping
│   ├── Utilities/
│   │   ├── Creator.luau          # Fast instance constructor
│   │   ├── Tween.luau            # Pre-cached animation engine
│   │   ├── Drag.luau             # Cross-platform draggable frame controller
│   │   └── Config.luau           # Fast JSON config & flag manager
│   ├── Components/
│   │   ├── Window.luau           # Main acrylic glass window frame
│   │   ├── Tab.luau              # Tab buttons & scrollable element containers
│   │   ├── Notification.luau     # Toast notifications with actions
│   │   └── KeySystem.luau        # Key authentication modal
│   └── Elements/
│       ├── Button.luau           # Glass button
│       ├── Toggle.luau           # Switch toggle
│       ├── Slider.luau           # Precision slider
│       ├── Dropdown.luau         # Single/multi dropdown
│       ├── Input.luau            # Text input field
│       ├── Keybind.luau          # Keybind listener
│       ├── Colorpicker.luau      # Real-time HSV colorpicker
│       ├── Section.luau          # Divider & section title
│       └── Paragraph.luau        # Informational card
├── dist/
│   └── CastUI.lua                # Compiled single-file bundle ready for loadstring
├── main.lua                      # Root distribution file
├── example.lua                   # Full showcase demonstration script
├── build.py                      # Automated compilation bundler
└── rayfield_reference.lua        # Original Rayfield reference copy
```

---

## Quick Start

### 1. Using in Roblox Executor / Studio
```lua
local CastUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/CastUI/main/dist/CastUI.lua"))()

local Window = CastUI.CreateWindow({
    Title = "My Hub",
    SubTitle = "v1.0",
    Size = UDim2.new(0, 620, 0, 420),
    ToggleKey = Enum.KeyCode.RightControl
})

local Tab = Window:CreateTab({
    Title = "Combat",
    Icon = "crosshair"
})

Tab:AddToggle({
    Title = "Aimbot Enabled",
    Default = false,
    Flag = "AimbotFlag",
    Callback = function(state)
        print("Aimbot:", state)
    end
})

Tab:AddSlider({
    Title = "Smoothness",
    Min = 1,
    Max = 20,
    Default = 5,
    Flag = "SmoothnessFlag",
    Callback = function(val)
        print("Smoothness:", val)
    end
})
```

---

## Building the Library

Whenever you edit files inside `src/`, compile the distribution bundle by running:

```bash
python build.py
```

This compiles all modules into [dist/CastUI.lua](file:///e:/cast/dist/CastUI.lua) and [main.lua](file:///e:/cast/main.lua).

---

## Credits
- **The Ventryx Company** — Design, Architecture & Programming
