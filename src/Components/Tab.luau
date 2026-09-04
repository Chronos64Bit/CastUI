--[[
	CastUI • Tab Component
	The Ventryx Company
	Tab navigation button and scrollable element container
]]

local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Icons = require(script.Parent.Parent.Icons)

-- Elements
local Button = require(script.Parent.Parent.Elements.Button)
local Toggle = require(script.Parent.Parent.Elements.Toggle)
local Slider = require(script.Parent.Parent.Elements.Slider)
local Dropdown = require(script.Parent.Parent.Elements.Dropdown)
local Input = require(script.Parent.Parent.Elements.Input)
local Keybind = require(script.Parent.Parent.Elements.Keybind)
local Colorpicker = require(script.Parent.Parent.Elements.Colorpicker)
local Section = require(script.Parent.Parent.Elements.Section)
local Paragraph = require(script.Parent.Parent.Elements.Paragraph)

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

	Creator.Round(tabBtn, 6)
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
