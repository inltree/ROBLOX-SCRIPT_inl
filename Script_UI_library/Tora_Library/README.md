# Tora Library
## Simple UI library. Features a clean and stylish interface.

- Made by Tora Is Me
- Github: [https://github.com/liebertsx/Tora-Library/](https://github.com/liebertsx/Tora-Library/)

### Setup the Library

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/inltree/ROBLOX-SCRIPT_inl/main/Script_UI_library/Tora_Library/Tora_Library.lua",true))()
```

### Adding a Tab

```lua
local tab = library:CreateWindow("Your Title")
```

### Adding a Folder

```lua
local folder = tab:AddFolder("Folder")
```

### Adding a Button

```lua
folder:AddButton({
    text = "Click Me",
    flag = "button",
    callback = function()
        print("hello world")
    end
})
```

### Adding a Toggle

```lua
folder:AddToggle({
    text = "Toggle",
    flag = "toggle",
    callback = function(v)
        print(v)
    end
})
```

### Adding a Label

```lua
folder:AddLabel({
    text = "This is cool!",
    type = "label"
})
```

### Adding a Slider

```lua
folder:AddSlider({
    text = "Field of View",
    min = 70,
    max = 170,
    dual = true,
    type = "slider",
    callback = function(v)
        print(v)
    end
})
```

### Adding a Color Picker

```lua
folder:AddColor({
    text = "Color Picker",
    flag = "color",
    type = "color",
    callback = function(v)
        print(v)
    end
})
```

### Adding a Dropdown

```lua
folder:AddList({
    text = "Color",
    values = {"Red", "Green", "Blue"},
    callback = function(value)
        print("Selected color:", value)
    end,
    open = false,
    flag = "color_option"
})
```

### Adding a Bind

```lua
folder:AddBind({
    text = "Bind",
    key = "X",
    hold = false,
    callback = function()
    end
})
```

### Close the Library

```lua
library:Close()
```

### Final Initialization (REQUIRED OR THE UI WILL NOT SHOW)

```lua
library:Init()
```

### Credits: Tora Is Me
