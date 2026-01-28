AxeM_Hitbox 🪓

[![GitHub](https://img.shields.io/badge/author-Fonihm-blue)](https://github.com/Fonihm)

A powerful and flexible **hitbox module** for Roblox, designed for server-side use. Easily create customizable hitboxes for models with support for multiple touch modes, visual debugging, and cooldowns.

---

Features ✨

* Create hitboxes attached to any `BasePart`
* Configurable **size**, **color**, **offset**, and **visibility**
* Multiple **touch modes**: `single`, `cooldown`, or `always`
* **Cooldown support** between touches
* Ignore specific parts or models via **IgnoreList**
* Visual debug mode for easy testing
* Runtime setters for dynamic updates

---

Installation 🛠️

1. Clone or download this repository
2. Place `AxeMHitbox` in your `ServerScriptService` or appropriate folder
3. Require the module in your script:

```lua
local AxeM_Hitbox = require(path.to.AxeMHitbox)
```

---

Usage 📦

```lua
local hitbox = AxeM_Hitbox.new({
    AnchorPart = script.Parent,
    Size = Vector3.new(4, 4, 4),
    Visible = true,
    TouchMode = "cooldown",
    TouchCooldown = 1,
    OnModelTouched = function(model, hb, part)
        print(model.Name .. " touched the hitbox!")
    end
})

hitbox:Enable()
```

Runtime Setters

```lua
hitbox:SetSize(Vector3.new(6, 6, 6))
hitbox:SetColor(Color3.fromRGB(255, 0, 0))
hitbox:SetVisible(true)
hitbox:SetOffset(Vector3.new(0, 2, 0))
hitbox:AddIgnore(game.Workspace.IgnoreMe)
hitbox:RemoveIgnore(game.Workspace.IgnoreMe)
hitbox:SetTouchMode("always")
hitbox:SetTouchCooldown(2)
hitbox:SetOnModelTouched(function(model) print(model.Name) end)
```

---

API Reference 📖

* **Enable()** — Activates the hitbox
* **Disable()** — Deactivates the hitbox
* **Destroy()** — Cleans up and removes the hitbox
* **ResetTouches(model?)** — Resets touch state (specific model or all)
* **HasModelTouched(model)** — Checks if the model has already touched the hitbox

---

Parameters ⚙️

| Parameter        | Type                | Description                              |
| ---------------- | ------------------- | ---------------------------------------- |
| `AnchorPart`     | BasePart (required) | The part to attach the hitbox to         |
| `Size`           | Vector3             | Hitbox dimensions                        |
| `Offset`         | Vector3             | Position offset from anchor              |
| `Color`          | Color3              | Visual color                             |
| `Visible`        | boolean             | Show the hitbox visual                   |
| `TouchMode`      | string              | "single", "cooldown", or "always"        |
| `TouchCooldown`  | number              | Seconds between touches in cooldown mode |
| `OnModelTouched` | function            | Callback when a model touches the hitbox |
| `IgnoreList`     | table               | Parts/models to ignore                   |
| `Debug`          | boolean             | Enable visual debug                      |

---

License 📝

This project is open-source under the **MIT License**. Feel free to use, modify, and contribute!

---

**Author:** [Fonihm](https://github.com/Fonihm)
**Module Version:** 1.1
