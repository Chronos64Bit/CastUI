--[[
	CastUI • Colorpicker Element
	The Ventryx Company
	Real-time interactive HSV glass colorpicker with hex/RGB inputs
]]

local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Services = require(script.Parent.Parent.Services)
local UserInputService = Services.UserInputService
local Config = require(script.Parent.Parent.Utilities.Config)

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

	Creator.Round(container, 6)
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
		Font = currentTheme.FontMono,
		Text = "#" .. currentColor:ToHex():upper(),
		TextColor3 = currentTheme.TextPrimary,
		TextSize = 12,
		ClearTextOnFocus = false,
		Parent = pickerBody
	})
	Creator.Round(hexBox, 5)
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
