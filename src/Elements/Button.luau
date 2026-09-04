local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Icons = require(script.Parent.Parent.Icons)

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

	Creator.Round(btn, 6)
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
