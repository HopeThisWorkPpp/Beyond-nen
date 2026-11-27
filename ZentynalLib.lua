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
