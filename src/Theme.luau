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
