🪓 AxeM_Hitbox v1.1

A flexible and easy‑to‑use Hitbox Module for Roblox — perfect for combat systems, interactive objects, or any scenario where you need to detect when models intersect a zone!

---

✨ What It Does

AxeM_Hitbox allows you to create and control hitboxes in Roblox with:

- Multiple touch modes (single, cooldown, always)
- Optional visual hitbox with color & transparency
- Simple runtime API for dynamic control
- Ignore lists to skip specific parts/models
- Safe detection using GetPartBoundsInBox
- Automatic filtering of dead humanoids

---

🔧 Constructor Parameters

Parameter                | Type      | Description
------------------------ | -------- | ---------------------------------------
AnchorPart               | BasePart | Required. The part the hitbox attaches to
Size                     | Vector3  | Hitbox dimensions
Offset                   | Vector3  | Offset relative to the AnchorPart
Color                    | Color3   | Visual color of the hitbox
Visible                  | boolean  | Show the visual hitbox
VisibleTransparency      | number   | Transparency of the visual
Anchored                 | boolean  | Should the visual be anchored?
CanCollide               | boolean  | Should the visual collide?
TouchMode                | string   | "single", "cooldown", or "always"
TouchCooldown            | number   | Delay between detections (seconds)
OnModelTouched           | function | Callback when a model touches
IgnoreList               | {Instance} | Things to ignore during checks
PollRate                 | number   | How often collisions are checked
AutoParent               | Instance | Where the visual is parented
Debug                    | boolean  | Enables debug/testing behaviors

---

🧠 Touch Modes Explained

- single  — triggers only one time per model until reset.
- cooldown — triggers again after the cooldown period has passed.
- always — triggers every time an overlap is detected.

If your callback returns:
return { Consume = false }

the hitbox will not mark the model as "touched" (useful for persistent effects).

---

🛠️ Methods

Method                                      | What It Does
------------------------------------------- | ------------------------
SetSize(Vector3)                            | Update hitbox size
SetColor(Color3)                            | Change visual color
SetVisible(boolean, optionalTransparency)   | Show/hide visual
SetOffset(Vector3)                          | Change hitbox offset
AddIgnore(Instance)                         | Add to ignore list
RemoveIgnore(Instance)                      | Remove from ignore list
SetTouchMode(string)                        | Update touch mode
SetTouchCooldown(number)                    | Update cooldown
SetOnModelTouched(function)                 | Change touch callback
ResetTouches(optionalModel)                 | Reset touch history
HasModelTouched(model)                      | Check if a model touched
Enable()                                    | Turn hitbox on
Disable()                                   | Turn hitbox off
Destroy()                                   | Destroy the hitbox

---

📜 Example Usage

local AxeM_Hitbox = require(game.ReplicatedStorage.AxeM_Hitbox)

-- Create a hitbox
local hitbox = AxeM_Hitbox.new({
    AnchorPart = script.Parent,
    Size = Vector3.new(4, 4, 4),
    Offset = Vector3.new(0, 0, 0),
    Visible = true,
    VisibleTransparency = 0.6,
    Color = Color3.fromRGB(255, 0, 0),
    TouchMode = "cooldown",
    TouchCooldown = 1,
    IgnoreList = {},
    OnModelTouched = function(model, hb, part)
        print(model.Name .. " touched the hitbox!")
        -- Here you can deal damage, trigger effects, etc.
    end
})

-- Enable the hitbox
hitbox:Enable()

-- Change hitbox properties at runtime
hitbox:SetColor(Color3.fromRGB(0, 255, 0))  -- make it green
hitbox:SetSize(Vector3.new(6, 6, 6))        -- make it bigger

---

📋 Collision Detection Details

AxeM_Hitbox uses Workspace:GetPartBoundsInBox() with OverlapParams to reliably check overlaps every frame based on PollRate.

Filtering Rules:

- Parts in IgnoreList are not counted.
- Players or models with a Humanoid whose Health <= 0 are automatically ignored.
- The hitbox itself (visual part) is ignored.
- You can pass both parts and entire models into IgnoreList.

---

💡 Useful Tips

- Make sure AnchorPart is valid.
- Check Size and Offset values.
- Try increasing PollRate if detection fails.
- Add objects that shouldn’t trigger to the IgnoreList.
- Use ResetTouches() to allow repeated hit registrations.
- Adjust VisibleTransparency to make the hitbox easier to debug without blocking view.

---

📜 License

MIT License

Copyrigh / AxeM_FoNi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software...
