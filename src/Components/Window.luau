--[[
	CastUI • Window Component
	The Ventryx Company
	Main modern frosted glass window with header, sidebar, and controls
]]

local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Icons = require(script.Parent.Parent.Icons)
local Drag = require(script.Parent.Parent.Utilities.Drag)
local Services = require(script.Parent.Parent.Services)
local Tab = require(script.Parent.Tab)
local Notification = require(script.Parent.Notification)

local Window = {}

function Window.New(parentGui: Instance, config: {
	Title: string?,
	SubTitle: string?,
	Size: UDim2?,
	ToggleKey: Enum.KeyCode?,
	MobileButton: boolean?,
	OnClose: (() -> ())?,
	PromoNotifications: boolean?,
	PromoInterval: number?
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

	Creator.Round(mainFrame, 10)
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
	Creator.Round(topBar, 10)

	Drag.MakeDraggable(topBar, mainFrame)

	-- Title
	local titleLabel = Creator.New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 13),
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
			Position = UDim2.new(0, 20 + titleLabel.TextBounds.X, 0, 15),
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
	-- Plain glyph TextButtons: no external image asset, so they always render
	-- and hover feedback makes it obvious they're clickable.
	local controlsHolder = Creator.New("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -72, 0, 9),
		Size = UDim2.new(0, 56, 0, 28),
		Parent = topBar
	})

	local function makeControlButton(name: string, glyph: string, xOffset: number)
		local btn = Creator.New("TextButton", {
			Name = name,
			BackgroundColor3 = currentTheme.GlassPanel,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, xOffset, 0, 0),
			Size = UDim2.new(0, 26, 0, 26),
			Font = currentTheme.FontMedium,
			Text = glyph,
			TextColor3 = currentTheme.TextSecondary,
			TextSize = 15,
			AutoButtonColor = false,
			Parent = controlsHolder
		})
		Creator.Round(btn, 5)

		btn.MouseEnter:Connect(function()
			Tween.Play(btn, "Fast", { BackgroundTransparency = 0.4, TextColor3 = Theme.Current.TextPrimary })
		end)
		btn.MouseLeave:Connect(function()
			Tween.Play(btn, "Fast", { BackgroundTransparency = 1, TextColor3 = Theme.Current.TextSecondary })
		end)

		return btn
	end

	local minimizeBtn = makeControlButton("Minimize", "-", 0)
	local closeBtn = makeControlButton("Close", "X", 30)

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
	Creator.Round(sidebar, 6)
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

	-- Intro Splash: briefly covers the window on first load
	local splash = Creator.New("Frame", {
		Name = "Splash",
		BackgroundColor3 = currentTheme.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 20,
		Parent = mainFrame
	})
	Creator.Round(splash, 10)

	local splashTitle = Creator.New("TextLabel", {
		Name = "SplashTitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, -26),
		Size = UDim2.new(1, 0, 0, 28),
		Font = currentTheme.FontBold,
		Text = "CastUI",
		TextColor3 = currentTheme.TextPrimary,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 21,
		Parent = splash
	})

	local splashSub = Creator.New("TextLabel", {
		Name = "SplashSubtitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, 4),
		Size = UDim2.new(1, 0, 0, 16),
		Font = currentTheme.FontRegular,
		Text = "Loading interface...",
		TextColor3 = currentTheme.TextMuted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 21,
		Parent = splash
	})

	local splashBarTrack = Creator.New("Frame", {
		Name = "SplashBarTrack",
		BackgroundColor3 = currentTheme.GlassPanel,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -60, 0.5, 28),
		Size = UDim2.new(0, 120, 0, 3),
		ZIndex = 21,
		Parent = splash
	})
	Creator.Round(splashBarTrack, 2)

	local splashBarFill = Creator.New("Frame", {
		Name = "SplashBarFill",
		BackgroundColor3 = currentTheme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 22,
		Parent = splashBarTrack
	})
	Creator.Round(splashBarFill, 2)

	Tween.Play(splashBarFill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })

	task.delay(1.1, function()
		Tween.Play(splash, "Fast", { BackgroundTransparency = 1 })
		Tween.Play(splashTitle, "Fast", { TextTransparency = 1 })
		Tween.Play(splashSub, "Fast", { TextTransparency = 1 })
		Tween.Play(splashBarTrack, "Fast", { BackgroundTransparency = 1 })
		task.delay(0.2, function()
			splash:Destroy()
		end)
	end)

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

	-- Occasional bottom-right nudge notification
	if config.PromoNotifications ~= false then
		task.spawn(function()
			task.wait(25)
			while mainFrame.Parent do
				if isVisible then
					Notification.Notify({
						Title = "Enjoying CastUI?",
						Content = "Use it in your own script today.",
						Duration = 6
					})
				end
				task.wait(config.PromoInterval or 120)
			end
		end)
	end

	Theme.OnThemeChanged(function(t)
		mainFrame.BackgroundColor3 = t.Background
		mainFrame.BackgroundTransparency = t.BackgroundTransparency
		windowStroke.Color = t.Border
		windowStroke.Transparency = t.BorderTransparency
		ambientGlow.ImageColor3 = t.Accent
		topBar.BackgroundColor3 = t.GlassPanel
		titleLabel.TextColor3 = t.TextPrimary
		sidebar.BackgroundColor3 = t.GlassPanel
		sidebarScroll.ScrollBarImageColor3 = t.Accent
	end)

	return windowObj
end

return Window
