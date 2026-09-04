local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Services = require(script.Parent.Parent.Services)
local Config = require(script.Parent.Parent.Utilities.Config)

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

	Creator.Round(root, 6)
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
		Font = theme.FontMono,
		Text = key.Name,
		TextColor3 = theme.Accent,
		TextSize = 12,
		AutoButtonColor = false,
		Parent = root
	})
	Creator.Round(bindBtn, 5)
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
