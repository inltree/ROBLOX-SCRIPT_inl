# Vigil UI Library – 使用文档

> **版本**: 1.7 (SafeLoad V1)  
> **作者**: doom.dtw alohabeach  
> **适用环境**: Roblox Lua (Script Executor)  
> **特点**: 安全加载、补间动画、拖拽窗口、模块化组件  

---

## ✨ 特性概览

- **安全加载** – 通过 `SafeLoad` 绕过大多数 CoreGui 检测（如 Peroxide, Da Hood）
- **补间动画** – 所有过渡使用 TweenService 实现平滑动画
- **窗口拖拽** – 窗口支持鼠标拖拽移动
- **密钥切换** – 可绑定按键显示/隐藏 UI（需自行绑定 `ToggleKey`）
- **模块化架构** – Window → Page → Section → 组件 的清晰层级
- **丰富组件**:
  - Checkpoints (状态日志)
  - Label (多行文本)
  - Button (按钮)
  - Keybind (按键绑定)
  - Slider (滑动条)
  - Textbox (文本输入)
  - Dropdown (单/多选下拉)
  - Toggle (开关)

---

## 🔧 快速开始

### 1. 加载库

将 `vigil.lua` 源码上传至可直链访问的位置，然后使用 `loadstring` 加载：

```lua
local Vigil = loadstring(game:HttpGet("https://raw.githubusercontent.com/inltree/ROBLOX-SCRIPT_inl/main/Script_UI_library/Vigil_Library/Vigil_Library.luau"))()
```

### 2. 创建窗口

```lua
local Window = Vigil.new("My Script", {
    Anchor = Vector2.new(0.5, 0.5),          -- 锚点
    Size = UDim2.new(0, 600, 0, 526),        -- 窗口尺寸
    Pos = UDim2.new(0.5, 0, 0.5, 0)          -- 初始位置
})
```

### 3. 初始化（加载到界面）

```lua
Vigil.init()  -- 将 UI 插入 CoreGui（或 PlayerGui 降级）
```

此时 UI 已可见。

---

## 📚 架构分层

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
      └── ... 更多页面
```

---

## 🪟 Window – 窗口

### 创建窗口

```lua
Vigil.new(title, meta?)
```

| 参数 | 类型 | 默认值 | 说明 |
|-|-|-|-|
| title | string | 必填 | 窗口标题 |
| meta | table | 见下方 | 可选的配置表 |

**meta 选项**:

| 键 | 类型 | 默认值 | 说明 |
|-|-|-|-|
| Anchor | Vector2 | (0.5, 0.5) | 窗口锚点 |
| Size | UDim2 | (0,600,0,526) | 窗口大小 |
| Pos | UDim2 | (0.809,0,0.75,0) | 窗口初始位置 |

### 窗口方法

#### `Window:toggle()`
手动切换窗口显示/隐藏（带动画）。

#### `Window:setPosition(position)`
设置窗口位置。  
`position`: UDim2

#### `Window:getPosition()`
返回当前窗口的 UDim2 位置。

#### `Window:addPage(name)`
添加一个新页面，返回 `Page` 对象。

---

## 📄 Page – 页面

通过 `Window:addPage("Page Name")` 创建。

### 页面方法

#### `Page:open()`
激活该页面（切换显示，带动画）。

#### `Page:addSection(sectionName)`
向当前页面添加一个区块，返回 `Section` 对象。

---

## 📦 Section – 区块

所有 UI 组件都添加到 Section 内。

---

## 🧩 组件详解

### 1. 添加状态日志 – `addCheckpoints`

```lua
local checkpoints = section:addCheckpoints({
    title = "Status Log",               -- 预留，暂未使用
    xAlignment = Enum.TextXAlignment.Left, -- 文本对齐
    maxHeight = 150,                     -- 滚动框最大高度（像素）
})
```

#### Checkpoints 方法

- **`checkpoints:add(message, colorVariant?)`**  
  添加一条日志。  
  `message`: string  
  `colorVariant`: 可选，默认为 `"default"`。可用变体：

  | 变体 | 颜色 | 说明 |
  |-|-|-|
  | `"default"` | 白色 | 普通消息 |
  | `"success"` | 绿色 | 成功 |
  | `"destructive"` | 红色 | 错误/破坏性 |
  | `"warning"` | 黄/橙色 | 警告 |
  | `"info"` | 蓝色 | 信息 |
  | `"muted"` | 灰色 | 弱化 |

  重复相同的消息会合并显示，并在末尾附加出现次数，如 `"Connected (3x)"`。

- **`checkpoints:clear()`**  
  清空所有日志。

**示例**:
```lua
checkpoints:add("Script loaded", "success")
checkpoints:add("Player joined", "info")
checkpoints:add("Error: invalid data", "destructive")
```

---

### 2. 添加标签 – `addLabel`

```lua
section:addLabel({
    title = "Welcome!",
    xAlignment = Enum.TextXAlignment.Left,  -- 可选，文本对齐
})
```

- `title` 支持多行文本（自动调整高度）。
- 可通过 `Label:updateText(newText)` 更新文本内容。

**返回** `Label` 对象：
- `Label:updateText(text)` – 修改标签文字。

---

### 3. 添加按钮 – `addButton`

```lua
section:addButton({
    title = "Click Me",
    callback = function()
        print("Button clicked!")
    end
})
```

按下/抬起有缩放反馈动画。

---

### 4. 添加按键绑定 – `addKeybind`

```lua
local keybind = section:addKeybind({
    title = "Toggle UI",
    default = Enum.KeyCode.RightControl,   -- 默认按键
    mode = "click",   -- "click" / "hold" / "toggle"
    blacklist = { Enum.KeyCode.Escape },   -- 额外禁止的按键
    on_update = function(newKey)
        print("Key changed to", newKey)
    end,
    on_press = function(key)
        print("Pressed", key)
    end,
    on_release = function(key)  -- 仅在 mode="hold" 时有效
        print("Released", key)
    end
})
```

- 点击按键按钮进入编辑状态，按下新按键完成绑定。
- 支持键盘按键和鼠标按键（MouseButton1, MouseButton2）。
- `mode`:
  - `"click"` – 按下时触发一次 `on_press`。
  - `"hold"` – 按下时持续触发 `on_press`（直到松开），松开触发 `on_release`。
  - `"toggle"` – 按下切换状态，`on_press` 接收布尔值。

---

### 5. 添加滑动条 – `addSlider`

```lua
section:addSlider({
    title = "Volume",
    default = 50,
    min = 0,
    max = 100,
    decimals = false,   -- true 时保留两位小数
    prefix = "",
    suffix = "%",
    callback = function(value)
        print("Volume:", value)
    end
})
```

**注意**：`default` 不能小于 `min`，若小于则自动调整为 `min`。

---

### 6. 添加文本输入框 – `addTextbox`

```lua
section:addTextbox({
    title = "Username",
    default = "Player",
    callback = function(text)
        print("Username set to:", text)
    end
})
```

失去焦点时触发回调。

---

### 7. 添加下拉菜单 – `addDropdown`

```lua
local dropdown = section:addDropdown({
    title = "Select Fruit",
    default = "Apple",
    list = {"Apple", "Banana", "Cherry"},
    mode = "single",   -- "single" 或 "multi"
    callback = function(selected)
        print("Selected:", selected)
    end
})
```

- `mode = "single"` 时，回调接收选中的字符串。
- `mode = "multi"` 时，回调接收包含已选项的数组。

#### Dropdown 方法

- **`dropdown:updateList(newList, instantAnimation?)`**  
  动态替换下拉列表，并可选择是否跳过动画。

**示例（多选）**:
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

### 8. 添加开关 – `addToggle`

```lua
section:addToggle({
    title = "God Mode",
    toggled = false,
    callback = function(state)
        print("God Mode:", state)
    end
})
```

#### Toggle 方法

- **`Toggle:update(newMeta)`**  
  动态修改标题、开关状态并触发回调。  
  `newMeta` 表可包含 `title`, `toggled`, `callback` 等。

**示例**:
```lua
local godToggle = section:addToggle({...})
godToggle:update({
    title = "Immortal",
    toggled = true,
})
```

---

## ⚙️ 高级说明

### 安全加载 (SafeLoad)

- UI 所有实例的名称会被随机中文字符替换（`EncryptedString`），降低被检测风险。
- 尝试插入到 `CoreGui`，若无权限则回退到 `PlayerGui`。

### 自定义窗口拖拽

窗口拖拽逻辑已内置，鼠标在窗口范围内按下即可拖动。

### 颜色与样式

组件颜色均为硬编码，如需更改请在源码中搜索 `Color3.fromRGB` 进行批量替换或修改。

---

## 🧪 完整示例脚本

```lua
local Vigil = loadstring(game:HttpGet("https://raw.githubusercontent.com/inltree/ROBLOX-SCRIPT_inl/main/Script_UI_library/Vigil_Library/Vigil_Library.luau"))()

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

-- 打开第一个页面
MainPage:open()
```

---

## 📜 许可证

MIT / 自由使用。修改和分发请保留原作者署名。

> **提示**：本 UI 库默认变量名已优化为大蛇形命名（`Clone_Service`, `Easing_Style` 等），外部 API 不变，不影响使用。
