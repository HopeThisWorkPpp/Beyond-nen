--[[
    Zentynal UI Library V6
    Refactored for performance, zero input leaks, and premium aesthetics.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local LIB_NAME = "Zentynal"
local LOGO_ASSET = "rbxassetid://114884658309823"
local LOGO_FILE = "Zentynal/logo.png"

-- Utility: Viewport & Device
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
	return math.clamp((p.X - abs.X) / math.max(1, size.X), 0, 1), math.clamp((p.Y - abs.Y) / math.max(1, size.Y), 0, 1)
end

-- Theme
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
		else return core end
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
	local tw = TweenService:Create(obj, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
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
	local c1 = gui.MouseEnter:Connect(function() tween(s, { Scale = grow or 1.04 }, 0.14, Enum.EasingStyle.Quad) end)
	local c2 = gui.MouseLeave:Connect(function() tween(s, { Scale = 1 }, 0.18, Enum.EasingStyle.Quad) end)
	return { c1, c2 }
end

local function pressPunch(gui)
	local s = ensureScale(gui)
	s.Scale = 0.94
	tween(s, { Scale = 1 }, 0.22, Enum.EasingStyle.Back)
end

-- Custom Logo Handling (Fallback Logic)
local brandImage = nil
local function getBrandImage()
	if brandImage ~= nil then return brandImage end
	brandImage = LOGO_ASSET -- Default to Roblox asset
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
	
	local img = mk("ImageLabel", {
		Name = "LogoImage",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = getBrandImage(),
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = z + 1,
	}, wrap)
	corner(img, math.floor(size * 0.5))
	return wrap
end

-- Central Input Engine (Fixes memory leaks)
local InputManager = {
	activeDrag = nil,
	connections = {},
	initialized = false
}

function InputManager:Init()
	if self.initialized then return end
	self.initialized = true
	table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
		if not self.activeDrag then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			self.activeDrag(input)
		end
	end))
	table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if self.activeDrag then
				self.activeDrag = nil
			end
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

-- Cleanup Manager
local Maid = {}
Maid.__index = Maid
function Maid.new() return setmetatable({ tasks = {} }, Maid) end
function Maid:Add(item)
	table.insert(self.tasks, item)
	return item
end
function Maid:Clean()
	for _, item in ipairs(self.tasks) do
		if typeof(item) == "Instance" then
			pcall(function() item:Destroy() end)
		elseif typeof(item) == "RBXScriptConnection" then
			pcall(function() item:Disconnect() end)
		elseif type(item) == "function" then
			pcall(item)
		end
	end
	self.tasks = {}
end

local Library = {
	Theme = Theme,
	Windows = {},
	Maid = Maid,
}
local activeDropdownClose = nil

function Library.SetTheme(patch)
	for k, v in pairs(patch or {}) do Theme[k] = v end
end

-- Loading Screen (Splash)
local loadingGui, loadingText, loadingFill, loadingDots, loadingLabel = nil, nil, nil, nil, ""
local loadingMaid = Maid.new()

local function findNamedGui(name)
	local found
	pcall(function()
		if typeof(gethui) == "function" then
			local ok, hui = pcall(gethui)
			if ok and hui then found = hui:FindFirstChild(name) end
		end
	end)
	if not found then pcall(function() found = game:GetService("CoreGui"):FindFirstChild(name) end) end
	if not found then
		local pg = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
		found = pg and pg:FindFirstChild(name)
	end
	return found
end

function Library.HideLoading()
	loadingDots = false
	if loadingGui then pcall(function() loadingGui:Destroy() end) end
	loadingGui, loadingText, loadingFill = nil, nil, nil
	loadingMaid:Clean()
end

function Library.SetLoading(msg)
	loadingLabel = tostring(msg or ""):gsub("%.+$", "")
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
		warn("[Zentynal] " .. text)
	end
	task.delay(6, function() Library.HideLoading() end)
end

function Library.ShowLoading(opts)
	opts = opts or {}
	Library.HideLoading()
	local old = findNamedGui(LIB_NAME .. "Loading")
	if old then pcall(function() old:Destroy() end) end
	
	local splash = mk("ScreenGui", {
		Name = LIB_NAME .. "Loading",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 200000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function() splash.ClipToDeviceSafeArea = false end)
	
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
	
	-- Top gradient
	local topGrad = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, card)
	mk("UIGradient", {
		Color = ColorSequence.new(Theme.accent, Theme.mint),
	}, topGrad)
	
	local badge = makeBrand(card, 42, 21)
	badge.AnchorPoint = Vector2.new(0.5, 0)
	badge.Position = UDim2.new(0.5, 0, 0, 28)
	
	mk("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 80),
		Size = UDim2.new(1, -32, 0, 24),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.text,
		Text = tostring(opts.Title or LIB_NAME),
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
	mk("UIGradient", { Color = ColorSequence.new(Theme.accent, Theme.mint) }, loadingFill)
	
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

return Library

-- ── WINDOW CREATION ────────────────────────────────────────────────────────

function Library.CreateWindow(opts)
	opts = opts or {}
	local title = tostring(opts.Title or LIB_NAME)
	local subtitle = tostring(opts.Subtitle or "")
	local compact = isCompact()
	local size = opts.Size or UDim2.fromOffset(840, 560)
	
	local toggleKeys = {}
	local function addToggleKey(key)
		if typeof(key) == "string" then key = Enum.KeyCode[key] end
		if typeof(key) == "EnumItem" then
			for _, existing in ipairs(toggleKeys) do if existing == key then return end end
			table.insert(toggleKeys, key)
		end
	end
	if opts.ToggleKeys then for _, key in ipairs(opts.ToggleKeys) do addToggleKey(key) end end
	addToggleKey(opts.ToggleKey)
	if #toggleKeys == 0 then addToggleKey(Enum.KeyCode.RightShift) end
	
	local winMaid = Library.Maid.new()
	local screenParent = parentGui()
	
	local screen = mk("ScreenGui", {
		Name = LIB_NAME .. "Window",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = opts.DisplayOrder or 120000,
		IgnoreGuiInset = true,
		Enabled = false,
	}, screenParent)
	winMaid:Add(screen)
	
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
	
	-- Top Gradient Accent
	local topLine = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Theme.accent,
		BorderSizePixel = 0,
		ZIndex = 11,
	}, root)
	mk("UIGradient", {
		Color = ColorSequence.new(Theme.accent, Theme.mint),
	}, topLine)
	
	local openScale = mk("UIScale", { Name = "OpenScale", Scale = 1 }, root)
	local popupLayer = screen
	
	-- Layout: Body Row
	local body = mk("Frame", {
		Name = "BodyRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 20,
	}, root)
	
	local SIDE_W = compact and 148 or 200
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
	
	-- Brand Row
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
	
	-- Sidebar Nav
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
	
	-- Content Area
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
	
	-- Window Object
	local window = {
		Screen = screen,
		Root = root,
		Theme = Theme,
		_tabs = {},
		_active = nil,
		_open = false,
	}
	
	closeBtn.MouseButton1Click:Connect(function()
		window:SetOpen(false)
	end)
	
	-- Open / Close Logic
	function window:SetOpen(visible)
		if self._open == visible then return end
		self._open = visible
		if visible then
			screen.Enabled = true
			root.Visible = true
			openScale.Scale = 0.88
			tween(openScale, { Scale = 1 }, 0.34, Enum.EasingStyle.Back)
		else
			screen.Enabled = false
			root.Visible = false
		end
	end
	
	-- Top-level Tab Creation
	function window:AddTab(name)
		name = tostring(name)
		local btn = mk("TextButton", {
			Name = "Tab_" .. name,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.tabIdle,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40),
			Font = Enum.Font.GothamMedium,
			Text = "",
			LayoutOrder = #self._tabs + 1,
		}, sidebarNav)
		corner(btn, 10)
		
		mk("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -20, 1, 0),
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
		
		local tabApi = {
			Name = name,
			Button = btn,
			Page = page,
			_sections = {}
		}
		
		function tabApi:Section(title)
			local sec = createSection(page, title)
			table.insert(self._sections, sec)
			return sec
		end
		
		local function select()
			for n, t in pairs(window._tabs) do
				local isSel = n == name
				tween(t.Button, { BackgroundColor3 = isSel and Theme.panelAlt or Theme.tabIdle, BackgroundTransparency = isSel and 0 or 1 }, 0.16)
				local lbl = t.Button:FindFirstChildOfClass("TextLabel")
				if lbl then tween(lbl, { TextColor3 = isSel and Theme.text or Theme.textDim }, 0.16) end
				t.Page.Visible = isSel
			end
			window._active = name
			pageTitle.Text = name
		end
		
		btn.MouseButton1Click:Connect(function()
			pressPunch(btn)
			select()
		end)
		
		self._tabs[name] = tabApi
		if not self._active then select() end
		return tabApi
	end
	
	-- Notifications (Toasts)
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
	
	function window:Notify(opts)
		local text = type(opts) == "table" and (opts.Text or opts.Title) or tostring(opts)
		local color = type(opts) == "table" and (opts.Color or Theme.cyan) or Theme.cyan
		
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
		
		mk("TextLabel", {
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
		
		TweenService:Create(toast, TweenInfo.new(0.18), { BackgroundTransparency = 0.05 }):Play()
		TweenService:Create(tStroke, TweenInfo.new(0.18), { Transparency = 0.35 }):Play()
		
		task.delay(type(opts) == "table" and (opts.Duration or 3) or 3, function()
			if not toast.Parent then return end
			TweenService:Create(toast, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(tStroke, TweenInfo.new(0.22), { Transparency = 1 }):Play()
			task.wait(0.24)
			if toast.Parent then toast:Destroy() end
		end)
	end
	
	-- Dragging
	do
		local dragging, dragStart, startPos = false, nil, nil
		sideBrand.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = guiPointer(input)
				startPos = root.Position
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = guiPointer(input) - dragStart
				root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end
	
	window:SetOpen(true)
	return window
end

-- ── UI COMPONENTS ────────────────────────────────────────────────────────

function createSection(parent, title)
	local card = mk("Frame", {
		BackgroundColor3 = Theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, parent)
	corner(card, 16)
	local cardStroke = stroke(card, Theme.stroke, 1, 0.55)
	pad(card, 16, 16, 16, 16)
	
	mk("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, card)
	
	local head = mk("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		LayoutOrder = 0,
	}, card)
	
	mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = title or "Section",
		TextColor3 = Theme.text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, head)
	
	local order = 0
	local api = { Instance = card }
	
	local function nextOrder() order += 1 return order end
	
	function api:Toggle(opts)
		opts = opts or {}
		local row = mk("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
			LayoutOrder = nextOrder(),
		}, card)
		
		mk("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -56, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = tostring(opts.Text or "Toggle"),
			TextColor3 = Theme.text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, row)
		
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
		hoverScale(btn, 1.02)
		btn.MouseButton1Click:Connect(function()
			pressPunch(btn)
			if opts.Callback then opts.Callback(btn) end
		end)
		return btn
	end
	
	function api:Slider(opts)
		opts = opts or {}
		local minV, maxV = tonumber(opts.Min) or 0, tonumber(opts.Max) or 1
		local value = math.clamp(tonumber(opts.Default) or minV, minV, maxV)
		
		local row = mk("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
			LayoutOrder = nextOrder(),
		}, card)
		
		mk("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -48, 0, 16),
			Font = Enum.Font.GothamMedium,
			Text = tostring(opts.Text or "Slider"),
			TextColor3 = Theme.text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, row)
		
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
			Position = UDim2.fromOffset(0, 24),
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
		
		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local x, _ = pointer01(bar, input)
				apply(x, false)
				InputManager:StartDrag(function(dragInput)
					local nx, _ = pointer01(bar, dragInput)
					apply(nx, false)
				end)
			end
		end)
		return ctrl
	end
	
	-- Returns the section API
	return api
end

return Library
