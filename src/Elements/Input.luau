local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Config = require(script.Parent.Parent.Utilities.Config)

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

	Creator.Round(root, 6)
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

	Creator.Round(box, 5)
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
