local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Config = require(script.Parent.Parent.Utilities.Config)

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

	Creator.Round(btn, 6)
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

	local function thumbColor(s: boolean): Color3
		return s and Color3.fromRGB(15, 15, 16) or Color3.fromRGB(237, 237, 239)
	end

	local track = Creator.New("Frame", {
		Name = "Track",
		BackgroundColor3 = state and theme.Accent or theme.GlassActive,
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
		BackgroundColor3 = thumbColor(state),
		BorderSizePixel = 0,
		Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16),
		Parent = track
	})
	Creator.Round(thumb, 8)

	local function refresh(animate: boolean)
		local t = Theme.Current
		local bg = state and t.Accent or t.GlassActive
		local bgT = state and 0.1 or 0.5
		local pos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		local sc = state and t.AccentGlow or t.Border
		local tc = thumbColor(state)

		if animate then
			Tween.Play(track, "Fast", { BackgroundColor3 = bg, BackgroundTransparency = bgT })
			Tween.Play(trackStroke, "Fast", { Color = sc })
			Tween.Play(thumb, "Fast", { Position = pos, BackgroundColor3 = tc })
		else
			track.BackgroundColor3 = bg
			track.BackgroundTransparency = bgT
			trackStroke.Color = sc
			thumb.Position = pos
			thumb.BackgroundColor3 = tc
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
