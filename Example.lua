-- ConstantUI - complete API example
-- Place ConstantUI.lua in a ModuleScript named "ConstantUI" next to this script,
-- or adapt the require line to your own module path.
-- This source framework uses executor file/font/image APIs during initialization.

local Library = require(script.Parent.ConstantUI)

local function Notify(Text)
    Library:Notify({ Text = Text, Time = 3 })
end

-- Main window ---------------------------------------------------------------
local Window = Library:Window({
    Name = "ConstantUI Example",
    Size = UDim2.fromOffset(690, 560),
    Bind = Enum.KeyCode.RightAlt,
    Visible = true,
    HasTabs = true
})

-- Second window demonstrates multiple windows and Dock controls.
local ToolsWindow = Library:Window({
    Name = "Tools Example",
    Size = UDim2.fromOffset(420, 330),
    Bind = Enum.KeyCode.RightControl,
    Visible = false,
    HasTabs = true
})

-- Controls tab --------------------------------------------------------------
local ControlsTab = Window:Tab({ Name = "Controls", Opened = true })

local Basic = ControlsTab:Section({
    Name = "Basic controls",
    Side = "Left",
    Fill = true,
    Size = 420
})

local Selection = ControlsTab:Section({
    Name = "Selection and text",
    Side = "Right",
    Fill = true,
    Size = 420
})

-- Toggle + attached keybind.
local MasterToggle = Basic:Toggle({
    Name = "Master toggle",
    Flag = "Demo Master Toggle",
    Default = true,
    Callback = function(Value)
        Notify("Master toggle: " .. tostring(Value))
    end
})

MasterToggle:Keybind({
    Name = "Master toggle key",
    Default = Enum.KeyCode.G,
    Mode = "Toggle",
    Modes = { "Always On", "Toggle", "Held", "Off Hold" },
    Flag = "Demo Master Key",
    Activated = function()
        Notify("Master key activated")
    end,
    Changed = function(Value)
        -- Value is the selected input tuple from the library.
    end
})

-- Expandable toggle. It accepts normal Section controls while expanded.
local ExpandToggle = Basic:ExpandableToggle({
    Name = "Expandable toggle",
    Flag = "Demo Expandable Toggle",
    Default = true,
    Opened = true,
    Size = 145,
    Callback = function(Value)
        Notify("Expandable toggle: " .. tostring(Value))
    end
})

ExpandToggle:Toggle({
    Name = "Nested option",
    Flag = "Demo Nested Toggle",
    Default = false
})

ExpandToggle:Slider({
    Name = "Nested slider",
    Flag = "Demo Nested Slider",
    Min = 0,
    Max = 10,
    Default = 5,
    Decimals = 1
})

ExpandToggle:Dropdown({
    Name = "Nested dropdown",
    Flag = "Demo Nested Dropdown",
    Options = { "First", "Second", "Third" },
    Default = "First"
})

-- Expandable label can also contain the regular section controls.
local ExpandLabel = Basic:ExpandableLabel({
    Text = "Expandable label",
    Opened = true,
    Size = 105
})

ExpandLabel:Label({ Text = "Controls inside an expandable label" })
ExpandLabel:Toggle({ Name = "Label child toggle", Default = false })
ExpandLabel:Button({ Name = "Label child button", Callback = function() Notify("Expandable-label button") end })

-- Label with attached colorpicker.
local ColorLabel = Basic:Label({ Text = "Accent color picker" })
ColorLabel:Colorpicker({
    Color = Color3.fromRGB(90, 140, 255),
    Side = "Right",
    Transparency = 0,
    Flag = "Demo Accent Color",
    Callback = function(Color, Transparency)
        -- Color is a Color3; Transparency is a number when enabled.
    end
})

-- Label with attached keybind.
local BindLabel = Basic:Label({ Text = "Standalone keybind" })
BindLabel:Keybind({
    Name = "Standalone key",
    Default = Enum.KeyCode.K,
    Mode = "Held",
    Modes = { "Always On", "Toggle", "Held", "Off Hold" },
    Activated = function()
        Notify("Standalone key activated")
    end
})

-- Slider, single dropdown, multiselect dropdown, textbox and code editor.
Selection:Slider({
    Name = "Volume",
    Flag = "Demo Volume",
    Min = 0,
    Max = 100,
    Default = 65,
    Prefix = "%",
    Decimals = 0,
    Callback = function(Value) end
})

Selection:Slider({
    Name = "Decimal scale",
    Flag = "Demo Decimal Scale",
    Min = 0,
    Max = 2,
    Default = 0.75,
    Decimals = 2,
    Callback = function(Value) end
})

Selection:Dropdown({
    Name = "Single dropdown",
    Flag = "Demo Single Dropdown",
    Options = { "Alpha", "Bravo", "Charlie", "Delta" },
    Default = "Bravo",
    Callback = function(Value) end
})

-- In this library Dropdown becomes multiselect when Default is a table.
Selection:Dropdown({
    Name = "Multi dropdown",
    Flag = "Demo Multi Dropdown",
    Options = { "Red", "Green", "Blue", "Yellow" },
    Default = { "Red", "Blue" },
    Min = 1,
    Callback = function(Values) end
})

Selection:TextBox({
    Name = "Text box",
    Flag = "Demo Text Box",
    Placeholder = "Enter some text...",
    Default = "Hello ConstantUI",
    RequireSubmit = true,
    ResetOnSubmit = false,
    Callback = function(Text, Submitted)
        if Submitted then Notify("Text submitted: " .. Text) end
    end
})

Selection:CodeBox({
    Flag = "Demo Code Box",
    Default = "-- CodeBox example\nlocal greeting = 'Hello, world!'\nprint(greeting)",
    Size = 150
})

Selection:Button({
    Name = "Run button callback",
    CallbackText = "Done!",
    Callback = function()
        Notify("Button callback executed")
    end
})

Selection:Button({
    Name = "Confirm button",
    Confirm = true,
    Callback = function()
        Notify("Confirmed")
    end
})

-- List control --------------------------------------------------------------
local ItemList = Selection:List({
    Flag = "Demo List",
    Rows = { "Item", "Status", "Group" },
    Size = 120,
    Clickable = true,
    Default = "alpha",
    Options = {
        alpha = { "Alpha", "Ready", "A" },
        bravo = { "Bravo", "Idle", "B" },
        charlie = { "Charlie", "Busy", "A" }
    },
    Callback = function(Key, Data)
        Notify("Selected list item: " .. tostring(Key))
    end
})

-- List's dynamic data methods.
ItemList.Add("delta", { "Delta", "New", "C" })
ItemList.EditValue("delta", { [2] = "Updated" })
ItemList.ShowValues({ "alpha", "bravo", "charlie", "delta" })
ItemList.SetValue("bravo")
-- Available: ItemList.Find(key), ItemList.Remove(key), ItemList.Empty(),
-- ItemList.SetValues(data), ItemList.EditValues(data), ItemList.Sort().

-- Layout tab: Bar, ContentBox, MultiSection and Groupbox ---------------------
local LayoutTab = Window:Tab({ Name = "Layouts" })

local SearchBar
SearchBar = LayoutTab:Bar({
    Side = "Fill",
    ButtonsSide = "Right",
    TextBox = true,
    Placeholder = "Search or submit text...",
    Default = "",
    RequireSubmit = true,
    Buttons = {
        { "Notify", function() Notify("Bar button clicked") end },
        { "Reset", function()
            if SearchBar and SearchBar.Box then SearchBar.Box.Text = "" end
        end }
    },
    Callback = function(Text, Submitted)
        if Submitted then Notify("Bar submitted: " .. Text) end
    end
})

-- Bar button API: Add, Find, Remove, Clear, Refresh, Delete.
SearchBar.Add("Extra", function() Notify("Dynamically added Bar button") end)
SearchBar.Find("Extra")

local Content = LayoutTab:ContentBox({
    Side = "Left",
    Size = 310,
    Offset = 0,
    ScrollDown = true
})
Content:Label({ Text = "ContentBox is a control container." })
Content:Toggle({ Name = "ContentBox toggle", Default = true })
Content:Button({ Name = "ContentBox button", Callback = function() Notify("ContentBox button") end })

-- MultiSection returns the page array first and the manager second.
local MultiPages, Multi = LayoutTab:MultiSection({
    Name = "MultiSection example",
    Side = "Right",
    Fill = true,
    Size = 310,
    Sections = { "General", "Advanced", "About" },
    OpenIndex = 1
})

MultiPages[1]:Label({ Text = "General multisection page" })
MultiPages[1]:Toggle({ Name = "General option", Default = true })
MultiPages[2]:Label({ Text = "Advanced multisection page" })
MultiPages[2]:Slider({ Name = "Advanced value", Min = 1, Max = 20, Default = 10, Decimals = 0 })
MultiPages[3]:Label({ Text = "About this example" })
MultiPages[3]:Button({ Name = "About button", Callback = function() Notify("ConstantUI example") end })

local RuntimePage = Multi.Add("Runtime", false)
RuntimePage:Label({ Text = "Dynamically added multisection page" })
Multi.Find("Runtime")
-- Available: Multi.Add(name, opened), Multi.Find(name), Multi.Remove(name), Multi.Clear().

-- Groupbox is a set of icon tabs inside a regular Section.
local GroupSection = LayoutTab:Section({
    Name = "Icon groups",
    Side = "Fill",
    Fill = true,
    Size = 300
})

local GroupPages, Groupbox = GroupSection:Groupbox({
    OpenIndex = 1,
    Groups = {
        { "General", Library.Assets.Images["Square 4"], UDim2.fromOffset(8, 8) },
        { "Extra", Library.Assets.Images["Up Arrow 4"], UDim2.fromOffset(10, 14) }
    }
})

GroupPages[1]:Label({ Text = "First group page" })
GroupPages[1]:Toggle({ Name = "Group toggle", Default = false })
GroupPages[2]:Label({ Text = "Second group page" })
GroupPages[2]:Button({ Name = "Group button", Callback = function() Notify("Groupbox button") end })

Groupbox.Add(
    "Dynamic",
    Library.Assets.Images["Folder Icon"],
    UDim2.fromOffset(8, 8),
    false
)
local DynamicGroup = Groupbox.Find("Dynamic")
if DynamicGroup then
    DynamicGroup:Label({ Text = "Dynamically added group" })
end
-- Available: Groupbox.Add(name, image, imageSize, opened), Find(name), Remove(name).

-- List/section lookup APIs.
ControlsTab.Find("Basic controls")
LayoutTab.Find("MultiSection example")
Window.Find("Controls")

-- Utility window ------------------------------------------------------------
local ToolsTab = ToolsWindow:Tab({ Name = "Tools", Opened = true })
local ToolsSection = ToolsTab:Section({ Name = "Library utilities", Side = "Fill", Fill = true })
ToolsSection:Label({ Text = "Utility methods" })
ToolsSection:Button({ Name = "Show notification", Callback = function() Notify("Library:Notify works") end })
ToolsSection:Button({ Name = "Show card", Callback = function()
    Library:Card({
        Text = "Library:Card example",
        Position = UDim2.fromOffset(40, 150),
        Size = UDim2.fromOffset(220, 24),
        Draggable = true
    })
end })
ToolsSection:Button({ Name = "Open main window", Callback = function()
    Library:Fade(Window, true)
end })

-- Window-level overlays and Library-level Dock.
local Watermark = Window:Watermark({
    Text = "ConstantUI | {date}",
    Enabled = true
})

local Keybinds = Window:KeybindsList({ Enabled = true })

local Dock = Library:Dock({
    Text = "ConstantUI Example",
    Windows = {
        { Window, "Main", false },
        { ToolsWindow, "Tools", true },
        { Keybinds, "Keybinds", false },
        { Watermark, "Watermark", false }
    }
})

Dock.SetText("ConstantUI Example")
Dock.Enable(true)
Watermark.SetText("ConstantUI Example | {date}")
Keybinds.Enable(true)

-- Library-level helpers.
Library:Notify({ Text = "All example widgets have been created.", Time = 4 })
Library:Find("ConstantUI Example")
Library:SetTheme(Library.Theme, "All")

-- Lifecycle:
-- Library:Unload() removes the UI and disconnects the library's connections.
-- You can also use Window:Find(name), Window:CloseContent(...),
-- Tab:Open(), Section:Open(), Section:Update(), Section:Remove(),
-- Element:Show(), Element:Hide(), and Element:Remove().
