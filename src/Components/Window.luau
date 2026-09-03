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
