local Creator = require(script.Parent.Parent.Utilities.Creator)
local Theme = require(script.Parent.Parent.Theme)

local Section = {}

function Section.New(parent: Instance, cfg: { Title: string })
	local theme = Theme.Current

	local root = Creator.New("Frame", {
		Name = "Section_" .. (cfg.Title or "Section"),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = parent
	})

	local title = Creator.New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 4, 0, 0),
		Size = UDim2.new(1, -8, 0, 20),
		Font = theme.FontBold,
		Text = string.upper(cfg.Title or "SECTION"),
		TextColor3 = theme.Accent,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = root
	})

	local divider = Creator.New("Frame", {
		Name = "Line",
		BackgroundColor3 = theme.Border,
		BackgroundTransparency = theme.BorderTransparency,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 4, 0, 24),
		Size = UDim2.new(1, -8, 0, 1),
		Parent = root
	})

	Theme.OnThemeChanged(function(t)
		title.TextColor3 = t.Accent
		divider.BackgroundColor3 = t.Border
		divider.BackgroundTransparency = t.BorderTransparency
	end)

	return {
		Instance = root,
		SetTitle = function(_, text: string)
			title.Text = string.upper(text)
		end
	}
end

return Section
