--[[
    ConstantUI - Original-style example menu
    Based on the supplied Constant.cc menu layout.

    The Legit / Rage / Visuals / Misc tabs are UI-only previews.
    Their gameplay callbacks, hooks, targeting, movement, weapon edits,
    ESP rendering, teleporting and other game actions are intentionally removed.

    The UI itself remains interactive: controls, keybinds, configs, theme,
    watermark, dock, Environment player list, Lua editor preview and Activity chat.
]]

local LibraryURL = "https://raw.githubusercontent.com/aap27781-commits/bigubi/refs/heads/main/ConstantUI.lua"

local function LoadLibrary()
    assert(type(loadstring) == "function", "loadstring is unavailable in this executor")
    local Source = game:HttpGet(LibraryURL)
    local Chunk = loadstring(Source)
    assert(type(Chunk) == "function", "ConstantUI.lua did not compile")
    return Chunk()
end

local Loaded, Library = pcall(LoadLibrary)
if not Loaded then
    error("[ConstantUI Example] Could not load the UI library: " .. tostring(Library))
end

assert(type(Library) == "table" and type(Library.Window) == "function",
    "ConstantUI.lua did not return a valid Library table")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService = game:GetService("Stats")

local Enum = Enum
local NewUDim2 = UDim2.new
local NewVector2 = Vector2.new
local NewUDim = UDim.new
local NewRGB = Color3.fromRGB
local NewColorSequence = ColorSequence.new
local NewNumberSequence = NumberSequence.new
local NewVector3 = Vector3.new
local NewInstance = Instance.new

local Format = string.format
local Lower = string.lower
local GSub = string.gsub
local Date = os.date
local Find = table.find
local Insert = table.insert
local Remove = table.remove
local Clear = table.clear
local Sort = table.sort
local Unpack = table.unpack
local Clamp = math.clamp
local Round = math.round
local Floor = math.floor
local Min = math.min
local Max = math.max
local Random = math.random
local Match = string.match
local Split = string.split
local Sub = string.sub
local Concat = table.concat
local Delay = task.delay
local Spawn = task.spawn
local Wait = task.wait

local Menu = Library.Menu
local Flags = Library.Flags
local MenuTheme = Menu.Theme
local Images = Menu.Images

local function Notify(Text)
    Library:Notify({
        Text = tostring(Text),
        Time = 3
    })
end

-- This only changes the local frame cap, when the executor supports it.
local function ApplyFPSLimit(Value)
    if type(setfpscap) ~= "function" then
        Notify("FPS cap is not supported by this executor")
        return false
    end

    local Success = pcall(setfpscap, Clamp(Round(tonumber(Value) or 144), 30, 999))
    if not Success then
        Notify("Could not apply FPS cap")
    end
    return Success
end

local BodyPartNames = {
    "Head",
    "Torso",
    "Right Arm",
    "Left Arm",
    "Right Leg",
    "Left Leg"
}

local Environment
local Theme
local Lua
local Activity
local Dock
local Watermark
local KeybindsList

local Tab
local Section
local MultiSection
local Tree


-- Main window: same tabs and original control layout.
-- All gameplay callbacks have been stripped from these tabs.
local Window = Library:Window({
    Visible = true,
    HasTabs = true
})


    do
        Tab = Window:Tab({
            Name = "Legit",
            Opened = true
        })
        do
            Section = Tab:Section({
                Name = "Aim Assist",
                Size = 300
            })
            do
                Section:Toggle({
                    Name = "Enabled",
                    Flag = "AimAssist Enabled"
                }):Keybind({
                    Mode = "On Hold",
                    Flag = "Aim Assist Keybind",
                    Name = "Aim Assist"
                })

                Section:Dropdown({
                    Name = "Target Selection",
                    Options = { "Adaptive", "Lock" },
                    Default = "Adaptive",
                    Flag = "AimAssist Selection",
                    
                })

                Section:Toggle({
                    Name = "Priority Only",
                    Flag = "AimAssist PriorityOnly"
                })

                Section:Toggle({
                    Name = "Require Mouse Movement",
                    Flag = "AimAssist Require Mouse"
                })

                Section:Toggle({
                    Name = "Visible Check",
                    Flag = "AimAssist VisibleCheck",
                    Default = true
                })

                Section:Dropdown({
                    Name = "Hitboxes",
                    Options = BodyPartNames,
                    Default = { "Head" },
                    Flag = "AimAssist Hitparts"
                })

                Section:Slider({
                    Name = "Switch Delay",
                    Min = 0, Max = 2500, Default = 350,
                    Prefix = "ms",
                    Flag = "AimAssist SwitchDelay"
                })

                Section:Slider({
                    Name = "Aim Speed",
                    Min = 1, Max = 5, Default = 2,
                    Decimals = 0.1,
                    Prefix = "%",
                    Flag = "AimAssist Speed"
                })

                Section:Slider({
                    Name = "FOV",
                    Min = 1, Max = 35, Default = 5,
                    Decimals = 0.1,
                    Prefix = "°",
                    Flag = "AimAssist Fov"
                })

                Section:Slider({
                    Name = "Max Distance",
                    Min = 1,
                    Max = 2000,
                    Default = 500,
                    Prefix = "m",
                    Flag = "AimAssist MaxDistance"
                })
            end

            Section = Tab:Section({
                Name = "Trigger Bot",
                Size = 229
            })
            do
                Section:Toggle({
                    Name = "Enabled",
                    Flag = "TriggerBot Enabled"
                }):Keybind({
                    Mode = "Toggle",
                    Flag = "Triggerbot Keybind",
                    Name = "Triggerbot"
                })

                Section:Toggle({
                    Name = "Priority Only",
                    Flag = "TriggerBot PriorityOnly"
                })

                Section:Toggle({
                    Name = "Use Autowall",
                    Flag = "TriggerBot AutoWall"
                })

                Section:Dropdown({
                    Name = "Hitboxes",
                    Options = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Closest" },
                    Default = { "Head" },
                    Flag = "TriggerBot Hitpart"
                })

                Section:Slider({
                    Name = "Shoot Chance",
                    Min = 1,
                    Max = 100,
                    Default = 100,
                    Prefix = "%",
                    Flag = "TriggerBot ShootChance"
                })

                Section:Slider({
                    Name = "Reaction Time",
                    Min = 0,
                    Max = 950,
                    Default = 115,
                    Prefix = "ms",
                    Flag = "TriggerBot Reaction Time"
                })

                Section:Slider({
                    Name = "FOV",
                    Min = 1, Max = 25, Default = 5,
                    Decimals = 0.1,
                    Prefix = "°",
                    Flag = "TriggerBot FOV"
                })

                Section:Slider({
                    Name = "Max Distance",
                    Min = 1,
                    Max = 2000,
                    Default = 500,
                    Prefix = "m",
                    Flag = "TriggerBot MaxDistance"
                })
            end

            Section = Tab:Section({
                Name = "Silent Aim",
                Size = 348,
                Side = "Right"
            })
            do
                Section:Toggle({
                    Name = "Enabled",
                    Flag = "SilentAim Enabled"
                }):Keybind({
                    Mode = "Toggle",
                    Flag = "SilentAim Keybind",
                    Name = "Silent Aim"
                })

                Section:Toggle({
                    Name = "Priority Only",
                    Flag = "SilentAim PriorityOnly"
                })

                Section:Toggle({
                    Name = "Use Autowall",
                    Flag = "SilentAim AutoWall"
                })

                Section:Dropdown({
                    Name = "Hitboxes",
                    Options = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Closest" },
                    Default = { "Head" },
                    Flag = "SilentAim Hitpart"
                })

                Section:Slider({
                    Name = "Spread Amount",
                    Min = 0,
                    Max = 100,
                    Default = 60,
                    Prefix = "%",
                    Flag = "SilentAim Spread Amount"
                })

                Section:Slider({
                    Name = "Switch Delay",
                    Min = 0, Max = 5000, Default = 1250,
                    Prefix = "ms",
                    Flag = "SilentAim SwitchDelay"
                })

                Section:Slider({
                    Name = "FOV",
                    Flag = "SilentAim Fov",
                    Min = 1, Max = 90, Default = 40,
                    Decimals = 0.1,
                    Prefix = "°"
                })

                Section:Slider({
                    Name = "Max Distance",
                    Min = 1,
                    Max = 2000,
                    Default = 500,
                    Prefix = "m",
                    Flag = "SilentAim MaxDistance"
                })

                Section:Slider({
                    Name = "Hit Chance",
                    Min = 1,
                    Max = 100,
                    Default = 45,
                    Prefix = "%",
                    Flag = "SilentAim Hitchance"
                })
            end

            MultiSection = Tab:MultiSection({
                Name = "Misc",
                Size = 181,
                Side = "Right",
                Sections = { "General", "Gun Mods", "Knife Mods" }
            })
            do
                Section = MultiSection[1]
                do
                    Section:Toggle({
                        Name = "Visualise FOV",
                        Flag = "Visualise Fov",
                        
                    }):Colorpicker({
                        Color = NewRGB(255, 255, 255),
                        Transparency = 0,
                        Flag = "Visualise Fov Color",
                        
                    })

                    Section:Slider({
                        Name = "FOV Amount",
                        Min = 1, Max = 90, Default = 5,
                        Decimals = 0.1,
                        Prefix = "°",
                        Flag = "Visualise Fov Amount"
                    })
                end

                Section = MultiSection[2]
                do
                    Section:Toggle({
                        Name = "Force Hitbox",
                        Flag = "Gun Force Hitbox",
                        Unsafe = true
                    })

                    Section:Dropdown({
                        Name = "Hitboxes",
                        Options = BodyPartNames,
                        Default = { "Head" },
                        Flag = "Gun Hitboxes"
                    })

                    Section:Slider({
                        Name = "Camera Recoil Adjustment",
                        Flag = "Camera Recoil Adjustment",
                        Min = 0, Max = 100, Default = 100,
                        Prefix = "%"
                    })

                    Section:Slider({
                        Name = "Weapon Recoil Adjustment",
                        Flag = "Weapon Recoil Adjustment",
                        Min = 0, Max = 100, Default = 100,
                        Prefix = "%"
                    })

                    Section:Slider({
                        Name = "Spread Adjustment",
                        Flag = "Spread Adjustment",
                        Min = 0, Max = 100, Default = 100,
                        Prefix = "%"
                    })

                    Section:Slider({
                        Name = "Grenade Fuse Time",
                        Flag = "Grenade Fuse Time",
                        Min = 0, Max = 15, Default = 5,
                        Decimals = 0.1,
                        Prefix = "s"
                    })

                    Section:Slider({
                        Name = "Grenade Speed Adjustment",
                        Flag = "Grenade Speed Adjustment",
                        Min = 0, Max = 350, Default = 100,
                        Prefix = "%"
                    })

                    Section:Toggle({
                        Name = "No Weapon Sway",
                        Flag = "No Weapon Sway"
                    })

                    Section:Toggle({
                        Name = "Instant Equip",
                        Flag = "Instant Equip"
                    })

                    Section:Toggle({
                        Name = "Instant Unequip",
                        Flag = "Instant UnEquip"
                    })

                    Section:Toggle({
                        Name = "Instant Aim",
                        Flag = "Instant Aim"
                    })

                    Section:Toggle({
                        Name = "Instant Reload",
                        Flag = "Instant Reload"
                    })

                    Section:Toggle({
                        Name = "No ADS Restrictions",
                        Flag = "No ADS Restrictions"
                    })

                    Section:Toggle({
                        Name = "No Scope Overlay",
                        Flag = "No Scope Overlay"
                    })

                    Section:Toggle({
                        Name = "No Scope Sway",
                        Flag = "No Scope Sway"
                    })
                end

                Section = MultiSection[3]
                do
                    Section:Toggle({
                        Name = "Force Hitbox",
                        Flag = "Knife Force Hitbox",
                        Unsafe = true
                    })

                    Section:Dropdown({
                        Name = "Hitboxes",
                        Options = BodyPartNames,
                        Default = { "Head" },
                        Flag = "Knife Hitboxes"
                    })
                end
            end
        end

        Tab = Window:Tab({
            Name = "Rage"
        })
        do
            MultiSection = Tab:MultiSection({
                Name = "Ragebot",
                Fill = true,
                Sections = { "Main", "Misc", "Anti-Aim" }
            })
            do
                Section = MultiSection[1]
                do
                    Section:Toggle({
                        Name = "Enabled",
                        Unsafe = true,
                        Flag = "Ragebot Enabled"
                    }):Keybind({
                        Mode = "Toggle",
                        Modes = {"Toggle", "On Hold"},
                        Flag = "Ragebot Keybind",
                        Name = "Ragebot"
                    })

                    Section:Toggle({
                        Name = "Priority Only",
                        Flag = "Ragebot Priority Only"
                    })

                    Section:Dropdown({
                        Name = "Hitbox",
                        Flag = "Ragebot Hitscan Point",
                        Default = "Head",
                        Options = BodyPartNames,
                        Min = 1
                    })

                    Section:Slider({
                        Name = "Origin Radius",
                        Flag = "Ragebot Origin Radius",
                        Min = 2, Max = 15.9, Default = 10,
                        Decimals = 0.01,
                        Prefix = "m"
                    })

                    Section:Slider({
                        Name = "Origin Scans",
                        Flag = "Ragebot Origin Points",
                        Min = 2, Max = 40, Default = 3,
                        Prefix = "x"
                    })

                    Section:Slider({
                        Name = "Hit Radius",
                        Flag = "Ragebot Point Radius",
                        Min = 2, Max = 9.9, Default = 7,
                        Decimals = 0.01,
                        Prefix = "m"
                    })

                    Section:Slider({
                        Name = "Hit Scans",
                        Flag = "Ragebot Point Points",
                        Min = 2, Max = 40, Default = 3,
                        Prefix = "x"
                    })

                    Section:Slider({
                        Name = "Maximum Autowall Scans",
                        Flag = "Ragebot Maximum Scans",
                        Min = 1, Max = 10000, Default = 10000,
                        Specials = { { "∞", 10000 } },
                        Prefix = "x"
                    })

                    Section:Toggle({
                        Name = "Auto Peek",
                        Flag = "Ragebot Auto Peek",
                        Unsafe = true
                    })

                    Section:Toggle({
                        Name = "Force Ground Peek",
                        Flag = "Ragebot Peek Grounded",
                        Default = true
                    })

                    Section:Toggle({
                        Name = "Allow Up Peek",
                        Flag = "Ragebot Peek Up Peek",
                        Indev = true
                    })

                    Section:Slider({
                        Name = "Peek Radius",
                        Flag = "Ragebot Peek Radius",
                        Min = 5, Max = 500, Default = 50,
                        Decimals = 0.01,
                        Prefix = "m"
                    })

                    Section:Slider({
                        Name = "Peek Scans",
                        Flag = "Ragebot Peek Points",
                        Min = 1, Max = 40, Default = 2,
                        Prefix = "x"
                    })

                    Section:Toggle({
                        Name = "Randomise Peek Radius",
                        Flag = "Ragebot Fill Peek"
                    })

                    Section:Toggle({
                        Name = "Compensate Ping On Retreat",
                        Flag = "Ragebot Autopeek Compensate Ping",
                        Default = true
                    })
                end

                Section = MultiSection[2]
                do
                    Section:Toggle({
                        Name = "Prevent Overfire",
                        Flag = "Ragebot Prevent Overfire"
                    })

                    Section:Dropdown({
                        Name = "Scanning Modes",
                        Flag = "Ragebot Scanning Modes",
                        Default = { "Sphere" },
                        Options = { "Sphere", "Cardinals", "Random" }
                    })

                    Section:Dropdown({
                        Name = "Sorting Mode",
                        Flag = "Ragebot Sort Mode",
                        Default = "Highest Damage",
                        Options = { "Highest Damage", "Lowest Hit", "Lowest Origin", "Most Accurate" }
                    })

                    Section:Dropdown({
                        Name = "Backtrack Sorting",
                        Flag = "Ragebot Backtrack Sorting",
                        Default = "Reverse Chronological",
                        Options = { "Chronological", "Reverse Chronological", "Random" },
                        Min = 1
                    })

                    Section:Slider({
                        Name = "Backtrack Time",
                        Flag = "Ragebot Backtrack Amount",
                        Min = 100, Max = 4950, Default = 3000,
                        Prefix = "ms"
                    })

                    Section:Slider({
                        Name = "Backtrack Scans",
                        Flag = "Ragebot Backtrack Scans",
                        Min = 2, Max = 50, Default = 2,
                        Prefix = "x"
                    })
                end

                Section = MultiSection[3]
                do
                    Section:Toggle({
                        Name = "Fake Position",
                        Flag = "Fake Position Enabled",
                        Unsafe = true,
                        
                    }):Keybind({
                        Mode = "Toggle",
                        Modes = {"Toggle", "On Hold"},
                        Flag = "Fake Position Keybind",
                        Name = "Fake Position"
                    })

                    Section:Toggle({
                        Name = "Anti Aim Enabled",
                        Flag = "Anti Aim Enabled",
                        Unsafe = true
                    }):Keybind({
                        Mode = "Toggle",
                        Modes = {"Toggle", "On Hold"},
                        Flag = "Anti Aim Keybind",
                        Name = "Anti Aim"
                    })

                    Section:Dropdown({
                        Name = "Pitch",
                        Default = "None",
                        Options = { "None", "Full Up", "Normal Up", "Half Up", "Full Down", "Normal Down", "Half Down", "Zero", "Randomise", "Rotate", "Custom" },
                        Size = 125,
                        Flag = "Anti Aim Pitch",
                        
                    })

                    Section:Dropdown({
                        Name = "Yaw",
                        Default = "None",
                        Options = { "None", "Backwards", "Randomise", "Rotate", "Tweak", "Cycle", "Custom" },
                        Size = 125,
                        Flag = "Anti Aim Yaw",
                        
                    })

                    Section:Slider({
                        Name = "Custom Pitch",
                        Flag = "Anti Aim Custom Pitch",
                        Min = -2, Max = 2, Default = 0,
                        Prefix = "°",
                        Decimals = 0.01,
                        Hidden = true
                    })

                    Section:Slider({
                        Name = "Custom Yaw",
                        Flag = "Anti Aim Custom Yaw",
                        Min = -180, Max = 180, Default = 0,
                        Prefix = "°",
                        Decimals = 0.01,
                        Hidden = true
                    })

                    Section:Slider({
                        Name = "Jitter Amount",
                        Flag = "Anti Aim Jitter",
                        Min = 0, Max = 360, Default = 0,
                        Prefix = "°",
                        Decimals = 0.01
                    })

                    Section:Slider({
                        Name = "Pitch Speed",
                        Flag = "Anti Aim Pitch Speed",
                        Min = 1, Max = 50, Default = 10,
                        Hidden = true
                    })

                    Section:Slider({
                        Name = "Yaw Speed",
                        Flag = "Anti Aim Yaw Speed",
                        Min = 1, Max = 50, Default = 10,
                        Hidden = true
                    })

                    Section:Toggle({
                        Name = "Freeze Movements",
                        Flag = "Freeze Movements",
                        Unsafe = true
                    }):Keybind({
                        Mode = "Toggle",
                        Modes = {"Toggle", "On Hold"},
                        Flag = "Freeze Movements Keybind",
                        Name = "Freeze Movements"
                    })

                    Section:Toggle({
                        Name = "Tilt Neck",
                        Flag = "Tilt Neck",
                        
                    })

                    Section:Toggle({
                        Name = "Lower Arms",
                        Flag = "Lower Arms",
                        
                    })

                    Section:Dropdown({
                        Name = "Custom Stance",
                        Default = "None",
                        Options = { "None", "Stand", "Prone", "Crouch" },
                        Flag = "Custom Stance",
                        
                    })
                end
            end

            Section = Tab:Section({
                Name = "Knifebot",
                Fill = true,
                Side = "Right"
            })
            do
                Section:Toggle({
                    Name = "Enabled",
                    Flag = "Knifebot Enabled",
                    Unsafe = true
                }):Keybind({
                    Mode = "Toggle",
                    Modes = {"Toggle", "On Hold"},
                    Flag = "TriggerBot Keybind",
                    Name = "Knifebot"
                })

                Section:Toggle({
                    Name = "Priority Only",
                    Flag = "Knifebot Priority Only"
                })

                Section:Toggle({
                    Name = "On Knife Only",
                    Flag = "Knifebot Knife Only",
                    Default = true
                })

                Section:Dropdown({
                    Name = "Hitbox",
                    Flag = "Knifebot Hitbox",
                    Default = "Head",
                    Options = BodyPartNames
                })

                Section:Slider({
                    Name = "Max Range",
                    Flag = "Knifebot Max Range",
                    Min = 1,
                    Max = 25,
                    Default = 10,
                    Prefix = "m"
                })
            end
        end

        Tab = Window:Tab({
            Name = "Visuals"
        })
        do
            MultiSection = Tab:MultiSection({
                Name = "Player ESP",
                Size = 309,
                Sections = { "Team", "Enemy" }
            })
            do
                Section = MultiSection[1]
                do
                    Tree = Section:ExpandableToggle({
                        Name = "Enabled",
                        Flag = "Esp Enabled",
                        Category = "Team",
                        Opened = true,
                        Size = 227
                    })
                    do
                        Tree:Keybind({
                            Mode = "Toggle",
                            Modes = {"Toggle", "On Hold"},
                            Flag = "Esp Enabled Keybind",
                            Name = "ESP Enabled"
                        })

                        Tree:Toggle({
                            Name = "Name",
                            Flag = "Esp Name",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Name Color",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Skeleton",
                            Flag = "Esp Skeleton",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Skeleton Color",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Weapon",
                            Flag = "Esp Weapon",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Weapon Color",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Distance",
                            Flag = "Esp Distance",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Distance Color",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Bounding Box",
                            Flag = "Esp Box",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Flag = "Esp Box Color",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Bounding Box Fill",
                            Flag = "Esp Box Fill",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0.5,
                            Flag = "Esp Box Fill Color 1",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 1,
                            Flag = "Esp Box Fill Color 2",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Bounding Box Glow",
                            Flag = "Esp Box Glow",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Spin Box Fill",
                            Flag = "Esp Box Fill Spin",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Health Bar",
                            Flag = "Esp Health Bar",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(0, 255, 42),
                            Flag = "Esp Health Color 1",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 0, 0),
                            Flag = "Esp Health Color 2",
                            Category = "Team",
                            Hidden = true
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Health Color 3",
                            Category = "Team"
                        })

                        Tree:Dropdown({
                            Name = "Health Bar Type",
                            Options = { "Static", "Dynamic", "Gradient" },
                            Default = "Static",
                            Flag = "Esp Health Bar Type",
                            Category = "Team",
                            
                        })

                        Tree:Toggle({
                            Name = "Exploiting",
                            Flag = "Esp Exploiting",
                            Category = "Team"
                        }):Colorpicker({
                            Color = NewRGB(255, 0, 0),
                            Transparency = 0,
                            Flag = "Esp Exploiting Color",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Priority Only",
                            Flag = "Esp Priority Only",
                            Category = "Team"
                        })

                        Tree:Slider({
                            Name = "Render Distance",
                            Flag = "Esp Max Distance",
                            Category = "Team",
                            Min = 150, Max = 2000, Default = 400,
                            Prefix = "m"
                        })

                        Tree:Slider({
                            Name = "Refresh Rate",
                            Category = "Team",
                            Flag = "Esp Refresh Rate",
                            Prefix = "hz",
                            Min = 60, Max = 265, Default = 144
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Out of View",
                        Flag = "Esp Oov",
                        Category = "Team",
                        Size = 178
                    })
                    do
                        Tree:Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Oov Color",
                            Category = "Team",
                        })

                        Tree:Dropdown({
                            Name = "Elements",
                            Flag = "Esp Oov Elements",
                            Options = { "Name", "Health Bar", "Distance", "Weapon" },
                            Default = {},
                            Category = "Team",
                            Min = 0
                        })

                        Tree:Dropdown({
                            Name = "Style",
                            Flag = "Esp Oov Style",
                            Options = { "Normal", "Concave" },
                            Default = "Concave",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Dynamic Distance",
                            Flag = "Esp Oov Dynamic Distance",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Dynamic Size",
                            Flag = "Esp Oov Dynamic Size",
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Arrow Blinking",
                            Flag = "Esp Oov Blink",
                            Category = "Team"
                        })

                        Tree:Slider({
                            Name = "Blinking Speed",
                            Flag = "Esp Oov Blink Speed",
                            Category = "Team",
                            Min = 1, Max = 4, Default = 1
                        })

                        Tree:Slider({
                            Name = "Arrow Distance",
                            Flag = "Esp Oov Distance",
                            Category = "Team",
                            Min = 10, Max = 100, Default = 40,
                            Prefix = "%"
                        })

                        Tree:Slider({
                            Name = "Arrow Size",
                            Flag = "Esp Oov Size",
                            Category = "Team",
                            Prefix = "px",
                            Min = 10, Max = 50, Default = 13
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Sound ESP",
                        Flag = "Esp Sound",
                        Category = "Team",
                        Size = 42
                    })
                    do
                        Tree:Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Flag = "Esp Sound Color",
                            Transparency = 0,
                            Category = "Team"
                        })

                        Tree:Toggle({
                            Name = "Through Walls",
                            Flag = "Esp Sound Through Walls",
                            Category = "Team",
                            Default = true
                        })

                        Tree:Slider({
                            Name = "Duration",
                            Flag = "Esp Sound Duration",
                            Category = "Team",
                            Prefix = "s",
                            Min = 0.3, Max = 1.3, Default = 0.5,
                            Decimals = 0.01
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Chams",
                        Flag = "Chams Enabled",
                        Category = "Team",
                        Size = 42,
                        
                    })
                    do
                        Tree:Keybind({
                            Mode = "Toggle",
                            Modes = {"Toggle", "On Hold"},
                            Category = "Team",
                            Flag = "Chams Enabled Keybind",
                            Name = "Chams Enabled"
                        }):Colorpicker({
                            Color = NewRGB(0, 0, 0),
                            Transparency = 0.61,
                            Flag = "Chams Color",
                            Category = "Team",
                            
                        }):Colorpicker({
                            Color = NewRGB(255, 0, 105),
                            Transparency = 0.21,
                            Flag = "Outline Color",
                            Category = "Team",
                            
                        })

                        Tree:Toggle({
                            Name = "Glow Enabled",
                            Flag = "Glows Enabled",
                            Category = "Team",
                            
                        })

                        Tree:Slider({
                            Name = "Glow Size",
                            Flag = "Glows Size",
                            Category = "Team",
                            Min = 1, Max = 2.5, Default = 1.75,
                            Decimals = 0.01,
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Chams Shading",
                        Flag = "Chams Shading",
                        Category = "Team",
                        Unsafe = true,
                        Size = 67,
                        
                    })
                    do
                        Tree:Dropdown({
                            Name = "Inline Shade",
                            Flag = "Inline Shade",
                            Category = "Team",
                            Options = { "Default", "Shaded", "XRay", "XRayShaded", "AlwaysOnTop" },
                            Default = "Default",
                            
                        })

                        Tree:Dropdown({
                            Name = "Outline Shade",
                            Flag = "Outline Shade",
                            Category = "Team",
                            Options = { "Default", "Shaded", "XRay", "XRayShaded", "AlwaysOnTop" },
                            Default = "Default",
                            
                        })
                    end

                    Section:Toggle({
                        Name = "Disable Character Rendering",
                        Flag = "Disable Teammate Rendering"
                    })
                end

                Section = MultiSection[2]
                do
                    Tree = Section:ExpandableToggle({
                        Name = "Enabled",
                        Flag = "Esp Enabled",
                        Category = "Enemy",
                        Opened = true,
                        Size = 227
                    })
                    do
                        Tree:Keybind({
                            Mode = "Toggle",
                            Modes = {"Toggle", "On Hold"},
                            Flag = "Esp Enabled Keybind",
                            Name = "ESP Enabled"
                        })

                        Tree:Toggle({
                            Name = "Name",
                            Flag = "Esp Name",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Name Color",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Skeleton",
                            Flag = "Esp Skeleton",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Skeleton Color",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Weapon",
                            Flag = "Esp Weapon",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Weapon Color",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Distance",
                            Flag = "Esp Distance",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Distance Color",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Bounding Box",
                            Flag = "Esp Box",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Flag = "Esp Box Color",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Bounding Box Fill",
                            Flag = "Esp Box Fill",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0.5,
                            Flag = "Esp Box Fill Color 1",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 1,
                            Flag = "Esp Box Fill Color 2",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Bounding Box Glow",
                            Flag = "Esp Box Glow",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Spin Box Fill",
                            Flag = "Esp Box Fill Spin",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Health Bar",
                            Flag = "Esp Health Bar",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(0, 255, 42),
                            Flag = "Esp Health Color 1",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 0, 0),
                            Flag = "Esp Health Color 2",
                            Category = "Enemy",
                            Hidden = true
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Health Color 3",
                            Category = "Enemy"
                        })

                        Tree:Dropdown({
                            Name = "Health Bar Type",
                            Options = { "Static", "Dynamic", "Gradient" },
                            Default = "Static",
                            Flag = "Esp Health Bar Type",
                            Category = "Enemy",
                            
                        })

                        Tree:Toggle({
                            Name = "Exploiting",
                            Flag = "Esp Exploiting",
                            Category = "Enemy"
                        }):Colorpicker({
                            Color = NewRGB(255, 0, 0),
                            Transparency = 0,
                            Flag = "Esp Exploiting Color",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Priority Only",
                            Flag = "Esp Priority Only",
                            Category = "Enemy"
                        })

                        Tree:Slider({
                            Name = "Render Distance",
                            Flag = "Esp Max Distance",
                            Category = "Enemy",
                            Min = 150, Max = 2000, Default = 400,
                            Prefix = "m"
                        })

                        Tree:Slider({
                            Name = "Refresh Rate",
                            Category = "Enemy",
                            Flag = "Esp Refresh Rate",
                            Prefix = "hz",
                            Min = 60, Max = 265, Default = 144
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Out of View",
                        Flag = "Esp Oov",
                        Category = "Enemy",
                        Size = 178
                    })
                    do
                        Tree:Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Transparency = 0,
                            Flag = "Esp Oov Color",
                            Category = "Enemy"
                        })

                        Tree:Dropdown({
                            Name = "Elements",
                            Flag = "Esp Oov Elements",
                            Options = { "Name", "Health Bar", "Distance", "Weapon" },
                            Default = {},
                            Category = "Enemy",
                            Min = 0
                        })

                        Tree:Dropdown({
                            Name = "Style",
                            Flag = "Esp Oov Style",
                            Options = { "Normal", "Concave" },
                            Default = "Concave",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Dynamic Distance",
                            Flag = "Esp Oov Dynamic Distance",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Dynamic Size",
                            Flag = "Esp Oov Dynamic Size",
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Arrow Blinking",
                            Flag = "Esp Oov Blink",
                            Category = "Enemy"
                        })

                        Tree:Slider({
                            Name = "Blinking Speed",
                            Flag = "Esp Oov Blink Speed",
                            Category = "Enemy",
                            Min = 1, Max = 4, Default = 1
                        })

                        Tree:Slider({
                            Name = "Arrow Distance",
                            Flag = "Esp Oov Distance",
                            Category = "Enemy",
                            Min = 10, Max = 100, Default = 40,
                            Prefix = "%"
                        })

                        Tree:Slider({
                            Name = "Arrow Size",
                            Flag = "Esp Oov Size",
                            Category = "Enemy",
                            Prefix = "px",
                            Min = 10, Max = 50, Default = 13
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Sound ESP",
                        Flag = "Esp Sound",
                        Category = "Enemy",
                        Size = 42
                    })
                    do
                        Tree:Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Flag = "Esp Sound Color",
                            Transparency = 0,
                            Category = "Enemy"
                        })

                        Tree:Toggle({
                            Name = "Through Walls",
                            Flag = "Esp Sound Through Walls",
                            Category = "Enemy",
                            Default = true
                        })

                        Tree:Slider({
                            Name = "Duration",
                            Flag = "Esp Sound Duration",
                            Category = "Enemy",
                            Prefix = "s",
                            Min = 0.3, Max = 1.3, Default = 0.5,
                            Decimals = 0.01
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Chams",
                        Flag = "Chams Enabled",
                        Category = "Enemy",
                        Size = 42,
                        
                    })
                    do
                        Tree:Keybind({
                            Mode = "Toggle",
                            Modes = {"Toggle", "On Hold"},
                            Category = "Enemy",
                            Flag = "Chams Enabled Keybind",
                            Name = "Chams Enabled"
                        }):Colorpicker({
                            Color = NewRGB(0, 0, 0),
                            Transparency = 0.61,
                            Flag = "Chams Color",
                            Category = "Enemy",
                            
                        }):Colorpicker({
                            Color = NewRGB(255, 0, 105),
                            Transparency = 0.21,
                            Flag = "Outline Color",
                            Category = "Enemy",
                            
                        })

                        Tree:Toggle({
                            Name = "Glow Enabled",
                            Flag = "Glows Enabled",
                            Category = "Enemy",
                            
                        })

                        Tree:Slider({
                            Name = "Glow Size",
                            Flag = "Glows Size",
                            Category = "Enemy",
                            Min = 1, Max = 2.5, Default = 1.75,
                            Decimals = 0.01,
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Chams Shading",
                        Flag = "Chams Shading",
                        Category = "Enemy",
                        Unsafe = true,
                        Size = 67,
                        
                    })
                    do
                        Tree:Dropdown({
                            Name = "Inline Shade",
                            Flag = "Inline Shade",
                            Category = "Enemy",
                            Options = { "Default", "Shaded", "XRay", "XRayShaded", "AlwaysOnTop" },
                            Default = "Default",
                            
                        })

                        Tree:Dropdown({
                            Name = "Outline Shade",
                            Flag = "Outline Shade",
                            Category = "Enemy",
                            Options = { "Default", "Shaded", "XRay", "XRayShaded", "AlwaysOnTop" },
                            Default = "Default",
                            
                        })
                    end

                    Section:Toggle({
                        Name = "Resolve Interpolation",
                        Flag = "Interpolation Resolver"
                    })
                end
            end

            MultiSection = Tab:MultiSection({
                Name = "Tracers",
                Sections = { "Tracers", "Sounds" },
                Size = 160
            })
            do
                Section = MultiSection[1]
                do
                    Section:Toggle({
                        Name = "Local Tracers Enabled",
                        Flag = "Local Tracer Enabled"
                    }):Colorpicker({
                        Color = NewRGB(155, 255, 88),
                        Flag = "Local Tracer Color",
                        
                    })

                    Section:Toggle({
                        Name = "Team Tracers Enabled",
                        Flag = "Team Tracer Enabled"
                    }):Colorpicker({
                        Color = NewRGB(211, 132, 68),
                        Flag = "Team Tracer Color",
                        
                    })

                    Section:Toggle({
                        Name = "Enemy Tracers Enabled",
                        Flag = "Enemy Tracer Enabled"
                    }):Colorpicker({
                        Color = NewRGB(68, 131, 211),
                        Flag = "Enemy Tracer Color",
                        
                    })

                    Section:Toggle({
                        Name = "Grenade Tracers Enabled",
                        Flag = "Grenade Tracer Enabled"
                    }):Colorpicker({
                        Color = NewRGB(255, 225, 0),
                        Flag = "Grenade Tracer Color",
                        
                    })

                    Section:Toggle({
                        Name = "Bullet Impacts Enabled",
                        Flag = "Bullet Impacts Enabled"
                    }):Colorpicker({
                        Color = NewRGB(68, 131, 211),
                        Flag = "Bullet Impacts Color",
                        
                    })

                    Section:Dropdown({
                        Name = "Tracer Texture",
                        Flag = "Tracer Texture",
                        Options = { "Obelus", "Lightning", "DNA" },
                        Default = "Lightning",
                        
                    })

                    Section:Slider({
                        Name = "Tracer Lifetime",
                        Flag = "Tracer Time",
                        Min = 0.5, Max = 10, Default = 4,
                        Prefix = "s",
                        
                    })
                end

                Section = MultiSection[2]
                do
                    Tree = Section:ExpandableToggle({
                        Name = "Hitsound",
                        Flag = "Hitsound Enabled",
                        Size = 78,
                        Opened = true
                    })
                    do
                        Tree:Dropdown({
                            Name = "Sound",
                            Flag = "Hitsound",
                            Options = { "Disabled" },
                            Default = "Disabled",
                            Size = 125,
                            
                        })

                        Tree:Slider({
                            Name = "Volume",
                            Flag = "Hitsound Volume",
                            Min = 1, Max = 300, Default = 100,
                            Decimals = 0.01,
                            Prefix = "%",
                            
                        })

                        Tree:Button({
                            Name = "Refresh Hitsounds",
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Killsound",
                        Flag = "Killsound Enabled",
                        Size = 78,
                        Opened = true
                    })
                    do
                        Tree:Dropdown({
                            Name = "Sound",
                            Flag = "Killsound",
                            Options = { "Disabled" },
                            Default = "Disabled",
                            Size = 125,
                            
                        })

                        Tree:Slider({
                            Name = "Volume",
                            Flag = "Killsound Volume",
                            Min = 1, Max = 300, Default = 100,
                            Decimals = 0.01,
                            Prefix = "%",
                            
                        })

                        Tree:Button({
                            Name = "Refresh Killsounds",
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Shoot Sound",
                        Flag = "Custom ShootSound",
                        Size = 123
                    })
                    do
                        Tree:Toggle({
                            Name = "Play Original",
                            Flag = "ShootSound Play Original",
                            Default = true
                        })

                        Tree:Slider({
                            Name = "Original Volume",
                            Flag = "ShootSound Original Volume",
                            Min = 1, Max = 100, Default = 100,
                            Decimals = 0.01,
                            Prefix = "%"
                        })

                        Tree:Slider({
                            Name = "Shoot Sound Volume",
                            Flag = "ShootSound Volume",
                            Min = 1, Max = 100, Default = 100,
                            Decimals = 0.01,
                            Prefix = "%",
                            
                        })

                        Tree:Slider({
                            Name = "Shoot Sound Speed",
                            Flag = "ShootSound Speed",
                            Min = 1, Max = 5, Default = 1,
                            Decimals = 0.1,
                            
                        })

                        Tree:TextBox({
                            Name = "Shoot Sound ID",
                            Flag = "ShootSound Id",
                            Default = "",
                            Placeholder = "rbxassetid://",
                            
                        })
                    end
                end
            end

            Section = Tab:Section({
                Name = "Targeting",
                Size = 56
            })
            do
                Section:Toggle({
                    Name = "Priority Color",
                    Flag = "Priority Color Enabled",
                    Default = true
                }):Colorpicker({
                    Flag = "Priority Color",
                    Color = NewRGB(255, 210, 0)
                })

                Section:Toggle({
                    Name = "Whitelist Color",
                    Flag = "Whitelist Color Enabled",
                    Default = true
                }):Colorpicker({
                    Flag = "Whitelist Color",
                    Color = NewRGB(0, 255, 255)
                })
            end

            Section = Tab:Section({
                Name = "World ESP",
                Size = 329,
                Side = "Right"
            })
            do
                Section:Toggle({
                    Name = "Custom Ambience",
                    Flag = "Ambience",
                    
                }):Colorpicker({
                    Flag = "Ambience Color 1",
                    Color = NewRGB(117, 76, 236),
                    
                }):Colorpicker({
                    Flag = "Ambience Color 2",
                    Color = NewRGB(117, 76, 236),
                    
                })

                Section:Toggle({
                    Name = "Custom Colorshift",
                    Flag = "Colorshift",
                    
                }):Colorpicker({
                    Flag = "Colorshift Color 1",
                    Color = NewRGB(255, 0, 0),
                    
                }):Colorpicker({
                    Flag = "Colorshift Color 2",
                    Color = NewRGB(255, 0, 0),
                    
                })

                Section:Toggle({
                    Name = "Custom Exposure",
                    Flag = "Exposure",
                    
                })

                Section:Slider({
                    Name = "Exposure Amount",
                    Flag = "Exposure Amount",
                    Min = -2, Max = 3, Default = 0,
                    Decimals = 0.01,
                    Prefix = "%",
                    
                })

                Section:Toggle({
                    Name = "Custom Time",
                    Flag = "Time",
                    
                })

                Section:Slider({
                    Name = "Time",
                    Flag = "Time Factor",
                    Min = 0, Max = 24, Default = 12,
                    Prefix = "hr",
                    
                })

                Section:Toggle({
                    Name = "Shadows Enabled",
                    Flag = "Shadows",
                    Default = true,
                    
                })

                Section:Toggle({
                    Name = "Bloom Enabled",
                    Flag = "Bloom",
                    
                })

                Section:Slider({
                    Name = "Bloom Intensity",
                    Flag = "Bloom Intensity",
                    Min = 0, Max = 100, Default = 15,
                    Decimals = 0.1,
                    
                })

                Section:Slider({
                    Name = "Bloom Size",
                    Flag = "Bloom Size",
                    Min = 0, Max = 100, Default = 15,
                    Decimals = 0.1,
                    
                })

                Section:Slider({
                    Name = "Bloom Threshold",
                    Flag = "Bloom Threshold",
                    Min = 0, Max = 100, Default = 100,
                    Decimals = 0.1,
                    
                })

                Section:Dropdown({
                    Name = "Lighting Technology",
                    Flag = "Lighting Technology",
                    Default = "Voxel",
                    Options = { "Legacy", "Voxel", "Compatibility", "ShadowMap", "Future", "Unified" },
                    
                })

                Section:Dropdown({
                    Name = "Lighting Style",
                    Flag = "Lighting Style",
                    Default = "Soft",
                    Options = { "Soft", "Realistic" },
                    
                })

                Section:Dropdown({
                    Name = "Skybox",
                    Flag = "Custom Skybox",
                    Options = { "Default", "Nebula", "Blue Nebula", "Setting Hills", "Blue Aurora", "Red Aurora", "Pink Vision", "Twillight", "Distopia", "Peaceful" },
                    Default = "Default",
                    Size = 125,
                    
                })
            end

            MultiSection = Tab:MultiSection({
                Name = "Others",
                Size = 200,
                Side = "Right",
                Sections = { "Local", "3D", "Third-Person" }
            })
            do
                Section = MultiSection[1]
                do
                    Tree = Section:ExpandableToggle({
                        Name = "Local Chams",
                        Flag = "Local Chams",
                        Size = 91,
                        
                    })
                    do
                        Tree:Colorpicker({
                            Color = MenuTheme.Accent.A,
                            Transparency = 0,
                            Flag = "Local Chams Color",
                            
                        })

                        Tree:Dropdown({
                            Name = "Material",
                            Flag = "Local Chams Material",
                            Options = { "Plastic", "SmoothPlastic", "Neon", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "Sandstone", "Basalt", "CrackedLava", "Limestone", "Pavement", "CorrodedMetal", "DiamondPlate", "Foil", "Metal", "Grass", "LeafyGrass", "Sand", "Fabric", "Snow", "Mud", "Ground", "Asphalt", "Salt", "Ice", "Glacier", "Glass", "ForceField", "Cardboard", "Carpet", "Leather", "Plaster", "Rubber" },
                            Default = "Plastic",
                            Size = 125,
                            
                        })

                        Tree:Dropdown({
                            Name = "Animation",
                            Flag = "Local Chams Animation",
                            Options = { "Disabled", "Webbed", "Pixelated", "Swirl", "Shield", "Bubbles", "Matrix", "Honeycomb", "Clouds", "Galaxy", "Stars", "Wires", "Camo", "Hexagon", "Particles", "Triangular", "Wall", "Scanning" },
                            Default = "Disabled",
                            Size = 125,
                            
                        })

                        Tree:Slider({
                            Name = "Reflectance",
                            Flag = "Local Chams Reflectance",
                            Min = 0, Max = 1, Decimals = 0.01,
                            Default = 0,
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Sleeve Chams",
                        Flag = "Sleeve Chams",
                        Size = 91,
                        
                    })
                    do
                        Tree:Colorpicker({
                            Color = MenuTheme.Accent.A,
                            Transparency = 0,
                            Flag = "Sleeve Chams Color",
                            
                        })

                        Tree:Dropdown({
                            Name = "Material",
                            Flag = "Sleeve Chams Material",
                            Options = { "Plastic", "SmoothPlastic", "Neon", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "Sandstone", "Basalt", "CrackedLava", "Limestone", "Pavement", "CorrodedMetal", "DiamondPlate", "Foil", "Metal", "Grass", "LeafyGrass", "Sand", "Fabric", "Snow", "Mud", "Ground", "Asphalt", "Salt", "Ice", "Glacier", "Glass", "ForceField", "Cardboard", "Carpet", "Leather", "Plaster", "Rubber" },
                            Default = "Plastic",
                            Size = 125,
                            
                        })

                        Tree:Dropdown({
                            Name = "Animation",
                            Flag = "Sleeve Chams Animation",
                            Options = { "Disabled", "Webbed", "Pixelated", "Swirl", "Shield", "Bubbles", "Matrix", "Honeycomb", "Clouds", "Galaxy", "Stars", "Wires", "Camo", "Hexagon", "Particles", "Triangular", "Wall", "Scanning" },
                            Default = "Disabled",
                            Size = 125,
                            
                        })

                        Tree:Slider({
                            Name = "Reflectance",
                            Flag = "Sleeve Chams Reflectance",
                            Min = 0, Max = 1, Decimals = 0.01,
                            Default = 0,
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Skin Tone Chams",
                        Flag = "Skin Tone Chams",
                        Size = 91,
                        
                    })
                    do
                        Tree:Colorpicker({
                            Color = MenuTheme.Accent.A,
                            Transparency = 0,
                            Flag = "Skin Tone Chams Color",
                            
                        })

                        Tree:Dropdown({
                            Name = "Material",
                            Flag = "Skin Tone Chams Material",
                            Options = { "Plastic", "SmoothPlastic", "Neon", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "Sandstone", "Basalt", "CrackedLava", "Limestone", "Pavement", "CorrodedMetal", "DiamondPlate", "Foil", "Metal", "Grass", "LeafyGrass", "Sand", "Fabric", "Snow", "Mud", "Ground", "Asphalt", "Salt", "Ice", "Glacier", "Glass", "ForceField", "Cardboard", "Carpet", "Leather", "Plaster", "Rubber" },
                            Default = "Plastic",
                            Size = 125,
                            
                        })

                        Tree:Dropdown({
                            Name = "Animation",
                            Flag = "Skin Tone Chams Animation",
                            Options = { "Disabled", "Webbed", "Pixelated", "Swirl", "Shield", "Bubbles", "Matrix", "Honeycomb", "Clouds", "Galaxy", "Stars", "Wires", "Camo", "Hexagon", "Particles", "Triangular", "Wall", "Scanning" },
                            Default = "Disabled",
                            Size = 125,
                            
                        })

                        Tree:Slider({
                            Name = "Reflectance",
                            Flag = "Skin Tone Chams Reflectance",
                            Min = 0, Max = 1, Decimals = 0.01,
                            Default = 0,
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "Accessory Chams",
                        Flag = "Accessory Chams",
                        Size = 91,
                        
                    })
                    do
                        Tree:Colorpicker({
                            Color = MenuTheme.Accent.A,
                            Transparency = 0,
                            Flag = "Accessory Chams Color",
                            
                        })

                        Tree:Dropdown({
                            Name = "Material",
                            Flag = "Accessory Chams Material",
                            Options = { "Plastic", "SmoothPlastic", "Neon", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "Sandstone", "Basalt", "CrackedLava", "Limestone", "Pavement", "CorrodedMetal", "DiamondPlate", "Foil", "Metal", "Grass", "LeafyGrass", "Sand", "Fabric", "Snow", "Mud", "Ground", "Asphalt", "Salt", "Ice", "Glacier", "Glass", "ForceField", "Cardboard", "Carpet", "Leather", "Plaster", "Rubber" },
                            Default = "Plastic",
                            Size = 125,
                            
                        })

                        Tree:Dropdown({
                            Name = "Animation",
                            Flag = "Accessory Chams Animation",
                            Options = { "Disabled", "Webbed", "Pixelated", "Swirl", "Shield", "Bubbles", "Matrix", "Honeycomb", "Clouds", "Galaxy", "Stars", "Wires", "Camo", "Hexagon", "Particles", "Triangular", "Wall", "Scanning" },
                            Default = "Disabled",
                            Size = 125,
                            
                        })

                        Tree:Slider({
                            Name = "Reflectance",
                            Flag = "Accessory Chams Reflectance",
                            Min = 0, Max = 1, Decimals = 0.01,
                            Default = 0,
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "ViewModel Chams",
                        Flag = "ViewModel Chams",
                        Size = 91,
                        
                    })
                    do
                        Tree:Colorpicker({
                            Color = MenuTheme.Accent.A,
                            Transparency = 0,
                            Flag = "ViewModel Chams Color",
                            
                        })

                        Tree:Dropdown({
                            Name = "Material",
                            Flag = "ViewModel Chams Material",
                            Options = { "Plastic", "SmoothPlastic", "Neon", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete", "Granite", "Brick", "Pebble", "Cobblestone", "Rock", "Sandstone", "Basalt", "CrackedLava", "Limestone", "Pavement", "CorrodedMetal", "DiamondPlate", "Foil", "Metal", "Grass", "LeafyGrass", "Sand", "Fabric", "Snow", "Mud", "Ground", "Asphalt", "Salt", "Ice", "Glacier", "Glass", "ForceField", "Cardboard", "Carpet", "Leather", "Plaster", "Rubber" },
                            Default = "Plastic",
                            Size = 125,
                            
                        })

                        Tree:Dropdown({
                            Name = "Animation",
                            Flag = "ViewModel Chams Animation",
                            Options = { "Disabled", "Webbed", "Pixelated", "Swirl", "Shield", "Bubbles", "Matrix", "Honeycomb", "Clouds", "Galaxy", "Stars", "Wires", "Camo", "Hexagon", "Particles", "Triangular", "Wall", "Scanning" },
                            Default = "Disabled",
                            Size = 125,
                            
                        })

                        Tree:Slider({
                            Name = "Reflectance",
                            Flag = "ViewModel Chams Reflectance",
                            Min = 0, Max = 1, Decimals = 0.01,
                            Default = 0,
                            
                        })
                    end

                    Tree = Section:ExpandableToggle({
                        Name = "ViewModel Offsets",
                        Flag = "ViewModel Offsets",
                        Size = 162
                    })
                    do
                        Tree:Toggle({
                            Name = "Disable On Aim",
                            Flag = "ViewModel Disable On Aim",
                            Default = true
                        })

                        Tree:Slider({
                            Name = "X",
                            Flag = "ViewModel X Offset",
                            Min = -3, Max = 3, Default = 0,
                            Decimals = 0.1,
                            Prefix = "m"
                        })

                        Tree:Slider({
                            Name = "Y",
                            Flag = "ViewModel Y Offset",
                            Min = -3, Max = 3, Default = 0,
                            Decimals = 0.1,
                            Prefix = "m"
                        })

                        Tree:Slider({
                            Name = "Z",
                            Flag = "ViewModel Z Offset",
                            Min = -3, Max = 3, Default = 0,
                            Decimals = 0.1,
                            Prefix = "m"
                        })

                        Tree:Slider({
                            Name = "Pitch",
                            Flag = "ViewModel Pitch",
                            Min = -180, Max = 180, Default = 0,
                            Prefix = "°"
                        })

                        Tree:Slider({
                            Name = "Yaw",
                            Flag = "ViewModel Yaw",
                            Min = -180, Max = 180, Default = 0,
                            Prefix = "°"
                        })

                        Tree:Slider({
                            Name = "Roll",
                            Flag = "ViewModel Roll",
                            Min = -180, Max = 180, Default = 0,
                            Prefix = "°"
                        })
                    end

                    Section:Toggle({
                        Name = "No Camera Bob",
                        Flag = "No Camera Bob"
                    })

                    Section:Toggle({
                        Name = "No Camera Suppression",
                        Flag = "No Camera Suppression"
                    })

                    Tree = Section:ExpandableToggle({
                        Name = "Custom Camera FOV",
                        Flag = "Visuals Custom Fov",
                        Size = 42,
                        
                    })
                    do
                        Tree:Toggle({
                            Name = "Disable On Aim",
                            Flag = "Visuals Fov Disable Aim",
                            Default = true,
                            
                        })

                        Tree:Slider({
                            Name = "FOV",
                            Flag = "Visuals Custom Fov Factor",
                            Min = 70, Max = 120, Default = 90,
                            Prefix = "°",
                            
                        })
                    end

                    Section:Toggle({
                        Name = "Zoom",
                        Flag = "Zoom",
                        
                    }):Keybind({
                        Mode = "On Hold",
                        Flag = "Zoom Keybind",
                        Name = "Zoom"
                    })

                    Section:Slider({
                        Name = "Zoom Multiplier",
                        Flag = "Zoom Multiplier",
                        Min = 1, Max = 3, Default = 1,
                        Decimals = 0.01,
                        Prefix = "x"
                    })
                end

                Section = MultiSection[2]
                do
                    Tree = Section:ExpandableToggle({
                        Name = "Dropped Weapons",
                        Flag = "Dropped Weapon ESP",
                        Size = 66,
                        Opened = true
                    })
                    do
                        Tree:Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Flag = "Dropped Weapon Color"
                        })

                        Tree:Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Flag = "Dropped Weapon Bar Color"
                        })

                        Tree:Toggle({
                            Name = "Distance",
                            Flag = "Dropped Weapon Distance"
                        }):Colorpicker({
                            Color = NewRGB(255, 255, 255),
                            Flag = "Dropped Weapon Distance Color"
                        })

                        Tree:Slider({
                            Name = "Render Distance",
                            Flag = "Dropped Weapon Max Distance",
                            Min = 20, Max = 2000, Default = 150,
                            Prefix = "m"
                        })

                        Tree:Slider({
                            Name = "Refresh Rate",
                            Flag = "Dropped Weapon Refresh Rate",
                            Prefix = "hz",
                            Min = 60, Max = 265, Default = 100
                        })
                    end

                    Section:Toggle({
                        Name = "Firerate Bar",
                        Flag = "FireRate Bar"
                    }):Colorpicker({
                        Color = NewRGB(255, 255, 255),
                        Flag = "FireRate Bar Color"
                    })

                    Section:Toggle({
                        Name = "Penetration Crosshair",
                        Flag = "Penetration Crosshair",
                        
                    }):Colorpicker({
                        Color = NewRGB(255, 0, 0),
                        Flag = "Penetration Crosshair Color 1"
                    }):Colorpicker({
                        Color = NewRGB(0, 255, 0),
                        Flag = "Penetration Crosshair Color 2"
                    })

                    Section:Toggle({
                        Name = "Visualise Fake Position",
                        Flag = "Visualise Fake Position"
                    }):Colorpicker({
                        Flag = "Visualise Fake Position Bar Color",
                        Color = NewRGB(255, 255, 255)
                    }):Colorpicker({
                        Flag = "Visualise Fake Position Text Color",
                        Color = NewRGB(255, 255, 255)
                    })
                end

                Section = MultiSection[3]
                do
                    Section:Toggle({
                        Name = "Enabled",
                        Flag = "Third Person Enabled"
                    }):Keybind({
                        Mode = "Toggle",
                        Modes = {"Toggle", "On Hold"},
                        Flag = "Third Person Keybind",
                        Name = "Third Person"
                    })

                    Section:Toggle({
                        Name = "Render Weapon",
                        Flag = "Third Person Weapon",
                        Default = true
                    })

                    Tree = Section:ExpandableToggle({
                        Name = "Clip Camera",
                        Flag = "Third Person Clip",
                        Size = 53,
                        Opened = true,
                        Default = true
                    })
                    do
                        Tree:Slider({
                            Name = "Minimum",
                            Flag = "Third Person Minimum",
                            Min = 1, Max = 10, Default = 3,
                            Decimals = 0.1,
                            Prefix = "m"
                        })

                        Tree:Slider({
                            Name = "Maximum",
                            Flag = "Third Person Maximum",
                            Min = 1, Max = 20, Default = 8,
                            Decimals = 0.1,
                            Prefix = "m"
                        })
                    end
                end
            end
        end

        Tab = Window:Tab({
            Name = "Misc"
        })
        do
            Section = Tab:Section({
                Name = "Primary",
                Fill = true
            })
            do
                Section:Toggle({
                    Name = "Walkspeed Enabled",
                    Flag = "WalkSpeed Enabled",
                    
                }):Keybind({
                    Mode = "Toggle",
                    Modes = {"Toggle", "On Hold"},
                    Flag = "WS Keybind",
                    Name = "Walk Speed"
                })

                Section:Slider({
                    Name = "Walk Speed Value",
                    Min = 1,
                    Max = 750,
                    Default = 16,
                    Flag = "WalkSpeed Value",
                    
                })

                Section:Toggle({
                    Name = "Fly Enabled",
                    Flag = "Fly Enabled"
                }):Keybind({
                    Mode = "Toggle",
                    Modes = {"Toggle", "On Hold"},
                    Flag = "Fly Keybind",
                    Name = "Fly Enabled"
                })

                Section:Slider({
                    Name = "Fly Speed",
                    Min = 16,
                    Max = 250,
                    Default = 16,
                    Prefix = " m/s",
                    Flag = "Fly Speed"
                })

                Section:Toggle({
                    Name = "Bunny-hop Enabled",
                    Flag = "Bunny Hop Enabled"
                })

                Section:Toggle({
                    Name = "Air Strafe Enabled",
                    Flag = "Air Strafe Enabled"
                })

                Section:Slider({
                    Name = "Air Strafe Value",
                    Min = 1,
                    Max = 100,
                    Default = 40,
                    Prefix = "%",
                    Flag = "Air Strafe Boost"
                })

                Section:Toggle({
                    Name = "Slow Walk",
                    Flag = "Slow Walk Enabled"
                }):Keybind({
                    Mode = "On Hold",
                    Modes = {"Toggle", "On Hold"},
                    Flag = "Slow Walk Keybind",
                    Name = "Slow Walk"
                })

                Section:Slider({
                    Name = "Slow Walk Value",
                    Min = 1,
                    Max = 100,
                    Default = 40,
                    Prefix = "%",
                    Flag = "Slow Walk Speed"
                })

                Section:Toggle({
                    Name = "Assist In-air Despawns",
                    Flag = "Assist Air Despawns"
                })

                Section:Toggle({
                    Name = "Remove Fall Damage",
                    Flag = "Remove Fall Damage"
                })

                Section:Toggle({
                    Name = "Speed Bypass",
                    Flag = "Speed Bypass",
                    Unsafe = true
                })

                Section:Toggle({
                    Name = "Spawn Immunity",
                    Flag = "Spawn Immunity"
                })

                Section:Slider({
                    Name = "Immunity Time",
                    Min = 1, Max = 20, Default = 4,
                    Decimals = 0.1,
                    Prefix = "s",
                    Flag = "Spawn Immunity Time"
                })
            end

            Section = Tab:Section({
                Name = "Secondary",
                Side = "Right",
                Fill = true
            })
            do
                Section:Dropdown({
                    Name = "Event Logs",
                    Default = {},
                    Options = { "Ragebot Peek", "Ragebot Collat", "Bullet Hit", "Melee Hit", "Grenade Hit", "Server Corrections", "Server Flags" },
                    Flag = "Event Logs",
                    Min = 0
                })

                Section:Slider({
                    Name = "Time",
                    Min = 0.5,
                    Max = 5,
                    Default = 2,
                    Decimals = 0.1,
                    Prefix = "s",
                    Flag = "Event Logs Time"
                })

                Section:Toggle({
                    Name = "Force Character Rendering",
                    Flag = "Force Character Rendering",
                    Default = true
                })

                Section:Toggle({
                    Name = "Staff Detector",
                    Flag = "Staff Detector",
                    
                })

                Section:Toggle({
                    Name = "Kill Say",
                    Flag = "Kill Say"
                })

                Section:Toggle({
                    Name = "Vote Kick On Death",
                    Flag = "Vote Kick On Death"
                })

                Section:Toggle({
                    Name = "Hop on Vote Kick",
                    Flag = "Hop Vote Kick"
                })

                Section:Toggle({
                    Name = "Automatic Vote Kick",
                    Flag = "Automatic Vote Kick"
                })

                Section:Dropdown({
                    Name = "Vote Kick Mode",
                    Options = { "Yes", "Dismiss", "No" },
                    Default = "Yes",
                    Flag = "Vote Kick Mode"
                })

                Section:Button({
                    Name = "Refresh Killsay",
                    
                })

                Section:Button({
                    Name = "Re-join Server",
                    Confirm = true,
                    
                })

                Section:Button({
                    Name = "Hop Server",
                    Confirm = true,
                    
                })
            end
        end

        Tab = Window:Tab({
            Name = "Settings"
        })
        do
            Section = Tab:Section({
                Name = "Settings",
                Fill = true
            })
            do
                Section:Toggle({
                    Name = "Dock Enabled",
                    Flag = "Dock Enabled",
                    Default = true,
                    Callback = function(Value)
                        if Dock then
                            Dock.Enable(Value)
                        end
                    end
                }):Keybind({
                    Default = Enum.KeyCode.Insert,
                    Modes = {},
                    Mode = "Toggle",
                    Flag = "Dock Keybind",
                    ExcludeList = true
                })

                Section:Label({
                    Text = "Menu Key"
                }):Keybind({
                    Default = Enum.KeyCode.RightAlt,
                    Modes = {},
                    Mode = "Toggle",
                    Flag = "Menu Keybind",
                    ExcludeList = true,
                    Changed = function(Value)
                        local InputName = Value[2]

                        Window.Key = InputName and Enum[Value[1]][InputName]
                    end
                })

                Section:Label({
                    Text = "Additional Menu Key"
                }):Keybind({
                    Default = {},
                    Modes = {},
                    Mode = "Toggle",
                    Flag = "Additional Menu Keybind",
                    ExcludeList = true,
                    Changed = function(Value)
                        local InputName = Value[2]
                        local Keybind = InputName and Enum[Value[1]][InputName]

                        Environment.Key = Keybind
                        Theme.Key = Keybind
                        Lua.Key = Keybind
                        Activity.Key = Keybind
                    end
                })

                Section:Slider({
                    Name = "FPS Limit",
                    Min = 30,
                    Max = 999,
                    Default = 144,
                    Callback = function(Value)
                        ApplyFPSLimit(Value)
                    end
                })

                Section:TextBox({
                    Name = "Custom Title",
                    Flag = "Custom Title",
                    Default = "constant.cc | {date}",
                    Placeholder = "{date}",
                    Callback = function(Text)
                        if Dock then Dock.SetText(GSub(Text, "{date}", Date("%B. %d, %Y"))) end
                    end
                })

                Section:TextBox({
                    Name = "Custom Watermark",
                    Flag = "Custom Watermark",
                    Default = "constant.cc | {date} | {uid} | {fps} fps | {ping} ms",
                    Placeholder = "{date} - {uid} - {fps} - {ping}"
                })

                Section:Button({
                    Name = "Reset Position",
                    Callback = function()
                        Watermark.Outline.Position = NewUDim2(1, -23, 0, 23)
                    end
                })
            end

            Section = Tab:Section({
                Name = "Configurations",
                Side = "Right",
                Fill = true
            })
            do
                local Options = Menu.Config("List")

                local ConfigList = Section:Dropdown({
                    Name = "Config",
                    Flag = "Config List",
                    Exclude = true,
                    Options = Options,
                    Default = Options[1],
                    Size = 125
                })

                local ConfigTextBox = Section:TextBox({
                    Placeholder = "Config Name",
                    Default = ""
                })

                Section:Button({
                    Name = "New",
                    CallbackText = "Created!",
                    Callback = function()
                        local String = ConfigTextBox.Get()

                        if String then
                            Menu.Config("New", String)

                            local List = Menu.Config("List")

                            ConfigList.Options = List
                            ConfigList.Set(List[1])
                        end
                    end
                })

                Section:Button({
                    Name = "Save",
                    CallbackText = "Saved!",
                    Callback = function()
                        local String = ConfigList.Get()

                        if String then
                            Menu.Config("Save", String)
                        end
                    end
                })

                Section:Button({
                    Name = "Load",
                    CallbackText = "Loaded!",
                    Callback = function()
                        local String = ConfigList.Get()

                        if String then
                            Menu.Config("Load", String)

                            Library:Notify({
                                Text = Format("Loaded config: %s", String),
                                Time = 3
                            })
                        end
                    end
                })

                Section:Button({
                    Name = "Set Autoload",
                    CallbackText = "Set!",
                    Callback = function()
                        local String = ConfigList.Get()

                        if String then
                            Menu.Config("Set Autoload", String)
                        end
                    end
                })

                Section:Button({
                    Name = "Reset",
                    CallbackText = "Reset!",
                    Confirm = true,
                    Callback = function()
                        local String = ConfigList.Get()

                        if String then
                            Menu.Config("Reset", String)
                        end
                    end
                })

                Section:Button({
                    Name = "Refresh",
                    CallbackText = "Refreshed!",
                    Callback = function()
                        local List = Menu.Config("List")
                        local FirstValue = List[1]

                        ConfigList.Close()

                        ConfigList.Options = List

                        if FirstValue then
                            ConfigList.Set(FirstValue)
                        else
                            ConfigList.Value = nil

                            ConfigList.Update()
                        end
                    end
                })

                Section:Button({
                    Name = "Delete",
                    CallbackText = "Deleted!",
                    Confirm = true,
                    Callback = function()
                        local String = ConfigList.Get()

                        if String then
                            Menu.Config("Delete", String)

                            local List = Menu.Config("List")

                            ConfigList.Options = List
                            ConfigList.Set(List[1])
                        end
                    end
                })
            end
        end
    end


-- Environment ---------------------------------------------------------------
-- Player list is informational only. Whitelist / Prioritise are local UI tags.
Environment = Library:Window({
    Name = "Environment",
    Size = NewUDim2(0, 589, 0, 402),
    Bind = "none",
    Visible = false,
    HasTabs = true,
    Disabled = true
})

do
    local CurrentPlayerName
    local PlayerStates = {}
    local PlayerList
    local PlayerInfo
    local Whitelist
    local Prioritise

    local function GetTeamName(Player)
        if not Player then
            return "Neutral"
        end

        local Team = Player.Team
        if Team and Team.Name and Team.Name ~= "" then
            return Team.Name
        end

        if Player.Neutral then
            return "Neutral"
        end

        local TeamColor = Player.TeamColor
        if TeamColor and TeamColor.Name and TeamColor.Name ~= "" then
            return TeamColor.Name
        end

        return "Neutral"
    end

    local function GetStatus(Name)
        local State = PlayerStates[Name] or {}
        if State.Whitelist then
            return '<font color="rgb(158, 225, 255)">Whitelist</font>'
        elseif State.Priority then
            return '<font color="rgb(255, 0, 0)">Priority</font>'
        end
        return "Neutral"
    end

    local function UpdatePlayerRow(Name)
        if not PlayerList then
            return
        end

        local Player = Players:FindFirstChild(Name)
        if not Player then
            return
        end

        PlayerList.EditValue(Name, {
            [2] = GetTeamName(Player),
            [3] = GetStatus(Name)
        })
    end

    local function SelectPlayer(Name)
        CurrentPlayerName = Name
        local Player = Players:FindFirstChild(Name)
        if not Player then
            return
        end

        local State = PlayerStates[Name] or {
            Whitelist = false,
            Priority = false
        }
        PlayerStates[Name] = State

        PlayerInfo.SetText(Format(
            "Display Name: %s\nUsername: %s\nUser Id: %d\nAccount Age: %d days\nTeam: %s",
            Player.DisplayName,
            Player.Name,
            Player.UserId,
            Player.AccountAge,
            GetTeamName(Player)
        ))

        Whitelist.Set(State.Whitelist, false)
        Prioritise.Set(State.Priority, false)
    end

    local PlayersTab = Environment:Tab({
        Name = "Players",
        Opened = true
    })

    local SearchText = ""
    local SearchBar = PlayersTab:Bar({
        Side = "Fill",
        TextBox = true,
        Placeholder = "Search players...",
        Callback = function(Value)
            SearchText = Lower(tostring(Value or ""))
            if not PlayerList then
                return
            end

            local VisibleNames = {}
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and string.find(Lower(Player.Name), SearchText, 1, true) then
                    Insert(VisibleNames, Player.Name)
                end
            end
            PlayerList.ShowValues(VisibleNames)
        end
    })

    local PlayerContent = PlayersTab:ContentBox({
        Side = "Fill",
        Offset = -2,
        Size = 312
    })

    local PlayerOptions = {}
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            PlayerStates[Player.Name] = PlayerStates[Player.Name] or {
                Whitelist = false,
                Priority = false
            }
            Insert(PlayerOptions, {
                Player.Name,
                Player.Name,
                GetTeamName(Player),
                GetStatus(Player.Name)
            })
        end
    end

    PlayerList = PlayerContent:List({
        Options = PlayerOptions,
        Clickable = true,
        Flag = "Environment Player List",
        Rows = { "Player", "Team", "Priority" },
        Size = 280,
        Callback = function(Name)
            SelectPlayer(Name)
        end,
        Filter = function(Values)
            -- List.Sort expects each filtered row to be wrapped. The second
            -- return value {1} then resolves wrapper[1][1] to the row Frame.
            -- Returning the raw List.Values rows here made Sort index a Frame
            -- with [1], producing: "is not a valid member of Frame".
            local Sorted = {}
            for _, Row in ipairs(Values) do
                local Name = Row[2]
                local State = PlayerStates[Name] or {}
                Insert(Sorted, { Row, State })
            end

            Sort(Sorted, function(A, B)
                local AState = A[2]
                local BState = B[2]
                local AScore = (AState.Priority and 2 or 0) + (AState.Whitelist and 1 or 0)
                local BScore = (BState.Priority and 2 or 0) + (BState.Whitelist and 1 or 0)
                return AScore > BScore
            end)

            return Sorted, { 1 }
        end
    })

    local OptionsTab = Environment:Tab({
        Name = "Options"
    })

    local OptionsContent = OptionsTab:ContentBox({
        Side = "Fill",
        Size = 334
    })

    PlayerInfo = OptionsContent:Label({
        Text = "Display Name: -\nUsername: -\nUser Id: -\nAccount Age: - days\nTeam: -"
    })

    Whitelist = OptionsContent:Toggle({
        Name = "Whitelist",
        Callback = function(Value)
            if not CurrentPlayerName then
                return
            end

            local State = PlayerStates[CurrentPlayerName] or {}
            State.Whitelist = Value
            if Value then
                State.Priority = false
                Prioritise.Set(false, false)
            end
            PlayerStates[CurrentPlayerName] = State
            UpdatePlayerRow(CurrentPlayerName)
        end
    })

    Prioritise = OptionsContent:Toggle({
        Name = "Prioritise",
        Callback = function(Value)
            if not CurrentPlayerName then
                return
            end

            local State = PlayerStates[CurrentPlayerName] or {}
            State.Priority = Value
            if Value then
                State.Whitelist = false
                Whitelist.Set(false, false)
            end
            PlayerStates[CurrentPlayerName] = State
            UpdatePlayerRow(CurrentPlayerName)
        end
    })

    OptionsContent:Button({
        Name = "Reset All",
        Callback = function()
            for Name in pairs(PlayerStates) do
                PlayerStates[Name] = {
                    Whitelist = false,
                    Priority = false
                }
                UpdatePlayerRow(Name)
            end
            Whitelist.Set(false, false)
            Prioritise.Set(false, false)
        end
    })

    local function AddPlayer(Player)
        if Player == LocalPlayer then
            return
        end

        PlayerStates[Player.Name] = PlayerStates[Player.Name] or {
            Whitelist = false,
            Priority = false
        }

        PlayerList.Add(Player.Name, {
            Player.Name,
            GetTeamName(Player),
            GetStatus(Player.Name)
        })

        Player:GetPropertyChangedSignal("Team"):Connect(function()
            UpdatePlayerRow(Player.Name)
        end)
        Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
            UpdatePlayerRow(Player.Name)
        end)

        if SearchText ~= "" then
            local VisibleNames = {}
            for _, ExistingPlayer in ipairs(Players:GetPlayers()) do
                if ExistingPlayer ~= LocalPlayer
                    and string.find(Lower(ExistingPlayer.Name), SearchText, 1, true) then
                    Insert(VisibleNames, ExistingPlayer.Name)
                end
            end
            PlayerList.ShowValues(VisibleNames)
        end
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            Player:GetPropertyChangedSignal("Team"):Connect(function()
                UpdatePlayerRow(Player.Name)
            end)
            Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
                UpdatePlayerRow(Player.Name)
            end)
        end
    end

    Players.PlayerAdded:Connect(AddPlayer)
    Players.PlayerRemoving:Connect(function(Player)
        if PlayerList then
            PlayerList.Remove(Player.Name)
        end
        PlayerStates[Player.Name] = nil
        if CurrentPlayerName == Player.Name then
            CurrentPlayerName = nil
            PlayerInfo.SetText("Display Name: -\nUsername: -\nUser Id: -\nAccount Age: - days\nTeam: -")
            Whitelist.Set(false, false)
            Prioritise.Set(false, false)
        end
    end)

    local FirstPlayer = Players:GetPlayers()[1]
    if FirstPlayer == LocalPlayer then
        FirstPlayer = Players:GetPlayers()[2]
    end
    if FirstPlayer then
        SelectPlayer(FirstPlayer.Name)
    end
end


    Theme = Library:Window({
        Name = "Theme",
        Size = NewUDim2(0, 450, 0, 274),
        Bind = "none",
        Visible = false,
        Disabled = true
    })
    do
        local Bar

        Bar = Theme:Bar({
            Side = "Fill",
            ButtonsSide = "Center",
            Buttons = {
                {
                    "Default.json",
                    function(Value)
                        Menu.ConfigTheme("Load", Value)

                        MenuTheme = Menu.Theme

                        Flags["Menu Outline Color"].FromRGB(MenuTheme.Outline, false)

                        Flags["Accent Color"].FromRGB(MenuTheme.Accent.A, false)

                        Flags["Indev Color"].FromRGB(MenuTheme.Indev, false)
                        Flags["Unsafe Color"].FromRGB(MenuTheme.Unsafe, false)
                        Flags["Blocked Color"].FromRGB(MenuTheme.Blocked, false)

                        Flags["Tree Outline Color"].FromRGB(MenuTheme.Tree.Outline, false)
                        Flags["Tree Active Color"].FromRGB(MenuTheme.Tree.Active, false)
                        Flags["Tree Inactive Color"].FromRGB(MenuTheme.Tree.Inactive, false)

                        Flags["Toggle Outline Color"].FromRGB(MenuTheme.Toggle.Outline, false)
                        Flags["Toggle Active Color"].FromRGB(MenuTheme.Toggle.Active, false)
                        Flags["Toggle Inactive Color"].FromRGB(MenuTheme.Toggle.Inactive, false)

                        Flags["Slider Background Color"].FromRGB(MenuTheme.Slider.Background, false)
                        Flags["Slider Fill Color"].FromRGB(MenuTheme.Slider.Fill, false)

                        Flags["Dropdown Outline Color"].FromRGB(MenuTheme.Dropdown.Outline, false)
                        Flags["Dropdown Gradient A"].FromRGB(MenuTheme.Dropdown["Gradient A"], false)
                        Flags["Dropdown Gradient B"].FromRGB(MenuTheme.Dropdown["Gradient B"], false)

                        Flags["TextBox Outline Color"].FromRGB(MenuTheme.TextBox.Outline, false)
                        Flags["TextBox Inline Color"].FromRGB(MenuTheme.TextBox.Inline, false)
                        Flags["TextBox Background Color"].FromRGB(MenuTheme.TextBox.Background, false)

                        Flags["Button Outline Color"].FromRGB(MenuTheme.Button.Outline, false)
                        Flags["Button Gradient A"].FromRGB(MenuTheme.Button["Gradient A"], false)
                        Flags["Button Gradient B"].FromRGB(MenuTheme.Button["Gradient B"], false)

                        Flags["Keybind Background Color"].FromRGB(MenuTheme.Keybind.Background, false)

                        Flags["Contrast Color A"].FromRGB(MenuTheme.Contrast.A, false)
                        Flags["Contrast Color B"].FromRGB(MenuTheme.Contrast.B, false)
                        Flags["Contrast Color C"].FromRGB(MenuTheme.Contrast.C, false)
                        Flags["Contrast Color D"].FromRGB(MenuTheme.Contrast.D, false)

                        Flags["Text Color A"].FromRGB(MenuTheme["Text Color"].A, false)
                        Flags["Text Color B"].FromRGB(MenuTheme["Text Color"].B, false)

                        Flags["Text Stroke"].Set(MenuTheme["Text Stroke"].Enabled, false)
                        Flags["Text Stroke Color"].FromRGB(MenuTheme["Text Stroke"].Color, false)
                    end,
                    "Dropdown",
                    Menu.ConfigTheme("List"),
                    80
                },

                {
                    "Save",
                    function()
                        local String = Bar.Buttons[1].GetChosen()

                        if String then
                            Menu.ConfigTheme("Save", String)
                        end
                    end
                },

                {
                    "Refresh",
                    function()
                        local Button = Bar.Buttons[1]
                        local Choice = Button.GetChosen()

                        local NewTheme = Menu.ConfigTheme("List")

                        Button.Options = NewTheme

                        Button.Close()

                        if not Find(NewTheme, Choice) then
                            local First = NewTheme[1]

                            if First then
                                Button.SetValue(First)
                            else
                                Button.SetValue("Default.json")
                            end
                        else
                            Button.SetValue(Choice)
                        end
                    end
                }
            }
        })

        Section = Theme:ContentBox({
            Side = "Fill",
            Offset = -2,
            Size = 216
        })
        do
            Section:Label({
                Text = "Outline",
                Icon = { Images["Palette Icon"], NewUDim2(0, 3, 0, 1), NewUDim2(0, 9, 0, 9) }
            }):Colorpicker({
                Color = MenuTheme.Outline,
                Flag = "Menu Outline Color",
                Side = "Left",
                Exclude = true,
                Callback = function(Color)
                    MenuTheme.Outline = Color

                    Library:SetTheme(nil, { "Outline" })
                end
            })

            Section:Label({
                Text = "Accent",
                Icon = { Images["Palette Icon"], NewUDim2(0, 3, 0, 1), NewUDim2(0, 9, 0, 9) }
            }):Colorpicker({
                Color = MenuTheme.Accent.A,
                Flag = "Accent Color",
                Side = "Left",
                Exclude = true,
                Callback = function(Color)
                    MenuTheme.Accent = Menu.GetAccents(Color)

                    Library:SetTheme(nil, { "Accent" })
                end
            })

            Section:Label({
                Text = "Indev",
                Icon = { Images["Palette Icon"], NewUDim2(0, 3, 0, 1), NewUDim2(0, 9, 0, 9) }
            }):Colorpicker({
                Color = MenuTheme.Indev,
                Flag = "Indev Color",
                Side = "Left",
                Exclude = true,
                Callback = function(Color)
                    MenuTheme.Indev = Color

                    Library:SetTheme(nil, { "Indev" })
                end
            })

            Section:Label({
                Text = "Unsafe",
                Icon = { Images["Palette Icon"], NewUDim2(0, 3, 0, 1), NewUDim2(0, 9, 0, 9) }
            }):Colorpicker({
                Color = MenuTheme.Unsafe,
                Flag = "Unsafe Color",
                Side = "Left",
                Exclude = true,
                Callback = function(Color)
                    MenuTheme.Unsafe = Color

                    Library:SetTheme(nil, { "Unsafe" })
                end
            })

            Section:Label({
                Text = "Blocked",
                Icon = { Images["Palette Icon"], NewUDim2(0, 3, 0, 1), NewUDim2(0, 9, 0, 9) }
            }):Colorpicker({
                Color = MenuTheme.Blocked,
                Flag = "Blocked Color",
                Side = "Left",
                Exclude = true,
                Callback = function(Color)
                    MenuTheme.Blocked = Color

                    Library:SetTheme(nil, { "Blocked" })
                end
            })

            Tree = Section:ExpandableLabel({
                Text = "Tree",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 40
            })
            do
                Tree:Label({
                    Text = "Outline"
                }):Colorpicker({
                    Color = MenuTheme.Tree.Outline,
                    Flag = "Tree Outline Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Tree.Outline = Color

                        Library:SetTheme(nil, { "Tree" }, { "Outline" })
                    end
                })

                Tree:Label({
                    Text = "Active"
                }):Colorpicker({
                    Color = MenuTheme.Tree.Active,
                    Flag = "Tree Active Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Tree.Active = Color

                        Library:SetTheme(nil, { "Tree" }, { "Active" })
                    end
                })

                Tree:Label({
                    Text = "Inactive"
                }):Colorpicker({
                    Color = MenuTheme.Tree.Inactive,
                    Flag = "Tree Inactive Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Tree.Inactive = Color

                        Library:SetTheme(nil, { "Tree" }, { "Inactive" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Toggle",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 40
            })
            do
                Tree:Label({
                    Text = "Outline"
                }):Colorpicker({
                    Color = MenuTheme.Toggle.Outline,
                    Flag = "Toggle Outline Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Toggle.Outline = Color

                        Library:SetTheme(nil, { "Toggle" }, { "Outline" })
                    end
                })

                Tree:Label({
                    Text = "Active"
                }):Colorpicker({
                    Color = MenuTheme.Toggle.Active,
                    Flag = "Toggle Active Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Toggle.Active = Color

                        Library:SetTheme(nil, { "Toggle" }, { "Active" })
                    end
                })

                Tree:Label({
                    Text = "Inactive"
                }):Colorpicker({
                    Color = MenuTheme.Toggle.Inactive,
                    Flag = "Toggle Inactive Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Toggle.Inactive = Color

                        Library:SetTheme(nil, { "Toggle" }, { "Inactive" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Slider",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 28
            })
            do
                Tree:Label({
                    Text = "Background"
                }):Colorpicker({
                    Color = MenuTheme.Slider.Background,
                    Flag = "Slider Background Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Slider.Background = Color

                        Library:SetTheme(nil, { "Slider" }, { "Background" })
                    end
                })

                Tree:Label({
                    Text = "Fill"
                }):Colorpicker({
                    Color = MenuTheme.Slider.Fill,
                    Flag = "Slider Fill Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Slider.Fill = Color

                        Library:SetTheme(nil, { "Slider" }, { "Fill" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Dropdown",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 40
            })
            do
                Tree:Label({
                    Text = "Outline"
                }):Colorpicker({
                    Color = MenuTheme.Dropdown.Outline,
                    Flag = "Dropdown Outline Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Dropdown.Outline = Color

                        Library:SetTheme(nil, { "Dropdown" }, { "Outline" })
                    end
                })

                Tree:Label({
                    Text = "Gradient A"
                }):Colorpicker({
                    Color = MenuTheme.Dropdown["Gradient A"],
                    Flag = "Dropdown Gradient A",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Dropdown["Gradient A"] = Color

                        Library:SetTheme(nil, { "Dropdown" })
                    end
                })

                Tree:Label({
                    Text = "Gradient B"
                }):Colorpicker({
                    Color = MenuTheme.Dropdown["Gradient B"],
                    Flag = "Dropdown Gradient B",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Dropdown["Gradient B"] = Color

                        Library:SetTheme(nil, { "Dropdown" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Text Box",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 40
            })
            do
                Tree:Label({
                    Text = "Outline"
                }):Colorpicker({
                    Color = MenuTheme.TextBox.Outline,
                    Flag = "TextBox Outline Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.TextBox.Outline = Color

                        Library:SetTheme(nil, { "TextBox" }, { "Outline" })
                    end
                })

                Tree:Label({
                    Text = "Inline"
                }):Colorpicker({
                    Color = MenuTheme.TextBox.Inline,
                    Flag = "TextBox Inline Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.TextBox.Inline = Color

                        Library:SetTheme(nil, { "TextBox" }, { "Inline" })
                    end
                })

                Tree:Label({
                    Text = "Background"
                }):Colorpicker({
                    Color = MenuTheme.TextBox.Background,
                    Flag = "TextBox Background Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.TextBox.Background = Color

                        Library:SetTheme(nil, { "TextBox" }, { "Background" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Button",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 40
            })
            do
                Tree:Label({
                    Text = "Outline"
                }):Colorpicker({
                    Color = MenuTheme.Button.Outline,
                    Flag = "Button Outline Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Button.Outline = Color

                        Library:SetTheme(nil, { "Button" }, { "Outline" })
                    end
                })

                Tree:Label({
                    Text = "Gradient A"
                }):Colorpicker({
                    Color = MenuTheme.Button["Gradient A"],
                    Flag = "Button Gradient A",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Button["Gradient A"] = Color

                        Library:SetTheme(nil, { "Button" })
                    end
                })

                Tree:Label({
                    Text = "Gradient B"
                }):Colorpicker({
                    Color = MenuTheme.Button["Gradient B"],
                    Flag = "Button Gradient B",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Button["Gradient B"] = Color

                        Library:SetTheme(nil, { "Button" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Keybind",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 16
            })
            do
                Tree:Label({
                    Text = "Background"
                }):Colorpicker({
                    Color = MenuTheme.Keybind.Background,
                    Flag = "Keybind Background Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Keybind.Background = Color

                        Library:SetTheme(nil, { "Keybind" }, { "Background" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Contrast",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 52
            })
            do
                Tree:Label({
                    Text = "Color A"
                }):Colorpicker({
                    Color = MenuTheme.Contrast.A,
                    Flag = "Contrast Color A",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Contrast.A = Color

                        Library:SetTheme(nil, { "Contrast" })
                    end
                })

                Tree:Label({
                    Text = "Color B"
                }):Colorpicker({
                    Color = MenuTheme.Contrast.B,
                    Flag = "Contrast Color B",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Contrast.B = Color

                        Library:SetTheme(nil, { "Contrast" })
                    end
                })

                Tree:Label({
                    Text = "Color C"
                }):Colorpicker({
                    Color = MenuTheme.Contrast.C,
                    Flag = "Contrast Color C",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Contrast.C = Color

                        Library:SetTheme(nil, { "Custom Gradient", "Contrast" })
                    end
                })

                Tree:Label({
                    Text = "Color D"
                }):Colorpicker({
                    Color = MenuTheme.Contrast.D,
                    Flag = "Contrast Color D",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme.Contrast.D = Color

                        Library:SetTheme(nil, { "Custom Gradient", "Contrast" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Text Color",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 28
            })
            do
                Tree:Label({
                    Text = "Color A"
                }):Colorpicker({
                    Color = MenuTheme["Text Color"].A,
                    Flag = "Text Color A",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme["Text Color"].A = Color

                        Library:SetTheme(nil, { "Text Color" }, { "A" })
                    end
                })

                Tree:Label({
                    Text = "Color B"
                }):Colorpicker({
                    Color = MenuTheme["Text Color"].B,
                    Flag = "Text Color B",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme["Text Color"].B = Color

                        Library:SetTheme(nil, { "Text Color" }, { "B" })
                    end
                })
            end

            Tree = Section:ExpandableLabel({
                Text = "Text Outlines",
                Icon = { Images["Folder Icon"], NewUDim2(0, 3, 0, 2), NewUDim2(0, 8, 0, 7) },
                Size = 29
            })
            do
                Tree:Toggle({
                    Text = "Enabled",
                    Flag = "Text Stroke",
                    Exclude = true,
                    Default = MenuTheme["Text Stroke"].Enabled,
                    Callback = function(Value)
                        MenuTheme["Text Stroke"].Enabled = Value

                        Library:SetTheme(nil, { "Text Stroke" }, { "Enabled" })
                    end
                })

                Tree:Label({
                    Text = "Color"
                }):Colorpicker({
                    Color = MenuTheme["Text Stroke"].Color,
                    Flag = "Text Stroke Color",
                    Side = "Left",
                    Exclude = true,
                    Callback = function(Color)
                        MenuTheme["Text Stroke"].Color = Color

                        Library:SetTheme(nil, { "Text Stroke" }, { "Color" })
                    end
                })
            end
        end

        Flags["Menu Theme"] = {
            Get = function()
                return Bar.Buttons[1].GetChosen()
            end,

            Set = function(Value)
                local Button = Bar.Buttons[1]
                local NewTheme = Menu.ConfigTheme("List")

                Button.Options = NewTheme

                Button.Close()

                if Find(NewTheme, Value) then
                    Button.SetValue(Value)
                else
                    Button.SetValue("Default.json")
                end
            end
        }
    end



-- Lua -----------------------------------------------------------------------
-- The code editor is retained, but no Load/Execute button is provided.
-- This keeps the editor UI without introducing arbitrary script execution.
Lua = Library:Window({
    Name = "Lua",
    Size = NewUDim2(0, 490, 0, 400),
    Bind = "none",
    Visible = false,
    HasTabs = true,
    Disabled = true
})

do
    local EditorTab = Lua:Tab({
        Name = "Editor",
        Opened = true
    })

    local EditorContent = EditorTab:ContentBox({
        Side = "Fill",
        Size = 314,
        Offset = -2
    })

    EditorContent:CodeBox({
        Size = 306,
        Default = "-- ConstantUI editor preview\n-- Script execution is intentionally disabled in this UI-only example.\n\nlocal Message = 'Hello from ConstantUI'\nprint(Message)"
    })

    local OptionsTab = Lua:Tab({
        Name = "Options"
    })

    OptionsTab:Section({
        Name = "A",
        Fill = true
    })

    OptionsTab:Section({
        Name = "B",
        Side = "Right",
        Fill = true
    })
end



-- Activity ------------------------------------------------------------------
Activity = Library:Window({
    Name = "Activity",
    Size = NewUDim2(0, 500, 0, 500),
    Bind = "none",
    Visible = false,
    HasTabs = true,
    Disabled = true
})

do
    local PlayerBox
    local ChatBox
    local ChatBar
    local ChatLines = {}
    local SeenMessageIds = {}

    local PlayersTab = Activity:Tab({
        Name = "Players",
        Opened = true
    })

    PlayerBox = PlayersTab:ContentBox({
        Side = "Fill",
        Size = 436,
        Offset = -2,
        ScrollDown = true
    })

    local ChatTab = Activity:Tab({
        Name = "Chat"
    })

    ChatBar = ChatTab:Bar({
        Side = "Fill",
        TextBox = true,
        Placeholder = "Type a Roblox chat message...",
        Buttons = {
            {
                "Clear",
                function()
                    for _, Entry in ipairs(ChatLines) do
                        if Entry then
                            pcall(function() Entry:Remove() end)
                        end
                    end
                    Clear(ChatLines)
                end
            },
            {
                "Send",
                function()
                    local Message = ChatBar and ChatBar.Value or ""
                    Message = tostring(Message or "")
                    if Message:gsub("%s", "") == "" then
                        return
                    end

                    local Channels = TextChatService:FindFirstChild("TextChannels")
                    local Channel = Channels and (
                        Channels:FindFirstChild("RBXGeneral")
                        or Channels:FindFirstChildWhichIsA("TextChannel")
                    )

                    if Channel then
                        local Success, ErrorMessage = pcall(function()
                            Channel:SendAsync(Message)
                        end)
                        if not Success then
                            Notify("Chat send failed: " .. tostring(ErrorMessage))
                        end
                    else
                        -- Standard legacy Roblox chat fallback; filtering remains server-side.
                        local LegacyFolder = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                        local SayMessageRequest = LegacyFolder and LegacyFolder:FindFirstChild("SayMessageRequest")
                        if SayMessageRequest and SayMessageRequest:IsA("RemoteEvent") then
                            SayMessageRequest:FireServer(Message, "All")
                        else
                            Notify("No Roblox chat channel is available")
                        end
                    end

                    if ChatBar and ChatBar.Box then
                        ChatBar.Box.Text = ""
                    end
                end
            }
        }
    })

    ChatBox = ChatTab:ContentBox({
        Side = "Fill",
        Size = 412,
        Offset = -2,
        ScrollDown = true
    })

    local function AddChatLine(Text)
        local Entry = ChatBox:Label({
            Text = tostring(Text)
        })
        Insert(ChatLines, Entry)

        while #ChatLines > 100 do
            local Oldest = Remove(ChatLines, 1)
            if Oldest then
                pcall(function() Oldest:Remove() end)
            end
        end
    end

    local function AddPlayerLog(Player, Verb)
        PlayerBox:Label({
            Text = Format("Player: %s (%s) %s", Player.Name, tostring(Player.UserId), Verb)
        })
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            AddPlayerLog(Player, "was already in the server.")
        end
    end

    Players.PlayerAdded:Connect(function(Player)
        AddPlayerLog(Player, "has Joined.")
    end)

    Players.PlayerRemoving:Connect(function(Player)
        AddPlayerLog(Player, "has Left.")
    end)

    local PlatformIntegrated = false
    pcall(function()
        PlatformIntegrated = TextChatService.PlatformIntegratedChat == Enum.RolloutState.Enabled
    end)

    if PlatformIntegrated then
        AddChatLine("Platform Integrated Chat is enabled. Roblox does not expose message text to custom chat panels.")
    else
        local MessageSignal
        pcall(function()
            MessageSignal = TextChatService.MessageReceived
        end)

        if MessageSignal then
            MessageSignal:Connect(function(Message)
                local MessageId = Message.MessageId
                if MessageId and SeenMessageIds[MessageId] then
                    return
                end
                if MessageId then
                    SeenMessageIds[MessageId] = true
                end

                local Source = Message.TextSource
                local Speaker = Source and Players:GetPlayerByUserId(Source.UserId)
                local SpeakerName = Speaker and (Speaker.DisplayName or Speaker.Name)
                    or (Message.PrefixText ~= "" and Message.PrefixText)
                    or "System"

                AddChatLine(Format("%s: %s", tostring(SpeakerName), tostring(Message.Text or "")))
            end)
        else
            -- Fallback for experiences still using the legacy chat system.
            local function ConnectLegacyChat(Player)
                Player.Chatted:Connect(function(Message)
                    AddChatLine(Format("%s: %s", Player.DisplayName or Player.Name, tostring(Message)))
                end)
            end

            for _, Player in ipairs(Players:GetPlayers()) do
                ConnectLegacyChat(Player)
            end
            Players.PlayerAdded:Connect(ConnectLegacyChat)
        end
    end
end



-- Watermark, Keybinds and Dock ----------------------------------------------
Watermark = Window:Watermark({
    Text = "",
    Enabled = true
})

KeybindsList = Window:KeybindsList({
    Enabled = true
})

Dock = Library:Dock({
    Text = GSub("constant.cc | {date}", "{date}", Date("%B. %d, %Y")),
    Windows = {
        { Window, "Configurations", false },
        { Environment, "Environment", true },
        { Theme, "Theme", true },
        { Lua, "Lua", true },
        { Activity, "Activity", true },
        { KeybindsList, "Keybinds", false },
        { Watermark, "Watermark", false }
    }
})

-- The Dock library fades the navigation strip in automatically. Explicitly
-- enable it as well so a Settings toggle created before Dock initialization
-- cannot leave the strip hidden due to its callback firing too early.
if Dock and type(Dock.Enable) == "function" then
    local DockFlag = Flags["Dock Enabled"]
    Dock.Enable(not DockFlag or DockFlag.Value ~= false)
end

if Flags["Additional Menu Keybind"] then
    Flags["Additional Menu Keybind"].SetKeyFromInput(Enum.KeyCode.Delete)
end

-- Lightweight FPS / ping update for the watermark; no game-specific hooks.
do
    local FrameCount = 0
    local Elapsed = 0
    local FPS = 0
    local WatermarkTimer = 0

    local function GetPing()
        local Success, Value = pcall(function()
            return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if Success and tonumber(Value) then
            return Round(Value)
        end
        return 0
    end

    RunService.RenderStepped:Connect(function(DeltaTime)
        FrameCount += 1
        Elapsed += DeltaTime
        WatermarkTimer += DeltaTime

        if Elapsed >= 1 then
            FPS = Round(FrameCount / Elapsed)
            FrameCount = 0
            Elapsed = 0
        end

        if WatermarkTimer >= 0.5 then
            WatermarkTimer = 0
            if Watermark and Watermark.IsVisible then
                local Text = Flags["Custom Watermark"] and Flags["Custom Watermark"].Value
                    or "constant.cc | {date} | {uid} | {fps} fps | {ping} ms"

                Text = GSub(Text, "{date}", Date("%B. %d, %Y"))
                Text = GSub(Text, "{uid}", tostring(LocalPlayer.UserId))
                Text = GSub(Text, "{fps}", tostring(FPS))
                Text = GSub(Text, "{ping}", tostring(GetPing()))

                Watermark.SetText(Text)
            end
        end
    end)
end

-- No game hooks, weapon manipulation, targeting, movement changes or ESP logic
-- are initialized anywhere in this Example.
