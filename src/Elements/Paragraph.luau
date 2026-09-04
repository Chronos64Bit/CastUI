local Creator = require(script.Parent.Parent.Utilities.Creator)
local Theme = require(script.Parent.Parent.Theme)

local Paragraph = {}

function Paragraph.New(parent: Instance, cfg: { Title: string, Content: string })
	local theme = Theme.Current

	local card = Creator.New("Frame", {
		Name = "Paragraph_" .. (cfg.Title or "Card"),
		BackgroundColor3 = theme.GlassPanel,
		BackgroundTransparency = theme.GlassPanelTransparency,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent
	})

	Creator.Round(card, 6)
	local stroke = Creator.Stroke(card, theme.Border, theme.BorderTransparency, 1)
	Creator.Padding(card, 10, 10, 12, 12)

	local title = Creator.New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = theme.FontMedium,
		Text = cfg.Title or "Info",
		TextColor3 = theme.TextPrimary,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card
	})

	local desc = Creator.New("TextLabel", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = theme.FontRegular,
		Text = cfg.Content or "",
		TextColor3 = theme.TextSecondary,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card
	})

	Theme.OnThemeChanged(function(t)
		card.BackgroundColor3 = t.GlassPanel
		card.BackgroundTransparency = t.GlassPanelTransparency
		stroke.Color = t.Border
		stroke.Transparency = t.BorderTransparency
		title.TextColor3 = t.TextPrimary
		desc.TextColor3 = t.TextSecondary
	end)

	return {
		Instance = card,
		Set = function(_, newTitle: string?, newContent: string?)
			if newTitle then title.Text = newTitle end
			if newContent then desc.Text = newContent end
		end
	}
end

return Paragraph
