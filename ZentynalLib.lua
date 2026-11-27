-- ZentynalLib.lua
-- Zentynal UI Library V6 (Full + Polish)
-- Drop-in for YourNenHub.
-- Components: Toggle, Button, Slider, TextBox, Keybind, ColorPicker,
-- Dropdown, Label, Paragraph, Icon headers, Tab search, Toasts,
-- Window drag, Mobile scaling, Popup layer, Reopen pill.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local LIB_NAME = "Zentynal"
local LOGO_ASSET = "rbxassetid://114884658309823"
local LOGO_FILE = "Zentynal/logo.png"

local function isCompact()
	local cam = workspace.CurrentCamera
	local vs = cam and cam.ViewportSize or Vector2.new(1280, 720)
	if vs.X > 0 and vs.X < 820 then return true end
	return UserInputService.TouchEnabled == true and UserInputService.KeyboardEnabled ~= true
end

local function viewportSize()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function guiPointer(input)
	if input then return Vector2.new(input.Position.X, input.Position.Y) end
	return UserInputService:GetMouseLocation()
end

local function pointer01(gui, input)
	local p = guiPointer(input)
	local abs = gui.AbsolutePosition
	local size = gui.AbsoluteSize
	return math.clamp((p.X - abs.X) / math.max(1, size.X), 0, 1),
		math.clamp((p.Y - abs.Y) / math.max(1, size.Y), 0, 1)
end

local Theme = {
	bg = Color3.fromRGB(10, 14, 12),
	bgHi = Color3.fromRGB(16, 22, 20),
	panel = Color3.fromRGB(16, 24, 20),
	panelHi = Color3.fromRGB(20, 30, 26),
	panelAlt = Color3.fromRGB(24, 36, 30),
	sidebar = Color3.fromRGB(8, 12, 10),
	sidebarHi = Color3.fromRGB(14, 20, 17),
	stroke = Color3.fromRGB(40, 60, 50),
	strokeHi = Color3.fromRGB(60, 90, 74),
	accent = Color3.fromRGB(52, 211, 153),
	accentDim = Color3.fromRGB(16, 185, 129),
	mint = Color3.fromRGB(52, 211, 153),
	cyan = Color3.fromRGB(167, 243, 208),
	rose = Color3.fromRGB(248, 113, 113),
	text = Color3.fromRGB(240, 255, 248),
	textDim = Color3.fromRGB(148, 176, 160),
	off = Color3.fromRGB(34, 48, 40),
	tabIdle = Color3.fromRGB(8, 12, 10),
	tabHover = Color3.fromRGB(28, 44, 36),
	selected = Color3.fromRGB(48, 36, 74),
}

local function parentGui(gui)
	local function protect(inst)
		pcall(function() if syn and syn.protect_gui then syn.protect_gui(inst) end end)
		pcall(function() if protectgui then protectgui(inst) end end)
		pcall(function() if protect_gui then protect_gui(inst) end end)
	end
	if gui then protect(gui) end
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then
			if gui then gui.Parent = hui return hui end
			return hui
		end
	end
	local okCore, core = pcall(function() return game:GetService("CoreGui") end)
	if okCore and core then
		pcall(function()
			if typeof(cloneref) == "function" then core = cloneref(core) end
		end)
		if gui then
			local okP = pcall(function() gui.Parent = core end)
			if okP and gui.Parent then return core end
		else
			return core
		end
	end
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 8)
	if gui and pg then gui.Parent = pg end
	return pg
end

local function mk(className, props, parent)
	local inst = Instance.new(className)
	for k, v in pairs(props) do inst[k] = v end
	if parent then inst.Parent = parent end
	return inst
end

local function corner(parent, r) return mk("UICorner", { CornerRadius = UDim.new(0, r or 10) }, parent) end

local function stroke(parent, color, th, tr)
	return mk("UIStroke", {
		Color = color or Theme.stroke,
		Thickness = th or 1,
		Transparency = tr or 0.25,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
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
	if not obj then return nil end
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
	if not s then s = mk("UIScale", { Name = "AnimScale", Scale = 1 }, gui) end
	return s
end

local function hoverScale(gui, grow)
	local s = ensureScale(gui)
	gui.MouseEnter:Connect(function() tween(s, { Scale = grow or 1.04 }, 0.14, Enum.EasingStyle.Quad) end)
	gui.MouseLeave:Connect(function() tween(s, { Scale = 1 }, 0.18, Enum.EasingStyle.Quad) end)
end

local function pressPunch(gui)
	local s = ensureScale(gui)
	s.Scale = 0.94
	tween(s, { Scale = 1 }, 0.22, Enum.EasingStyle.Back)
end

local function makeShadow(parent, size, offsetStep)
	for i = 1, 3 do
		local off = offsetStep * i
		local sh = mk("Frame", {
			Name = "Shadow" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.72 + i * 0.07,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, off, 0.5, off),
			Size = size,
			ZIndex = 10 - i,
		}, parent)
		corner(sh, 14)
	end
end

local brandImage = nil
local function getBrandImage()
	if brandImage ~= nil then return brandImage end
	brandImage = LOGO_ASSET
	pcall(function()
		if typeof(isfile) ~= "function" or typeof(getcustomasset) ~= "function" then return end
		if isfile(LOGO_FILE) then
			local ok, asset = pcall(getcustomasset, LOGO_FILE)
			if ok and type(asset) == "string" and asset ~= "" then
				brandImage = asset
				return
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
		BackgroundColor3 = Theme.panelAlt,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(size, size),
		ClipsDescendants = true,
		ZIndex = z,
	}, parent)
	corner(wrap, math.floor(size * 0.5))
	local grad = mk("UIGradient", {
		Color = ColorSequence.new(Theme.accentDim, Theme.panelAlt),
		Rotation = 45,
	}, wrap)
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0.95),
	})
	mk("TextLabel", {
		Name = "BrandGlyph",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBlack,
		Text = "Z",
		TextColor3 = Theme.accent,
		TextSize = math.floor(size * 0.55),
		ZIndex = z + 1,
	}, wrap)
	local img = mk("ImageLabel", {
		Name = "LogoImage",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = getBrandImage(),
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = z + 2,
	}, wrap)
	corner(img, math.floor(size * 0.5))
	return wrap
end

local InputManager = { activeDrag = nil, connections = {}, initialized = false }

function InputManager:Init()
	if self.initialized then return end
	self.initialized = true
	table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
		if not self.activeDrag then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			self.activeDrag(input)
		end
	end))
	table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			self.activeDrag = nil
		end
	end))
end

function InputManager:StartDrag(callback)
	self:Init()
	self.activeDrag = callback
end

function InputManager:StopDrag()
	self.activeDrag = nil
end

local Maid = {}
Maid.__index = Maid
function Maid.new() return setmetatable({ tasks = {} }, Maid) end
function Maid:Add(item) table.insert(self.tasks, item) return item end
function Maid:Clean()
	for _, item in ipairs(self.tasks) do
		if typeof(item) == "Instance" then pcall(function() item:Destroy() end)
		elseif typeof(item) == "RBXScriptConnection" then pcall(function() item:Disconnect() end)
		elseif type(item) == "function" then pcall(item) end
	end
	self.tasks = {}
end

local Library = { Theme = Theme, Windows = {}, Maid = Maid }
local activeDropdownClose = nil
local activeColorClose = nil
local popupLayer = nil

function Library.SetTheme(patch)
	for k, v in pairs(patch or {}) do Theme[k] = v end
end

-- ── Icon painting ───────────────────────────────────────────────────────
local ICON_KIND = {
	ESP = "grid", Aim = "crosshair", Silent = "circle", Trigger = "bolt",
	Rage = "flame", Mods = "sliders", Lobby = "home", Queue = "list",
	Security = "shield", Config = "gear", Visuals = "grid", Misc = "dots",
	Configs = "list", Settings = "gear", Preview = "eye", Color = "drop",
	Filters = "funnel", Extras = "spark", Aimbot = "crosshair", Targeting = "crosshair",
	Precision = "sliders", Humanization = "dots", Box = "grid", Info = "list",
	Combat = "crosshair", Farm = "circle", Movement = "bolt", Player = "home",
	Main = "home", Stats = "list", Weapon = "sliders",
	Gathering = "funnel", Loot = "drop", Exam = "shield",
}

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
	if props.Corner then corner(f, props.Corner) end
	if props.Stroke then
		stroke(f, props.Color or Theme.textDim, props.Stroke, 0)
		f.BackgroundTransparency = 1
	end
	return f
end

local function clearMarks(box)
	for _, child in ipairs(box:GetChildren()) do
		if child.Name == "IconMark" then child:Destroy() end
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

local function rgbToHsv(c)
	local r, g, b = c.R, c.G, c.B
	local maxv = math.max(r, g, b)
	local minv = math.min(r, g, b)
	local d = maxv - minv
	local h = 0
	if d > 1e-5 then
		if maxv == r then h = ((g - b) / d) % 6
		elseif maxv == g then h = (b - r) / d + 2
		else h = (r - g) / d + 4 end
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
	if i == 0 then return Color3.new(v, t, p)
	elseif i == 1 then return Color3.new(q, v, p)
	elseif i == 2 then return Color3.new(p, v, t)
	elseif i == 3 then return Color3.new(p, q, v)
	elseif i == 4 then return Color3.new(t, p, v) end
	return Color3.new(v, p, q)
end

-- ── Section (card) ──────────────────────────────────────────────────────
local function createSection(host, title)
	local card = mk("Frame", {
		BackgroundColor3 = Theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, host)
	corner(card, 16)
	mk("UIGradient", {
		Color = ColorSequence.new(Theme.panel, Theme.panelHi),
		Rotation = 45,
	}, card)
	local cardStroke = stroke(card, Theme.stroke, 1, 0.55)
	pad(card, 16, 16, 16, 16)
	card.MouseEnter:Connect(function()
		tween(cardStroke, { Color = Theme.accent, Transparency = 0.28 }, 0.18)
	end)
	card.MouseLeave:Connect(function()
		tween(cardStroke, { Color = Theme.stroke, Transparency = 0.55 }, 0.22)
	end)
	mk("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, card)

	local head = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 0 }, card)
	local iconBox = mk("Frame", {
		BackgroundColor3 = Color3.fromRGB(30, 44, 38),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.fromOffset(0, 1),
	}, head)
	corner(iconBox, 7)
	stroke(iconBox, Theme.accentDim, 1, 0.55)
	mk("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(40, 60, 50), Color3.fromRGB(20, 30, 26)),
		Rotation = 45,
	}, iconBox)
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
	local function nextOrder() order += 1 return order end
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
			if show then any = true end
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

	function api:Paragraph(text) return self:Label(text) end

	function api:Toggle(opts)
		opts = opts or {}
		local desc = tostring(opts.Description or "")
		local rowH = desc ~= "" and 40 or 30
		local row = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, rowH), LayoutOrder = nextOrder() }, card)
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
				Text = string.gsub(desc, " +", "   "),
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

		local ctrl = { Flag = opts.Flag, Get = function() return on end }
		function ctrl:Set(v, silent)
			on = v and true or false
			tween(track, { BackgroundColor3 = on and accent or Theme.off }, 0.16)
			tween(knob, { Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, 0.16)
			if not silent and opts.Callback then opts.Callback(on) end
		end
		hoverScale(track, 1.04)
		track.MouseButton1Click:Connect(function() pressPunch(track) ctrl:Set(not on, false) end)
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
		local btnGrad = mk("UIGradient", {
			Color = ColorSequence.new(Theme.panelAlt, Theme.panel),
			Rotation = 45,
		}, btn)
		stroke(btn, opts.Danger and Theme.rose or Theme.accentDim, 1, 0.45)
		trackSearch(opts.Text, btn)
		hoverScale(btn, 1.02)
		btn.MouseButton1Click:Connect(function()
			pressPunch(btn)
			if opts.Callback then opts.Callback(btn) end
		end)
		btn.MouseEnter:Connect(function()
			tween(btn, { BackgroundColor3 = Theme.tabHover }, 0.14)
			tween(btnGrad, { Rotation = 135 }, 0.3)
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, { BackgroundColor3 = Theme.panelAlt }, 0.2)
			tween(btnGrad, { Rotation = 45 }, 0.3)
		end)
		return btn
	end

	function api:Slider(opts)
		opts = opts or {}
		local minV, maxV = tonumber(opts.Min) or 0, tonumber(opts.Max) or 1
		local value = math.clamp(tonumber(opts.Default) or minV, minV, maxV)
		local desc = tostring(opts.Description or "")
		local row = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, desc ~= "" and 54 or 40), LayoutOrder = nextOrder() }, card)
		trackSearch((opts.Text or "") .. " " .. desc, row)

		mk("TextLabel", {
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
				Text = string.gsub(desc, " +", "   "),
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
		mk("UIGradient", {
			Color = ColorSequence.new(Theme.accentDim, Theme.cyan),
		}, fill)
		local knob = mk("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new((value - minV) / math.max(0.001, maxV - minV), 0, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
		}, bar)
		corner(knob, 6)

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
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
			valLabel.Text = string.format(opts.Format or "%.2f", value)
			if not silent and opts.Callback then opts.Callback(value) end
		end
		function ctrl:Set(v, silent)
			apply((math.clamp(tonumber(v) or minV, minV, maxV) - minV) / math.max(0.001, maxV - minV), silent)
		end
		function ctrl:Get() return value end
		ctrl.Instance = row

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				local x = pointer01(bar, input)
				apply(x, false)
				InputManager:StartDrag(function(dragInput)
					local nx = pointer01(bar, dragInput)
					apply(nx, false)
				end)
			end
		end)
		return ctrl
	end

	function api:TextBox(opts)
		opts = opts or {}
		local row = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = nextOrder() }, card)
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
		function ctrl:Get() return box.Text end
		function ctrl:Set(text) box.Text = tostring(text or "") end
		box.Focused:Connect(function()
			tween(boxStroke, { Color = Theme.accent, Transparency = 0.05 }, 0.16)
			tween(box, { BackgroundColor3 = Theme.tabIdle }, 0.16)
		end)
		box.FocusLost:Connect(function(enter)
			tween(boxStroke, { Color = Theme.stroke, Transparency = 0.35 }, 0.2)
			tween(box, { BackgroundColor3 = Theme.panelAlt }, 0.2)
			if opts.Callback then opts.Callback(box.Text, enter) end
		end)
		return ctrl
	end

	function api:Keybind(opts)
		opts = opts or {}
		local current = opts.Default
		if typeof(current) == "string" then current = Enum.KeyCode[current] or Enum.KeyCode.K end
		if typeof(current) ~= "EnumItem" then current = Enum.KeyCode.K end
		local listening = false
		local desc = tostring(opts.Description or "")
		local row = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, desc ~= "" and 46 or 32), LayoutOrder = nextOrder() }, card)
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
				Text = string.gsub(desc, " +", "   "),
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
		function ctrl:Get() return current end
		function ctrl:Set(key, silent)
			if typeof(key) == "string" then key = Enum.KeyCode[key] end
			if typeof(key) ~= "EnumItem" then return end
			current = key
			listening = false
			paint()
			if not silent and opts.Callback then opts.Callback(current) end
		end
		btn.MouseButton1Click:Connect(function() pressPunch(btn) listening = not listening paint() end)
		UserInputService.InputBegan:Connect(function(input)
			if not listening then return end
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if input.KeyCode == Enum.KeyCode.Unknown or input.KeyCode == Enum.KeyCode.Escape then
				listening = false paint() return
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
		local row = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, desc ~= "" and 42 or 28), LayoutOrder = nextOrder() }, card)
		trackSearch((opts.Text or "Color") .. " " .. desc .. " color picker rgb hue", row)

		local openBtn = mk("TextButton", { AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "" }, row)
		local preview = mk("Frame", { BackgroundColor3 = current, BorderSizePixel = 0, Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(0, 5), ZIndex = 2 }, openBtn)
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
				Text = string.gsub(desc, " +", "   "),
				TextColor3 = Theme.textDim,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 2,
			}, openBtn)
		end

		local pop, svFill, svCursor, hueCursor, curSwatch, rBox, gBox, bBox

		local function hueColor() return hsvToRgb(h, 1, 1) end
		local function apply(silent)
			current = hsvToRgb(h, s, v)
			preview.BackgroundColor3 = current
			if curSwatch then curSwatch.BackgroundColor3 = current end
			if svFill then svFill.Color = ColorSequence.new(Color3.new(1, 1, 1), hueColor()) end
			if svCursor then svCursor.Position = UDim2.new(s, 0, 1 - v, 0) end
			if hueCursor then hueCursor.Position = UDim2.new(0.5, 0, h, 0) end
			if rBox and not rBox:IsFocused() then
				rBox.Text = tostring(math.floor(current.R * 255 + 0.5))
				gBox.Text = tostring(math.floor(current.G * 255 + 0.5))
				bBox.Text = tostring(math.floor(current.B * 255 + 0.5))
			end
			if not silent and opts.Callback then opts.Callback(current) end
		end

		local function closePop()
			if pop then pop:Destroy() pop = nil end
			if activeColorClose == closePop then activeColorClose = nil end
		end

		local function openPop()
			if activeColorClose then activeColorClose() end
			if activeDropdownClose then pcall(activeDropdownClose, false) end
			local host = popupLayer
			if not host then return end
			pop = mk("Frame", { Name = "ColorPop", BackgroundColor3 = Theme.panel, BorderSizePixel = 0, Size = UDim2.fromOffset(278, 214), ZIndex = 120 }, host)
			corner(pop, 12)
			stroke(pop, Theme.accentDim, 1, 0.35)
			mk("UIGradient", { Color = ColorSequence.new(Theme.panel, Theme.panelHi), Rotation = 45 }, pop)
			local sv = mk("TextButton", { AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(168, 168), Text = "", ZIndex = 121 }, pop)
			corner(sv, 8)
			svFill = mk("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), hueColor()) }, sv)
			local shade = mk("TextButton", { AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Text = "", Active = true, ZIndex = 122 }, sv)
			corner(shade, 8)
			mk("UIGradient", {
				Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
				Rotation = 90,
			}, shade)
			svCursor = mk("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), Active = false, ZIndex = 123 }, shade)
			pcall(function() svCursor.Interactable = false end)
			corner(svCursor, 6)
			stroke(svCursor, Color3.new(1, 1, 1), 2, 0)
			local hue = mk("TextButton", { AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.fromOffset(188, 12), Size = UDim2.fromOffset(16, 168), Text = "", ZIndex = 121 }, pop)
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
			hueCursor = mk("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 6, 0, 8), Active = false, ZIndex = 123 }, hue)
			pcall(function() hueCursor.Interactable = false end)
			corner(hueCursor, 4)
			stroke(hueCursor, Color3.new(1, 1, 1), 1.5, 0)
			local side = mk("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(214, 12), Size = UDim2.fromOffset(52, 168), ZIndex = 121 }, pop)
			mk("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Font = Enum.Font.Gotham, Text = "Current", TextColor3 = Theme.textDim, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left }, side)
			curSwatch = mk("Frame", { BackgroundColor3 = current, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 14), Size = UDim2.fromOffset(44, 36) }, side)
			corner(curSwatch, 6)
			mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 0, 12), Font = Enum.Font.Gotham, Text = "Original", TextColor3 = Theme.textDim, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left }, side)
			local origSwatch = mk("TextButton", { AutoButtonColor = false, BackgroundColor3 = original, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 68), Size = UDim2.fromOffset(44, 36), Text = "" }, side)
			corner(origSwatch, 6)
			origSwatch.MouseButton1Click:Connect(function()
				h, s, v = rgbToHsv(original)
				apply(false)
			end)
			local function chan(x, label)
				local box = mk("TextBox", { BackgroundColor3 = Theme.panelAlt, BorderSizePixel = 0, Position = UDim2.fromOffset(x, 180), Size = UDim2.fromOffset(40, 22), Font = Enum.Font.Gotham, Text = "0", TextColor3 = Theme.text, TextSize = 11, ClearTextOnFocus = false, ZIndex = 122 }, pop)
				corner(box, 5)
				mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(x, 168), Size = UDim2.fromOffset(40, 12), Font = Enum.Font.Gotham, Text = label, TextColor3 = Theme.textDim, TextSize = 9, ZIndex = 122 }, pop)
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
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						if kind == "sv" then readSv(input) else readHue(input) end
						InputManager:StartDrag(function(dragInput)
							if kind == "sv" then readSv(dragInput) else readHue(dragInput) end
						end)
					end
				end)
			end
			bindDrag(sv, "sv")
			bindDrag(shade, "sv")
			bindDrag(hue, "hue")
			apply(true)
			pop.Position = UDim2.fromOffset(
				math.clamp(preview.AbsolutePosition.X + 28, 12, 900),
				math.clamp(preview.AbsolutePosition.Y, 12, 520)
			)
			activeColorClose = closePop
			ignoreColorOutsideUntil = os.clock() + 0.2
		end

		openBtn.MouseButton1Click:Connect(function() if pop then closePop() else openPop() end end)
		UserInputService.InputBegan:Connect(function(input)
			if not pop then return end
			if input.KeyCode == Enum.KeyCode.Escape then closePop() return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			if os.clock() < ignoreColorOutsideUntil then return end
			local p = guiPointer(input)
			local function hit(gui)
				if not gui or not gui.Parent then return false end
				local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
				return p.X >= pos.X and p.X <= pos.X + size.X and p.Y >= pos.Y and p.Y <= pos.Y + size.Y
			end
			if not hit(pop) and not hit(openBtn) then closePop() end
		end)
		function ctrl:Set(color, silent)
			if typeof(color) ~= "Color3" then return end
			h, s, v = rgbToHsv(color)
			apply(silent == true)
		end
		function ctrl:Get() return current end
		apply(true)
		return ctrl
	end

	function api:Dropdown(opts)
		opts = opts or {}
		local options = {}
		local rawOpts = opts.Options or opts.Values or opts.List or {}
		if type(rawOpts) == "table" then
			if #rawOpts > 0 then
				for _, v in ipairs(rawOpts) do table.insert(options, tostring(v)) end
			else
				for k, v in pairs(rawOpts) do
					local s = type(v) == "string" and v ~= "" and v or (type(k) == "string" and k or "")
					if s ~= "" then table.insert(options, s) end
				end
				table.sort(options)
			end
		end
		if #options == 0 then options = { "None" } end
		local value = tostring(opts.Default or options[1])
		if not table.find(options, value) then value = options[1] end

		local desc = tostring(opts.Description or "")
		local row = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, desc ~= "" and 66 or 52), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 8 }, card)
		trackSearch(tostring(opts.Text or "") .. " " .. desc .. " " .. table.concat(options, " "), row)

		mk("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.GothamMedium, Text = tostring(opts.Text or "Select"), TextColor3 = Theme.text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, row)
		if desc ~= "" then
			mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1, 0, 0, 14), Font = Enum.Font.Gotham, Text = string.gsub(desc, " +", "   "), TextColor3 = Theme.textDim, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
		end

		local trigger = mk("TextButton", { AutoButtonColor = false, BackgroundColor3 = Theme.panelAlt, BorderSizePixel = 0, Position = UDim2.fromOffset(0, desc ~= "" and 32 or 20), Size = UDim2.new(1, 0, 0, 30), Text = "", ZIndex = 9 }, row)
		corner(trigger, 6)
		local triggerStroke = stroke(trigger, Theme.stroke, 1, 0.35)
		local valueLabel = mk("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.Gotham, Text = value, TextColor3 = Theme.text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 10 }, trigger)
		local chevron = mk("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(16, 16), Font = Enum.Font.GothamBold, Text = "v", TextColor3 = Theme.textDim, TextSize = 12, ZIndex = 10 }, trigger)

		local open = false
		local itemH = 22
		local host = popupLayer
		local catcher = mk("TextButton", { Name = "DropdownCatch", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Text = "", Visible = false, ZIndex = 398 }, host)
		local menu = mk("Frame", { Name = "DropdownMenu", BackgroundColor3 = Theme.panelAlt, BorderSizePixel = 0, Size = UDim2.fromOffset(200, 0), Visible = false, Active = true, ZIndex = 400, ClipsDescendants = true }, host)
		corner(menu, 6)
		stroke(menu, Theme.stroke, 1, 0.3)
		mk("UIGradient", { Color = ColorSequence.new(Theme.panelAlt, Theme.panel), Rotation = 90 }, menu)
		local list = mk("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.accentDim, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Active = false, ZIndex = 401 }, menu)
		pad(list, 3, 3, 3, 3)
		mk("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }, list)

		local ctrl = {}
		local itemButtons = {}

		local function setValue(v, silent)
			value = tostring(v)
			valueLabel.Text = value
			for _, item in ipairs(itemButtons) do
				local selected = item.Name == value
				item.BackgroundColor3 = selected and Theme.selected or Theme.panelAlt
				item.TextColor3 = selected and Theme.text or Theme.textDim
				local tick = item:FindFirstChildWhichIsA("TextLabel")
				if tick then tick.Text = selected and "✓" or "" end
			end
			if not silent and opts.Callback then opts.Callback(value) end
		end

		local function visibleCount()
			local n = 0
			for _, item in ipairs(itemButtons) do if item.Visible then n += 1 end end
			return math.max(n, 1)
		end

		local function placeMenu()
			local layer = host or popupLayer
			if not layer then return end
			if menu.Parent ~= layer then menu.Parent = layer end
			if catcher.Parent ~= layer then catcher.Parent = layer end
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

		local setOpen
		function setOpen(state)
			state = state and true or false
			if state and activeDropdownClose and activeDropdownClose ~= setOpen then
				activeDropdownClose(false)
			end
			if state and activeColorClose then pcall(activeColorClose) end
			open = state
			if open then
				activeDropdownClose = setOpen
				for _, item in ipairs(itemButtons) do item.Visible = true end
				placeMenu()
			else
				if activeDropdownClose == setOpen then activeDropdownClose = nil end
			end
			chevron.Text = open and "^" or "v"
			chevron.TextColor3 = open and Theme.accent or Theme.textDim
			triggerStroke.Color = open and Theme.accent or Theme.stroke
			triggerStroke.Transparency = open and 0.05 or 0.35
			catcher.Visible = open
			menu.Visible = open
		end

		function ctrl:Get() return value end
		function ctrl:Set(v, silent)
			if table.find(options, tostring(v)) then setValue(v, silent) end
		end
		function ctrl:SetOptions(listOpts, keep)
			local incoming = {}
			if type(listOpts) == "table" then
				if #listOpts > 0 then
					for _, v in ipairs(listOpts) do
						local s = tostring(v)
						if s ~= "" then table.insert(incoming, s) end
					end
				else
					for k, v in pairs(listOpts) do
						local s = type(v) == "string" and v ~= "" and v or (type(k) == "string" and k or "")
						if s ~= "" then table.insert(incoming, s) end
					end
					table.sort(incoming)
				end
			end
			table.clear(options)
			table.clear(itemButtons)
			for _, child in ipairs(list:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			for _, s in ipairs(incoming) do table.insert(options, s) end
			if #options == 0 then table.insert(options, "None") end
			for i, opt in ipairs(options) do
				local item = mk("TextButton", { Name = opt, AutoButtonColor = false, BackgroundColor3 = Theme.panelAlt, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, itemH), Font = Enum.Font.Gotham, Text = "  " .. opt, TextColor3 = Theme.textDim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, ZIndex = 402 }, list)
				corner(item, 4)
				local tick = mk("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(14, 14), Font = Enum.Font.GothamBold, Text = "", TextColor3 = Theme.accent, TextSize = 12, ZIndex = 403 }, item)
				item.MouseEnter:Connect(function()
					item.BackgroundColor3 = Theme.tabHover
					item.TextColor3 = Theme.text
				end)
				item.MouseLeave:Connect(function()
					local selected = item.Name == value
					item.BackgroundColor3 = selected and Theme.selected or Theme.panelAlt
					item.TextColor3 = selected and Theme.text or Theme.textDim
					tick.Text = selected and "✓" or ""
				end)
				local lastPick = 0
				local function pick()
					if os.clock() - lastPick < 0.08 then return end
					lastPick = os.clock()
					setValue(opt, false)
					setOpen(false)
				end
				item.Activated:Connect(pick)
				item.MouseButton1Click:Connect(pick)
				item.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						pick()
					end
				end)
				table.insert(itemButtons, item)
			end
			if keep and table.find(options, value) then setValue(value, true) else setValue(options[1], true) end
			if open then setOpen(true) end
		end

		ctrl:SetOptions(options, true)
		catcher.MouseButton1Click:Connect(function() setOpen(false) end)
		catcher.MouseButton1Down:Connect(function() setOpen(false) end)
		trigger.MouseButton1Click:Connect(function() setOpen(not open) end)
		row.Destroying:Connect(function()
			if activeDropdownClose == setOpen then activeDropdownClose = nil end
			if menu then menu:Destroy() end
			if catcher then catcher:Destroy() end
		end)
		return ctrl
	end

	return api
end

-- ── Window ───────────────────────────────────────────────────────────────
function Library.CreateWindow(opts)
	opts = opts or {}
	local title = tostring(opts.Title or LIB_NAME)
	if title == "" then title = LIB_NAME end
	local subtitle = tostring(opts.Subtitle or "")
	local compact = isCompact()
	local size = opts.Size or UDim2.fromOffset(840, 560)
	do
		local vs = viewportSize()
		local insetY = 0
		pcall(function() insetY = GuiService:GetGuiInset().Y end)
		local maxW = math.max(300, vs.X - (compact and 12 or 28))
		local maxH = math.max(260, vs.Y - (compact and 16 or 32) - insetY * 0.2)
		local wantW, wantH = size.X.Offset, size.Y.Offset
		if wantW <= 0 then wantW = 840 end
		if wantH <= 0 then wantH = 560 end
		size = UDim2.fromOffset(math.floor(math.min(wantW, maxW)), math.floor(math.min(wantH, maxH)))
	end

	local toggleKeys = {}
	local function addToggleKey(key)
		if typeof(key) == "string" then key = Enum.KeyCode[key] end
		if typeof(key) == "EnumItem" then
			for _, existing in ipairs(toggleKeys) do
				if existing == key then return end
			end
			table.insert(toggleKeys, key)
		end
	end
	if opts.ToggleKeys then
		for _, key in ipairs(opts.ToggleKeys) do addToggleKey(key) end
	end
	addToggleKey(opts.ToggleKey)
	if #toggleKeys == 0 then addToggleKey(Enum.KeyCode.RightShift) end

	local screenParent = parentGui()
	local screen = mk("ScreenGui", {
		Name = LIB_NAME .. "Window",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = opts.DisplayOrder or 120000,
		IgnoreGuiInset = true,
		Enabled = true,
	}, screenParent)

	makeShadow(screen, size, 8)

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
	mk("UIGradient", { Color = ColorSequence.new(Theme.bg, Theme.bgHi), Rotation = 45 }, root)
	stroke(root, Theme.strokeHi, 1, 0.55)

	local topLine = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Theme.accent,
		BorderSizePixel = 0,
		ZIndex = 11,
	}, root)
	mk("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.accentDim),
			ColorSequenceKeypoint.new(0.5, Theme.accent),
			ColorSequenceKeypoint.new(1, Theme.cyan),
		}),
	}, topLine)

	local openScale = mk("UIScale", { Name = "OpenScale", Scale = 1 }, root)
	local body = mk("Frame", { Name = "BodyRow", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 20 }, root)

	local SIDE_W = compact and 148 or 200
	local sidebar = mk("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.sidebar,
		BorderSizePixel = 0,
		Size = UDim2.new(0, SIDE_W, 1, 0),
		ClipsDescendants = true,
	}, body)
	mk("UIGradient", { Color = ColorSequence.new(Theme.sidebar, Theme.sidebarHi), Rotation = 90 }, sidebar)

	mk("Frame", {
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
	mk("TextLabel", {
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

	local content = mk("Frame", {
		Name = "Content",
		BackgroundColor3 = Theme.bg,
		BackgroundTransparency = 1,
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

	local searchBox = mk("TextBox", {
		Name = "Search",
		BackgroundColor3 = Theme.panelAlt,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -52, 0.5, 0),
		Size = UDim2.fromOffset(170, 26),
		Font = Enum.Font.Gotham,
		Text = "",
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.textDim,
		TextColor3 = Theme.text,
		TextSize = 11,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 10,
	}, contentHead)
	corner(searchBox, 6)
	pad(searchBox, 0, 0, 8, 8)
	local searchStroke = stroke(searchBox, Theme.stroke, 1, 0.4)

	local closeBtn = mk("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextColor3 = Theme.textDim,
		TextSize = 16,
		ZIndex = 10,
	}, contentHead)

	local pagesFolder = mk("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 58),
		Size = UDim2.new(1, -24, 1, -84),
		ClipsDescendants = true,
	}, content)

	popupLayer = mk("Frame", {
		Name = "PopupLayer",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 350,
		ClipsDescendants = false,
	}, screen)

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

	local reopen = mk("TextButton", {
		Name = "Reopen",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.panel,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 72),
		Size = UDim2.fromOffset(50, 50),
		Text = "",
		Visible = false,
		ZIndex = 60,
	}, screen)
	corner(reopen, 25)
	stroke(reopen, Theme.accent, 1, 0.35)
	mk("UIGradient", { Color = ColorSequence.new(Theme.panel, Theme.panelHi), Rotation = 45 }, reopen)
	local pillBrand = makeBrand(reopen, 32, 61)
	pillBrand.AnchorPoint = Vector2.new(0.5, 0.5)
	pillBrand.Position = UDim2.new(0.5, 0, 0.5, 0)
	hoverScale(reopen, 1.08)

	local window = {
		Screen = screen,
		Root = root,
		Reopen = reopen,
		Theme = Theme,
		_tabs = {},
		_tabOrder = {},
		_active = nil,
		_open = false,
		_search = "",
	}

	closeBtn.MouseButton1Click:Connect(function() window:SetOpen(false) end)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, { TextColor3 = Theme.rose }, 0.14) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, { TextColor3 = Theme.textDim }, 0.16) end)
	reopen.MouseButton1Click:Connect(function() pressPunch(reopen) window:Toggle() end)

	function window:SetOpen(visible)
		visible = visible and true or false
		if self._open == visible then return end
		self._open = visible
		screen.Enabled = true
		if visible then
			root.Visible = true
			reopen.Visible = false
			openScale.Scale = 0.88
			tween(openScale, { Scale = 1 }, 0.34, Enum.EasingStyle.Back)
		else
			root.Visible = false
			reopen.Visible = true
			if activeDropdownClose then pcall(activeDropdownClose, false) end
			if activeColorClose then pcall(activeColorClose) end
		end
	end

	function window:Toggle() self:SetOpen(not self._open) end

	function window:SetSearch(q)
		self._search = tostring(q or "")
		local tabApi = self._active and self._tabs[self._active] or nil
		if tabApi and tabApi._applySearch then tabApi._applySearch(self._search) end
	end

	function window:AddTab(name, iconKind)
		name = tostring(name)
		if self._tabs[name] then return self._tabs[name] end

		local btn = mk("TextButton", {
			Name = "Tab_" .. name,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.tabIdle,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40),
			Font = Enum.Font.GothamMedium,
			Text = "",
			LayoutOrder = #self._tabOrder + 1,
		}, sidebarNav)
		corner(btn, 10)

		local accentBar = mk("Frame", {
			Name = "AccentBar",
			BackgroundColor3 = Theme.accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 20),
			Visible = false,
			ZIndex = 4,
		}, btn)
		corner(accentBar, 2)
		mk("UIGradient", { Color = ColorSequence.new(Theme.accentDim, Theme.cyan), Rotation = 90 }, accentBar)

		local iconBox = mk("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 7),
			Size = UDim2.fromOffset(26, 26),
			ZIndex = 3,
		}, btn)
		paintIcon(iconBox, iconKind or name, Theme.textDim)

		local label = mk("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(48, 0),
			Size = UDim2.new(1, -52, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = Theme.textDim,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 2,
		}, btn)

		local page = mk("ScrollingFrame", {
			Name = "Page_" .. name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.accentDim,
			Visible = false,
		}, pagesFolder)
		pad(page, 4, 16, 4, 4)
		mk("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, page)

		local tabApi = { Name = name, Button = btn, Page = page, _sections = {}, _iconBox = iconBox, _accent = accentBar, _label = label }

		function tabApi:Section(sectionTitle)
			local sec = createSection(page, sectionTitle)
			table.insert(self._sections, sec)
			return sec
		end

		function tabApi._applySearch(q)
			local any = false
			for _, sec in ipairs(self._sections) do
				local shown = sec:SetSearch(q)
				if shown then any = true end
			end
			return any
		end

		local function paintIconColor(isSel)
			for _, m in ipairs(iconBox:GetChildren()) do
				if m.Name == "IconMark" then
					m.BackgroundColor3 = isSel and Theme.accent or Theme.textDim
					local st = m:FindFirstChildOfClass("UIStroke")
					if st then st.Color = isSel and Theme.accent or Theme.textDim end
				end
			end
		end

		local function select()
			for n, t in pairs(self._tabs) do
				local isSel = n == name
				tween(t.Button, {
					BackgroundColor3 = isSel and Theme.panelAlt or Theme.tabIdle,
					BackgroundTransparency = isSel and 0 or 1,
				}, 0.16)
				if t._label then
					tween(t._label, { TextColor3 = isSel and Theme.text or Theme.textDim }, 0.16)
				end
				if t._accent then
					t._accent.Visible = isSel
					if isSel then
						t._accent.Size = UDim2.new(0, 3, 0, 10)
						tween(t._accent, { Size = UDim2.new(0, 3, 0, 20) }, 0.2)
					end
				end
				if t._iconBox then
					for _, m in ipairs(t._iconBox:GetChildren()) do
						if m.Name == "IconMark" then
							m.BackgroundColor3 = isSel and Theme.accent or Theme.textDim
							local st = m:FindFirstChildOfClass("UIStroke")
							if st then st.Color = isSel and Theme.accent or Theme.textDim end
						end
					end
				end
				t.Page.Visible = isSel
			end
			self._active = name
			pageTitle.Text = name
			if self._search ~= "" then tabApi._applySearch(self._search) end
		end

		btn.MouseButton1Click:Connect(function() pressPunch(btn) select() end)
		btn.MouseEnter:Connect(function()
			if self._active ~= name then
				tween(btn, { BackgroundTransparency = 0.55, BackgroundColor3 = Theme.tabHover }, 0.14)
			end
		end)
		btn.MouseLeave:Connect(function()
			if self._active ~= name then
				tween(btn, { BackgroundTransparency = 1 }, 0.16)
			end
		end)

		self._tabs[name] = tabApi
		table.insert(self._tabOrder, name)
		if not self._active then select() end
		return tabApi
	end

	function window:SelectTab(name)
		local t = self._tabs[name]
		if not t then return end
		for n, tt in pairs(self._tabs) do
			local isSel = n == name
			tween(tt.Button, {
				BackgroundColor3 = isSel and Theme.panelAlt or Theme.tabIdle,
				BackgroundTransparency = isSel and 0 or 1,
			}, 0.16)
			if tt._label then tween(tt._label, { TextColor3 = isSel and Theme.text or Theme.textDim }, 0.16) end
			if tt._accent then
				tt._accent.Visible = isSel
				if isSel then
					tt._accent.Size = UDim2.new(0, 3, 0, 10)
					tween(tt._accent, { Size = UDim2.new(0, 3, 0, 20) }, 0.2)
				end
			end
			if tt._iconBox then
				for _, m in ipairs(tt._iconBox:GetChildren()) do
					if m.Name == "IconMark" then
						m.BackgroundColor3 = isSel and Theme.accent or Theme.textDim
						local st = m:FindFirstChildOfClass("UIStroke")
						if st then st.Color = isSel and Theme.accent or Theme.textDim end
					end
				end
			end
			tt.Page.Visible = isSel
		end
		self._active = name
		pageTitle.Text = name
		if self._search ~= "" and t._applySearch then t._applySearch(self._search) end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		window:SetSearch(searchBox.Text)
	end)
	searchBox.Focused:Connect(function() tween(searchStroke, { Color = Theme.accent, Transparency = 0.05 }, 0.16) end)
	searchBox.FocusLost:Connect(function() tween(searchStroke, { Color = Theme.stroke, Transparency = 0.4 }, 0.2) end)

	function window:Notify(opts)
		local text = type(opts) == "table" and (opts.Text or opts.Title) or tostring(opts)
		local color = type(opts) == "table" and (opts.Color or Theme.cyan) or Theme.cyan
		local dur = type(opts) == "table" and (opts.Duration or 3) or 3
		local toast = mk("Frame", {
			BackgroundColor3 = Theme.panel,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ZIndex = 81,
		}, toastHold)
		corner(toast, 8)
		local bar = mk("Frame", {
			Name = "Bar",
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 1, 0),
			ZIndex = 82,
		}, toast)
		corner(bar, 2)
		local toastStroke = stroke(toast, color, 1, 0.4)
		local lbl = mk("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 10),
			Size = UDim2.new(1, -22, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			Text = tostring(text),
			TextColor3 = Theme.text,
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 82,
		}, toast)
		toastStroke.Transparency = 1
		lbl.TextTransparency = 1

		tween(toast, { BackgroundTransparency = 0 }, 0.2)
		tween(toastStroke, { Transparency = 0.4 }, 0.2)
		tween(lbl, { TextTransparency = 0 }, 0.2)

		task.delay(math.max(0.5, tonumber(dur) or 3), function()
			if not toast.Parent then return end
			tween(toast, { BackgroundTransparency = 1 }, 0.25)
			tween(lbl, { TextTransparency = 1 }, 0.25)
			tween(toastStroke, { Transparency = 1 }, 0.25)
			tween(bar, { BackgroundTransparency = 1 }, 0.25)
			task.wait(0.3)
			if toast.Parent then toast:Destroy() end
		end)
		return toast
	end

	-- drag by brand row in sidebar
	do
		local dragging, dragStart, startPos = false, nil, nil
		sideBrand.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = guiPointer(input)
				startPos = root.Position
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
				local delta = guiPointer(input) - dragStart
				root.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	-- toggle keys: CAS + UIS fallback
	do
		local casName = "ZentynalToggle_" .. tostring(math.random(100000, 999999))
		local function onToggle()
			if UserInputService:GetFocusedTextBox() then return end
			window:Toggle()
		end
		local okCAS = pcall(function()
			ContextActionService:BindActionAtPriority(
				casName,
				function(_, state)
					if state == Enum.UserInputState.Begin then
						onToggle()
						return Enum.ContextActionResult.Sink
					end
					return Enum.ContextActionResult.Pass
				end,
				false,
				Enum.ContextActionPriority.High.Value,
				table.unpack(toggleKeys)
			)
		end)
		local toggleConn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			for _, k in ipairs(toggleKeys) do
				if input.KeyCode == k then onToggle() return end
			end
		end)
		window._casName = casName
		window._okCAS = okCAS
		window._toggleConn = toggleConn
	end

	function window:Destroy()
		if activeDropdownClose then pcall(activeDropdownClose, false) end
		if activeColorClose then pcall(activeColorClose) end
		if self._okCAS and self._casName then
			pcall(function() ContextActionService:UnbindAction(self._casName) end)
		end
		if self._toggleConn then pcall(function() self._toggleConn:Disconnect() end) end
		popupLayer = nil
		if screen then pcall(function() screen:Destroy() end) end
		for i, w in ipairs(Library.Windows) do
			if w == window then
				table.remove(Library.Windows, i)
				break
			end
		end
	end

	table.insert(Library.Windows, window)
	window:SetOpen(true)
	return window
end

function Library.DestroyAll()
	for i = #Library.Windows, 1, -1 do
		pcall(function() Library.Windows[i]:Destroy() end)
	end
end

return Library
