# ConstantUI

Extracted from the supplied Constant.cc UI source. This package keeps the UI framework and its controls; it does not include the original game-specific feature callbacks.

## Files

- `ConstantUI.lua` — the reusable UI library module.
- `Example.lua` — a complete usage example covering the exposed controls and layout builders.

## Runtime requirements

The original renderer uses executor-side file, asset and font APIs during startup (notably `isfolder`, `makefolder`, `writefile`, `getcustomasset`, and `crypt.base64.decode`) and parents its ScreenGui to `CoreGui`. This is therefore an executor-oriented library, not a drop-in Roblox Studio LocalScript. Missing executor APIs must be supplied or the asset loader must be adapted before use in Studio.

Install `ConstantUI.lua` as a ModuleScript, put `Example.lua` in a sibling LocalScript, and use:

```lua
local Library = require(script.Parent.ConstantUI)
```

For a file-based executor workflow, adapt that one line to load the local file that returns the library table.

## Public API

### Library

- `Library:Window(parameters)` / `Library:CreateWindow(parameters)`
- `Library:AddAccent(instance, zIndex, offset, vertical)`
- `Library:Card(parameters)`
- `Library:Notify(parameters)`
- `Library:Dock(parameters)`
- `Library:SetTheme(theme, indexes, keys)`
- `Library:Find(windowName)`
- `Library:Fade(object, visible)`
- `Library:Unload()`
- `Library.Flags`, `Library.Theme`, `Library.Assets`, `Library.Folders`, `Library.Menu`

### Window

- `Window:Tab(parameters)`
- `Window:Watermark(parameters)`
- `Window:KeybindsList(parameters)`
- `Window:Find(tabName)`
- `Window:CloseContent(content)`

### Tab

- `Tab:Bar(parameters)`
- `Tab:ContentBox(parameters)`
- `Tab:Section(parameters)`
- `Tab:MultiSection(parameters)` — returns `pages, multiSectionManager`
- `Tab:Find(sectionName)`
- `Tab:Open()`

### Section / ContentBox / MultiSection page / Groupbox page

- `:Groupbox(parameters)` — returns `groups, groupboxManager`
- `:Toggle(parameters)`
- `:ExpandableToggle(parameters)`
- `:ExpandableLabel(parameters)`
- `:Slider(parameters)`
- `:Dropdown(parameters)`
- `:TextBox(parameters)`
- `:CodeBox(parameters)`
- `:Button(parameters)`
- `:List(parameters)`
- `:Label(parameters)`
- `:Open()`, `:Update()`, `:Remove()`

`Dropdown` also provides multi-select behavior: pass a table as `Default`, e.g. `Default = {"A", "B"}`. The supplied source does not define a separate `MultiDropdown` method.

### Element chaining

- `Toggle:Keybind(parameters)`
- `Label:Keybind(parameters)`
- `Label:Colorpicker(parameters)`
- Elements provide visibility/removal methods where applicable: `:Show()`, `:Hide()`, `:Remove()`.

### Groupbox manager

- `groups, groupbox = section:Groupbox(parameters)`
- `groupbox.Add(name, image, imageSize, opened)`
- `groupbox.Find(name)`
- `groupbox.Remove(name)`

### MultiSection manager

- `pages, multi = tab:MultiSection(parameters)`
- `multi.Add(name, opened)`
- `multi.Find(name)`
- `multi.Remove(name)`
- `multi.Clear()`

### Bar

`Tab:Bar(parameters)` supports a textbox, buttons, and callback. The returned bar exposes `Add`, `Find`, `Remove`, `Clear`, `Refresh`, and `Delete`.

### Other element managers

- `Window:Watermark(parameters)` returns an object with `Get`, `Set`, `SetText`, and `Enable`.
- `Window:KeybindsList(parameters)` returns an object with `Enable`, `Add`, `Remove`, and `Find`.
- `Library:Dock(parameters)` returns an object with `SetText`, `Add`, `Remove`, `Find`, and `Enable`.
- `Library:Card(parameters)` creates a styled card; `Library:Notify(parameters)` creates a notification.

### List

The returned list exposes `Add`, `Find`, `Remove`, `Empty`, `SetValues`, `EditValue`, `EditValues`, `ShowValues`, `SetValue`, `Sort`, and `Update`.

## Notes

- The visual framework is retained from the supplied source rather than rewritten into a new visual design.
- `Example.lua` intentionally demonstrates only harmless UI callbacks (notifications and local UI updates).
- No separate multi-dropdown constructor exists in the source; use `Dropdown` with a table default for multiple selections.
