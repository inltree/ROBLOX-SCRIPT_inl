# Vigil UI Library – Documentation

> **Version**: 1.7 (SafeLoad V1)  
> **Author**: doom.dtw / alohabeach  
> **Environment**: Roblox Lua (Script Executor)  
> **Features**: Safe loading, tween animations, draggable windows, modular components  

---

## ✨ Feature Overview

- **Safe Loading** – Bypasses most CoreGui detections (e.g., Peroxide, Da Hood) via `SafeLoad`
- **Tween Animations** – All transitions use TweenService for smooth animation
- **Window Dragging** – Windows support mouse drag movement
- **Key Toggle** – Bind a key to show/hide the UI (requires binding the `ToggleKey` yourself)
- **Modular Architecture** – Clear hierarchy: Window → Page → Section → Component
- **Rich Components**:
  - Checkpoints (status log)
  - Label (multiline text)
  - Button
  - Keybind (keybinding)
  - Slider
  - Textbox (text input)
  - Dropdown (single/multi-select)
  - Toggle (switch)

---

## 🔧 Quick Start

### 1. Loading the Library

Upload the `vigil.luau` source to a direct-link accessible location, then load it using `loadstring`:

```lua
local Vigil = loadstring(game:HttpGet("https://raw.githubusercontent.com/inltree/ROBLOX-SCRIPT_inl/main/Script_UI_Library/Vigil_Library/Vigil_Library.luau"))()
```

### 2. Creating a Window

```lua
local Window = Vigil.new("My Script", {
    Anchor = Vector2.new(0.5, 0.5),          -- anchor point
    Size = UDim2.new(0, 600, 0, 526),        -- window size
    Pos = UDim2.new(0.5, 0, 0.5, 0)          -- initial position
})
```

### 3. Initialization (Inject into UI)

```lua
Vigil.init()  -- Inserts UI into CoreGui (or falls back to PlayerGui)
```

The UI is now visible.

---

## 📚 Architecture Hierarchy

```
Vigil (Library)
 └── Window (new)
      ├── Page (addPage)
      │    └── Section (addSection)
      │         ├── addCheckpoints(...)
      │         ├── addLabel(...)
      │         ├── addButton(...)
      │         ├── addKeybind(...)
      │         ├── addSlider(...)
      │         ├── addTextbox(...)
      │         ├── addDropdown(...)
      │         └── addToggle(...)
      └── ... more pages
```

---

## 🪟 Window

### Creating a Window

```lua
Vigil.new(title, meta?)
```

| Parameter | Type | Default | Description |
|-|-|-|-|
| title | string | Required | Window title |
| meta | table | See below | Optional configuration table |

**meta options**:

| Key | Type | Default | Description |
|-|-|-|-|
| Anchor | Vector2 | (0.5, 0.5) | Window anchor point |
| Size | UDim2 | (0,600,0,526) | Window size |
| Pos | UDim2 | (0.809,0,0.75,0) | Window initial position |

### Window Methods

#### `Window:toggle()`
Manually toggles window visibility (with animation).

#### `Window:setPosition(position)`
Sets the window position.  
`position`: UDim2

#### `Window:getPosition()`
Returns the current UDim2 position of the window.

#### `Window:addPage(name)`
Adds a new page, returns a `Page` object.

---

## 📄 Page

Created via `Window:addPage("Page Name")`.

### Page Methods

#### `Page:open()`
Activates the page (switches display with animation).

#### `Page:addSection(sectionName)`
Adds a section to the current page, returns a `Section` object.

---

## 📦 Section

All UI components are added to a Section.

---

## 🧩 Component Details

### 1. Adding a Status Log – `addCheckpoints`

```lua
local checkpoints = section:addCheckpoints({
    title = "Status Log",               -- reserved, not yet used
    xAlignment = Enum.TextXAlignment.Left, -- text alignment
    maxHeight = 150,                     -- max height of scrolling frame (pixels)
})
```

#### Checkpoints Methods

- **`checkpoints:add(message, colorVariant?)`**  
  Adds a log entry.  
  `message`: string  
  `colorVariant`: optional, defaults to `"default"`. Available variants:

  | Variant | Color | Description|
  |-|-|-|
  | `"default"` | White | Normal message|
  | `"success"` | Green | Success |
  | `"destructive"` | Red | Error/destructive|
  | `"warning"` | Yellow/Orange | Warning |
  | `"info"` | Blue | Informational |
  | `"muted"` | Gray | Dimmed |

  Duplicate identical messages are merged and a count is appended, e.g., `"Connected (3x)"`.

- **`checkpoints:clear()`**  
  Clears all log entries.

**Example**:
```lua
checkpoints:add("Script loaded", "success")
checkpoints:add("Player joined", "info")
checkpoints:add("Error: invalid data", "destructive")
```

---

### 2. Adding a Label – `addLabel`

```lua
section:addLabel({
    title = "Welcome!",
    xAlignment = Enum.TextXAlignment.Left,  -- optional, text alignment
})
```

- `title` supports multiline text (auto-adjusts height).
- The text content can be updated via `Label:updateText(newText)`.

Returns a **Label** object:
- `Label:updateText(text)` – modifies the label text.

---

### 3. Adding a Button – `addButton`

```lua
section:addButton({
    title = "Click Me",
    callback = function()
        print("Button clicked!")
    end
})
```

Includes press/release scaling feedback animation.

---

### 4. Adding a Keybind – `addKeybind`

```lua
local keybind = section:addKeybind({
    title = "Toggle UI",
    default = Enum.KeyCode.RightControl,   -- default key
    mode = "click",   -- "click" / "hold" / "toggle"
    blacklist = { Enum.KeyCode.Escape },   -- additional forbidden keys
    on_update = function(newKey)
        print("Key changed to", newKey)
    end,
    on_press = function(key)
        print("Pressed", key)
    end,
    on_release = function(key)  -- only effective when mode="hold"
        print("Released", key)
    end
})
```

- Click the keybind button to enter edit mode; press a new key to complete binding.
- Supports both keyboard keys and mouse buttons (MouseButton1, MouseButton2).
- `mode`:
  - `"click"` – triggers `on_press` once on press.
  - `"hold"` – continuously triggers `on_press` while held, `on_release` on release.
  - `"toggle"` – toggles state on press; `on_press` receives a boolean.

---

### 5. Adding a Slider – `addSlider`

```lua
section:addSlider({
    title = "Volume",
    default = 50,
    min = 0,
    max = 100,
    decimals = false,   -- true retains two decimal places
    prefix = "",
    suffix = "%",
    callback = function(value)
        print("Volume:", value)
    end
})
```

**Note**: `default` cannot be less than `min`; if it is, it will be automatically adjusted to `min`.

---

### 6. Adding a Textbox – `addTextbox`

```lua
section:addTextbox({
    title = "Username",
    default = "Player",
    callback = function(text)
        print("Username set to:", text)
    end
})
```

The callback fires when the textbox loses focus.

---

### 7. Adding a Dropdown – `addDropdown`

```lua
local dropdown = section:addDropdown({
    title = "Select Fruit",
    default = "Apple",
    list = {"Apple", "Banana", "Cherry"},
    mode = "single",   -- "single" or "multi"
    callback = function(selected)
        print("Selected:", selected)
    end
})
```

- When `mode = "single"`, the callback receives the selected string.
- When `mode = "multi"`, the callback receives an array of selected items.

#### Dropdown Methods

- **`dropdown:updateList(newList, instantAnimation?)`**  
  Dynamically replaces the dropdown list, optionally skipping animation.

**Example (multi-select)**:
```lua
local dd = section:addDropdown({
    title = "Perks",
    mode = "multi",
    list = {"Speed", "Jump", "Health"},
    callback = function(selected)
        print("Active perks:", table.concat(selected, ", "))
    end
})
```

---

### 8. Adding a Toggle – `addToggle`

```lua
section:addToggle({
    title = "God Mode",
    toggled = false,
    callback = function(state)
        print("God Mode:", state)
    end
})
```

#### Toggle Methods

- **`Toggle:update(newMeta)`**  
  Dynamically changes title, toggle state and triggers the callback.  
  The `newMeta` table can include `title`, `toggled`, `callback`, etc.

**Example**:
```lua
local godToggle = section:addToggle({...})
godToggle:update({
    title = "Immortal",
    toggled = true,
})
```

---

## ⚙️ Advanced Notes

### Safe Loading (SafeLoad)

- All UI instance names are replaced with random Chinese characters (`EncryptedString`) to reduce detection risk.
- Attempts to insert into `CoreGui`; if permission is denied, falls back to `PlayerGui`.

### Custom Window Dragging

Window dragging logic is built-in. Press and drag within the window area to move it.

### Colors & Styling

Component colors are hardcoded. To change them, search for `Color3.fromRGB` in the source and replace or modify accordingly.

---

## 🧪 Complete Example Script

```lua
local Vigil = loadstring(game:HttpGet("https://raw.githubusercontent.com/inltree/ROBLOX-SCRIPT_inl/main/Script_UI_Library/Vigil_Library/Vigil_Library.luau"))()

local Window = Vigil.new("Vigil Demo", {
    Pos = UDim2.new(0.5, -300, 0.5, -263)
})

Vigil.init()

local MainPage = Window:addPage("Main")
local Section = MainPage:addSection("Controls")

Section:addLabel({ title = "Welcome to Vigil UI" })

Section:addButton({
    title = "Say Hello",
    callback = function()
        print("Hello, Roblox!")
    end
})

local checkpoints = Section:addCheckpoints({
    xAlignment = Enum.TextXAlignment.Left,
    maxHeight = 120
})
checkpoints:add("Script executed", "success")

Section:addToggle({
    title = "Auto Farm",
    toggled = false,
    callback = function(state)
        checkpoints:add("Auto Farm: " .. tostring(state), state and "success" or "destructive")
    end
})

Section:addSlider({
    title = "Walk Speed",
    default = 16,
    min = 10,
    max = 100,
    suffix = " studs",
    callback = function(val)
        -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

Section:addDropdown({
    title = "Weapon",
    default = "Sword",
    list = {"Sword", "Gun", "Fist"},
    mode = "single",
    callback = print
})

Section:addKeybind({
    title = "Teleport",
    default = Enum.KeyCode.T,
    mode = "click",
    on_press = function()
        checkpoints:add("Teleport key pressed", "info")
    end
})

-- Open the first page
MainPage:open()
```

---

## 📜 License

MIT / Free to use. Please retain original author attribution when modifying or distributing.

> **Note**: This UI library's internal variable names have been optimized to snake_case (e.g., `Clone_Service`, `Easing_Style`). External API remains unchanged and unaffected.
