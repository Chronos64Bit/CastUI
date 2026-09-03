--[[
	CastUI
	Modern Glass UI Library for Roblox Luau
	Developed by The Ventryx Company

	High Performance • Modern Acrylic Aesthetics • Zero Telemetry
--]]
return (function()
	local _modules = {}
	local _cache = {}

	local function require(modName: string)
		if _cache[modName] then
			return _cache[modName]
		end
		local fn = _modules[modName]
		if not fn then
			error("[CastUI] Module not found: " .. tostring(modName))
		end
		local result = fn(require)
		_cache[modName] = result
		return result
	end

	-- Module: Icons
	_modules["Icons"] = function(require)
		local Icons = {}
		
		local IconMap = {
			["home"] = "rbxassetid://10723407389",
			["settings"] = "rbxassetid://10734950309",
			["user"] = "rbxassetid://10747373176",
			["users"] = "rbxassetid://10747373426",
			["shield"] = "rbxassetid://10734951847",
			["sword"] = "rbxassetid://10734975692",
			["crosshair"] = "rbxassetid://10709769841",
			["eye"] = "rbxassetid://10723346959",
			["eye-off"] = "rbxassetid://10723347128",
			["terminal"] = "rbxassetid://10734982144",
			["code"] = "rbxassetid://10709810463",
			["cpu"] = "rbxassetid://10709772223",
			["zap"] = "rbxassetid://10709819149",
			["flame"] = "rbxassetid://10709782497",
			["sparkles"] = "rbxassetid://10734969248",
			["info"] = "rbxassetid://10723415903",
			["alert"] = "rbxassetid://10709752935",
			["bell"] = "rbxassetid://10709756041",
			["check"] = "rbxassetid://10709790644",
			["x"] = "rbxassetid://10709791437",
			["minus"] = "rbxassetid://10734896206",
			["minimize"] = "rbxassetid://10734896206",
			["maximize"] = "rbxassetid://10734895856",
			["chevron-down"] = "rbxassetid://10709790948",
			["chevron-up"] = "rbxassetid://10709791176",
			["chevron-right"] = "rbxassetid://10709791053",
			["search"] = "rbxassetid://10734943674",
			["copy"] = "rbxassetid://10709771143",
			["sliders"] = "rbxassetid://10734966600",
			["palette"] = "rbxassetid://10734919597",
			["lock"] = "rbxassetid://10723434791",
			["unlock"] = "rbxassetid://10723434938",
			["key"] = "rbxassetid://10723424505",
			["folder"] = "rbxassetid://10723387841",
			["file"] = "rbxassetid://10723374641",
			["download"] = "rbxassetid://10709767827",
			["upload"] = "rbxassetid://10734983377",
			["refresh"] = "rbxassetid://10734940376",
			["trash"] = "rbxassetid://10747362393",
			["globe"] = "rbxassetid://10723404337",
			["link"] = "rbxassetid://10723434557",
			["sun"] = "rbxassetid://10734974297",
			["moon"] = "rbxassetid://10734913867",
			["menu"] = "rbxassetid://10734898592",
			["mouse-pointer"] = "rbxassetid://10734915632",
		}
		
		function Icons.Get(name: string?): string
			if not name or name == "" then return "" end
			if string.find(name, "rbxassetid://") or string.find(name, "http") then
				return name
			end
			if tonumber(name) then
				return "rbxassetid://" .. name
			end
			local key = string.lower(string.gsub(name, "lucide%-", ""))
			return IconMap[key] or IconMap["sparkles"]
		end
		
		return Icons
	end

	-- Module: Init
	_modules["Init"] = function(require)
		--[[
			CastUI
			Modern Glass UI Library for Roblox Luau
			Developed by The Ventryx Company
		]]
		
		local Services = require("Services")
		local Theme = require("Theme")
		local Icons = require("Icons")
		local Config = require("Utilities.Config")
		local Creator = require("Utilities.Creator")
		local Window = require("Components.Window")
		local Notification = require("Components.Notification")
		local KeySystem = require("Components.KeySystem")
		
		local CastUI = {
			Version = "1.0.0",
			Author = "The Ventryx Company",
			Flags = Config.Flags
		}
		
		local ScreenGui = nil
		
		local function getRootGui(): ScreenGui
			if ScreenGui and ScreenGui.Parent then
				return ScreenGui
			end
		
			local targetParent = Services.GetGuiParent()
		
			ScreenGui = Creator.New("ScreenGui", {
				Name = "CastUI_Ventryx",
				ResetOnSpawn = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = 9999,
				Parent = targetParent
			})
		
			-- Protect GUI if supported by executor
			local protect = rawget(getfenv(), "protectgui") or rawget(getfenv(), "protect_gui")
			if protect and type(protect) == "function" then
				pcall(protect, ScreenGui)
			end
		
			Notification.Init(ScreenGui)
			return ScreenGui
		end
		
		-- Public API
		function CastUI.CreateWindow(config: {
			Title: string?,
			SubTitle: string?,
			Size: UDim2?,
			ToggleKey: Enum.KeyCode?,
			MobileButton: boolean?,
			OnClose: (() -> ())?
		})
			local gui = getRootGui()
			return Window.New(gui, config or {})
		end
		
		function CastUI.PromptKey(config: {
			Title: string?,
			Subtitle: string?,
			Key: string | { string },
			GetKeyLink: string?,
			SaveKey: boolean?,
			OnSuccess: () -> ()
		})
			local gui = getRootGui()
			KeySystem.Prompt(gui, config)
		end
		
		function CastUI.Notify(config: {
			Title: string,
			Content: string,
			Duration: number?,
			Icon: string?,
			Actions: { [string]: () -> () }?
		})
			getRootGui()
			Notification.Notify(config)
		end
		
		function CastUI.SetTheme(themeNameOrTable)
			Theme.SetTheme(themeNameOrTable)
		end
		
		function CastUI.SetAccent(accentColor: Color3)
			Theme.SetAccent(accentColor)
		end
		
		function CastUI.SaveConfig(name: string?)
			return Config.Save(name)
		end
		
		function CastUI.LoadConfig(name: string?)
			return Config.Load(name)
		end
		
		function CastUI.SetConfigFolder(folder: string)
			Config.SetFolder(folder)
		end
		
		return CastUI
	end

	-- Module: Services
	_modules["Services"] = function(require)
		local Services = {}
		
		local cloneref = rawget(getfenv(), "cloneref")
		local function getService(name: string)
			local service = game:GetService(name)
			return if (cloneref and type(cloneref) == "function") then cloneref(service) else service
		end
		
		Services.TweenService = getService("TweenService")
		Services.UserInputService = getService("UserInputService")
		Services.RunService = getService("RunService")
		Services.HttpService = getService("HttpService")
		Services.Players = getService("Players")
		Services.CoreGui = getService("CoreGui")
		Services.LocalPlayer = Services.Players.LocalPlayer
		
		function Services.GetGuiParent(): Instance
			local gethui = rawget(getfenv(), "gethui")
			if gethui and type(gethui) == "function" then
				local ok, res = pcall(gethui)
				if ok and res then return res end
			end
		
			local ok = pcall(function() return Services.CoreGui:GetChildren() end)
			if ok then return Services.CoreGui end
		
			if Services.LocalPlayer then
				local pgui = Services.LocalPlayer:FindFirstChild("PlayerGui")
				if pgui then return pgui end
			end
		
			return Services.CoreGui
		end
		
		return Services
	end

	-- Module: Theme
	_modules["Theme"] = function(require)
		local Theme = {}
		local listeners = {}
		
		Theme.Presets = {
			["Monochrome (Default)"] = {
				Background = Color3.fromRGB(10, 10, 11),
				BackgroundTransparency = 0.12,
				GlassPanel = Color3.fromRGB(20, 20, 22),
				GlassPanelTransparency = 0.35,
				GlassHover = Color3.fromRGB(32, 32, 35),
				GlassActive = Color3.fromRGB(45, 45, 49),
		
				Border = Color3.fromRGB(255, 255, 255),
				BorderTransparency = 0.88,
				BorderFocus = Color3.fromRGB(235, 235, 240),
				BorderFocusTransparency = 0.4,
		
				Accent = Color3.fromRGB(235, 235, 240),
				AccentGlow = Color3.fromRGB(200, 200, 208),
				AccentSecondary = Color3.fromRGB(140, 140, 148),
		
				TextPrimary = Color3.fromRGB(245, 245, 247),
				TextSecondary = Color3.fromRGB(150, 150, 158),
				TextMuted = Color3.fromRGB(95, 95, 102),
		
				Success = Color3.fromRGB(110, 200, 150),
				Danger = Color3.fromRGB(220, 100, 100),
				Warning = Color3.fromRGB(210, 180, 120),
		
				CornerRadius = 8,
				FontRegular = Enum.Font.Gotham,
				FontMedium = Enum.Font.GothamMedium,
				FontBold = Enum.Font.GothamBold,
			},
		
			["Midnight Violet"] = {
				Background = Color3.fromRGB(14, 12, 24),
				BackgroundTransparency = 0.12,
				GlassPanel = Color3.fromRGB(22, 18, 38),
				GlassPanelTransparency = 0.35,
				GlassHover = Color3.fromRGB(36, 30, 60),
				GlassActive = Color3.fromRGB(48, 40, 80),
				Border = Color3.fromRGB(255, 255, 255),
				BorderTransparency = 0.88,
				BorderFocus = Color3.fromRGB(168, 85, 247),
				BorderFocusTransparency = 0.4,
				Accent = Color3.fromRGB(168, 85, 247),
				AccentGlow = Color3.fromRGB(139, 92, 246),
				AccentSecondary = Color3.fromRGB(236, 72, 153),
				TextPrimary = Color3.fromRGB(248, 247, 252),
				TextSecondary = Color3.fromRGB(160, 155, 180),
				TextMuted = Color3.fromRGB(105, 100, 125),
				Success = Color3.fromRGB(52, 211, 153),
				Danger = Color3.fromRGB(244, 63, 94),
				Warning = Color3.fromRGB(251, 191, 36),
				CornerRadius = 10,
				FontRegular = Enum.Font.Gotham,
				FontMedium = Enum.Font.GothamMedium,
				FontBold = Enum.Font.GothamBold,
			},
		
			["Emerald Frost"] = {
				Background = Color3.fromRGB(10, 18, 16),
				BackgroundTransparency = 0.12,
				GlassPanel = Color3.fromRGB(16, 28, 25),
				GlassPanelTransparency = 0.35,
				GlassHover = Color3.fromRGB(24, 42, 38),
				GlassActive = Color3.fromRGB(32, 56, 50),
				Border = Color3.fromRGB(255, 255, 255),
				BorderTransparency = 0.88,
				BorderFocus = Color3.fromRGB(16, 185, 129),
				BorderFocusTransparency = 0.4,
				Accent = Color3.fromRGB(16, 185, 129),
				AccentGlow = Color3.fromRGB(5, 150, 105),
				AccentSecondary = Color3.fromRGB(45, 212, 191),
				TextPrimary = Color3.fromRGB(242, 250, 246),
				TextSecondary = Color3.fromRGB(145, 170, 160),
				TextMuted = Color3.fromRGB(90, 115, 105),
				Success = Color3.fromRGB(16, 185, 129),
				Danger = Color3.fromRGB(244, 63, 94),
				Warning = Color3.fromRGB(245, 158, 11),
				CornerRadius = 10,
				FontRegular = Enum.Font.Gotham,
				FontMedium = Enum.Font.GothamMedium,
				FontBold = Enum.Font.GothamBold,
			}
		}
		
		Theme.Current = {}
		
		local function applyTheme(src)
			for k, v in pairs(src) do
				Theme.Current[k] = v
			end
		end
		
		applyTheme(Theme.Presets["Monochrome (Default)"])
		
		function Theme.SetTheme(theme)
			local target = if type(theme) == "string" then Theme.Presets[theme] else theme
			if not target then return end
			applyTheme(target)
			for _, fn in ipairs(listeners) do
				task.spawn(fn, Theme.Current)
			end
		end
		
		function Theme.SetAccent(color: Color3)
			Theme.Current.Accent = color
			for _, fn in ipairs(listeners) do
				task.spawn(fn, Theme.Current)
			end
		end
		
		function Theme.OnThemeChanged(fn: (typeof(Theme.Current)) -> ())
			table.insert(listeners, fn)
			return function()
				local idx = table.find(listeners, fn)
				if idx then table.remove(listeners, idx) end
			end
		end
		
		return Theme
	end

	-- Module: Components.KeySystem
	_modules["Components.KeySystem"] = function(require)
		--[[
			CastUI • Key System Modal
			The Ventryx Company
			Modern frosted glass key authentication interface
		]]
		
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Drag = require("Utilities.Drag")
		
		local KeySystem = {}
		
		function KeySystem.Prompt(parentGui: Instance, config: {
			Title: string?,
			Subtitle: string?,
			Key: string | { string },
			GetKeyLink: string?,
			SaveKey: boolean?,
			OnSuccess: () -> ()
		})
			local currentTheme = Theme.Current
			local validKeys = type(config.Key) == "table" and config.Key or { config.Key }
		
			local savePath = "CastUI_Key.txt"
			local hasFileSystem = rawget(getfenv(), "writefile") ~= nil and rawget(getfenv(), "readfile") ~= nil
		
			-- Check auto-saved key
			if config.SaveKey and hasFileSystem and rawget(getfenv(), "isfile") and isfile(savePath) then
				local saved = readfile(savePath)
				for _, key in ipairs(validKeys) do
					if saved == key then
						task.spawn(config.OnSuccess)
						return
					end
				end
			end
		
			-- Backdrop Glass Blur Overlay
			local overlay = Creator.New("Frame", {
				Name = "KeyOverlay",
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.5,
				Size = UDim2.new(1, 0, 1, 0),
				Parent = parentGui
			})
		
			local modal = Creator.New("Frame", {
				Name = "KeyModal",
				BackgroundColor3 = currentTheme.Background,
				BackgroundTransparency = 0.12,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, -170, 0.5, -110),
				Size = UDim2.new(0, 340, 0, 220),
				ClipsDescendants = true,
				Parent = overlay
			})
		
			Creator.Round(modal, 12)
			local stroke = Creator.Stroke(modal, currentTheme.Border, currentTheme.BorderTransparency, 1)
			Creator.Padding(modal, 16, 16, 18, 18)
		
			Drag.MakeDraggable(modal)
		
			-- Branding Header
			local brandLabel = Creator.New("TextLabel", {
				Name = "Brand",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 14),
				Font = currentTheme.FontBold,
				Text = "CASTUI • THE VENTRYX COMPANY",
				TextColor3 = currentTheme.Accent,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = modal
			})
		
			local titleLabel = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 18),
				Size = UDim2.new(1, 0, 0, 24),
				Font = currentTheme.FontBold,
				Text = config.Title or "Key Verification",
				TextColor3 = currentTheme.TextPrimary,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = modal
			})
		
			local subLabel = Creator.New("TextLabel", {
				Name = "Subtitle",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 44),
				Size = UDim2.new(1, 0, 0, 20),
				Font = currentTheme.FontRegular,
				Text = config.Subtitle or "Enter your access key to continue",
				TextColor3 = currentTheme.TextSecondary,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = modal
			})
		
			-- Key Input
			local keyBox = Creator.New("TextBox", {
				Name = "KeyInput",
				BackgroundColor3 = currentTheme.GlassPanel,
				BackgroundTransparency = 0.3,
				Position = UDim2.new(0, 0, 0, 76),
				Size = UDim2.new(1, 0, 0, 38),
				Font = currentTheme.FontRegular,
				PlaceholderText = "Paste key here...",
				PlaceholderColor3 = currentTheme.TextMuted,
				Text = "",
				TextColor3 = currentTheme.TextPrimary,
				TextSize = 13,
				ClearTextOnFocus = false,
				Parent = modal
			})
			Creator.Round(keyBox, 8)
			local boxStroke = Creator.Stroke(keyBox, currentTheme.Border, 0.8, 1)
		
			local errorLabel = Creator.New("TextLabel", {
				Name = "ErrorMsg",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 118),
				Size = UDim2.new(1, 0, 0, 16),
				Font = currentTheme.FontRegular,
				Text = "",
				TextColor3 = currentTheme.Danger,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = modal
			})
		
			-- Buttons
			local btnContainer = Creator.New("Frame", {
				Name = "Buttons",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 1, -40),
				Size = UDim2.new(1, 0, 0, 36),
				Parent = modal
			})
		
			local verifyBtn = Creator.New("TextButton", {
				Name = "Verify",
				BackgroundColor3 = currentTheme.Accent,
				BorderSizePixel = 0,
				Position = config.GetKeyLink and UDim2.new(0.5, 6, 0, 0) or UDim2.new(0, 0, 0, 0),
				Size = config.GetKeyLink and UDim2.new(0.5, -6, 1, 0) or UDim2.new(1, 0, 1, 0),
				Font = currentTheme.FontBold,
				Text = "Verify Key",
				TextColor3 = Color3.fromRGB(15, 20, 30),
				TextSize = 13,
				AutoButtonColor = false,
				Parent = btnContainer
			})
			Creator.Round(verifyBtn, 8)
		
			if config.GetKeyLink then
				local getBtn = Creator.New("TextButton", {
					Name = "GetKey",
					BackgroundColor3 = currentTheme.GlassPanel,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(0.5, -6, 1, 0),
					Font = currentTheme.FontMedium,
					Text = "Get Key",
					TextColor3 = currentTheme.TextPrimary,
					TextSize = 13,
					AutoButtonColor = false,
					Parent = btnContainer
				})
				Creator.Round(getBtn, 8)
				Creator.Stroke(getBtn, currentTheme.Border, 0.8, 1)
		
				getBtn.MouseButton1Click:Connect(function()
					local setclip = rawget(getfenv(), "setclipboard") or rawget(getfenv(), "toclipboard")
					if setclip then
						setclip(config.GetKeyLink)
						errorLabel.TextColor3 = Theme.Current.Success
						errorLabel.Text = "Key link copied to clipboard!"
					end
				end)
			end
		
			verifyBtn.MouseButton1Click:Connect(function()
				local entered = keyBox.Text
				local isValid = false
				for _, k in ipairs(validKeys) do
					if entered == k then
						isValid = true
						break
					end
				end
		
				if isValid then
					if config.SaveKey and hasFileSystem then
						pcall(writefile, savePath, entered)
					end
					Tween.Play(modal, "Fast", { Size = UDim2.new(0, 340, 0, 0), BackgroundTransparency = 1 })
					Tween.Play(overlay, "Fast", { BackgroundTransparency = 1 })
					task.wait(0.2)
					overlay:Destroy()
					task.spawn(config.OnSuccess)
				else
					errorLabel.TextColor3 = Theme.Current.Danger
					errorLabel.Text = "Invalid key. Please check and retry."
					Tween.Play(boxStroke, "Fast", { Color = Theme.Current.Danger })
				end
			end)
		end
		
		return KeySystem
	end

	-- Module: Components.Notification
	_modules["Components.Notification"] = function(require)
		--[[
			CastUI • Notification Engine
			The Ventryx Company
			Modern frosted glass toast notifications with timer bar & actions
		]]
		
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Icons = require("Icons")
		
		local Notification = {}
		local notifContainer = nil
		
		function Notification.Init(parentGui: Instance)
			if notifContainer then return end
		
			notifContainer = Creator.New("Frame", {
				Name = "NotificationContainer",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -320, 1, -20),
				AnchorPoint = Vector2.new(0, 1),
				Size = UDim2.new(0, 300, 1, -40),
				Parent = parentGui
			})
		
			local layout = Creator.New("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 8),
				Parent = notifContainer
			})
		end
		
		function Notification.Notify(config: {
			Title: string,
			Content: string,
			Duration: number?,
			Icon: string?,
			Actions: { [string]: () -> () }?
		})
			if not notifContainer then return end
		
			local currentTheme = Theme.Current
			local duration = config.Duration or 4
			local hasActions = config.Actions and next(config.Actions) ~= nil
		
			local toast = Creator.New("Frame", {
				Name = "Toast",
				BackgroundColor3 = currentTheme.Background,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Position = UDim2.new(1, 40, 0, 0), -- Slide-in start
				Size = UDim2.new(1, 0, 0, hasActions and 95 or 65),
				Parent = notifContainer
			})
		
			Creator.Round(toast, 8)
			local stroke = Creator.Stroke(toast, currentTheme.Border, currentTheme.BorderTransparency, 1)
		
			local iconOffset = 12
			if config.Icon and config.Icon ~= "" then
				iconOffset = 34
				local iconImg = Creator.New("ImageLabel", {
					Name = "Icon",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(0, 18, 0, 18),
					Image = Icons.Get(config.Icon),
					ImageColor3 = currentTheme.Accent,
					Parent = toast
				})
			end
		
			local titleLabel = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, iconOffset, 0, 8),
				Size = UDim2.new(1, -iconOffset - 30, 0, 18),
				Font = currentTheme.FontMedium,
				Text = config.Title or "Notification",
				TextColor3 = currentTheme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = toast
			})
		
			local contentLabel = Creator.New("TextLabel", {
				Name = "Content",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, iconOffset, 0, 26),
				Size = UDim2.new(1, -iconOffset - 12, 0, 28),
				Font = currentTheme.FontRegular,
				Text = config.Content or "",
				TextColor3 = currentTheme.TextSecondary,
				TextSize = 11,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Parent = toast
			})
		
			-- Close Button (X)
			local closeBtn = Creator.New("ImageButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -22, 0, 10),
				Size = UDim2.new(0, 14, 0, 14),
				Image = Icons.Get("x"),
				ImageColor3 = currentTheme.TextMuted,
				Parent = toast
			})
		
			-- Progress Bar
			local progressBar = Creator.New("Frame", {
				Name = "ProgressBar",
				BackgroundColor3 = currentTheme.Accent,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -2),
				Size = UDim2.new(1, 0, 0, 2),
				Parent = toast
			})
		
			local function dismiss()
				Tween.Play(toast, "Fast", { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 })
				task.wait(0.2)
				toast:Destroy()
			end
		
			closeBtn.MouseButton1Click:Connect(dismiss)
		
			-- Action Buttons (if provided)
			if hasActions then
				local actionHolder = Creator.New("Frame", {
					Name = "ActionHolder",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 60),
					Size = UDim2.new(1, -24, 0, 24),
					Parent = toast
				})
		
				local btnLayout = Creator.New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 8),
					Parent = actionHolder
				})
		
				for actName, actFunc in pairs(config.Actions) do
					local actBtn = Creator.New("TextButton", {
						Name = "Act_" .. actName,
						BackgroundColor3 = currentTheme.GlassHover,
						BorderSizePixel = 0,
						Size = UDim2.new(0, 70, 0, 22),
						Font = currentTheme.FontMedium,
						Text = actName,
						TextColor3 = currentTheme.Accent,
						TextSize = 11,
						AutoButtonColor = false,
						Parent = actionHolder
					})
					Creator.Round(actBtn, 4)
					Creator.Stroke(actBtn, currentTheme.Border, 0.8, 1)
		
					actBtn.MouseButton1Click:Connect(function()
						task.spawn(actFunc)
						dismiss()
					end)
				end
			end
		
			-- Slide-in
			Tween.Play(toast, "Smooth", { Position = UDim2.new(0, 0, 0, 0) })
			Tween.Play(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
		
			task.delay(duration, function()
				if toast and toast.Parent then
					dismiss()
				end
			end)
		end
		
		return Notification
	end

	-- Module: Components.Tab
	_modules["Components.Tab"] = function(require)
		--[[
			CastUI • Tab Component
			The Ventryx Company
			Tab navigation button and scrollable element container
		]]
		
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Icons = require("Icons")
		
		-- Elements
		local Button = require("Elements.Button")
		local Toggle = require("Elements.Toggle")
		local Slider = require("Elements.Slider")
		local Dropdown = require("Elements.Dropdown")
		local Input = require("Elements.Input")
		local Keybind = require("Elements.Keybind")
		local Colorpicker = require("Elements.Colorpicker")
		local Section = require("Elements.Section")
		local Paragraph = require("Elements.Paragraph")
		
		local Tab = {}
		
		function Tab.New(sidebarParent: Instance, contentParent: Instance, config: {
			Title: string,
			Icon: string?,
			SelectedCallback: (() -> ())?
		})
			local currentTheme = Theme.Current
			local isSelected = false
		
			-- Sidebar Tab Button
			local tabBtn = Creator.New("TextButton", {
				Name = "Tab_" .. (config.Title or "Tab"),
				BackgroundColor3 = currentTheme.GlassPanel,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 36),
				Text = "",
				AutoButtonColor = false,
				Parent = sidebarParent
			})
		
			Creator.Round(tabBtn, 8)
			Creator.Padding(tabBtn, 0, 0, 10, 10)
		
			-- Active Left Indicator Pill
			local indicator = Creator.New("Frame", {
				Name = "ActiveIndicator",
				BackgroundColor3 = currentTheme.Accent,
				BorderSizePixel = 0,
				Position = UDim2.new(0, -6, 0.5, -8),
				Size = UDim2.new(0, 3, 0, 16),
				Visible = false,
				Parent = tabBtn
			})
			Creator.Round(indicator, 2)
		
			local iconOffset = 0
			local tabIcon = nil
		
			if config.Icon and config.Icon ~= "" then
				iconOffset = 24
				tabIcon = Creator.New("ImageLabel", {
					Name = "Icon",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, -8),
					Size = UDim2.new(0, 16, 0, 16),
					Image = Icons.Get(config.Icon),
					ImageColor3 = currentTheme.TextSecondary,
					Parent = tabBtn
				})
			end
		
			local tabLabel = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, iconOffset, 0.5, -9),
				Size = UDim2.new(1, -iconOffset, 0, 18),
				Font = currentTheme.FontMedium,
				Text = config.Title or "Tab",
				TextColor3 = currentTheme.TextSecondary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = tabBtn
			})
		
			-- Tab Elements Container
			local contentScroll = Creator.New("ScrollingFrame", {
				Name = "Content_" .. (config.Title or "Tab"),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = currentTheme.Accent,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
				Visible = false,
				Parent = contentParent
			})
		
			local contentLayout = Creator.New("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				Parent = contentScroll
			})
		
			Creator.Padding(contentScroll, 4, 12, 4, 8)
		
			local function setSelected(state: boolean)
				isSelected = state
				contentScroll.Visible = state
				indicator.Visible = state
		
				local t = Theme.Current
				if state then
					Tween.Play(tabBtn, "Fast", { BackgroundColor3 = t.GlassPanel, BackgroundTransparency = t.GlassPanelTransparency })
					Tween.Play(tabLabel, "Fast", { TextColor3 = t.TextPrimary })
					if tabIcon then Tween.Play(tabIcon, "Fast", { ImageColor3 = t.Accent }) end
					if config.SelectedCallback then
						config.SelectedCallback()
					end
				else
					Tween.Play(tabBtn, "Fast", { BackgroundTransparency = 1 })
					Tween.Play(tabLabel, "Fast", { TextColor3 = t.TextSecondary })
					if tabIcon then Tween.Play(tabIcon, "Fast", { ImageColor3 = t.TextSecondary }) end
				end
			end
		
			tabBtn.MouseEnter:Connect(function()
				if not isSelected then
					Tween.Play(tabBtn, "Fast", { BackgroundColor3 = Theme.Current.GlassHover, BackgroundTransparency = 0.5 })
					Tween.Play(tabLabel, "Fast", { TextColor3 = Theme.Current.TextPrimary })
				end
			end)
		
			tabBtn.MouseLeave:Connect(function()
				if not isSelected then
					Tween.Play(tabBtn, "Fast", { BackgroundTransparency = 1 })
					Tween.Play(tabLabel, "Fast", { TextColor3 = Theme.Current.TextSecondary })
				end
			end)
		
			local tabObj = {
				Button = tabBtn,
				Container = contentScroll,
				SetSelected = setSelected
			}
		
			tabBtn.MouseButton1Click:Connect(function()
				setSelected(true)
			end)
		
			-- Element Creators
			function tabObj:AddButton(cfg)
				return Button.New(contentScroll, cfg)
			end
		
			function tabObj:AddToggle(cfg)
				return Toggle.New(contentScroll, cfg)
			end
		
			function tabObj:AddSlider(cfg)
				return Slider.New(contentScroll, cfg)
			end
		
			function tabObj:AddDropdown(cfg)
				return Dropdown.New(contentScroll, cfg)
			end
		
			function tabObj:AddInput(cfg)
				return Input.New(contentScroll, cfg)
			end
		
			function tabObj:AddKeybind(cfg)
				return Keybind.New(contentScroll, cfg)
			end
		
			function tabObj:AddColorpicker(cfg)
				return Colorpicker.New(contentScroll, cfg)
			end
		
			function tabObj:AddSection(cfg)
				return Section.New(contentScroll, cfg)
			end
		
			function tabObj:AddParagraph(cfg)
				return Paragraph.New(contentScroll, cfg)
			end
		
			Theme.OnThemeChanged(function(t)
				indicator.BackgroundColor3 = t.Accent
				contentScroll.ScrollBarImageColor3 = t.Accent
				if isSelected then
					tabBtn.BackgroundColor3 = t.GlassPanel
					tabBtn.BackgroundTransparency = t.GlassPanelTransparency
					tabLabel.TextColor3 = t.TextPrimary
					if tabIcon then tabIcon.ImageColor3 = t.Accent end
				else
					tabLabel.TextColor3 = t.TextSecondary
					if tabIcon then tabIcon.ImageColor3 = t.TextSecondary end
				end
			end)
		
			return tabObj
		end
		
		return Tab
	end

	-- Module: Components.Window
	_modules["Components.Window"] = function(require)
		--[[
			CastUI • Window Component
			The Ventryx Company
			Main modern frosted glass window with header, sidebar, and controls
		]]
		
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Icons = require("Icons")
		local Drag = require("Utilities.Drag")
		local Services = require("Services")
		local Tab = require("Components.Tab")
		local Notification = require("Components.Notification")
		
		local Window = {}
		
		function Window.New(parentGui: Instance, config: {
			Title: string?,
			SubTitle: string?,
			Size: UDim2?,
			ToggleKey: Enum.KeyCode?,
			MobileButton: boolean?,
			OnClose: (() -> ())?
		})
			local currentTheme = Theme.Current
			local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
			local isVisible = true
			local isMinimized = false
		
			local winSize = config.Size or UDim2.new(0, 620, 0, 420)
			local tabs = {}
			local activeTab = nil
		
			-- Main Window Canvas Frame
			local mainFrame = Creator.New("Frame", {
				Name = "CastUI_Window",
				BackgroundColor3 = currentTheme.Background,
				BackgroundTransparency = currentTheme.BackgroundTransparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2),
				Size = winSize,
				ClipsDescendants = true,
				Parent = parentGui
			})
		
			Creator.Round(mainFrame, 12)
			local windowStroke = Creator.Stroke(mainFrame, currentTheme.Border, currentTheme.BorderTransparency, 1)
		
			-- Ambient Glow Behind Glass
			local ambientGlow = Creator.New("ImageLabel", {
				Name = "AmbientGlow",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, -20, 0, -20),
				Size = UDim2.new(1, 40, 1, 40),
				Image = "rbxassetid://5028857084",
				ImageColor3 = currentTheme.Accent,
				ImageTransparency = 0.85,
				ZIndex = 0,
				Parent = mainFrame
			})
		
			-- Top Header Bar (Draggable)
			local topBar = Creator.New("Frame", {
				Name = "TopBar",
				BackgroundColor3 = currentTheme.GlassPanel,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 46),
				Parent = mainFrame
			})
			Creator.Round(topBar, 12)
		
			Drag.MakeDraggable(topBar, mainFrame)
		
			-- Brand & Titles
			local brandTag = Creator.New("TextLabel", {
				Name = "BrandTag",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 16, 0, 8),
				Size = UDim2.new(0, 300, 0, 12),
				Font = currentTheme.FontBold,
				Text = "CASTUI • THE VENTRYX COMPANY",
				TextColor3 = currentTheme.Accent,
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = topBar
			})
		
			local titleLabel = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 16, 0, 20),
				Size = UDim2.new(0, 300, 0, 20),
				Font = currentTheme.FontBold,
				Text = config.Title or "CastUI Suite",
				TextColor3 = currentTheme.TextPrimary,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = topBar
			})
		
			if config.SubTitle and config.SubTitle ~= "" then
				local subLabel = Creator.New("TextLabel", {
					Name = "Subtitle",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 20 + titleLabel.TextBounds.X, 0, 22),
					Size = UDim2.new(0, 200, 0, 18),
					Font = currentTheme.FontRegular,
					Text = "|  " .. config.SubTitle,
					TextColor3 = currentTheme.TextMuted,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = topBar
				})
			end
		
			-- Window Control Buttons (Minimize / Close)
			local controlsHolder = Creator.New("Frame", {
				Name = "Controls",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -74, 0, 11),
				Size = UDim2.new(0, 60, 0, 24),
				Parent = topBar
			})
		
			local minimizeBtn = Creator.New("ImageButton", {
				Name = "Minimize",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 4, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = Icons.Get("minus") or Icons.Get("chevron-down"),
				ImageColor3 = currentTheme.TextSecondary,
				Parent = controlsHolder
			})
		
			local closeBtn = Creator.New("ImageButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -20, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = Icons.Get("x"),
				ImageColor3 = currentTheme.TextSecondary,
				Parent = controlsHolder
			})
		
			-- Body Area
			local bodyFrame = Creator.New("Frame", {
				Name = "Body",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 46),
				Size = UDim2.new(1, 0, 1, -46),
				Parent = mainFrame
			})
		
			-- Sidebar Navigation
			local sidebar = Creator.New("Frame", {
				Name = "Sidebar",
				BackgroundColor3 = currentTheme.GlassPanel,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 12, 0, 10),
				Size = UDim2.new(0, 160, 1, -22),
				Parent = bodyFrame
			})
			Creator.Round(sidebar, 8)
			local sidebarStroke = Creator.Stroke(sidebar, currentTheme.Border, 0.9, 1)
		
			local sidebarScroll = Creator.New("ScrollingFrame", {
				Name = "TabsList",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = currentTheme.Accent,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
				Parent = sidebar
			})
			Creator.Padding(sidebarScroll, 8, 8, 8, 8)
		
			local tabListLayout = Creator.New("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
				Parent = sidebarScroll
			})
		
			-- Main Content Viewport
			local contentArea = Creator.New("Frame", {
				Name = "ContentArea",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 184, 0, 10),
				Size = UDim2.new(1, -196, 1, -22),
				ClipsDescendants = true,
				Parent = bodyFrame
			})
		
			-- Toggle Visibility Logic
			local function setVisibility(state: boolean)
				isVisible = state
				if isVisible then
					mainFrame.Visible = true
					Tween.Play(mainFrame, "Fast", {
						Size = isMinimized and UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 46) or winSize,
						BackgroundTransparency = currentTheme.BackgroundTransparency
					})
				else
					Tween.Play(mainFrame, "Fast", {
						Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 0),
						BackgroundTransparency = 1
					})
					task.delay(0.18, function()
						if not isVisible then
							mainFrame.Visible = false
						end
					end)
				end
			end
		
			local function toggleMinimize()
				isMinimized = not isMinimized
				if isMinimized then
					bodyFrame.Visible = false
					Tween.Play(mainFrame, "Fast", { Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 46) })
				else
					Tween.Play(mainFrame, "Fast", { Size = winSize })
					task.delay(0.15, function()
						if not isMinimized then
							bodyFrame.Visible = true
						end
					end)
				end
			end
		
			minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
		
			closeBtn.MouseButton1Click:Connect(function()
				setVisibility(false)
				if config.OnClose then
					task.spawn(config.OnClose)
				end
			end)
		
			Services.UserInputService.InputBegan:Connect(function(input, gpe)
				if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
					setVisibility(not isVisible)
				end
			end)
		
			-- Mobile Floating Button (if enabled or mobile touch detected)
			if config.MobileButton or Services.UserInputService.TouchEnabled then
				local mobileToggle = Creator.New("ImageButton", {
					Name = "CastUI_MobileToggle",
					BackgroundColor3 = currentTheme.Background,
					BackgroundTransparency = 0.2,
					Position = UDim2.new(0, 20, 0, 80),
					Size = UDim2.new(0, 44, 0, 44),
					Image = Icons.Get("flame") or Icons.Get("menu"),
					ImageColor3 = currentTheme.Accent,
					Parent = parentGui
				})
				Creator.Round(mobileToggle, 22)
				Creator.Stroke(mobileToggle, currentTheme.Border, 0.8, 1)
				Drag.MakeDraggable(mobileToggle)
		
				mobileToggle.MouseButton1Click:Connect(function()
					setVisibility(not isVisible)
				end)
			end
		
			local windowObj = {
				Instance = mainFrame,
				SetVisible = setVisibility,
				Toggle = function() setVisibility(not isVisible) end
			}
		
			function windowObj:CreateTab(tabConfig: { Title: string, Icon: string? })
				local newTab = Tab.New(sidebarScroll, contentArea, {
					Title = tabConfig.Title,
					Icon = tabConfig.Icon,
					SelectedCallback = function()
						for _, t in ipairs(tabs) do
							if t ~= newTab then
								t.SetSelected(false)
							end
						end
					end
				})
		
				table.insert(tabs, newTab)
		
				-- Auto-select first tab
				if #tabs == 1 then
					newTab.SetSelected(true)
					activeTab = newTab
				end
		
				return newTab
			end
		
			function windowObj:Notify(notifConfig)
				Notification.Notify(notifConfig)
			end
		
			function windowObj:Destroy()
				mainFrame:Destroy()
			end
		
			Theme.OnThemeChanged(function(t)
				mainFrame.BackgroundColor3 = t.Background
				mainFrame.BackgroundTransparency = t.BackgroundTransparency
				windowStroke.Color = t.Border
				windowStroke.Transparency = t.BorderTransparency
				ambientGlow.ImageColor3 = t.Accent
				topBar.BackgroundColor3 = t.GlassPanel
				brandTag.TextColor3 = t.Accent
				titleLabel.TextColor3 = t.TextPrimary
				sidebar.BackgroundColor3 = t.GlassPanel
				sidebarScroll.ScrollBarImageColor3 = t.Accent
			end)
		
			return windowObj
		end
		
		return Window
	end

	-- Module: Elements.Button
	_modules["Elements.Button"] = function(require)
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Icons = require("Icons")
		
		local Button = {}
		
		function Button.New(parent: Instance, cfg: {
			Title: string,
			Description: string?,
			Icon: string?,
			Callback: (() -> ())?
		})
			local theme = Theme.Current
			local callback = cfg.Callback or function() end
			local hasDesc = cfg.Description and cfg.Description ~= ""
		
			local btn = Creator.New("TextButton", {
				Name = "Button_" .. (cfg.Title or "Action"),
				BackgroundColor3 = theme.GlassPanel,
				BackgroundTransparency = theme.GlassPanelTransparency,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, hasDesc and 48 or 38),
				Text = "",
				AutoButtonColor = false,
				ClipsDescendants = true,
				Parent = parent
			})
		
			Creator.Round(btn, 8)
			local stroke = Creator.Stroke(btn, theme.Border, theme.BorderTransparency, 1)
			Creator.Padding(btn, 0, 0, 12, 12)
		
			local iconOffset = 0
			local icon = nil
			if cfg.Icon and cfg.Icon ~= "" then
				iconOffset = 24
				icon = Creator.New("ImageLabel", {
					Name = "Icon",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					Image = Icons.Get(cfg.Icon),
					ImageColor3 = theme.TextSecondary,
					Parent = btn
				})
			end
		
			local title = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = hasDesc and UDim2.new(0, iconOffset, 0, 8) or UDim2.new(0, iconOffset, 0.5, -9),
				Size = UDim2.new(1, -iconOffset - 30, 0, 18),
				Font = theme.FontMedium,
				Text = cfg.Title or "Button",
				TextColor3 = theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = btn
			})
		
			local desc = nil
			if hasDesc then
				desc = Creator.New("TextLabel", {
					Name = "Description",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, iconOffset, 0, 26),
					Size = UDim2.new(1, -iconOffset - 30, 0, 14),
					Font = theme.FontRegular,
					Text = cfg.Description,
					TextColor3 = theme.TextSecondary,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = btn
				})
			end
		
			local arrow = Creator.New("ImageLabel", {
				Name = "Arrow",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -16, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = Icons.Get("chevron-right"),
				ImageColor3 = theme.TextMuted,
				Parent = btn
			})
		
			btn.MouseEnter:Connect(function()
				Tween.Play(btn, "Fast", { BackgroundColor3 = Theme.Current.GlassHover, BackgroundTransparency = 0.25 })
				Tween.Play(stroke, "Fast", { Color = Theme.Current.BorderFocus, Transparency = Theme.Current.BorderFocusTransparency })
				Tween.Play(arrow, "Fast", { ImageColor3 = Theme.Current.Accent, Position = UDim2.new(1, -14, 0.5, -8) })
				if icon then Tween.Play(icon, "Fast", { ImageColor3 = Theme.Current.Accent }) end
			end)
		
			btn.MouseLeave:Connect(function()
				Tween.Play(btn, "Fast", { BackgroundColor3 = Theme.Current.GlassPanel, BackgroundTransparency = Theme.Current.GlassPanelTransparency })
				Tween.Play(stroke, "Fast", { Color = Theme.Current.Border, Transparency = Theme.Current.BorderTransparency })
				Tween.Play(arrow, "Fast", { ImageColor3 = Theme.Current.TextMuted, Position = UDim2.new(1, -16, 0.5, -8) })
				if icon then Tween.Play(icon, "Fast", { ImageColor3 = Theme.Current.TextSecondary }) end
			end)
		
			btn.MouseButton1Down:Connect(function()
				Tween.Play(btn, "Fast", { BackgroundColor3 = Theme.Current.GlassActive })
			end)
		
			btn.MouseButton1Up:Connect(function()
				Tween.Play(btn, "Fast", { BackgroundColor3 = Theme.Current.GlassHover })
			end)
		
			btn.MouseButton1Click:Connect(function()
				task.spawn(callback)
			end)
		
			Theme.OnThemeChanged(function(t)
				btn.BackgroundColor3 = t.GlassPanel
				btn.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				title.TextColor3 = t.TextPrimary
				if desc then desc.TextColor3 = t.TextSecondary end
			end)
		
			return {
				Instance = btn,
				SetTitle = function(_, text: string) title.Text = text end,
				SetDescription = function(_, text: string) if desc then desc.Text = text end end,
				SetCallback = function(_, fn: () -> ()) callback = fn end
			}
		end
		
		return Button
	end

	-- Module: Elements.Colorpicker
	_modules["Elements.Colorpicker"] = function(require)
		--[[
			CastUI • Colorpicker Element
			The Ventryx Company
			Real-time interactive HSV glass colorpicker with hex/RGB inputs
		]]
		
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Services = require("Services")
		local UserInputService = Services.UserInputService
		local Config = require("Utilities.Config")
		
		local Colorpicker = {}
		
		function Colorpicker.New(parent: Instance, config: {
			Title: string,
			Default: Color3?,
			Flag: string?,
			Callback: ((Color3) -> ())?
		})
			local currentTheme = Theme.Current
			local currentColor = config.Default or Color3.fromRGB(0, 209, 255)
			local callback = config.Callback or function() end
			local isOpen = false
		
			local h, s, v = currentColor:ToHSV()
		
			if config.Flag then
				Config.SetFlag(config.Flag, currentColor)
			end
		
			local container = Creator.New("Frame", {
				Name = "Colorpicker_" .. (config.Title or "Color"),
				BackgroundColor3 = currentTheme.GlassPanel,
				BackgroundTransparency = currentTheme.GlassPanelTransparency,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = parent
			})
		
			Creator.Round(container, 8)
			local stroke = Creator.Stroke(container, currentTheme.Border, currentTheme.BorderTransparency, 1)
		
			local header = Creator.New("TextButton", {
				Name = "Header",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 42),
				Text = "",
				AutoButtonColor = false,
				Parent = container
			})
			Creator.Padding(header, 0, 0, 12, 12)
		
			local titleLabel = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, -9),
				Size = UDim2.new(1, -70, 0, 18),
				Font = currentTheme.FontMedium,
				Text = config.Title or "Colorpicker",
				TextColor3 = currentTheme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = header
			})
		
			-- Color Chip Preview
			local colorChip = Creator.New("Frame", {
				Name = "ColorChip",
				BackgroundColor3 = currentColor,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -44, 0.5, -10),
				Size = UDim2.new(0, 44, 0, 20),
				Parent = header
			})
			Creator.Round(colorChip, 5)
			local chipStroke = Creator.Stroke(colorChip, Color3.fromRGB(255, 255, 255), 0.7, 1)
		
			-- Expanded Canvas & Controls
			local pickerBody = Creator.New("Frame", {
				Name = "PickerBody",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 44),
				Size = UDim2.new(1, -24, 0, 140),
				Parent = container
			})
		
			-- Saturation/Value Canvas
			local satValCanvas = Creator.New("ImageButton", {
				Name = "SatValCanvas",
				BackgroundColor3 = Color3.fromHSV(h, 1, 1),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, -26, 0, 100),
				Image = "rbxassetid://4155801252", -- Saturation/Value gradient overlay
				AutoButtonColor = false,
				Parent = pickerBody
			})
			Creator.Round(satValCanvas, 6)
		
			local satValCursor = Creator.New("Frame", {
				Name = "Cursor",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(s, -5, 1 - v, -5),
				Size = UDim2.new(0, 10, 0, 10),
				Parent = satValCanvas
			})
			Creator.Round(satValCursor, 5)
			Creator.Stroke(satValCursor, Color3.fromRGB(0, 0, 0), 0.3, 1)
		
			-- Hue Bar
			local hueBar = Creator.New("ImageButton", {
				Name = "HueBar",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -16, 0, 0),
				Size = UDim2.new(0, 16, 0, 100),
				Image = "rbxassetid://3641079629", -- Vertical Hue rainbow gradient
				AutoButtonColor = false,
				Parent = pickerBody
			})
			Creator.Round(hueBar, 6)
		
			local hueCursor = Creator.New("Frame", {
				Name = "HueCursor",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(0, -2, h, -2),
				Size = UDim2.new(1, 4, 0, 4),
				Parent = hueBar
			})
			Creator.Round(hueCursor, 2)
			Creator.Stroke(hueCursor, Color3.fromRGB(0, 0, 0), 0.5, 1)
		
			-- Hex Display Box
			local hexBox = Creator.New("TextBox", {
				Name = "HexBox",
				BackgroundColor3 = currentTheme.GlassHover,
				BackgroundTransparency = 0.4,
				Position = UDim2.new(0, 0, 0, 108),
				Size = UDim2.new(1, 0, 0, 24),
				Font = currentTheme.FontMedium,
				Text = "#" .. currentColor:ToHex():upper(),
				TextColor3 = currentTheme.TextPrimary,
				TextSize = 12,
				ClearTextOnFocus = false,
				Parent = pickerBody
			})
			Creator.Round(hexBox, 4)
			Creator.Stroke(hexBox, currentTheme.Border, 0.8, 1)
		
			local function updateColor(newColor: Color3, triggerCallback: boolean?)
				currentColor = newColor
				colorChip.BackgroundColor3 = currentColor
				satValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				hexBox.Text = "#" .. currentColor:ToHex():upper()
		
				if config.Flag then
					Config.SetFlag(config.Flag, currentColor)
				end
		
				if triggerCallback ~= false then
					task.spawn(callback, currentColor)
				end
			end
		
			local draggingSV = false
			local draggingHue = false
		
			satValCanvas.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSV = true
					local absPos = satValCanvas.AbsolutePosition
					local absSize = satValCanvas.AbsoluteSize
					s = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
					v = 1 - math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
					satValCursor.Position = UDim2.new(s, -5, 1 - v, -5)
					updateColor(Color3.fromHSV(h, s, v), true)
				end
			end)
		
			hueBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingHue = true
					local absPos = hueBar.AbsolutePosition
					local absSize = hueBar.AbsoluteSize
					h = math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
					hueCursor.Position = UDim2.new(0, -2, h, -2)
					updateColor(Color3.fromHSV(h, s, v), true)
				end
			end)
		
			UserInputService.InputChanged:Connect(function(input)
				if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local absPos = satValCanvas.AbsolutePosition
					local absSize = satValCanvas.AbsoluteSize
					s = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
					v = 1 - math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
					satValCursor.Position = UDim2.new(s, -5, 1 - v, -5)
					updateColor(Color3.fromHSV(h, s, v), true)
				elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local absPos = hueBar.AbsolutePosition
					local absSize = hueBar.AbsoluteSize
					h = math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
					hueCursor.Position = UDim2.new(0, -2, h, -2)
					updateColor(Color3.fromHSV(h, s, v), true)
				end
			end)
		
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSV = false
					draggingHue = false
				end
			end)
		
			hexBox.FocusLost:Connect(function()
				local cleanHex = string.gsub(hexBox.Text, "#", "")
				local success, col = pcall(function()
					return Color3.fromHex(cleanHex)
				end)
				if success and col then
					h, s, v = col:ToHSV()
					satValCursor.Position = UDim2.new(s, -5, 1 - v, -5)
					hueCursor.Position = UDim2.new(0, -2, h, -2)
					updateColor(col, true)
				else
					hexBox.Text = "#" .. currentColor:ToHex():upper()
				end
			end)
		
			header.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local targetHeight = isOpen and 192 or 42
				Tween.Play(container, "Fast", { Size = UDim2.new(1, 0, 0, targetHeight) })
			end)
		
			local colorpickerObj = {
				Instance = container
			}
		
			function colorpickerObj:Set(newColor: Color3)
				h, s, v = newColor:ToHSV()
				satValCursor.Position = UDim2.new(s, -5, 1 - v, -5)
				hueCursor.Position = UDim2.new(0, -2, h, -2)
				updateColor(newColor, true)
			end
		
			function colorpickerObj:GetColor(): Color3
				return currentColor
			end
		
			Theme.OnThemeChanged(function(t)
				container.BackgroundColor3 = t.GlassPanel
				container.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				titleLabel.TextColor3 = t.TextPrimary
			end)
		
			return colorpickerObj
		end
		
		return Colorpicker
	end

	-- Module: Elements.Dropdown
	_modules["Elements.Dropdown"] = function(require)
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Icons = require("Icons")
		local Config = require("Utilities.Config")
		
		local Dropdown = {}
		
		function Dropdown.New(parent: Instance, cfg: {
			Title: string,
			Options: { string },
			Default: (string | { string })?,
			MultiSelect: boolean?,
			Flag: string?,
			Callback: ((any) -> ())?
		})
			local theme = Theme.Current
			local options = cfg.Options or {}
			local isMulti = cfg.MultiSelect or false
			local callback = cfg.Callback or function() end
			local isOpen = false
		
			local selected = isMulti and {} or (cfg.Default or options[1] or "")
			if isMulti and type(cfg.Default) == "table" then
				for _, v in ipairs(cfg.Default) do selected[v] = true end
			end
		
			if cfg.Flag then Config.SetFlag(cfg.Flag, selected) end
		
			local root = Creator.New("Frame", {
				Name = "Dropdown_" .. (cfg.Title or "Dropdown"),
				BackgroundColor3 = theme.GlassPanel,
				BackgroundTransparency = theme.GlassPanelTransparency,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = parent
			})
		
			Creator.Round(root, 8)
			local stroke = Creator.Stroke(root, theme.Border, theme.BorderTransparency, 1)
		
			local header = Creator.New("TextButton", {
				Name = "Header",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 42),
				Text = "",
				AutoButtonColor = false,
				Parent = root
			})
			Creator.Padding(header, 0, 0, 12, 12)
		
			local titleLabel = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, -9),
				Size = UDim2.new(0.45, 0, 0, 18),
				Font = theme.FontMedium,
				Text = cfg.Title or "Select",
				TextColor3 = theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = header
			})
		
			local function formatSelected(): string
				if isMulti then
					local list = {}
					for opt, on in pairs(selected) do
						if on then table.insert(list, opt) end
					end
					return #list > 0 and table.concat(list, ", ") or "None"
				end
				return tostring(selected)
			end
		
			local valLabel = Creator.New("TextLabel", {
				Name = "Value",
				BackgroundTransparency = 1,
				Position = UDim2.new(0.45, 0, 0.5, -9),
				Size = UDim2.new(0.55, -26, 0, 18),
				Font = theme.FontRegular,
				Text = formatSelected(),
				TextColor3 = theme.Accent,
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = header
			})
		
			local chevron = Creator.New("ImageLabel", {
				Name = "Chevron",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -16, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = Icons.Get("chevron-down"),
				ImageColor3 = theme.TextSecondary,
				Parent = header
			})
		
			local list = Creator.New("ScrollingFrame", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, 46),
				Size = UDim2.new(1, -16, 0, 120),
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = theme.Accent,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
				Parent = root
			})
		
			Creator.New("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
				Parent = list
			})
		
			local optBtns = {}
		
			local function buildOptions()
				for _, b in ipairs(optBtns) do b:Destroy() end
				optBtns = {}
		
				for _, opt in ipairs(options) do
					local isSel = isMulti and (selected[opt] == true) or (selected == opt)
					local t = Theme.Current
		
					local ob = Creator.New("TextButton", {
						Name = "Opt_" .. opt,
						BackgroundColor3 = isSel and t.GlassActive or t.GlassHover,
						BackgroundTransparency = isSel and 0.2 or 0.5,
						BorderSizePixel = 0,
						Size = UDim2.new(1, -6, 0, 28),
						Font = t.FontMedium,
						Text = "   " .. opt,
						TextColor3 = isSel and t.Accent or t.TextSecondary,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutoButtonColor = false,
						Parent = list
					})
					Creator.Round(ob, 6)
		
					local checkmark = Creator.New("ImageLabel", {
						Name = "Check",
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -22, 0.5, -7),
						Size = UDim2.new(0, 14, 0, 14),
						Image = Icons.Get("check"),
						ImageColor3 = t.Accent,
						Visible = isSel,
						Parent = ob
					})
		
					ob.MouseButton1Click:Connect(function()
						local curr = Theme.Current
						if isMulti then
							selected[opt] = not selected[opt]
							checkmark.Visible = selected[opt]
							ob.TextColor3 = selected[opt] and curr.Accent or curr.TextSecondary
							ob.BackgroundColor3 = selected[opt] and curr.GlassActive or curr.GlassHover
						else
							selected = opt
							valLabel.Text = opt
							for _, b in ipairs(optBtns) do
								local chk = b:FindFirstChild("Check")
								local isThis = b.Name == "Opt_" .. opt
								if chk then chk.Visible = isThis end
								b.TextColor3 = isThis and curr.Accent or curr.TextSecondary
								b.BackgroundColor3 = isThis and curr.GlassActive or curr.GlassHover
							end
						end
		
						valLabel.Text = formatSelected()
						if cfg.Flag then Config.SetFlag(cfg.Flag, selected) end
						task.spawn(callback, selected)
		
						if not isMulti then
							isOpen = false
							Tween.Play(root, "Fast", { Size = UDim2.new(1, 0, 0, 42) })
							Tween.Play(chevron, "Fast", { Rotation = 0 })
						end
					end)
		
					table.insert(optBtns, ob)
				end
			end
		
			buildOptions()
		
			header.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				local h = isOpen and (46 + math.min(#options * 32, 130)) or 42
				Tween.Play(root, "Fast", { Size = UDim2.new(1, 0, 0, h) })
				Tween.Play(chevron, "Fast", { Rotation = isOpen and 180 or 0 })
			end)
		
			Theme.OnThemeChanged(function(t)
				root.BackgroundColor3 = t.GlassPanel
				root.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				titleLabel.TextColor3 = t.TextPrimary
				valLabel.TextColor3 = t.Accent
				chevron.ImageColor3 = t.TextSecondary
			end)
		
			return {
				Instance = root,
				SetOptions = function(_, opts: { string })
					options = opts or {}
					buildOptions()
				end,
				Set = function(_, val: any)
					selected = val
					valLabel.Text = formatSelected()
					if cfg.Flag then Config.SetFlag(cfg.Flag, selected) end
					buildOptions()
					task.spawn(callback, selected)
				end,
				GetValue = function(_): any return selected end
			}
		end
		
		return Dropdown
	end

	-- Module: Elements.Input
	_modules["Elements.Input"] = function(require)
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Config = require("Utilities.Config")
		
		local Input = {}
		
		function Input.New(parent: Instance, cfg: {
			Title: string,
			Placeholder: string?,
			Default: string?,
			Numeric: boolean?,
			FinishedOnly: boolean?,
			Flag: string?,
			Callback: ((string) -> ())?
		})
			local theme = Theme.Current
			local callback = cfg.Callback or function() end
			local finishedOnly = cfg.FinishedOnly ~= false
			local val = cfg.Default or ""
		
			if cfg.Flag then Config.SetFlag(cfg.Flag, val) end
		
			local root = Creator.New("Frame", {
				Name = "Input_" .. (cfg.Title or "Input"),
				BackgroundColor3 = theme.GlassPanel,
				BackgroundTransparency = theme.GlassPanelTransparency,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = parent
			})
		
			Creator.Round(root, 8)
			local stroke = Creator.Stroke(root, theme.Border, theme.BorderTransparency, 1)
			Creator.Padding(root, 0, 0, 12, 12)
		
			local title = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, -9),
				Size = UDim2.new(0.45, 0, 0, 18),
				Font = theme.FontMedium,
				Text = cfg.Title or "Input",
				TextColor3 = theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = root
			})
		
			local box = Creator.New("TextBox", {
				Name = "Field",
				BackgroundColor3 = theme.GlassHover,
				BackgroundTransparency = 0.4,
				Position = UDim2.new(0.45, 0, 0.5, -13),
				Size = UDim2.new(0.55, 0, 0, 26),
				Font = theme.FontRegular,
				PlaceholderText = cfg.Placeholder or "Type here...",
				PlaceholderColor3 = theme.TextMuted,
				Text = val,
				TextColor3 = theme.TextPrimary,
				TextSize = 12,
				ClearTextOnFocus = false,
				ClipsDescendants = true,
				Parent = root
			})
		
			Creator.Round(box, 6)
			local boxStroke = Creator.Stroke(box, theme.Border, 0.8, 1)
			Creator.Padding(box, 0, 0, 8, 8)
		
			box.Focused:Connect(function()
				Tween.Play(boxStroke, "Fast", { Color = Theme.Current.BorderFocus, Transparency = Theme.Current.BorderFocusTransparency })
				Tween.Play(box, "Fast", { BackgroundColor3 = Theme.Current.GlassActive, BackgroundTransparency = 0.2 })
			end)
		
			box.FocusLost:Connect(function()
				Tween.Play(boxStroke, "Fast", { Color = Theme.Current.Border, Transparency = 0.8 })
				Tween.Play(box, "Fast", { BackgroundColor3 = Theme.Current.GlassHover, BackgroundTransparency = 0.4 })
		
				val = box.Text
				if cfg.Numeric then
					val = tostring(tonumber(val) or 0)
					box.Text = val
				end
		
				if cfg.Flag then Config.SetFlag(cfg.Flag, val) end
				if finishedOnly then task.spawn(callback, val) end
			end)
		
			if not finishedOnly then
				box:GetPropertyChangedSignal("Text"):Connect(function()
					val = box.Text
					if cfg.Flag then Config.SetFlag(cfg.Flag, val) end
					task.spawn(callback, val)
				end)
			end
		
			Theme.OnThemeChanged(function(t)
				root.BackgroundColor3 = t.GlassPanel
				root.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				title.TextColor3 = t.TextPrimary
				box.TextColor3 = t.TextPrimary
				box.PlaceholderColor3 = t.TextMuted
			end)
		
			return {
				Instance = root,
				Set = function(_, text: string)
					val = text
					box.Text = text
					if cfg.Flag then Config.SetFlag(cfg.Flag, val) end
					task.spawn(callback, val)
				end,
				GetValue = function(_): string return val end
			}
		end
		
		return Input
	end

	-- Module: Elements.Keybind
	_modules["Elements.Keybind"] = function(require)
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Services = require("Services")
		local Config = require("Utilities.Config")
		
		local UserInputService = Services.UserInputService
		
		local Keybind = {}
		
		local Blacklist = {
			[Enum.KeyCode.Unknown] = true,
			[Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
			[Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
			[Enum.KeyCode.Slash] = true, [Enum.KeyCode.Tab] = true,
			[Enum.KeyCode.Backspace] = true, [Enum.KeyCode.Escape] = true,
		}
		
		function Keybind.New(parent: Instance, cfg: {
			Title: string,
			Default: Enum.KeyCode?,
			Mode: ("Toggle" | "Hold" | "Always")?,
			Flag: string?,
			Callback: ((boolean, Enum.KeyCode) -> ())?
		})
			local theme = Theme.Current
			local key = cfg.Default or Enum.KeyCode.E
			local mode = cfg.Mode or "Toggle"
			local callback = cfg.Callback or function() end
			local listening = false
			local toggled = false
		
			if cfg.Flag then Config.SetFlag(cfg.Flag, key.Name) end
		
			local root = Creator.New("Frame", {
				Name = "Keybind_" .. (cfg.Title or "Keybind"),
				BackgroundColor3 = theme.GlassPanel,
				BackgroundTransparency = theme.GlassPanelTransparency,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 42),
				Parent = parent
			})
		
			Creator.Round(root, 8)
			local stroke = Creator.Stroke(root, theme.Border, theme.BorderTransparency, 1)
			Creator.Padding(root, 0, 0, 12, 12)
		
			local title = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, -9),
				Size = UDim2.new(1, -110, 0, 18),
				Font = theme.FontMedium,
				Text = cfg.Title or "Keybind",
				TextColor3 = theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = root
			})
		
			local bindBtn = Creator.New("TextButton", {
				Name = "BindBtn",
				BackgroundColor3 = theme.GlassHover,
				BackgroundTransparency = 0.4,
				Position = UDim2.new(1, -90, 0.5, -12),
				Size = UDim2.new(0, 90, 0, 24),
				Font = theme.FontMedium,
				Text = key.Name,
				TextColor3 = theme.Accent,
				TextSize = 12,
				AutoButtonColor = false,
				Parent = root
			})
			Creator.Round(bindBtn, 6)
			Creator.Stroke(bindBtn, theme.Border, 0.8, 1)
		
			local function setKey(k: Enum.KeyCode)
				key = k
				bindBtn.Text = key.Name
				bindBtn.TextColor3 = Theme.Current.Accent
				listening = false
				if cfg.Flag then Config.SetFlag(cfg.Flag, key.Name) end
			end
		
			bindBtn.MouseButton1Click:Connect(function()
				if listening then return end
				listening = true
				bindBtn.Text = "..."
				bindBtn.TextColor3 = Theme.Current.Warning
			end)
		
			UserInputService.InputBegan:Connect(function(input, gpe)
				if listening then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode.Escape then
							setKey(Enum.KeyCode.Unknown)
						elseif not Blacklist[input.KeyCode] then
							setKey(input.KeyCode)
						end
					end
					return
				end
		
				if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
					if mode == "Toggle" then
						toggled = not toggled
						task.spawn(callback, toggled, key)
					else
						task.spawn(callback, true, key)
					end
				end
			end)
		
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key and mode == "Hold" then
					task.spawn(callback, false, key)
				end
			end)
		
			Theme.OnThemeChanged(function(t)
				root.BackgroundColor3 = t.GlassPanel
				root.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				title.TextColor3 = t.TextPrimary
				bindBtn.TextColor3 = listening and t.Warning or t.Accent
			end)
		
			return {
				Instance = root,
				SetKey = function(_, k: Enum.KeyCode) setKey(k) end,
				GetKey = function(_): Enum.KeyCode return key end
			}
		end
		
		return Keybind
	end

	-- Module: Elements.Paragraph
	_modules["Elements.Paragraph"] = function(require)
		local Creator = require("Utilities.Creator")
		local Theme = require("Theme")
		
		local Paragraph = {}
		
		function Paragraph.New(parent: Instance, cfg: { Title: string, Content: string })
			local theme = Theme.Current
		
			local card = Creator.New("Frame", {
				Name = "Paragraph_" .. (cfg.Title or "Card"),
				BackgroundColor3 = theme.GlassPanel,
				BackgroundTransparency = theme.GlassPanelTransparency,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = parent
			})
		
			Creator.Round(card, 8)
			local stroke = Creator.Stroke(card, theme.Border, theme.BorderTransparency, 1)
			Creator.Padding(card, 10, 10, 12, 12)
		
			local title = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = theme.FontMedium,
				Text = cfg.Title or "Info",
				TextColor3 = theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = card
			})
		
			local desc = Creator.New("TextLabel", {
				Name = "Content",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 20),
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Font = theme.FontRegular,
				Text = cfg.Content or "",
				TextColor3 = theme.TextSecondary,
				TextSize = 12,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = card
			})
		
			Theme.OnThemeChanged(function(t)
				card.BackgroundColor3 = t.GlassPanel
				card.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				title.TextColor3 = t.TextPrimary
				desc.TextColor3 = t.TextSecondary
			end)
		
			return {
				Instance = card,
				Set = function(_, newTitle: string?, newContent: string?)
					if newTitle then title.Text = newTitle end
					if newContent then desc.Text = newContent end
				end
			}
		end
		
		return Paragraph
	end

	-- Module: Elements.Section
	_modules["Elements.Section"] = function(require)
		local Creator = require("Utilities.Creator")
		local Theme = require("Theme")
		
		local Section = {}
		
		function Section.New(parent: Instance, cfg: { Title: string })
			local theme = Theme.Current
		
			local root = Creator.New("Frame", {
				Name = "Section_" .. (cfg.Title or "Section"),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 32),
				Parent = parent
			})
		
			local title = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 4, 0, 0),
				Size = UDim2.new(1, -8, 0, 20),
				Font = theme.FontBold,
				Text = string.upper(cfg.Title or "SECTION"),
				TextColor3 = theme.Accent,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = root
			})
		
			local divider = Creator.New("Frame", {
				Name = "Line",
				BackgroundColor3 = theme.Border,
				BackgroundTransparency = theme.BorderTransparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 4, 0, 24),
				Size = UDim2.new(1, -8, 0, 1),
				Parent = root
			})
		
			Theme.OnThemeChanged(function(t)
				title.TextColor3 = t.Accent
				divider.BackgroundColor3 = t.Border
				divider.BackgroundTransparency = t.BorderTransparency
			end)
		
			return {
				Instance = root,
				SetTitle = function(_, text: string)
					title.Text = string.upper(text)
				end
			}
		end
		
		return Section
	end

	-- Module: Elements.Slider
	_modules["Elements.Slider"] = function(require)
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Services = require("Services")
		local Config = require("Utilities.Config")
		
		local UserInputService = Services.UserInputService
		
		local Slider = {}
		
		function Slider.New(parent: Instance, cfg: {
			Title: string,
			Min: number,
			Max: number,
			Default: number?,
			Increment: number?,
			Suffix: string?,
			Flag: string?,
			Callback: ((number) -> ())?
		})
			local theme = Theme.Current
			local min = cfg.Min or 0
			local max = cfg.Max or 100
			local step = cfg.Increment or 1
			local suffix = cfg.Suffix or ""
			local callback = cfg.Callback or function() end
			local value = math.clamp(cfg.Default or min, min, max)
		
			if cfg.Flag then Config.SetFlag(cfg.Flag, value) end
		
			local root = Creator.New("Frame", {
				Name = "Slider_" .. (cfg.Title or "Slider"),
				BackgroundColor3 = theme.GlassPanel,
				BackgroundTransparency = theme.GlassPanelTransparency,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 52),
				Parent = parent
			})
		
			Creator.Round(root, 8)
			local stroke = Creator.Stroke(root, theme.Border, theme.BorderTransparency, 1)
			Creator.Padding(root, 8, 8, 12, 12)
		
			local title = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, -70, 0, 18),
				Font = theme.FontMedium,
				Text = cfg.Title or "Slider",
				TextColor3 = theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = root
			})
		
			local valBox = Creator.New("TextBox", {
				Name = "ValueBox",
				BackgroundColor3 = theme.GlassHover,
				BackgroundTransparency = 0.4,
				Position = UDim2.new(1, -64, 0, 0),
				Size = UDim2.new(0, 64, 0, 20),
				Font = theme.FontMedium,
				Text = tostring(value) .. suffix,
				TextColor3 = theme.Accent,
				TextSize = 12,
				ClearTextOnFocus = false,
				Parent = root
			})
			Creator.Round(valBox, 4)
			Creator.Stroke(valBox, theme.Border, 0.8, 1)
		
			local barBg = Creator.New("TextButton", {
				Name = "Bar",
				BackgroundColor3 = Color3.fromRGB(30, 35, 48),
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -10),
				Size = UDim2.new(1, 0, 0, 6),
				Text = "",
				AutoButtonColor = false,
				Parent = root
			})
			Creator.Round(barBg, 3)
		
			local fill = Creator.New("Frame", {
				Name = "Fill",
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0),
				Parent = barBg
			})
			Creator.Round(fill, 3)
		
			local knob = Creator.New("Frame", {
				Name = "Knob",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -5, 0.5, -5),
				Size = UDim2.new(0, 10, 0, 10),
				Parent = fill
			})
			Creator.Round(knob, 5)
		
			local function snap(raw: number): number
				return math.clamp(math.floor((raw - min) / step + 0.5) * step + min, min, max)
			end
		
			local function update(raw: number, fire: boolean?)
				value = snap(raw)
				if cfg.Flag then Config.SetFlag(cfg.Flag, value) end
				local pct = math.clamp((value - min) / (max - min), 0, 1)
				Tween.Play(fill, "Fast", { Size = UDim2.new(pct, 0, 1, 0) })
				valBox.Text = tostring(value) .. suffix
				if fire ~= false then task.spawn(callback, value) end
			end
		
			local dragging = false
		
			local function inputToValue(input)
				local w = barBg.AbsoluteSize.X
				local x = barBg.AbsolutePosition.X
				local pct = math.clamp((input.Position.X - x) / w, 0, 1)
				update(min + (max - min) * pct, true)
			end
		
			barBg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					inputToValue(input)
				end
			end)
		
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					inputToValue(input)
				end
			end)
		
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
		
			valBox.FocusLost:Connect(function()
				local n = tonumber(string.match(valBox.Text, "[%d%.%-]+"))
				if n then update(n, true)
				else valBox.Text = tostring(value) .. suffix end
			end)
		
			root.MouseEnter:Connect(function()
				Tween.Play(root, "Fast", { BackgroundColor3 = Theme.Current.GlassHover, BackgroundTransparency = 0.25 })
				Tween.Play(stroke, "Fast", { Color = Theme.Current.BorderFocus, Transparency = Theme.Current.BorderFocusTransparency })
			end)
		
			root.MouseLeave:Connect(function()
				Tween.Play(root, "Fast", { BackgroundColor3 = Theme.Current.GlassPanel, BackgroundTransparency = Theme.Current.GlassPanelTransparency })
				Tween.Play(stroke, "Fast", { Color = Theme.Current.Border, Transparency = Theme.Current.BorderTransparency })
			end)
		
			Theme.OnThemeChanged(function(t)
				root.BackgroundColor3 = t.GlassPanel
				root.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				title.TextColor3 = t.TextPrimary
				valBox.TextColor3 = t.Accent
				fill.BackgroundColor3 = t.Accent
			end)
		
			return {
				Instance = root,
				Set = function(_, val: number) update(val, true) end,
				GetValue = function(_): number return value end
			}
		end
		
		return Slider
	end

	-- Module: Elements.Toggle
	_modules["Elements.Toggle"] = function(require)
		local Creator = require("Utilities.Creator")
		local Tween = require("Utilities.Tween")
		local Theme = require("Theme")
		local Config = require("Utilities.Config")
		
		local Toggle = {}
		
		function Toggle.New(parent: Instance, cfg: {
			Title: string,
			Description: string?,
			Default: boolean?,
			Flag: string?,
			Callback: ((boolean) -> ())?
		})
			local theme = Theme.Current
			local state = cfg.Default or false
			local callback = cfg.Callback or function() end
			local hasDesc = cfg.Description and cfg.Description ~= ""
		
			if cfg.Flag then Config.SetFlag(cfg.Flag, state) end
		
			local btn = Creator.New("TextButton", {
				Name = "Toggle_" .. (cfg.Title or "Toggle"),
				BackgroundColor3 = theme.GlassPanel,
				BackgroundTransparency = theme.GlassPanelTransparency,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, hasDesc and 48 or 38),
				Text = "",
				AutoButtonColor = false,
				ClipsDescendants = true,
				Parent = parent
			})
		
			Creator.Round(btn, 8)
			local stroke = Creator.Stroke(btn, theme.Border, theme.BorderTransparency, 1)
			Creator.Padding(btn, 0, 0, 12, 12)
		
			local title = Creator.New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = hasDesc and UDim2.new(0, 0, 0, 8) or UDim2.new(0, 0, 0.5, -9),
				Size = UDim2.new(1, -60, 0, 18),
				Font = theme.FontMedium,
				Text = cfg.Title or "Toggle",
				TextColor3 = theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = btn
			})
		
			local desc = nil
			if hasDesc then
				desc = Creator.New("TextLabel", {
					Name = "Description",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 26),
					Size = UDim2.new(1, -60, 0, 14),
					Font = theme.FontRegular,
					Text = cfg.Description,
					TextColor3 = theme.TextSecondary,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = btn
				})
			end
		
			local track = Creator.New("Frame", {
				Name = "Track",
				BackgroundColor3 = state and theme.Accent or Color3.fromRGB(40, 45, 60),
				BackgroundTransparency = state and 0.1 or 0.5,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -42, 0.5, -11),
				Size = UDim2.new(0, 42, 0, 22),
				Parent = btn
			})
			Creator.Round(track, 11)
			local trackStroke = Creator.Stroke(track, state and theme.AccentGlow or theme.Border, 0.7, 1)
		
			local thumb = Creator.New("Frame", {
				Name = "Thumb",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Parent = track
			})
			Creator.Round(thumb, 8)
		
			local function refresh(animate: boolean)
				local t = Theme.Current
				local bg = state and t.Accent or Color3.fromRGB(40, 45, 60)
				local bgT = state and 0.1 or 0.5
				local pos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
				local sc = state and t.AccentGlow or t.Border
		
				if animate then
					Tween.Play(track, "Fast", { BackgroundColor3 = bg, BackgroundTransparency = bgT })
					Tween.Play(trackStroke, "Fast", { Color = sc })
					Tween.Play(thumb, "Fast", { Position = pos })
				else
					track.BackgroundColor3 = bg
					track.BackgroundTransparency = bgT
					trackStroke.Color = sc
					thumb.Position = pos
				end
			end
		
			btn.MouseEnter:Connect(function()
				Tween.Play(btn, "Fast", { BackgroundColor3 = Theme.Current.GlassHover, BackgroundTransparency = 0.25 })
				Tween.Play(stroke, "Fast", { Color = Theme.Current.BorderFocus, Transparency = Theme.Current.BorderFocusTransparency })
			end)
		
			btn.MouseLeave:Connect(function()
				Tween.Play(btn, "Fast", { BackgroundColor3 = Theme.Current.GlassPanel, BackgroundTransparency = Theme.Current.GlassPanelTransparency })
				Tween.Play(stroke, "Fast", { Color = Theme.Current.Border, Transparency = Theme.Current.BorderTransparency })
			end)
		
			btn.MouseButton1Click:Connect(function()
				state = not state
				if cfg.Flag then Config.SetFlag(cfg.Flag, state) end
				refresh(true)
				task.spawn(callback, state)
			end)
		
			Theme.OnThemeChanged(function(t)
				btn.BackgroundColor3 = t.GlassPanel
				btn.BackgroundTransparency = t.GlassPanelTransparency
				stroke.Color = t.Border
				stroke.Transparency = t.BorderTransparency
				title.TextColor3 = t.TextPrimary
				if desc then desc.TextColor3 = t.TextSecondary end
				refresh(false)
			end)
		
			return {
				Instance = btn,
				Set = function(_, val: boolean)
					state = val
					if cfg.Flag then Config.SetFlag(cfg.Flag, state) end
					refresh(true)
					task.spawn(callback, state)
				end,
				GetValue = function(_): boolean return state end
			}
		end
		
		return Toggle
	end

	-- Module: Utilities.Config
	_modules["Utilities.Config"] = function(require)
		local Services = require("Services")
		local HttpService = Services.HttpService
		
		local Config = {
			Flags = {},
			Folder = "CastUI_Configs",
			File = "default.json"
		}
		
		local hasFs = rawget(getfenv(), "writefile") ~= nil and rawget(getfenv(), "readfile") ~= nil
		
		function Config.SetFolder(folder: string)
			Config.Folder = folder
			if hasFs and rawget(getfenv(), "isfolder") and rawget(getfenv(), "makefolder") then
				if not isfolder(folder) then
					makefolder(folder)
				end
			end
		end
		
		function Config.SetFlag(flag: string, value: any)
			if flag and flag ~= "" then
				Config.Flags[flag] = value
			end
		end
		
		function Config.GetFlag(flag: string): any
			return Config.Flags[flag]
		end
		
		function Config.Save(name: string?)
			local fileName = name or Config.File
			if not string.find(fileName, "%.json$") then
				fileName = fileName .. ".json"
			end
		
			local path = Config.Folder .. "/" .. fileName
			local data = {}
		
			for k, v in pairs(Config.Flags) do
				if typeof(v) == "Color3" then
					data[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
				elseif typeof(v) == "EnumItem" then
					data[k] = { __type = "EnumItem", enum = tostring(v) }
				else
					data[k] = v
				end
			end
		
			local encoded = HttpService:JSONEncode(data)
		
			if hasFs then
				local ok, err = pcall(function() writefile(path, encoded) end)
				return ok, err
			end
		
			return false, "Filesystem not available"
		end
		
		function Config.Load(name: string?): (boolean, any)
			local fileName = name or Config.File
			if not string.find(fileName, "%.json$") then
				fileName = fileName .. ".json"
			end
		
			local path = Config.Folder .. "/" .. fileName
		
			if hasFs and rawget(getfenv(), "isfile") and isfile(path) then
				local ok, content = pcall(readfile, path)
				if ok and content then
					local decOk, decoded = pcall(function() return HttpService:JSONDecode(content) end)
					if decOk and type(decoded) == "table" then
						for k, v in pairs(decoded) do
							if type(v) == "table" and v.__type == "Color3" then
								Config.Flags[k] = Color3.new(v.r, v.g, v.b)
							else
								Config.Flags[k] = v
							end
						end
						return true, Config.Flags
					end
				end
			end
		
			return false, "Config file not found"
		end
		
		return Config
	end

	-- Module: Utilities.Creator
	_modules["Utilities.Creator"] = function(require)
		local Creator = {}
		
		function Creator.New(className: string, props: { [string]: any }?, children: { Instance }?): Instance
			local inst = Instance.new(className)
			if props then
				for k, v in pairs(props) do
					if k ~= "Parent" then
						inst[k] = v
					end
				end
				if props.Parent then
					inst.Parent = props.Parent
				end
			end
		
			if children then
				for _, child in ipairs(children) do
					if typeof(child) == "Instance" then
						child.Parent = inst
					end
				end
			end
		
			return inst
		end
		
		function Creator.Round(parent: Instance, radius: number?): UICorner
			return Creator.New("UICorner", {
				CornerRadius = UDim.new(0, radius or 8),
				Parent = parent
			})
		end
		
		function Creator.Stroke(parent: Instance, color: Color3?, transparency: number?, thickness: number?): UIStroke
			return Creator.New("UIStroke", {
				Color = color or Color3.fromRGB(255, 255, 255),
				Transparency = transparency or 0.88,
				Thickness = thickness or 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = parent
			})
		end
		
		function Creator.Padding(parent: Instance, top: number, bottom: number, left: number, right: number): UIPadding
			return Creator.New("UIPadding", {
				PaddingTop = UDim.new(0, top),
				PaddingBottom = UDim.new(0, bottom),
				PaddingLeft = UDim.new(0, left),
				PaddingRight = UDim.new(0, right),
				Parent = parent
			})
		end
		
		return Creator
	end

	-- Module: Utilities.Drag
	_modules["Utilities.Drag"] = function(require)
		local Services = require("Services")
		local UserInputService = Services.UserInputService
		local Tween = require("Utilities.Tween")
		
		local Drag = {}
		
		function Drag.MakeDraggable(handle: GuiObject, target: GuiObject?)
			local frame = target or handle
			local dragging = false
			local dragStart = nil
			local startPos = nil
		
			local function update(input)
				local delta = input.Position - dragStart
				local newPos = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
				Tween.Play(frame, "Fast", { Position = newPos })
			end
		
			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = frame.Position
		
					local endedConn
					local changedConn
		
					endedConn = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							if endedConn then endedConn:Disconnect() end
							if changedConn then changedConn:Disconnect() end
						end
					end)
		
					changedConn = UserInputService.InputChanged:Connect(function(moveInput)
						if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
							update(moveInput)
						end
					end)
				end
			end)
		end
		
		return Drag
	end

	-- Module: Utilities.Tween
	_modules["Utilities.Tween"] = function(require)
		local Services = require("Services")
		local TweenService = Services.TweenService
		
		local Tween = {}
		
		local Presets = {
			Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			Spring = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			Modal = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			Slow = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		}
		
		Tween.Presets = Presets
		
		function Tween.Play(inst: Instance, info: TweenInfo | string, goals: { [string]: any }): Tween
			local tInfo = if type(info) == "string" then (Presets[info] or Presets.Normal) else info
			local tw = TweenService:Create(inst, tInfo, goals)
			tw:Play()
			return tw
		end
		
		return Tween
	end

	return require("Init")
end)()