local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Services = require(script.Parent.Parent.Services)
local Config = require(script.Parent.Parent.Utilities.Config)

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
