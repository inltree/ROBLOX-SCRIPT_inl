# Notification Library

First, you need to load the library

```lua
local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/inltree/ROBLOX-SCRIPT_inl/main/Script_UI_library/Notification_Library/Notification_Library.luau"))()
```

Then you can use the `SendNotification` function to send a notification.

Available modes:
- `Success`
- `Warning`
- `Error`
- `Info`

You can send a notification like this:
```lua
NotificationLibrary:SendNotification("Info", "I'm a cool message", 3)
--NotificationLibrary:SendNotification(theme, message content, duration (seconds))
```

Example using all themes:
```lua
NotificationLibrary:SendNotification("Success", "I'm a cool message", 3)

NotificationLibrary:SendNotification("Warning", "I'm a cool message", 3)

NotificationLibrary:SendNotification("Error", "I'm a cool message", 3)

NotificationLibrary:SendNotification("Info", "I'm a cool message", 3)
```
