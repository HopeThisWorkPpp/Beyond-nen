--[[
 MythiOs UI Library V5
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
 LocalPlayer = Players.PlayerAdded:Wait()
end

local function isCompact()
 local cam = workspace.CurrentCamera
 local vs = cam and cam.ViewportSize or Vector2.new(1280, 720)
 if vs.X > 0 and vs.X < 820 then
  return true
 end
 return UserInputService.TouchEnabled == true and UserInputService.KeyboardEnabled ~= true
end

local function viewportSize()
 local cam = workspace.CurrentCamera
 if cam then
  return cam.ViewportSize
 end
 return Vector2.new(1280, 720)
end

local function guiPointer(input)
 if input then
  return Vector2.new(input.Position.X, input.Position.Y)
 end
 return UserInputService:GetMouseLocation()
end

local function pointer01(gui, input)
 local p = guiPointer(input)
 local abs = gui.AbsolutePosition
 local size = gui.AbsoluteSize
 return math.clamp((p.X - abs.X) / math.max(1, size.X), 0, 1), math.clamp((p.Y - abs.Y) / math.max(1, size.Y), 0, 1)
end

-- Dark purple
local Theme = {
 bg = Color3.fromRGB(12, 10, 18),
 panel = Color3.fromRGB(18, 14, 26),
 panelAlt = Color3.fromRGB(28, 22, 40),
 sidebar = Color3.fromRGB(10, 8, 16),
 stroke = Color3.fromRGB(52, 40, 72),
 accent = Color3.fromRGB(168, 85, 247),
 accentDim = Color3.fromRGB(126, 58, 196),
 mint = Color3.fromRGB(52, 211, 153),
 cyan = Color3.fromRGB(196, 181, 253),
 rose = Color3.fromRGB(248, 113, 113),
 text = Color3.fromRGB(244, 240, 255),
 textDim = Color3.fromRGB(156, 148, 176),
 off = Color3.fromRGB(42, 34, 56),
 tabIdle = Color3.fromRGB(10, 8, 16),
 tabHover = Color3.fromRGB(32, 24, 48),
}

local function parentGui(gui)
 local function protect(inst)
  pcall(function()
   syn.protect_gui(inst)
  end)
  pcall(function()
   protectgui(inst)
  end)
  pcall(function()
   protect_gui(inst)
  end)
 end
 if gui then
  protect(gui)
 end
 if typeof(gethui) == "function" then
  local ok, hui = pcall(gethui)
  if ok and hui then
   if gui then
    gui.Parent = hui
    return hui
   end
   return hui
  end
 end
 local okCore, core = pcall(function()
  return game:GetService("CoreGui")
 end)
 if okCore and core then
  pcall(function()
   if typeof(cloneref) == "function" then
    core = cloneref(core)
   end
  end)
  if gui then
   local okP = pcall(function()
    gui.Parent = core
   end)
   if okP and gui.Parent then
    return core
   end
  else
   return core
  end
 end
 local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 8)
 if gui and pg then
  gui.Parent = pg
 end
 return pg
end

local function mk(className, props, parent)
 local inst = Instance.new(className)
 for k, v in pairs(props) do
 inst[k] = v
 end
 if parent then
 inst.Parent = parent
 end
 return inst
end

local function corner(parent, r)
 return mk("UICorner", { CornerRadius = UDim.new(0, r or 10) }, parent)
end

local function stroke(parent, color, th, tr)
 return mk("UIStroke", {
 Color = color or Theme.stroke,
 Thickness = th or 1,
 Transparency = tr or 0.25,
 ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
 }, parent)
end

local brandImage = nil
local function getBrandImage()
 if brandImage ~= nil then
  return brandImage
 end
 brandImage = ""
 pcall(function()
  if typeof(isfile) ~= "function" or typeof(getcustomasset) ~= "function" then
   return
  end
  local paths = {
   "MythiOs/icon.jpg",
   "MythiOs/icon.png",
   "Scripts/MythiOs/icon.jpg",
  }
  for i = 1, #paths do
   local path = paths[i]
   if isfile(path) then
    local ok, asset = pcall(getcustomasset, path)
    if ok and type(asset) == "string" and asset ~= "" then
     brandImage = asset
     return
    end
   end
  end
 end)
 return brandImage
end

local function makeBrand(parent, size, z)
 size = size or 28
 z = z or 21
 local wrap = mk("Frame", {
 Name = "Brand",
 BackgroundColor3 = Color3.fromRGB(12, 8, 24),
 BorderSizePixel = 0,
 Size = UDim2.fromOffset(size, size),
 ClipsDescendants = true,
 ZIndex = z,
 }, parent)
 corner(wrap, math.floor(size * 0.5))
 local img = getBrandImage()
 if img ~= "" then
  mk("ImageLabel", {
   BackgroundTransparency = 1,
   Size = UDim2.fromScale(1, 1),
   Image = img,
   ScaleType = Enum.ScaleType.Crop,
   ZIndex = z + 1,
  }, wrap)
 else
  wrap.BackgroundColor3 = Theme.accent
  mk("TextLabel", {
   BackgroundTransparency = 1,
   Size = UDim2.fromScale(1, 1),
   Font = Enum.Font.GothamBold,
   Text = "M",
   TextColor3 = Color3.fromRGB(16, 14, 12),
   TextSize = math.max(12, math.floor(size * 0.48)),
   ZIndex = z + 1,
  }, wrap)
 end
 return wrap
end

local function readableDesc(s)
 s = tostring(s or "")
 if s == "" then
  return s
 end
 return (string.gsub(s, " +", "   "))
end

local function pad(parent, t, b, l, r)
 return mk("UIPadding", {
 PaddingTop = UDim.new(0, t or 0),
 PaddingBottom = UDim.new(0, b or 0),
 PaddingLeft = UDim.new(0, l or 0),
 PaddingRight = UDim.new(0, r or 0),
 }, parent)
end

local function tween(obj, props, t, style, dir)
 if not obj then
 return nil
 end
 local tw = TweenService:Create(
 obj,
 TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
 props
 )
 tw:Play()
 return tw
end

local function ensureScale(gui)
 local s = gui:FindFirstChild("AnimScale")
 if not s then
 s = mk("UIScale", { Name = "AnimScale", Scale = 1 }, gui)
 end
 return s
end

local function hoverScale(gui, grow)
 local s = ensureScale(gui)
 gui.MouseEnter:Connect(function()
 tween(s, { Scale = grow or 1.04 }, 0.14, Enum.EasingStyle.Quad)
 end)
 gui.MouseLeave:Connect(function()
 tween(s, { Scale = 1 }, 0.18, Enum.EasingStyle.Quad)
 end)
end

local function pressPunch(gui)
 local s = ensureScale(gui)
 s.Scale = 0.94
 tween(s, { Scale = 1 }, 0.22, Enum.EasingStyle.Back)
end

local Library = {
 Theme = Theme,
 Windows = {},
}
local activeDropdownClose = nil

function Library.SetTheme(patch)
 for k, v in pairs(patch or {}) do
 Theme[k] = v
 end
end

local loadingGui
local loadingText
local loadingFill
local loadingDots
local loadingLabel = ""

local function findNamedGui(name)
 local found
 pcall(function()
  if typeof(gethui) == "function" then
   local ok, hui = pcall(gethui)
   if ok and hui then
    found = hui:FindFirstChild(name)
   end
  end
 end)
 if not found then
  pcall(function()
   found = game:GetService("CoreGui"):FindFirstChild(name)
  end)
 end
 if not found then
  local pg = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
  found = pg and pg:FindFirstChild(name)
 end
 return found
end

function Library.HideLoading()
 loadingDots = false
 if loadingGui then
  pcall(function()
   loadingGui:Destroy()
  end)
 end
 loadingGui = nil
 loadingText = nil
 loadingFill = nil
end

function Library.SetLoading(msg)
 loadingLabel = tostring(msg or "")
 loadingLabel = string.gsub(loadingLabel, "%.+$", "")
 if loadingText then
  loadingText.Text = loadingLabel .. "..."
  loadingText.TextColor3 = Theme.textDim
 end
 if loadingFill then
  loadingFill.Size = UDim2.new(0, 0, 1, 0)
  tween(loadingFill, { Size = UDim2.new(1, 0, 1, 0) }, 0.9, Enum.EasingStyle.Quart)
 end
end

function Library.FailLoading(msg)
 loadingDots = false
 local text = tostring(msg or "Failed to load")
 if loadingText then
  loadingText.Text = text
  loadingText.TextColor3 = Theme.rose
 else
  warn("[MythiOs] " .. text)
 end
 task.delay(6, function()
  Library.HideLoading()
 end)
end

function Library.ShowLoading(opts)
 opts = opts or {}
 Library.HideLoading()
 local old = findNamedGui("MythiOsLoading") or findNamedGui("MythiOsLoader")
 if old then
  pcall(function()
   old:Destroy()
  end)
 end
 local splash = mk("ScreenGui", {
  Name = "MythiOsLoading",
  ResetOnSpawn = false,
  IgnoreGuiInset = true,
  DisplayOrder = 200000,
  ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
 })
 pcall(function()
  splash.ClipToDeviceSafeArea = false
 end)
 local overlay = mk("Frame", {
  Size = UDim2.fromScale(1, 1),
  BackgroundColor3 = Color3.fromRGB(0, 0, 0),
  BackgroundTransparency = 0.22,
  BorderSizePixel = 0,
 }, splash)
 local vs = viewportSize()
 local scale = math.clamp(math.min(vs.X / 420, vs.Y / 320), 0.72, 1.15)
 local card = mk("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromScale(0.5, 0.5),
  Size = UDim2.fromOffset(math.floor(300 * scale), math.floor(176 * scale)),
  BackgroundColor3 = Theme.panel,
  BorderSizePixel = 0,
 }, overlay)
 corner(card, 14)
 stroke(card, Theme.accent, 1, 0.25)
 mk("Frame", {
  AnchorPoint = Vector2.new(0.5, 0),
  Position = UDim2.new(0.5, 0, 0, 0),
  Size = UDim2.new(1, 0, 0, 3),
  BackgroundColor3 = Theme.accent,
  BorderSizePixel = 0,
 }, card)
 local badge = mk("Frame", {
  AnchorPoint = Vector2.new(0.5, 0),
  Position = UDim2.new(0.5, 0, 0, 28),
  Size = UDim2.fromOffset(42, 42),
  BackgroundColor3 = Theme.accent,
  BorderSizePixel = 0,
 }, card)
 corner(badge, 21)
 mk("TextLabel", {
  BackgroundTransparency = 1,
  Size = UDim2.fromScale(1, 1),
  Font = Enum.Font.GothamBold,
  Text = tostring(opts.Brand or "M"),
  TextColor3 = Color3.fromRGB(16, 14, 12),
  TextSize = 20,
 }, badge)
 mk("TextLabel", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(16, 80),
  Size = UDim2.new(1, -32, 0, 24),
  Font = Enum.Font.GothamBold,
  TextSize = 18,
  TextColor3 = Theme.text,
  Text = tostring(opts.Title or "MythiOs"),
 }, card)
 loadingText = mk("TextLabel", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(16, 104),
  Size = UDim2.new(1, -32, 0, 16),
  Font = Enum.Font.Gotham,
  TextSize = 11,
  TextColor3 = Theme.textDim,
  Text = "Loading...",
 }, card)
 local track = mk("Frame", {
  Position = UDim2.fromOffset(28, 136),
  Size = UDim2.new(1, -56, 0, 6),
  BackgroundColor3 = Theme.off,
  BorderSizePixel = 0,
 }, card)
 corner(track, 3)
 loadingFill = mk("Frame", {
  Size = UDim2.new(0, 0, 1, 0),
  BackgroundColor3 = Theme.accent,
  BorderSizePixel = 0,
 }, track)
 corner(loadingFill, 3)
 loadingGui = splash
 parentGui(splash)
 loadingDots = true
 task.spawn(function()
  local n = 0
  while loadingDots and loadingText and loadingText.Parent do
   n = (n % 3) + 1
   if loadingLabel ~= "" then
    loadingText.Text = loadingLabel .. string.rep(".", n)
   end
   task.wait(0.28)
  end
 end)
 Library.SetLoading(opts.Text or "Loading")
 return splash
end

local ICON_KIND = {
 ESP = "grid",
 Aim = "crosshair",
 Silent = "circle",
 Trigger = "bolt",
 Rage = "flame",
 Mods = "sliders",
 Lobby = "home",
 Queue = "list",
 Security = "shield",
 Config = "gear",
 Visuals = "grid",
 Misc = "dots",
 Configs = "list",
 Settings = "gear",
 Preview = "eye",
 Color = "drop",
 Filters = "funnel",
 Extras = "spark",
 Aimbot = "crosshair",
 Targeting = "crosshair",
 Precision = "sliders",
 Humanization = "dots",
 Visuals = "grid",
 Box = "grid",
 Info = "list",
}

local popupLayer = nil
local activeColorClose = nil

local function mark(parent, props)
 local f = mk("Frame", {
 Name = "IconMark",
 BackgroundColor3 = props.Color or Theme.textDim,
 BackgroundTransparency = props.Transparency or 0,
 BorderSizePixel = 0,
 Size = props.Size,
 Position = props.Position or UDim2.fromOffset(0, 0),
 AnchorPoint = props.Anchor or Vector2.new(0, 0),
 Rotation = props.Rotation or 0,
 ZIndex = (parent.ZIndex or 1) + 1,
 }, parent)
 if props.Corner then
 corner(f, props.Corner)
 end
 if props.Stroke then
 stroke(f, props.Color or Theme.textDim, props.Stroke, 0)
 f.BackgroundTransparency = 1
 end
 return f
end

local function clearMarks(box)
 for _, child in ipairs(box:GetChildren()) do
 if child.Name == "IconMark" then
 child:Destroy()
 end
 end
end

local function paintIcon(box, kind, color)
 color = color or Theme.textDim
 kind = ICON_KIND[tostring(kind or "")] or tostring(kind or "dot")
 clearMarks(box)
 if kind == "crosshair" then
 mark(box, { Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(6, 6), Corner = 6, Color = color, Stroke = 1.4 })
 mark(box, { Size = UDim2.fromOffset(2, 10), Position = UDim2.fromOffset(11, 7), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(10, 2), Position = UDim2.fromOffset(7, 11), Corner = 1, Color = color })
 elseif kind == "grid" then
 mark(box, { Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(4, 4), Corner = 2, Color = color, Stroke = 1.2 })
 mark(box, { Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(13, 4), Corner = 2, Color = color, Stroke = 1.2 })
 mark(box, { Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(4, 13), Corner = 2, Color = color, Stroke = 1.2 })
 mark(box, { Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(13, 13), Corner = 2, Color = color, Stroke = 1.2 })
 elseif kind == "circle" then
 mark(box, { Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(6, 6), Corner = 6, Color = color, Stroke = 1.4 })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(10, 10), Corner = 2, Color = color })
 elseif kind == "bolt" then
 mark(box, { Size = UDim2.fromOffset(8, 3), Position = UDim2.fromOffset(10, 6), Rotation = 35, Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(8, 3), Position = UDim2.fromOffset(6, 12), Rotation = 35, Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(3, 12), Position = UDim2.fromOffset(10, 6), Rotation = 20, Corner = 1, Color = color })
 elseif kind == "flame" then
 mark(box, { Size = UDim2.fromOffset(10, 14), Position = UDim2.fromOffset(7, 5), Corner = 5, Color = color })
 mark(box, { Size = UDim2.fromOffset(6, 8), Position = UDim2.fromOffset(9, 9), Corner = 3, Color = Theme.sidebar })
 elseif kind == "sliders" then
 mark(box, { Size = UDim2.fromOffset(14, 2), Position = UDim2.fromOffset(5, 7), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(14, 2), Position = UDim2.fromOffset(5, 12), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(14, 2), Position = UDim2.fromOffset(5, 17), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(8, 6), Corner = 2, Color = color })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(14, 11), Corner = 2, Color = color })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(7, 16), Corner = 2, Color = color })
 elseif kind == "home" then
 mark(box, { Size = UDim2.fromOffset(12, 8), Position = UDim2.fromOffset(6, 11), Corner = 2, Color = color, Stroke = 1.2 })
 mark(box, { Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(7, 5), Rotation = 45, Corner = 2, Color = color })
 elseif kind == "list" then
 mark(box, { Size = UDim2.fromOffset(12, 2), Position = UDim2.fromOffset(8, 7), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(12, 2), Position = UDim2.fromOffset(8, 12), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(12, 2), Position = UDim2.fromOffset(8, 17), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(2, 2), Position = UDim2.fromOffset(4, 7), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(2, 2), Position = UDim2.fromOffset(4, 12), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(2, 2), Position = UDim2.fromOffset(4, 17), Corner = 1, Color = color })
 elseif kind == "shield" then
 mark(box, { Size = UDim2.fromOffset(12, 14), Position = UDim2.fromOffset(6, 5), Corner = 6, Color = color, Stroke = 1.3 })
 elseif kind == "gear" then
 mark(box, { Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(7, 7), Corner = 5, Color = color, Stroke = 1.4 })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(10, 10), Corner = 2, Color = color })
 elseif kind == "drop" then
 mark(box, { Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(7, 8), Corner = 5, Color = color })
 mark(box, { Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(9, 6), Rotation = 45, Corner = 1, Color = color })
 elseif kind == "funnel" then
 mark(box, { Size = UDim2.fromOffset(14, 3), Position = UDim2.fromOffset(5, 7), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(8, 3), Position = UDim2.fromOffset(8, 12), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(4, 6), Position = UDim2.fromOffset(10, 14), Corner = 1, Color = color })
 elseif kind == "spark" then
 mark(box, { Size = UDim2.fromOffset(2, 12), Position = UDim2.fromOffset(11, 6), Corner = 1, Color = color })
 mark(box, { Size = UDim2.fromOffset(12, 2), Position = UDim2.fromOffset(6, 11), Corner = 1, Color = color })
 elseif kind == "eye" then
 mark(box, { Size = UDim2.fromOffset(14, 8), Position = UDim2.fromOffset(5, 8), Corner = 4, Color = color, Stroke = 1.2 })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(10, 10), Corner = 2, Color = color })
 elseif kind == "dots" then
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(5, 10), Corner = 2, Color = color })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(10, 10), Corner = 2, Color = color })
 mark(box, { Size = UDim2.fromOffset(4, 4), Position = UDim2.fromOffset(15, 10), Corner = 2, Color = color })
 else
 mark(box, { Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(8, 8), Corner = 4, Color = color })
 end
end

local function setIconColor(box, color)
 for _, child in ipairs(box:GetChildren()) do
 if child.Name == "IconMark" then
 if child.BackgroundTransparency < 1 then
 child.BackgroundColor3 = color
 end
 local s = child:FindFirstChildOfClass("UIStroke")
 if s then
 s.Color = color
 end
 end
 end
end

local function rgbToHsv(c)
 local r, g, b = c.R, c.G, c.B
 local maxv = math.max(r, g, b)
 local minv = math.min(r, g, b)
 local d = maxv - minv
 local h = 0
 if d > 1e-5 then
 if maxv == r then
 h = ((g - b) / d) % 6
 elseif maxv == g then
 h = (b - r) / d + 2
 else
 h = (r - g) / d + 4
 end
 h /= 6
 end
 local s = maxv <= 1e-5 and 0 or d / maxv
 return h, s, maxv
end

local function hsvToRgb(h, s, v)
 h = ((h % 1) + 1) % 1
 local i = math.floor(h * 6)
 local f = h * 6 - i
 local p = v * (1 - s)
 local q = v * (1 - f * s)
 local t = v * (1 - (1 - f) * s)
 i = i % 6
 if i == 0 then
 return Color3.new(v, t, p)
 elseif i == 1 then
 return Color3.new(q, v, p)
 elseif i == 2 then
 return Color3.new(p, v, t)
 elseif i == 3 then
 return Color3.new(p, q, v)
 elseif i == 4 then
 return Color3.new(t, p, v)
 end
 return Color3.new(v, p, q)
end

local function makeSection(host, title)
 local card = mk("Frame", {
 BackgroundColor3 = Theme.panel,
 BorderSizePixel = 0,
 Size = UDim2.new(1, 0, 0, 0),
 AutomaticSize = Enum.AutomaticSize.Y,
 }, host)
 corner(card, 16)
 local cardStroke = stroke(card, Theme.stroke, 1, 0.55)
 pad(card, 16, 16, 16, 16)
 card.MouseEnter:Connect(function()
 tween(cardStroke, { Color = Theme.accent, Transparency = 0.28 }, 0.18)
 end)
 card.MouseLeave:Connect(function()
 tween(cardStroke, { Color = Theme.stroke, Transparency = 0.55 }, 0.22)
 end)

 local list = mk("UIListLayout", {
 Padding = UDim.new(0, 10),
 SortOrder = Enum.SortOrder.LayoutOrder,
 }, card)

 local head = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 28),
 LayoutOrder = 0,
 }, card)

 local iconBox = mk("Frame", {
 BackgroundColor3 = Color3.fromRGB(36, 28, 54),
 BorderSizePixel = 0,
 Size = UDim2.fromOffset(26, 26),
 Position = UDim2.fromOffset(0, 1),
 }, head)
 corner(iconBox, 7)
 paintIcon(iconBox, title, Theme.accent)

 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(34, 0),
 Size = UDim2.new(1, -34, 1, 0),
 Font = Enum.Font.GothamBold,
 Text = title or "Section",
 TextColor3 = Theme.text,
 TextSize = 14,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, head)

 local order = 0
 local api = { Instance = card, _items = {}, _title = string.lower(tostring(title or "")) }

 local function nextOrder()
 order += 1
 return order
 end

 local function trackSearch(text, root)
 table.insert(api._items, { text = string.lower(tostring(text or "")), root = root })
 end

 function api:SetSearch(query)
 local q = string.lower(tostring(query or ""))
 local titleHit = q == "" or string.find(self._title, q, 1, true) ~= nil
 local any = titleHit
 for _, item in ipairs(self._items) do
 local show = q == "" or titleHit or string.find(item.text, q, 1, true) ~= nil
 item.root.Visible = show
 if show then
 any = true
 end
 end
 self.Instance.Visible = any
 return any
 end

 function api:Label(text)
 local row = mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 0),
 AutomaticSize = Enum.AutomaticSize.Y,
 Font = Enum.Font.Gotham,
 Text = tostring(text or ""),
 TextColor3 = Theme.textDim,
 TextSize = 11,
 TextWrapped = true,
 TextXAlignment = Enum.TextXAlignment.Left,
 LayoutOrder = nextOrder(),
 }, card)
 trackSearch(text, row)
 return row
 end

 function api:Toggle(opts)
 opts = opts or {}
 local desc = tostring(opts.Description or "")
 local rowH = desc ~= "" and 40 or 30
 local row = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, rowH),
 LayoutOrder = nextOrder(),
 }, card)
 trackSearch(tostring(opts.Text or "") .. " " .. desc, row)

 mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, -56, 0, 16),
 Position = UDim2.fromOffset(0, desc ~= "" and 2 or 7),
 Font = Enum.Font.GothamMedium,
 Text = tostring(opts.Text or "Toggle"),
 TextColor3 = Theme.text,
 TextSize = 13,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, row)
 if desc ~= "" then
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 20),
 Size = UDim2.new(1, -56, 0, 16),
 Font = Enum.Font.Gotham,
 Text = readableDesc(desc),
 TextColor3 = Theme.textDim,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 }, row)
 end

 local on = opts.Default == true
 local accent = opts.Accent or Theme.accent
 local track = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = on and accent or Theme.off,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(1, 0.5),
 Position = UDim2.new(1, 0, 0.5, 0),
 Size = UDim2.fromOffset(42, 24),
 Text = "",
 }, row)
 corner(track, 12)
 local knob = mk("Frame", {
 BackgroundColor3 = Color3.fromRGB(255, 255, 255),
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(0, 0.5),
 Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
 Size = UDim2.fromOffset(18, 18),
 ZIndex = 2,
 }, track)
 corner(knob, 9)

 local ctrl = {
 Flag = opts.Flag,
 Get = function()
 return on
 end,
 }
 function ctrl:Set(v, silent)
 on = v and true or false
 tween(track, { BackgroundColor3 = on and accent or Theme.off }, 0.16)
 tween(knob, { Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, 0.16)
 if not silent and opts.Callback then
 opts.Callback(on)
 end
 end

 hoverScale(track, 1.04)
 track.MouseButton1Click:Connect(function()
 pressPunch(track)
 ctrl:Set(not on, false)
 end)
 return ctrl
 end

 function api:Button(opts)
 opts = opts or {}
 local btn = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 Size = UDim2.new(1, 0, 0, 32),
 Font = Enum.Font.GothamBold,
 Text = tostring(opts.Text or "Button"),
 TextColor3 = opts.Danger and Theme.rose or Theme.accent,
 TextSize = 12,
 LayoutOrder = nextOrder(),
 }, card)
 corner(btn, 9)
 stroke(btn, opts.Danger and Theme.rose or Theme.accentDim, 1, 0.45)
 trackSearch(opts.Text, btn)
 hoverScale(btn, 1.02)
 btn.MouseButton1Click:Connect(function()
 pressPunch(btn)
 if opts.Callback then
 opts.Callback(btn)
 end
 end)
 btn.MouseEnter:Connect(function()
 tween(btn, { BackgroundColor3 = Theme.tabHover }, 0.14)
 end)
 btn.MouseLeave:Connect(function()
 tween(btn, { BackgroundColor3 = Theme.panelAlt }, 0.2)
 end)
 return btn
 end

 function api:Slider(opts)
 opts = opts or {}
 local minV = tonumber(opts.Min) or 0
 local maxV = tonumber(opts.Max) or 1
 local value = math.clamp(tonumber(opts.Default) or minV, minV, maxV)
 local desc = tostring(opts.Description or "")
 local row = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, desc ~= "" and 54 or 40),
 LayoutOrder = nextOrder(),
 }, card)
 trackSearch((opts.Text or "") .. " " .. desc, row)

 local title = mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, -48, 0, 16),
 Font = Enum.Font.GothamMedium,
 Text = tostring(opts.Text or "Slider"),
 TextColor3 = Theme.text,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, row)
 if desc ~= "" then
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 16),
 Size = UDim2.new(1, -48, 0, 14),
 Font = Enum.Font.Gotham,
 Text = readableDesc(desc),
 TextColor3 = Theme.textDim,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 }, row)
 end
 local valLabel = mk("TextLabel", {
 BackgroundTransparency = 1,
 AnchorPoint = Vector2.new(1, 0),
 Position = UDim2.new(1, 0, 0, 0),
 Size = UDim2.fromOffset(48, 16),
 Font = Enum.Font.GothamBold,
 Text = string.format(opts.Format or "%.2f", value),
 TextColor3 = Theme.textDim,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Right,
 }, row)

 local bar = mk("Frame", {
 BackgroundColor3 = Theme.off,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(0, desc ~= "" and 34 or 24),
 Size = UDim2.new(1, 0, 0, 6),
 }, row)
 corner(bar, 3)
 local fill = mk("Frame", {
 BackgroundColor3 = Theme.accent,
 BorderSizePixel = 0,
 Size = UDim2.new((value - minV) / math.max(0.001, maxV - minV), 0, 1, 0),
 }, bar)
 corner(fill, 3)
 local knob = mk("Frame", {
 BackgroundColor3 = Color3.fromRGB(255, 255, 255),
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(0.5, 0.5),
 Position = UDim2.new((value - minV) / math.max(0.001, maxV - minV), 0, 0.5, 0),
 Size = UDim2.fromOffset(12, 12),
 }, bar)
 corner(knob, 6)

 local dragging = false
 local ctrl = {}
 local function apply(alpha, silent)
 alpha = math.clamp(alpha, 0, 1)
 value = minV + (maxV - minV) * alpha
 if opts.Step then
 local step = tonumber(opts.Step) or 1
 value = math.floor((value / step) + 0.5) * step
 value = math.clamp(value, minV, maxV)
 alpha = (value - minV) / math.max(0.001, maxV - minV)
 end
 if dragging then
 fill.Size = UDim2.new(alpha, 0, 1, 0)
 knob.Position = UDim2.new(alpha, 0, 0.5, 0)
 else
 tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, 0.16)
 tween(knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, 0.18, Enum.EasingStyle.Back)
 end
 valLabel.Text = string.format(opts.Format or "%.2f", value)
 if not silent and opts.Callback then
 opts.Callback(value)
 end
 end
 function ctrl:Set(v, silent)
 local alpha = (math.clamp(tonumber(v) or minV, minV, maxV) - minV) / math.max(0.001, maxV - minV)
 apply(alpha, silent)
 end
 function ctrl:Get()
 return value
 end
 ctrl.Instance = row

 local function fromX(x)
 local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
 apply(rel, false)
 end
 bar.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 fromX(input.Position.X)
 end
 end)
 UserInputService.InputChanged:Connect(function(input)
 if not dragging then
 return
 end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 fromX(input.Position.X)
 end
 end)
 UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = false
 end
 end)
 return ctrl
 end

 function api:Paragraph(text)
 return self:Label(text)
 end

 function api:TextBox(opts)
 opts = opts or {}
 local row = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 52),
 LayoutOrder = nextOrder(),
 }, card)
 trackSearch(opts.Text or opts.Placeholder, row)
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 16),
 Font = Enum.Font.GothamMedium,
 Text = tostring(opts.Text or "Value"),
 TextColor3 = Theme.text,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, row)
 local box = mk("TextBox", {
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(0, 20),
 Size = UDim2.new(1, 0, 0, 28),
 Font = Enum.Font.Gotham,
 Text = tostring(opts.Default or ""),
 PlaceholderText = tostring(opts.Placeholder or ""),
 PlaceholderColor3 = Theme.textDim,
 TextColor3 = Theme.text,
 TextSize = 12,
 ClearTextOnFocus = false,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, row)
 corner(box, 8)
 pad(box, 0, 0, 10, 10)
 local boxStroke = stroke(box, Theme.stroke, 1, 0.35)
 local ctrl = {}
 function ctrl:Get()
 return box.Text
 end
 function ctrl:Set(text)
 box.Text = tostring(text or "")
 end
 box.Focused:Connect(function()
 tween(boxStroke, { Color = Theme.accent, Transparency = 0.05 }, 0.16)
 tween(box, { BackgroundColor3 = Theme.tabIdle }, 0.16)
 end)
 box.FocusLost:Connect(function(enter)
 tween(boxStroke, { Color = Theme.stroke, Transparency = 0.35 }, 0.2)
 tween(box, { BackgroundColor3 = Theme.panelAlt }, 0.2)
 if opts.Callback then
 opts.Callback(box.Text, enter)
 end
 end)
 return ctrl
 end

 function api:Keybind(opts)
 opts = opts or {}
 local current = opts.Default
 if typeof(current) == "string" then
 current = Enum.KeyCode[current] or Enum.KeyCode.K
 end
 if typeof(current) ~= "EnumItem" then
 current = Enum.KeyCode.K
 end
 local listening = false
 local desc = tostring(opts.Description or "")
 local row = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, desc ~= "" and 46 or 32),
 LayoutOrder = nextOrder(),
 }, card)
 trackSearch((opts.Text or "") .. " " .. desc, row)
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, -92, 0, 16),
 Position = UDim2.fromOffset(0, desc ~= "" and 4 or 8),
 Font = Enum.Font.GothamMedium,
 Text = tostring(opts.Text or "Keybind"),
 TextColor3 = Theme.text,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, row)
 if desc ~= "" then
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 22),
 Size = UDim2.new(1, -92, 0, 14),
 Font = Enum.Font.Gotham,
 Text = readableDesc(desc),
 TextColor3 = Theme.textDim,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 }, row)
 end
 local btn = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(1, 0.5),
 Position = UDim2.new(1, 0, 0.5, 0),
 Size = UDim2.fromOffset(86, 26),
 Font = Enum.Font.GothamBold,
 Text = current.Name,
 TextColor3 = Theme.text,
 TextSize = 11,
 }, row)
 corner(btn, 6)
 stroke(btn, Theme.stroke, 1, 0.3)
 hoverScale(btn, 1.06)
 local ctrl = {}
 local function paint()
 btn.Text = listening and "..." or current.Name
 tween(btn, {
 BackgroundColor3 = listening and Theme.accentDim or Theme.panelAlt,
 TextColor3 = listening and Color3.fromRGB(255, 255, 255) or Theme.text,
 }, 0.16)
 end
 function ctrl:Get()
 return current
 end
 function ctrl:Set(key, silent)
 if typeof(key) == "string" then
 key = Enum.KeyCode[key]
 end
 if typeof(key) ~= "EnumItem" then
 return
 end
 current = key
 listening = false
 paint()
 if not silent and opts.Callback then
 opts.Callback(current)
 end
 end
 btn.MouseButton1Click:Connect(function()
 pressPunch(btn)
 listening = not listening
 paint()
 end)
 UserInputService.InputBegan:Connect(function(input)
 if not listening then
 return
 end
 if input.UserInputType ~= Enum.UserInputType.Keyboard then
 return
 end
 if input.KeyCode == Enum.KeyCode.Unknown or input.KeyCode == Enum.KeyCode.Escape then
 listening = false
 paint()
 return
 end
 ctrl:Set(input.KeyCode, false)
 end)
 paint()
 return ctrl
 end

 function api:ColorPicker(opts)
 opts = opts or {}
 local ignoreColorOutsideUntil = 0
 local current = opts.Default or Theme.accent
 local original = current
 local h, s, v = rgbToHsv(current)
 local desc = tostring(opts.Description or "")
 local row = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, desc ~= "" and 42 or 28),
 LayoutOrder = nextOrder(),
 }, card)
 trackSearch((opts.Text or "Color") .. " " .. desc .. " color picker rgb hue", row)

 local openBtn = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundTransparency = 1,
 Size = UDim2.fromScale(1, 1),
 Text = "",
 }, row)
 local preview = mk("Frame", {
 BackgroundColor3 = current,
 BorderSizePixel = 0,
 Size = UDim2.fromOffset(18, 18),
 Position = UDim2.fromOffset(0, 5),
 ZIndex = 2,
 }, openBtn)
 corner(preview, 5)
 stroke(preview, Color3.fromRGB(255, 255, 255), 1, 0.55)
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(26, desc ~= "" and 2 or 0),
 Size = UDim2.new(1, -26, 0, 16),
 Font = Enum.Font.GothamMedium,
 Text = tostring(opts.Text or "Color"),
 TextColor3 = Theme.text,
 TextSize = 13,
 TextXAlignment = Enum.TextXAlignment.Left,
 ZIndex = 2,
 }, openBtn)
 if desc ~= "" then
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(26, 20),
 Size = UDim2.new(1, -26, 0, 14),
 Font = Enum.Font.Gotham,
 Text = readableDesc(desc),
 TextColor3 = Theme.textDim,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 2,
 }, openBtn)
 end

 local pop
 local svFill
 local hueFill
 local svCursor
 local hueCursor
 local curSwatch
 local rBox
 local gBox
 local bBox
 local dragging = nil
 local svBtn = nil
 local hueBtn = nil

 local ctrl = {}
 local function hueColor()
 return hsvToRgb(h, 1, 1)
 end
 local function apply(silent)
 current = hsvToRgb(h, s, v)
 preview.BackgroundColor3 = current
 if curSwatch then
 curSwatch.BackgroundColor3 = current
 end
 if svFill then
 svFill.Color = ColorSequence.new(Color3.new(1, 1, 1), hueColor())
 end
 if svCursor then
 svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
 end
 if hueCursor then
 hueCursor.Position = UDim2.new(0.5, 0, h, 0)
 end
 if rBox and not rBox:IsFocused() then
 rBox.Text = tostring(math.floor(current.R * 255 + 0.5))
 gBox.Text = tostring(math.floor(current.G * 255 + 0.5))
 bBox.Text = tostring(math.floor(current.B * 255 + 0.5))
 end
 if not silent and opts.Callback then
 opts.Callback(current)
 end
 end

 local function closePop()
 dragging = nil
 if pop then
 pop:Destroy()
 pop = nil
 end
 if activeColorClose == closePop then
 activeColorClose = nil
 end
 end

 local function openPop()
 if activeColorClose then
 activeColorClose()
 end
 if activeDropdownClose then
 pcall(activeDropdownClose, false)
 end
 local host = popupLayer
 if not host then
 return
 end
 pop = mk("Frame", {
 Name = "ColorPop",
 BackgroundColor3 = Theme.panel,
 BorderSizePixel = 0,
 Size = UDim2.fromOffset(278, 214),
 Position = UDim2.fromOffset(8, 64),
 ZIndex = 120,
 }, host)
 corner(pop, 12)
 stroke(pop, Theme.stroke, 1, 0.25)
 local sv = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = Color3.new(1, 1, 1),
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(12, 12),
 Size = UDim2.fromOffset(168, 168),
 Text = "",
 ZIndex = 121,
 }, pop)
 corner(sv, 8)
 svFill = mk("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), hueColor()) }, sv)
 local shade = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = Color3.new(0, 0, 0),
 BorderSizePixel = 0,
 Size = UDim2.fromScale(1, 1),
 Text = "",
 Active = true,
 ZIndex = 122,
 }, sv)
 corner(shade, 8)
 mk("UIGradient", {
 Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
 Transparency = NumberSequence.new({
 NumberSequenceKeypoint.new(0, 1),
 NumberSequenceKeypoint.new(1, 0),
 }),
 Rotation = 90,
 }, shade)
 svCursor = mk("Frame", {
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(0.5, 0.5),
 Size = UDim2.fromOffset(12, 12),
 Active = false,
 ZIndex = 123,
 }, shade)
 pcall(function()
  svCursor.Interactable = false
 end)
 corner(svCursor, 6)
 stroke(svCursor, Color3.new(1, 1, 1), 2, 0)
 local hue = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = Color3.new(1, 1, 1),
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(188, 12),
 Size = UDim2.fromOffset(16, 168),
 Text = "",
 ZIndex = 121,
 }, pop)
 corner(hue, 6)
 mk("UIGradient", {
 Rotation = 90,
 Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
 ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
 ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
 ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
 ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
 ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
 }),
 }, hue)
 hueCursor = mk("Frame", {
 BackgroundTransparency = 1,
 AnchorPoint = Vector2.new(0.5, 0.5),
 Size = UDim2.new(1, 6, 0, 8),
 Active = false,
 ZIndex = 123,
 }, hue)
 pcall(function()
  hueCursor.Interactable = false
 end)
 corner(hueCursor, 4)
 stroke(hueCursor, Color3.new(1, 1, 1), 1.5, 0)
 local side = mk("Frame", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(214, 12),
 Size = UDim2.fromOffset(52, 168),
 ZIndex = 121,
 }, pop)
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 12),
 Font = Enum.Font.Gotham,
 Text = "Current",
 TextColor3 = Theme.textDim,
 TextSize = 9,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, side)
 curSwatch = mk("Frame", {
 BackgroundColor3 = current,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(0, 14),
 Size = UDim2.fromOffset(44, 36),
 }, side)
 corner(curSwatch, 6)
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 54),
 Size = UDim2.new(1, 0, 0, 12),
 Font = Enum.Font.Gotham,
 Text = "Original",
 TextColor3 = Theme.textDim,
 TextSize = 9,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, side)
 local origSwatch = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = original,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(0, 68),
 Size = UDim2.fromOffset(44, 36),
 Text = "",
 }, side)
 corner(origSwatch, 6)
 origSwatch.MouseButton1Click:Connect(function()
 h, s, v = rgbToHsv(original)
 apply(false)
 end)
 local function chan(x, label)
 local box = mk("TextBox", {
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(x, 180),
 Size = UDim2.fromOffset(40, 22),
 Font = Enum.Font.Gotham,
 Text = "0",
 TextColor3 = Theme.text,
 TextSize = 11,
 ClearTextOnFocus = false,
 ZIndex = 122,
 }, pop)
 corner(box, 5)
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(x, 168),
 Size = UDim2.fromOffset(40, 12),
 Font = Enum.Font.Gotham,
 Text = label,
 TextColor3 = Theme.textDim,
 TextSize = 9,
 ZIndex = 122,
 }, pop)
 return box
 end
 rBox = chan(12, "R")
 gBox = chan(56, "G")
 bBox = chan(100, "B")
 local function fromBoxes()
 local rr = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
 local gg = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
 local bb = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
 h, s, v = rgbToHsv(Color3.fromRGB(rr, gg, bb))
 apply(false)
 end
 rBox.FocusLost:Connect(fromBoxes)
 gBox.FocusLost:Connect(fromBoxes)
 bBox.FocusLost:Connect(fromBoxes)
 local function readSv(input)
 local x, y = pointer01(sv, input)
 s = x
 v = 1 - y
 apply(false)
 end
 local function readHue(input)
 local _, y = pointer01(hue, input)
 h = y
 apply(false)
 end
 local function bindDrag(gui, kind)
 gui.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = kind
 if kind == "sv" then
 readSv(input)
 else
 readHue(input)
 end
 end
 end)
 gui.InputChanged:Connect(function(input)
 if dragging ~= kind then
  return
 end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
  if kind == "sv" then
   readSv(input)
  else
   readHue(input)
  end
 end
 end)
 gui.MouseMoved:Connect(function(x, y)
 if dragging ~= kind then
  return
 end
 local size = gui.AbsoluteSize
 local nx = math.clamp(x / math.max(1, size.X), 0, 1)
 local ny = math.clamp(y / math.max(1, size.Y), 0, 1)
 if kind == "sv" then
  s = nx
  v = 1 - ny
 else
  h = ny
 end
 apply(false)
 end)
 end
 bindDrag(sv, "sv")
 bindDrag(shade, "sv")
 bindDrag(hue, "hue")
 apply(true)
 svBtn = sv
 hueBtn = hue
 pop.Position = UDim2.fromOffset(
 math.clamp(preview.AbsolutePosition.X + 28, 12, 900),
 math.clamp(preview.AbsolutePosition.Y, 12, 520)
 )
 activeColorClose = closePop
 ignoreColorOutsideUntil = os.clock() + 0.2
 end

 UserInputService.InputChanged:Connect(function(input)
 if not pop or not dragging then
  return
 end
 if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
  return
 end
 if dragging == "sv" and svBtn then
  local x, y = pointer01(svBtn, input)
  s = x
  v = 1 - y
  apply(false)
 elseif dragging == "hue" and hueBtn then
  local _, y = pointer01(hueBtn, input)
  h = y
  apply(false)
 end
 end)

 UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = nil
 end
 end)

 openBtn.MouseButton1Click:Connect(function()
 if pop then
 closePop()
 else
 openPop()
 end
 end)

 UserInputService.InputBegan:Connect(function(input)
 if not pop then
 return
 end
 if input.KeyCode == Enum.KeyCode.Escape then
 closePop()
 return
 end
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
 return
 end
 if os.clock() < ignoreColorOutsideUntil then
 return
 end
 local p = guiPointer(input)
 local function hit(gui)
 if not gui or not gui.Parent then
 return false
 end
 local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
 return p.X >= pos.X and p.X <= pos.X + size.X and p.Y >= pos.Y and p.Y <= pos.Y + size.Y
 end
 if not hit(pop) and not hit(openBtn) then
 closePop()
 end
 end)

 function ctrl:Set(color, silent)
 if typeof(color) ~= "Color3" then
 return
 end
 h, s, v = rgbToHsv(color)
 apply(silent == true)
 end
 function ctrl:Get()
 return current
 end
 apply(true)
 return ctrl
 end

 function api:Dropdown(opts)
 opts = opts or {}
 local options = {}
 local rawOpts = opts.Options or opts.Values or opts.List or {}
 if type(rawOpts) == "table" then
 if #rawOpts > 0 then
 for _, v in ipairs(rawOpts) do
 table.insert(options, tostring(v))
 end
 else
 for k, v in pairs(rawOpts) do
 local s = type(v) == "string" and v ~= "" and v or (type(k) == "string" and k or "")
 if s ~= "" then
 table.insert(options, s)
 end
 end
 table.sort(options)
 end
 end
 if #options == 0 then
 options = { "None" }
 end
 local value = tostring(opts.Default or options[1])
 if not table.find(options, value) then
 value = options[1]
 end

 local desc = tostring(opts.Description or "")
 local row = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, desc ~= "" and 66 or 52),
 AutomaticSize = Enum.AutomaticSize.Y,
 LayoutOrder = nextOrder(),
 ZIndex = 8,
 }, card)
 trackSearch(tostring(opts.Text or "") .. " " .. desc .. " " .. table.concat(options, " "), row)

 mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 16),
 Font = Enum.Font.GothamMedium,
 Text = tostring(opts.Text or "Select"),
 TextColor3 = Theme.text,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, row)
 if desc ~= "" then
 mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 16),
 Size = UDim2.new(1, 0, 0, 14),
 Font = Enum.Font.Gotham,
 Text = readableDesc(desc),
 TextColor3 = Theme.textDim,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 }, row)
 end

 local trigger = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(0, desc ~= "" and 32 or 20),
 Size = UDim2.new(1, 0, 0, 30),
 Text = "",
 ZIndex = 9,
 }, row)
 corner(trigger, 6)
 local triggerStroke = stroke(trigger, Theme.stroke, 1, 0.35)

 local valueLabel = mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(10, 0),
 Size = UDim2.new(1, -28, 1, 0),
 Font = Enum.Font.Gotham,
 Text = value,
 TextColor3 = Theme.text,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 10,
 }, trigger)

 local chevron = mk("TextLabel", {
 BackgroundTransparency = 1,
 AnchorPoint = Vector2.new(1, 0.5),
 Position = UDim2.new(1, -8, 0.5, 0),
 Size = UDim2.fromOffset(16, 16),
 Font = Enum.Font.GothamBold,
 Text = "v",
 TextColor3 = Theme.textDim,
 TextSize = 12,
 ZIndex = 10,
 }, trigger)

 local open = false
 local itemH = 22
 local host = popupLayer
 local catcher = mk("TextButton", {
 Name = "DropdownCatch",
 AutoButtonColor = false,
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Size = UDim2.fromScale(1, 1),
 Text = "",
 Visible = false,
 ZIndex = 398,
 }, host)
 local menu = mk("Frame", {
 Name = "DropdownMenu",
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 Size = UDim2.fromOffset(200, 0),
 Visible = false,
 Active = true,
 ZIndex = 400,
 ClipsDescendants = true,
 }, host)
 corner(menu, 6)
 stroke(menu, Theme.stroke, 1, 0.3)

 local list = mk("ScrollingFrame", {
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Size = UDim2.new(1, 0, 1, 0),
 ScrollBarThickness = 3,
 ScrollBarImageColor3 = Theme.accentDim,
 CanvasSize = UDim2.new(0, 0, 0, 0),
 AutomaticCanvasSize = Enum.AutomaticSize.Y,
 ScrollingDirection = Enum.ScrollingDirection.Y,
 Active = false,
 ZIndex = 401,
 }, menu)
 pad(list, 3, 3, 3, 3)
 mk("UIListLayout", {
 Padding = UDim.new(0, 1),
 SortOrder = Enum.SortOrder.LayoutOrder,
 }, list)

 local ctrl = {}
 local itemButtons = {}

 local function setValue(v, silent)
 value = tostring(v)
 valueLabel.Text = value
 for _, item in ipairs(itemButtons) do
 local selected = item.Name == value
 item.BackgroundColor3 = selected and Color3.fromRGB(48, 36, 74) or Theme.panelAlt
 item.TextColor3 = selected and Theme.text or Theme.textDim
 local tick = item:FindFirstChildWhichIsA("TextLabel")
 if tick then
 tick.Text = selected and "✓" or ""
 end
 end
 if not silent and opts.Callback then
 opts.Callback(value)
 end
 end

 local function visibleCount()
 local n = 0
 for _, item in ipairs(itemButtons) do
 if item.Visible then
 n += 1
 end
 end
 return math.max(n, 1)
 end

 local function placeMenu()
 local layer = host or popupLayer
 if not layer then
 return
 end
 if menu.Parent ~= layer then
 menu.Parent = layer
 end
 if catcher.Parent ~= layer then
 catcher.Parent = layer
 end
 local pos = trigger.AbsolutePosition
 local size = trigger.AbsoluteSize
 local n = math.min(6, visibleCount())
 local height = 6 + n * (itemH + 1)
 local layerSize = layer.AbsoluteSize
 if layerSize.X < 8 or layerSize.Y < 8 then
 layerSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
 end
 local hostPos = layer.AbsolutePosition
 local x = pos.X - hostPos.X
 local y = pos.Y - hostPos.Y + size.Y + 2
 if y + height > layerSize.Y - 8 then
 y = math.max(0, pos.Y - hostPos.Y - height - 2)
 end
 menu.Position = UDim2.fromOffset(x, y)
 menu.Size = UDim2.fromOffset(math.max(120, size.X), height)
 end

 local function setOpen(state)
 state = state and true or false
 if state and activeDropdownClose and activeDropdownClose ~= setOpen then
 activeDropdownClose(false)
 end
 if state and activeColorClose then
 pcall(activeColorClose)
 end
 open = state
 if open then
 activeDropdownClose = setOpen
 for _, item in ipairs(itemButtons) do
 item.Visible = true
 end
 placeMenu()
 else
 if activeDropdownClose == setOpen then
 activeDropdownClose = nil
 end
 end
 chevron.Text = open and "^" or "v"
 chevron.TextColor3 = open and Theme.accent or Theme.textDim
 triggerStroke.Color = open and Theme.accent or Theme.stroke
 triggerStroke.Transparency = open and 0.05 or 0.35
 catcher.Visible = open
 menu.Visible = open
 end

 function ctrl:Get()
 return value
 end
 function ctrl:Set(v, silent)
 if table.find(options, tostring(v)) then
 setValue(v, silent)
 end
 end
 function ctrl:SetOptions(listOpts, keep)
 local incoming = {}
 if type(listOpts) == "table" then
 if #listOpts > 0 then
 for _, v in ipairs(listOpts) do
 local s = tostring(v)
 if s ~= "" then
 table.insert(incoming, s)
 end
 end
 else
 for k, v in pairs(listOpts) do
 local s = type(v) == "string" and v ~= "" and v or (type(k) == "string" and k or "")
 if s ~= "" then
 table.insert(incoming, s)
 end
 end
 table.sort(incoming)
 end
 end
 table.clear(options)
 table.clear(itemButtons)
 for _, child in ipairs(list:GetChildren()) do
 if child:IsA("TextButton") then
 child:Destroy()
 end
 end
 for _, s in ipairs(incoming) do
 table.insert(options, s)
 end
 if #options == 0 then
 table.insert(options, "None")
 end
 for i, opt in ipairs(options) do
 local item = mk("TextButton", {
 Name = opt,
 AutoButtonColor = false,
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 Size = UDim2.new(1, 0, 0, itemH),
 Font = Enum.Font.Gotham,
 Text = "  " .. opt,
 TextColor3 = Theme.textDim,
 TextSize = 11,
 TextXAlignment = Enum.TextXAlignment.Left,
 LayoutOrder = i,
 ZIndex = 402,
 }, list)
 corner(item, 4)
 local tick = mk("TextLabel", {
 BackgroundTransparency = 1,
 AnchorPoint = Vector2.new(1, 0.5),
 Position = UDim2.new(1, -8, 0.5, 0),
 Size = UDim2.fromOffset(14, 14),
 Font = Enum.Font.GothamBold,
 Text = "",
 TextColor3 = Theme.accent,
 TextSize = 12,
 ZIndex = 403,
 }, item)
 item:SetAttribute("Tick", true)
 item.MouseEnter:Connect(function()
 item.BackgroundColor3 = Theme.tabHover
 item.TextColor3 = Theme.text
 end)
 item.MouseLeave:Connect(function()
 local selected = item.Name == value
 item.BackgroundColor3 = selected and Color3.fromRGB(48, 36, 74) or Theme.panelAlt
 item.TextColor3 = selected and Theme.text or Theme.textDim
 tick.Text = selected and "✓" or ""
 end)
 local lastPick = 0
 local function pick()
 if os.clock() - lastPick < 0.08 then
 return
 end
 lastPick = os.clock()
 setValue(opt, false)
 setOpen(false)
 end
 item.Activated:Connect(pick)
 item.MouseButton1Click:Connect(pick)
 item.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 pick()
 end
 end)
 table.insert(itemButtons, item)
 end
 if keep and table.find(options, value) then
 setValue(value, true)
 else
 setValue(options[1], true)
 end
 if open then
 setOpen(true)
 end
 end

 ctrl:SetOptions(options, true)

 catcher.MouseButton1Click:Connect(function()
 setOpen(false)
 end)
 catcher.MouseButton1Down:Connect(function()
 setOpen(false)
 end)

 trigger.MouseButton1Click:Connect(function()
 setOpen(not open)
 end)

 row.Destroying:Connect(function()
 if activeDropdownClose == setOpen then
 activeDropdownClose = nil
 end
 if menu then
 menu:Destroy()
 end
 if catcher then
 catcher:Destroy()
 end
 end)

 return ctrl
 end

 return api
end

function Library.CreateWindow(opts)
 opts = opts or {}
 local title = tostring(opts.Title or "MythiOs")
 if title == "" then
  title = "MythiOs"
 end
 local subtitle = tostring(opts.Subtitle or "")
 local compact = isCompact()
 local size = opts.Size or UDim2.fromOffset(840, 560)
 do
  local vs = viewportSize()
  local insetY = 0
  pcall(function()
   insetY = GuiService:GetGuiInset().Y
  end)
  local maxW = math.max(300, vs.X - (compact and 12 or 28))
  local maxH = math.max(260, vs.Y - (compact and 16 or 32) - insetY * 0.2)
  local wantW = size.X.Offset
  local wantH = size.Y.Offset
  if wantW <= 0 then
   wantW = 840
  end
  if wantH <= 0 then
   wantH = 560
  end
  wantW = math.min(wantW, maxW)
  wantH = math.min(wantH, maxH)
  size = UDim2.fromOffset(math.floor(wantW), math.floor(wantH))
 end
 local toggleKeys = {}
 local function addToggleKey(key)
 if typeof(key) == "string" then
 key = Enum.KeyCode[key]
 end
 if typeof(key) == "EnumItem" then
 for _, existing in ipairs(toggleKeys) do
 if existing == key then
 return
 end
 end
 table.insert(toggleKeys, key)
 end
 end
 if opts.ToggleKeys then
 for _, key in ipairs(opts.ToggleKeys) do
 addToggleKey(key)
 end
 end
 addToggleKey(opts.ToggleKey)
 if #toggleKeys == 0 then
 addToggleKey(Enum.KeyCode.RightShift)
 end
 local unlockName = "PLUI_Toggle_" .. tostring(math.random(10000, 99999))
 local mouseUnlockName = unlockName .. "_Mouse"

 local connections = {}
 local function bind(sig)
 table.insert(connections, sig)
 return sig
 end

 local screenParent = parentGui()
 local screen = mk("ScreenGui", {
 Name = opts.Name or "PLUIWindow",
 ResetOnSpawn = false,
 ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
 DisplayOrder = opts.DisplayOrder or 120000,
 IgnoreGuiInset = true,
 Enabled = false,
 }, screenParent)
 pcall(function()
  screen.ClipToDeviceSafeArea = true
 end)
 local hintGui = mk("ScreenGui", {
 Name = (opts.Name or "PLUIWindow") .. "Hint",
 ResetOnSpawn = false,
 ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
 DisplayOrder = 120001,
 IgnoreGuiInset = true,
 Enabled = true,
 }, screenParent)
 pcall(function()
  hintGui.ClipToDeviceSafeArea = true
 end)

 local root = mk("Frame", {
 Name = "Root",
 BackgroundColor3 = Theme.bg,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(0.5, 0.5),
 Position = UDim2.new(0.5, 0, 0.5, 0),
 Size = size,
 ClipsDescendants = true,
 Visible = false,
 Active = true,
 ZIndex = 10,
 }, screen)
 corner(root, 12)
 stroke(root, Theme.stroke, 1, 0.2)
 local openScale = mk("UIScale", { Name = "OpenScale", Scale = 1 }, root)
 popupLayer = screen

 -- hint chip (tap to open on mobile; click-through text on desktop still toggles)
 local hintChip = mk("TextButton", {
 Name = "Hint",
 AutoButtonColor = false,
 BackgroundTransparency = 0.12,
 BackgroundColor3 = Theme.bg,
 AnchorPoint = compact and Vector2.new(1, 0) or Vector2.new(0, 1),
 Position = compact and UDim2.new(1, -12, 0, 72) or UDim2.new(0, 16, 1, -16),
 AutomaticSize = Enum.AutomaticSize.X,
 Size = UDim2.fromOffset(0, compact and 40 or 28),
 ZIndex = 5,
 Visible = true,
 Active = true,
 Text = "",
 }, hintGui)
 corner(hintChip, 8)
 stroke(hintChip, Theme.accent, 1, 0.35)
 mk("UIPadding", {
 PaddingLeft = UDim.new(0, 5),
 PaddingRight = UDim.new(0, 10),
 PaddingTop = UDim.new(0, 4),
 PaddingBottom = UDim.new(0, 4),
 }, hintChip)
 mk("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 VerticalAlignment = Enum.VerticalAlignment.Center,
 SortOrder = Enum.SortOrder.LayoutOrder,
 Padding = UDim.new(0, 6),
 }, hintChip)
 local hintBrand = makeBrand(hintChip, 20, 6)
 hintBrand.LayoutOrder = 1
 hintBrand.Active = false
 local hintLabel = mk("TextLabel", {
 Name = "HintText",
 BackgroundTransparency = 1,
 AutomaticSize = Enum.AutomaticSize.X,
 Size = UDim2.fromOffset(0, 20),
 Font = Enum.Font.GothamBold,
 TextSize = 12,
 TextColor3 = Theme.text,
 TextXAlignment = Enum.TextXAlignment.Left,
 ZIndex = 6,
 Text = "MythiOs",
 LayoutOrder = 2,
 }, hintChip)
 local function refreshHint()
 hintLabel.Text = compact and "Tap to open" or "MythiOs"
 end
 refreshHint()

 -- toast stack
 local banner = mk("Frame", {
 Name = "StatusBanner",
 AnchorPoint = Vector2.new(0.5, 0),
 Position = UDim2.new(0.5, 0, 0, 14),
 Size = UDim2.fromOffset(compact and 320 or 420, compact and 52 or 58),
 BackgroundColor3 = Theme.panel,
 BorderSizePixel = 0,
 Visible = false,
 ZIndex = 90,
 }, screen)
 corner(banner, 14)
 local bannerStroke = stroke(banner, Theme.accent, 1, 0.25)
 local bannerBar = mk("Frame", {
 BackgroundColor3 = Theme.accent,
 BorderSizePixel = 0,
 Size = UDim2.new(0, 4, 1, -16),
 Position = UDim2.fromOffset(8, 8),
 ZIndex = 91,
 }, banner)
 corner(bannerBar, 2)
 local bannerBadge = mk("TextLabel", {
 BackgroundColor3 = Theme.accentDim,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(20, 10),
 Size = UDim2.fromOffset(54, 18),
 Font = Enum.Font.GothamBold,
 Text = "SPEC",
 TextColor3 = Color3.fromRGB(255, 255, 255),
 TextSize = 10,
 ZIndex = 91,
 }, banner)
 corner(bannerBadge, 6)
 local bannerCount = mk("TextLabel", {
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(1, 0),
 Position = UDim2.new(1, -12, 0, 10),
 Size = UDim2.fromOffset(64, 18),
 Font = Enum.Font.GothamBold,
 Text = "0",
 TextColor3 = Theme.text,
 TextSize = 10,
 ZIndex = 91,
 }, banner)
 corner(bannerCount, 6)
 local bannerTitle = mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(20, 32),
 Size = UDim2.new(1, -32, 0, 18),
 Font = Enum.Font.GothamBold,
 Text = "",
 TextColor3 = Theme.text,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 91,
 }, banner)
 local bannerBody = mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(20, 48),
 Size = UDim2.new(1, -32, 0, 0),
 Font = Enum.Font.Gotham,
 Text = "",
 TextColor3 = Theme.textDim,
 TextSize = 11,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 Visible = false,
 ZIndex = 91,
 }, banner)

 local toastHold = mk("Frame", {
 Name = "Toasts",
 AnchorPoint = Vector2.new(1, 1),
 Position = UDim2.new(1, -16, 1, -16),
 Size = UDim2.fromOffset(280, 220),
 BackgroundTransparency = 1,
 ZIndex = 80,
 }, screen)
 mk("UIListLayout", {
 FillDirection = Enum.FillDirection.Vertical,
 VerticalAlignment = Enum.VerticalAlignment.Bottom,
 Padding = UDim.new(0, 6),
 SortOrder = Enum.SortOrder.LayoutOrder,
 }, toastHold)

 local SIDE_W = compact and 148 or 200
 local body = mk("Frame", {
 Name = "BodyRow",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 0),
 Size = UDim2.new(1, 0, 1, 0),
 ZIndex = 20,
 }, root)

 local sidebar = mk("Frame", {
 Name = "Sidebar",
 BackgroundColor3 = Theme.sidebar,
 BorderSizePixel = 0,
 Size = UDim2.new(0, SIDE_W, 1, 0),
 ClipsDescendants = true,
 }, body)
 local sideLine = mk("Frame", {
 BackgroundColor3 = Theme.stroke,
 BackgroundTransparency = 0.45,
 BorderSizePixel = 0,
 Position = UDim2.new(1, -1, 0, 0),
 Size = UDim2.new(0, 1, 1, 0),
 ZIndex = 3,
 }, sidebar)

 local sideBrand = mk("Frame", {
 Name = "BrandRow",
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 64),
 ZIndex = 5,
 }, sidebar)
 local headerBrand = makeBrand(sideBrand, 32, 6)
 headerBrand.Position = UDim2.fromOffset(16, 16)
 mk("TextLabel", {
 Name = "Title",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(56, 14),
 Size = UDim2.new(1, -68, 0, 22),
 Font = Enum.Font.GothamBold,
 Text = title,
 TextColor3 = Theme.text,
 TextSize = 16,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 6,
 }, sideBrand)
 local subtitleLabel = mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(56, 34),
 Size = UDim2.new(1, -68, 0, 16),
 Font = Enum.Font.Gotham,
 Text = subtitle,
 TextColor3 = Theme.textDim,
 TextSize = 11,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 6,
 }, sideBrand)

 local sidebarNav = mk("ScrollingFrame", {
 Name = "Nav",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(0, 64),
 Size = UDim2.new(1, 0, 1, -128),
 CanvasSize = UDim2.new(0, 0, 0, 0),
 AutomaticCanvasSize = Enum.AutomaticSize.Y,
 ScrollBarThickness = 2,
 ScrollBarImageColor3 = Theme.accentDim,
 ZIndex = 2,
 }, sidebar)
 pad(sidebarNav, 8, 8, 12, 12)
 mk("UIListLayout", {
 Padding = UDim.new(0, 3),
 SortOrder = Enum.SortOrder.LayoutOrder,
 HorizontalAlignment = Enum.HorizontalAlignment.Center,
 }, sidebarNav)

 local profile = mk("Frame", {
 Name = "Profile",
 BackgroundTransparency = 1,
 AnchorPoint = Vector2.new(0, 1),
 Position = UDim2.new(0, 0, 1, 0),
 Size = UDim2.new(1, 0, 0, 62),
 ZIndex = 4,
 }, sidebar)
 mk("Frame", {
 BackgroundColor3 = Theme.stroke,
 BackgroundTransparency = 0.4,
 BorderSizePixel = 0,
 Size = UDim2.new(1, -20, 0, 1),
 Position = UDim2.fromOffset(10, 0),
 }, profile)
 local avatar = mk("ImageLabel", {
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(12, 14),
 Size = UDim2.fromOffset(34, 34),
 Image = "",
 ZIndex = 5,
 }, profile)
 corner(avatar, 17)
 task.spawn(function()
  local userId = LocalPlayer and LocalPlayer.UserId
  local content = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId or 1) .. "&w=48&h=48"
  local ok, url = pcall(function()
   return Players:GetUserThumbnailAsync(
    userId,
    Enum.ThumbnailType.HeadShot,
    Enum.ThumbnailSize.Size48x48
   )
  end)
  if ok and type(url) == "string" and url ~= "" then
   content = url
  elseif ok and typeof(url) == "Instance" then
   local fromInst
   pcall(function()
    if url:IsA("ImageLabel") or url:IsA("ImageButton") or url:IsA("Decal") then
     fromInst = url.Image
    end
   end)
   if type(fromInst) == "string" and fromInst ~= "" then
    content = fromInst
   end
  end
  if avatar.Parent and type(content) == "string" then
   avatar.Image = content
  end
 end)
 local profileName = LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name) or "Player"
 if profileName == "" then
  profileName = LocalPlayer.Name
 end
 local displayLbl = mk("TextLabel", {
 Name = "DisplayLbl",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(54, 14),
 Size = UDim2.new(1, -64, 0, 18),
 Font = Enum.Font.GothamBold,
 Text = profileName,
 TextColor3 = Theme.text,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 5,
 }, profile)
 local handleLbl = mk("TextLabel", {
 Name = "HandleLbl",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(54, 32),
 Size = UDim2.new(1, -64, 0, 16),
 Font = Enum.Font.Gotham,
 Text = "@" .. tostring(LocalPlayer.Name),
 TextColor3 = Theme.textDim,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 5,
 }, profile)

 local content = mk("Frame", {
 Name = "Content",
 BackgroundColor3 = Theme.bg,
 BorderSizePixel = 0,
 Position = UDim2.new(0, SIDE_W, 0, 0),
 Size = UDim2.new(1, -SIDE_W, 1, 0),
 }, body)

 local contentHead = mk("Frame", {
 Name = "ContentHead",
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 58),
 ZIndex = 8,
 }, content)

 local pageTitle = mk("TextLabel", {
 Name = "PageTitle",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(22, 10),
 Size = UDim2.new(1, -240, 0, 24),
 Font = Enum.Font.GothamBold,
 Text = "",
 TextColor3 = Theme.text,
 TextSize = 20,
 TextXAlignment = Enum.TextXAlignment.Left,
 ZIndex = 9,
 }, contentHead)
 local pageSub = mk("TextLabel", {
 Name = "PageSub",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(22, 34),
 Size = UDim2.new(1, -240, 0, 16),
 Font = Enum.Font.Gotham,
 Text = "configure module",
 TextColor3 = Theme.textDim,
 TextSize = 12,
 TextXAlignment = Enum.TextXAlignment.Left,
 ZIndex = 9,
 }, contentHead)

 local closeBtn = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(1, 0.5),
 Position = UDim2.new(1, -12, 0.5, 0),
 Size = UDim2.fromOffset(compact and 36 or 28, compact and 36 or 28),
 Font = Enum.Font.GothamBold,
 Text = "×",
 TextColor3 = Theme.textDim,
 TextSize = compact and 20 or 16,
 ZIndex = 10,
 }, contentHead)
 local minBtn = mk("TextButton", {
 AutoButtonColor = false,
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(1, 0.5),
 Position = UDim2.new(1, compact and -48 or -40, 0.5, 0),
 Size = UDim2.fromOffset(compact and 36 or 28, compact and 36 or 28),
 Font = Enum.Font.GothamBold,
 Text = "–",
 TextColor3 = Theme.textDim,
 TextSize = 16,
 ZIndex = 10,
 }, contentHead)
 closeBtn.MouseEnter:Connect(function()
 tween(closeBtn, { TextColor3 = Theme.rose }, 0.12)
 end)
 closeBtn.MouseLeave:Connect(function()
 tween(closeBtn, { TextColor3 = Theme.textDim }, 0.16)
 end)
 minBtn.MouseEnter:Connect(function()
 tween(minBtn, { TextColor3 = Theme.text }, 0.12)
 end)
 minBtn.MouseLeave:Connect(function()
 tween(minBtn, { TextColor3 = Theme.textDim }, 0.16)
 end)

 local searchBox = mk("TextBox", {
 Name = "Search",
 BackgroundColor3 = Theme.panelAlt,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(1, 0.5),
 Position = UDim2.new(1, compact and -96 or -76, 0.5, 0),
 Size = UDim2.fromOffset(compact and 108 or 150, 28),
 Font = Enum.Font.Gotham,
 PlaceholderText = "Search anything",
 PlaceholderColor3 = Theme.textDim,
 Text = "",
 TextColor3 = Theme.text,
 TextSize = 11,
 ClearTextOnFocus = false,
 Selectable = true,
 ZIndex = 10,
 }, contentHead)
 corner(searchBox, 8)
 pad(searchBox, 0, 0, 10, 10)
 local searchStroke = stroke(searchBox, Theme.stroke, 1, 0.4)
 searchBox.Focused:Connect(function()
 tween(searchStroke, { Color = Theme.accent, Transparency = 0.08 }, 0.16)
 tween(searchBox, { BackgroundColor3 = Theme.tabIdle }, 0.16)
 end)
 searchBox.FocusLost:Connect(function()
 tween(searchStroke, { Color = Theme.stroke, Transparency = 0.4 }, 0.2)
 tween(searchBox, { BackgroundColor3 = Theme.panelAlt }, 0.2)
 end)

 local pagesFolder = mk("Frame", {
 Name = "Pages",
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(16, 58),
 Size = UDim2.new(1, -24, 1, -84),
 ClipsDescendants = true,
 }, content)

 local footer = mk("Frame", {
 Name = "Footer",
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 AnchorPoint = Vector2.new(0, 1),
 Position = UDim2.new(0, 0, 1, 0),
 Size = UDim2.new(1, 0, 0, 26),
 ZIndex = 8,
 }, content)
 local footerLabel = mk("TextLabel", {
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(12, 0),
 Size = UDim2.new(0.55, 0, 1, 0),
 Font = Enum.Font.Gotham,
 Text = "Ready",
 TextColor3 = Theme.textDim,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Left,
 }, footer)
 local pulseLabel = mk("TextLabel", {
 BackgroundTransparency = 1,
 AnchorPoint = Vector2.new(1, 0),
 Position = UDim2.new(1, -12, 0, 0),
 Size = UDim2.new(0.42, 0, 1, 0),
 Font = Enum.Font.GothamBold,
 Text = "",
 TextColor3 = Theme.cyan,
 TextSize = 10,
 TextXAlignment = Enum.TextXAlignment.Right,
 }, footer)

 local window = {
 Screen = screen,
 Root = root,
 Theme = Theme,
 _tabs = {},
 _active = nil,
 _flags = {},
 _searchables = {},
 _open = false,
 _savedMouseBehavior = nil,
 _savedMouseIcon = nil,
 _restoreFrames = 0,
 _alive = true,
 Hint = hintChip,
 _displayLbl = displayLbl,
 _handleLbl = handleLbl,
 _profileName = profileName,
 _profileHandle = "@" .. tostring(LocalPlayer and LocalPlayer.Name or "player"),
 }

 function window:SetStreamerMode(on)
  local shown = on == true
  if self._displayLbl then
   self._displayLbl.Text = shown and "Hidden" or tostring(self._profileName or "Player")
  end
  if self._handleLbl then
   self._handleLbl.Text = shown and "@hidden" or tostring(self._profileHandle or "@player")
  end
 end

 local selectTab
 local function applySearch(query, keepTab)
 local q = string.lower(tostring(query or ""))
 local firstHit
 local firstGroup
 for name, tabApi in pairs(window._tabs) do
 local tabHit = q == "" or string.find(string.lower(name), q, 1, true) ~= nil
 local any = tabHit
 local hitGroup
 if tabHit then
 for _, section in ipairs(tabApi._sections) do
 section:SetSearch("")
 section.Instance.Visible = true
 end
 else
 for _, section in ipairs(tabApi._sections) do
 if section:SetSearch(q) then
 any = true
 if not hitGroup then
 hitGroup = section._group
 end
 end
 end
 end
 if any and not firstHit then
 firstHit = name
 firstGroup = hitGroup
 end
 end
 if q ~= "" and firstHit and not keepTab then
 if window._active ~= firstHit then
 selectTab(firstHit, true)
 end
 local tabApi = window._tabs[firstHit]
 if tabApi and firstGroup and type(tabApi.SelectGroup) == "function" then
 tabApi:SelectGroup(firstGroup)
 end
 end
 end

 searchBox:GetPropertyChangedSignal("Text"):Connect(function()
 applySearch(searchBox.Text)
 end)

 function window:SetSubtitle(text)
 subtitleLabel.Text = tostring(text or "")
 end

 function window:SetFooter(text)
 footerLabel.Text = tostring(text or "")
 end

 function window:SetBanner(opts)
 opts = opts or {}
 local visible = opts.Visible == true
 banner.Visible = visible
 if not visible then
 return
 end
 local kind = tostring(opts.Kind or "spec")
 local tone = Theme.accent
 local badge = "SPEC"
 if kind == "staff" then
 tone = Theme.rose
 badge = "STAFF"
 elseif kind == "both" then
 tone = Theme.rose
 badge = "ALERT"
 end
 bannerStroke.Color = tone
 bannerBar.BackgroundColor3 = tone
 bannerBadge.BackgroundColor3 = tone
 bannerBadge.Text = badge
 local count = tonumber(opts.Count) or 0
 bannerCount.Text = count > 0 and (tostring(count) .. (count == 1 and " spec" or " spec")) or "—"
 bannerCount.Visible = kind ~= "staff"
 bannerTitle.Text = tostring(opts.Title or "")
 local body = tostring(opts.Body or "")
 if body ~= "" then
 bannerBody.Text = body
 bannerBody.Visible = true
 banner.Size = UDim2.fromOffset(420, 72)
 bannerBody.Size = UDim2.new(1, -32, 0, 16)
 else
 bannerBody.Visible = false
 banner.Size = UDim2.fromOffset(420, 58)
 end
 end

 function window:Notify(text, color)
 text = tostring(text or "")
 color = color or Theme.cyan
 pulseLabel.Text = text
 pulseLabel.TextColor3 = color
 task.delay(1.4, function()
 if pulseLabel.Text == text then
 pulseLabel.Text = ""
 end
 end)

 local toast = mk("Frame", {
 BackgroundColor3 = Theme.panel,
 BorderSizePixel = 0,
 Size = UDim2.new(1, 0, 0, 0),
 AutomaticSize = Enum.AutomaticSize.Y,
 BackgroundTransparency = 1,
 ZIndex = 81,
 }, toastHold)
 corner(toast, 8)
 local tStroke = stroke(toast, color, 1, 0.35)
 tStroke.Transparency = 1
 pad(toast, 10, 10, 12, 12)
 local tLabel = mk("TextLabel", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 0),
 AutomaticSize = Enum.AutomaticSize.Y,
 Font = Enum.Font.Gotham,
 Text = text,
 TextColor3 = Theme.text,
 TextSize = 12,
 TextWrapped = true,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTransparency = 1,
 ZIndex = 82,
 }, toast)
 mk("Frame", {
 Size = UDim2.new(0, 3, 1, 0),
 Position = UDim2.fromOffset(-12, 0),
 BackgroundColor3 = color,
 BorderSizePixel = 0,
 BackgroundTransparency = 1,
 ZIndex = 82,
 }, toast)
 TweenService:Create(toast, TweenInfo.new(0.18), { BackgroundTransparency = 0.05 }):Play()
 TweenService:Create(tStroke, TweenInfo.new(0.18), { Transparency = 0.35 }):Play()
 TweenService:Create(tLabel, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
 task.delay(2.4, function()
 if not toast.Parent then
 return
 end
 TweenService:Create(toast, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
 TweenService:Create(tStroke, TweenInfo.new(0.22), { Transparency = 1 }):Play()
 TweenService:Create(tLabel, TweenInfo.new(0.22), { TextTransparency = 1 }):Play()
 task.wait(0.24)
 if toast.Parent then
 toast:Destroy()
 end
 end)
 end

 function window:SetFlag(flag, value)
 self._flags[flag] = value
 end

 function window:GetFlag(flag)
 return self._flags[flag]
 end

 selectTab = function(name, fromSearch)
 if activeDropdownClose then
 pcall(activeDropdownClose, false)
 end
 if activeColorClose then
 pcall(activeColorClose)
 end
 for n, tabApi in pairs(window._tabs) do
 local on = n == name
 tween(tabApi.Button, {
 BackgroundColor3 = on and Color3.fromRGB(92, 70, 148) or Theme.tabIdle,
 BackgroundTransparency = on and 0 or 1,
 }, 0.16)
 local nameLbl = tabApi.Button:FindFirstChild("NameLbl")
 if nameLbl then
 tween(nameLbl, { TextColor3 = on and Color3.fromRGB(255, 255, 255) or Theme.textDim }, 0.16)
 end
 local iconBox = tabApi.Button:FindFirstChild("IconBox")
 if iconBox then
 iconBox.BackgroundTransparency = 1
 setIconColor(iconBox, on and Color3.fromRGB(255, 255, 255) or Theme.textDim)
 end
 local pageScale = tabApi.Page:FindFirstChild("PageScale")
 if on then
 tabApi.Page.Visible = true
 if pageScale then
 pageScale.Scale = 0.96
 tween(pageScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Back)
 end
 else
 tabApi.Page.Visible = false
 end
 end
 window._active = name
 pageTitle.Text = name
 pageSub.Text = "configure module"
 if not fromSearch then
 applySearch(searchBox.Text, true)
 end
 end

 local function makeScrollPage(parent)
 local scroll = mk("ScrollingFrame", {
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Size = UDim2.fromScale(1, 1),
 CanvasSize = UDim2.new(0, 0, 0, 0),
 AutomaticCanvasSize = Enum.AutomaticSize.Y,
 ScrollBarThickness = 3,
 ScrollBarImageColor3 = Theme.accentDim,
 }, parent)
 pad(scroll, 4, 16, 4, 4)
 mk("UIListLayout", {
 Padding = UDim.new(0, 12),
 SortOrder = Enum.SortOrder.LayoutOrder,
 }, scroll)
 return scroll
 end

 local function bindHost(tabApi, hostFrame, groupName)
 local methods = {}
 function methods:Section(title)
 local sec = makeSection(hostFrame, title)
 sec._group = groupName
 sec.Instance.LayoutOrder = #tabApi._sections + 1
 table.insert(tabApi._sections, sec)
 return sec
 end
 function methods:Columns()
 local row = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(1, 0, 0, 0),
 AutomaticSize = Enum.AutomaticSize.Y,
 LayoutOrder = #tabApi._sections + 100,
 }, hostFrame)
 mk("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 Padding = UDim.new(0, 10),
 SortOrder = Enum.SortOrder.LayoutOrder,
 }, row)
 local function col()
 local holder = mk("Frame", {
 BackgroundTransparency = 1,
 Size = UDim2.new(0.5, -5, 0, 0),
 AutomaticSize = Enum.AutomaticSize.Y,
 }, row)
 mk("UIListLayout", {
 Padding = UDim.new(0, 10),
 SortOrder = Enum.SortOrder.LayoutOrder,
 }, holder)
 local proxy = {
 _sections = tabApi._sections,
 Section = function(_, title)
 local sec = makeSection(holder, title)
 sec._group = groupName
 table.insert(tabApi._sections, sec)
 return sec
 end,
 }
 return proxy
 end
 return col(), col()
 end
 return methods
 end

 function window:AddTab(name)
 name = tostring(name)
 local order = 0
 for _ in pairs(self._tabs) do
 order += 1
 end

 local btn = mk("TextButton", {
 Name = "Tab_" .. name,
 AutoButtonColor = false,
 BackgroundColor3 = Theme.accent,
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Size = UDim2.new(1, 0, 0, 40),
 Font = Enum.Font.GothamMedium,
 Text = "",
 TextColor3 = Theme.textDim,
 TextSize = 13,
 LayoutOrder = order,
 }, sidebarNav)
 corner(btn, 10)
 local iconBox = mk("Frame", {
 Name = "IconBox",
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(8, 8),
 Size = UDim2.fromOffset(24, 24),
 ZIndex = 2,
 }, btn)
 paintIcon(iconBox, name, Theme.textDim)
 mk("TextLabel", {
 Name = "NameLbl",
 BackgroundTransparency = 1,
 Position = UDim2.fromOffset(40, 0),
 Size = UDim2.new(1, -48, 1, 0),
 Font = Enum.Font.GothamMedium,
 Text = name,
 TextColor3 = Theme.textDim,
 TextSize = 13,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ZIndex = 2,
 }, btn)

 local page = mk("Frame", {
 Name = "Page_" .. name,
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Size = UDim2.fromScale(1, 1),
 Visible = false,
 }, pagesFolder)
 mk("UIScale", { Name = "PageScale", Scale = 1 }, page)

 local subNav = mk("Frame", {
 Name = "SubNav",
 BackgroundColor3 = Theme.panel,
 BorderSizePixel = 0,
 Size = UDim2.new(1, 0, 0, 38),
 Visible = false,
 ZIndex = 3,
 }, page)
 corner(subNav, 12)
 stroke(subNav, Theme.stroke, 1, 0.55)
 pad(subNav, 4, 4, 6, 6)
 mk("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 Padding = UDim.new(0, 4),
 SortOrder = Enum.SortOrder.LayoutOrder,
 VerticalAlignment = Enum.VerticalAlignment.Center,
 }, subNav)

 local body = mk("Frame", {
 Name = "Body",
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Position = UDim2.fromOffset(0, 0),
 Size = UDim2.new(1, 0, 1, 0),
 }, page)

 local pageScroll = makeScrollPage(body)
 local groupsHolder = mk("Frame", {
 Name = "Groups",
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Size = UDim2.fromScale(1, 1),
 Visible = false,
 }, body)

 local tabApi = {
 Name = name,
 Button = btn,
 Page = page,
 _sections = {},
 _groups = {},
 _groupMap = {},
 _activeGroup = nil,
 _colOrder = 0,
 }
 local defaultHost = bindHost(tabApi, pageScroll, nil)
 tabApi.Section = defaultHost.Section
 tabApi.Columns = defaultHost.Columns

 local function styleGroupPill(pill, on)
 tween(pill, {
 BackgroundTransparency = on and 0 or 1,
 BackgroundColor3 = on and Color3.fromRGB(92, 70, 148) or Theme.tabIdle,
 }, 0.14)
 tween(pill, { TextColor3 = on and Color3.fromRGB(255, 255, 255) or Theme.textDim }, 0.14)
 end

 local function layoutGroups()
 local many = #tabApi._groups >= 2
 subNav.Visible = many
 groupsHolder.Visible = #tabApi._groups > 0
 pageScroll.Visible = #tabApi._groups == 0
 if many then
 body.Position = UDim2.fromOffset(0, 46)
 body.Size = UDim2.new(1, 0, 1, -46)
 else
 body.Position = UDim2.fromOffset(0, 0)
 body.Size = UDim2.new(1, 0, 1, 0)
 end
 end

 function tabApi:SelectGroup(title)
 title = tostring(title or "")
 if title == "" then
 return
 end
 for _, group in ipairs(self._groups) do
 local on = group.Name == title
 group.Page.Visible = on
 styleGroupPill(group.Button, on)
 end
 self._activeGroup = title
 end

 function tabApi:Group(title)
 title = tostring(title or "Group")
 if self._groupMap[title] then
 return self._groupMap[title]
 end
 local gScroll = makeScrollPage(groupsHolder)
 gScroll.Name = "Group_" .. title
 gScroll.Visible = false
 local methods = bindHost(self, gScroll, title)
 methods.Name = title
 methods.Page = gScroll
 local pill = mk("TextButton", {
 Name = "Sub_" .. title,
 AutoButtonColor = false,
 BackgroundColor3 = Color3.fromRGB(92, 70, 148),
 BackgroundTransparency = 1,
 BorderSizePixel = 0,
 Size = UDim2.fromOffset(math.max(72, 18 + #title * 7), 28),
 Font = Enum.Font.GothamMedium,
 Text = title,
 TextColor3 = Theme.textDim,
 TextSize = 12,
 LayoutOrder = #self._groups,
 ZIndex = 4,
 }, subNav)
 corner(pill, 8)
 methods.Button = pill
 pill.MouseButton1Click:Connect(function()
 pressPunch(pill)
 tabApi:SelectGroup(title)
 end)
 pill.MouseEnter:Connect(function()
 if tabApi._activeGroup ~= title then
 tween(pill, { TextColor3 = Theme.text }, 0.12)
 end
 end)
 pill.MouseLeave:Connect(function()
 if tabApi._activeGroup ~= title then
 tween(pill, { TextColor3 = Theme.textDim }, 0.12)
 end
 end)
 table.insert(self._groups, methods)
 self._groupMap[title] = methods
 layoutGroups()
 if not self._activeGroup or self._activeGroup == title then
 self:SelectGroup(title)
 end
 layoutGroups()
 return methods
 end

 function tabApi:Clear()
 local stayGroup = self._activeGroup
 for _, child in ipairs(pageScroll:GetChildren()) do
 if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
 child:Destroy()
 end
 end
 for _, group in ipairs(self._groups) do
 if group.Page then
 group.Page:Destroy()
 end
 if group.Button then
 group.Button:Destroy()
 end
 end
 table.clear(self._groups)
 table.clear(self._groupMap)
 table.clear(self._sections)
 self._activeGroup = stayGroup
 layoutGroups()
 end

 btn.MouseButton1Click:Connect(function()
 pressPunch(btn)
 selectTab(name)
 end)
 btn.MouseEnter:Connect(function()
 if window._active ~= name then
 tween(btn, { BackgroundTransparency = 0.55, BackgroundColor3 = Theme.tabHover }, 0.14)
 local nameLbl = btn:FindFirstChild("NameLbl")
 if nameLbl then
 tween(nameLbl, { TextColor3 = Theme.text }, 0.14)
 end
 end
 end)
 btn.MouseLeave:Connect(function()
 if window._active ~= name then
 tween(btn, { BackgroundTransparency = 1 }, 0.16)
 local nameLbl = btn:FindFirstChild("NameLbl")
 if nameLbl then
 tween(nameLbl, { TextColor3 = Theme.textDim }, 0.16)
 end
 end
 end)

 self._tabs[name] = tabApi
 if not self._active then
 selectTab(name)
 end
 return tabApi
 end

 local function applyClosedMouse()
 pcall(function()
 screen.Enabled = false
 root.Visible = false
 root.Active = false
 pcall(function()
 screen.Interactable = false
 end)
 game:GetService("GuiService").SelectedObject = nil
 local box = UserInputService:GetFocusedTextBox()
 if box then
 box:ReleaseFocus()
 end
 end)
 end

 local function mouseUnlockEnabled()
 if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
 return false
 end
 if opts.UnlockMouseWhileOpen == false then
 return false
 end
 if type(opts.UnlockMouseWhileOpen) == "function" then
 local ok, want = pcall(opts.UnlockMouseWhileOpen)
 return ok and want == true
 end
 return true
 end

 local function stopMouseUnlock()
 pcall(function()
 RunService:UnbindFromRenderStep(mouseUnlockName)
 end)
 end

 local function startMouseUnlock()
 stopMouseUnlock()
 if not mouseUnlockEnabled() then
 return
 end
 pcall(function()
 UserInputService.MouseBehavior = Enum.MouseBehavior.Default
 UserInputService.MouseIconEnabled = true
 end)
 RunService:BindToRenderStep(mouseUnlockName, Enum.RenderPriority.Last.Value, function()
 if not window._alive or not window._open then
 return
 end
 if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
 UserInputService.MouseBehavior = Enum.MouseBehavior.Default
 end
 if not UserInputService.MouseIconEnabled then
 UserInputService.MouseIconEnabled = true
 end
 end)
 end

 function window:IsOpen()
 return self._open == true
 end

 function window:SetHintVisible(visible)
 hintChip.Visible = visible and true or false
 end

 function window:SetToggleKeys(keys)
 table.clear(toggleKeys)
 if typeof(keys) == "EnumItem" or typeof(keys) == "string" then
 addToggleKey(keys)
 else
 for _, key in ipairs(keys or {}) do
 addToggleKey(key)
 end
 end
 if #toggleKeys == 0 then
 addToggleKey(Enum.KeyCode.K)
 end
 refreshHint()
 if type(window.RebindToggle) == "function" then
 window:RebindToggle()
 end
 end

 function window:GetToggleKeys()
 local copy = {}
 for _, key in ipairs(toggleKeys) do
 table.insert(copy, key)
 end
 return copy
 end

 function window:SetOpen(visible)
 visible = visible and true or false
 if self._open == visible then
 return
 end
 self._open = visible
 local hideHint = visible
 if not visible and opts.HintVisible then
 local ok, show = pcall(opts.HintVisible)
 hideHint = not (ok and show)
 elseif not visible then
 hideHint = false
 end
 hintChip.Visible = not hideHint
 hintChip.BackgroundTransparency = 0.12
 hintLabel.TextTransparency = 0
 if visible then
		screen.Enabled = true
		root.Visible = true
		root.Active = true
		pcall(function()
			screen.Interactable = true
		end)
 startMouseUnlock()
 if not root:GetAttribute("Moved") then
 root.Position = UDim2.fromScale(0.5, 0.48)
 tween(root, { Position = UDim2.fromScale(0.5, 0.5) }, 0.28, Enum.EasingStyle.Quart)
 end
 pcall(function()
 local box = UserInputService:GetFocusedTextBox()
 if box then
 box:ReleaseFocus()
 end
 end)
 openScale.Scale = 0.88
 tween(openScale, { Scale = 1 }, 0.34, Enum.EasingStyle.Back)
 else
 stopMouseUnlock()
 applyClosedMouse()
 end
 if opts.OnOpenChanged then
 pcall(opts.OnOpenChanged, visible)
 end
 end

 function window:Toggle()
 self:SetOpen(not self._open)
 end

 function window:Destroy()
 self._alive = false
 self._open = false
 stopMouseUnlock()
 pcall(function()
 ContextActionService:UnbindAction(unlockName .. "_Toggle")
 end)
 applyClosedMouse()
 for _, c in ipairs(connections) do
 pcall(function()
 c:Disconnect()
 end)
 end
 table.clear(connections)
 if screen then
 screen:Destroy()
 end
 if hintGui then
 hintGui:Destroy()
 end
 end

 -- drag (viewport-stable via RenderStepped)
 do
 local dragging = false
 local dragStart = Vector2.zero
 local startPos = UDim2.fromScale(0.5, 0.5)
 local lastPtr = UserInputService:GetMouseLocation()
 local dragConn
 local function stopDrag()
 dragging = false
 if dragConn then
 dragConn:Disconnect()
 dragConn = nil
 end
 end
 local function startDrag()
 if dragConn then
 return
 end
 dragConn = RunService.Heartbeat:Connect(function()
 if not dragging or not window._open then
 stopDrag()
 return
 end
 local d = lastPtr - dragStart
 root:SetAttribute("Moved", true)
 root.Position = UDim2.new(
 startPos.X.Scale,
 startPos.X.Offset + d.X,
 startPos.Y.Scale,
 startPos.Y.Offset + d.Y
 )
 end)
 end
 local function bindDrag(gui)
 gui.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 lastPtr = guiPointer(input)
 dragStart = lastPtr
 startPos = root.Position
 startDrag()
 end
 end)
 gui.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 stopDrag()
 end
 end)
 end
 bindDrag(sideBrand)
 bindDrag(contentHead)
 bind(UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 stopDrag()
 end
 end))
 bind(UserInputService.InputChanged:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
 return
 end
 lastPtr = guiPointer(input)
 end))
 end

 local lastToggleAt = 0
 local function isToggleKey(code)
 for _, key in ipairs(toggleKeys) do
 if code == key then
 return true
 end
 end
 return false
 end
 local function handleTogglePress()
 if not window._alive then
 return
 end
 local now = os.clock()
 if now - lastToggleAt < 0.28 then
 return
 end
 lastToggleAt = now
 pcall(function()
 local box = UserInputService:GetFocusedTextBox()
 if box then
 box:ReleaseFocus()
 end
 end)
 window:Toggle()
 end
 function window:RebindToggle()
 pcall(function()
 ContextActionService:UnbindAction(unlockName .. "_Toggle")
 end)
 end
 window:RebindToggle()
 bind(UserInputService.InputBegan:Connect(function(input)
 if not window._alive then
 return
 end
 if input.UserInputType ~= Enum.UserInputType.Keyboard then
 return
 end
 if UserInputService:GetFocusedTextBox() then
 return
 end
 if isToggleKey(input.KeyCode) then
 handleTogglePress()
 end
 end))

 local function hideWindow()
 if opts.OnClose then
 opts.OnClose()
 else
 window:SetOpen(false)
 end
 end
 closeBtn.MouseButton1Click:Connect(hideWindow)
 minBtn.MouseButton1Click:Connect(function()
 window:SetOpen(false)
 end)
 hintChip.MouseButton1Click:Connect(function()
 if not window._open then
 handleTogglePress()
 end
 end)

 window.FinishBoot = function()
 pcall(Library.HideLoading)
 if window._alive then
 window:SetOpen(true)
 end
 end

 if opts.StartOpen ~= false then
 window:SetOpen(true)
 end

 table.insert(Library.Windows, window)
 return window
end

pcall(function()
 if typeof(getgenv) == "function" then
 getgenv().MythiOs = Library
 end
end)

return Library
