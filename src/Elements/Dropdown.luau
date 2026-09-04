local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Icons = require(script.Parent.Parent.Icons)
local Config = require(script.Parent.Parent.Utilities.Config)

local Dropdown = {}

function Dropdown.New(parent: Instance, cfg: {
	Title: string,
	Options: { string },
	Default: (string | { string })?,
	MultiSelect: boolean?,
	Flag: string?,
	Callback: ((any) -> ())?
})
	local theme = Theme.Current
	local options = cfg.Options or {}
	local isMulti = cfg.MultiSelect or false
	local callback = cfg.Callback or function() end
	local isOpen = false

	local selected = isMulti and {} or (cfg.Default or options[1] or "")
	if isMulti and type(cfg.Default) == "table" then
		for _, v in ipairs(cfg.Default) do selected[v] = true end
	end

	if cfg.Flag then Config.SetFlag(cfg.Flag, selected) end

	local root = Creator.New("Frame", {
		Name = "Dropdown_" .. (cfg.Title or "Dropdown"),
		BackgroundColor3 = theme.GlassPanel,
		BackgroundTransparency = theme.GlassPanelTransparency,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 42),
		Parent = parent
	})

	Creator.Round(root, 6)
	local stroke = Creator.Stroke(root, theme.Border, theme.BorderTransparency, 1)

	local header = Creator.New("TextButton", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 42),
		Text = "",
		AutoButtonColor = false,
		Parent = root
	})
	Creator.Padding(header, 0, 0, 12, 12)

	local titleLabel = Creator.New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, -9),
		Size = UDim2.new(0.45, 0, 0, 18),
		Font = theme.FontMedium,
		Text = cfg.Title or "Select",
		TextColor3 = theme.TextPrimary,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header
	})

	local function formatSelected(): string
		if isMulti then
			local list = {}
			for opt, on in pairs(selected) do
				if on then table.insert(list, opt) end
			end
			return #list > 0 and table.concat(list, ", ") or "None"
		end
		return tostring(selected)
	end

	local valLabel = Creator.New("TextLabel", {
		Name = "Value",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.45, 0, 0.5, -9),
		Size = UDim2.new(0.55, -26, 0, 18),
		Font = theme.FontRegular,
		Text = formatSelected(),
		TextColor3 = theme.Accent,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header
	})

	local chevron = Creator.New("ImageLabel", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -16, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16),
		Image = Icons.Get("chevron-down"),
		ImageColor3 = theme.TextSecondary,
		Parent = header
	})

	local list = Creator.New("ScrollingFrame", {
		Name = "List",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0, 46),
		Size = UDim2.new(1, -16, 0, 120),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		Parent = root
	})

	Creator.New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = list
	})

	local optBtns = {}

	local function buildOptions()
		for _, b in ipairs(optBtns) do b:Destroy() end
		optBtns = {}

		for _, opt in ipairs(options) do
			local isSel = isMulti and (selected[opt] == true) or (selected == opt)
			local t = Theme.Current

			local ob = Creator.New("TextButton", {
				Name = "Opt_" .. opt,
				BackgroundColor3 = isSel and t.GlassActive or t.GlassHover,
				BackgroundTransparency = isSel and 0.2 or 0.5,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -6, 0, 28),
				Font = t.FontMedium,
				Text = "   " .. opt,
				TextColor3 = isSel and t.Accent or t.TextSecondary,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				Parent = list
			})
			Creator.Round(ob, 5)

			local checkmark = Creator.New("ImageLabel", {
				Name = "Check",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -22, 0.5, -7),
				Size = UDim2.new(0, 14, 0, 14),
				Image = Icons.Get("check"),
				ImageColor3 = t.Accent,
				Visible = isSel,
				Parent = ob
			})

			ob.MouseButton1Click:Connect(function()
				local curr = Theme.Current
				if isMulti then
					selected[opt] = not selected[opt]
					checkmark.Visible = selected[opt]
					ob.TextColor3 = selected[opt] and curr.Accent or curr.TextSecondary
					ob.BackgroundColor3 = selected[opt] and curr.GlassActive or curr.GlassHover
				else
					selected = opt
					valLabel.Text = opt
					for _, b in ipairs(optBtns) do
						local chk = b:FindFirstChild("Check")
						local isThis = b.Name == "Opt_" .. opt
						if chk then chk.Visible = isThis end
						b.TextColor3 = isThis and curr.Accent or curr.TextSecondary
						b.BackgroundColor3 = isThis and curr.GlassActive or curr.GlassHover
					end
				end

				valLabel.Text = formatSelected()
				if cfg.Flag then Config.SetFlag(cfg.Flag, selected) end
				task.spawn(callback, selected)

				if not isMulti then
					isOpen = false
					Tween.Play(root, "Fast", { Size = UDim2.new(1, 0, 0, 42) })
					Tween.Play(chevron, "Fast", { Rotation = 0 })
				end
			end)

			table.insert(optBtns, ob)
		end
	end

	buildOptions()

	header.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		local h = isOpen and (46 + math.min(#options * 32, 130)) or 42
		Tween.Play(root, "Fast", { Size = UDim2.new(1, 0, 0, h) })
		Tween.Play(chevron, "Fast", { Rotation = isOpen and 180 or 0 })
	end)

	Theme.OnThemeChanged(function(t)
		root.BackgroundColor3 = t.GlassPanel
		root.BackgroundTransparency = t.GlassPanelTransparency
		stroke.Color = t.Border
		stroke.Transparency = t.BorderTransparency
		titleLabel.TextColor3 = t.TextPrimary
		valLabel.TextColor3 = t.Accent
		chevron.ImageColor3 = t.TextSecondary
	end)

	return {
		Instance = root,
		SetOptions = function(_, opts: { string })
			options = opts or {}
			buildOptions()
		end,
		Set = function(_, val: any)
			selected = val
			valLabel.Text = formatSelected()
			if cfg.Flag then Config.SetFlag(cfg.Flag, selected) end
			buildOptions()
			task.spawn(callback, selected)
		end,
		GetValue = function(_): any return selected end
	}
end

return Dropdown
