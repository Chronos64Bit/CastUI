--[[
	CastUI • Notification Engine
	The Ventryx Company
	Modern frosted glass toast notifications with timer bar & actions
]]

local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Icons = require(script.Parent.Parent.Icons)

local Notification = {}
local notifContainer = nil

function Notification.Init(parentGui: Instance)
	if notifContainer then return end

	notifContainer = Creator.New("Frame", {
		Name = "NotificationContainer",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -320, 1, -20),
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.new(0, 300, 1, -40),
		Parent = parentGui
	})

	local layout = Creator.New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 8),
		Parent = notifContainer
	})
end

function Notification.Notify(config: {
	Title: string,
	Content: string,
	Duration: number?,
	Icon: string?,
	Actions: { [string]: () -> () }?
})
	if not notifContainer then return end

	local currentTheme = Theme.Current
	local duration = config.Duration or 4
	local hasActions = config.Actions and next(config.Actions) ~= nil

	local toast = Creator.New("Frame", {
		Name = "Toast",
		BackgroundColor3 = currentTheme.Background,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(1, 40, 0, 0), -- Slide-in start
		Size = UDim2.new(1, 0, 0, hasActions and 95 or 65),
		Parent = notifContainer
	})

	Creator.Round(toast, 8)
	local stroke = Creator.Stroke(toast, currentTheme.Border, currentTheme.BorderTransparency, 1)

	local iconOffset = 12
	if config.Icon and config.Icon ~= "" then
		iconOffset = 34
		local iconImg = Creator.New("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(0, 18, 0, 18),
			Image = Icons.Get(config.Icon),
			ImageColor3 = currentTheme.Accent,
			Parent = toast
		})
	end

	local titleLabel = Creator.New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, iconOffset, 0, 8),
		Size = UDim2.new(1, -iconOffset - 30, 0, 18),
		Font = currentTheme.FontMedium,
		Text = config.Title or "Notification",
		TextColor3 = currentTheme.TextPrimary,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = toast
	})

	local contentLabel = Creator.New("TextLabel", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, iconOffset, 0, 26),
		Size = UDim2.new(1, -iconOffset - 12, 0, 28),
		Font = currentTheme.FontRegular,
		Text = config.Content or "",
		TextColor3 = currentTheme.TextSecondary,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = toast
	})

	-- Close Button (X)
	local closeBtn = Creator.New("ImageButton", {
		Name = "Close",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -22, 0, 10),
		Size = UDim2.new(0, 14, 0, 14),
		Image = Icons.Get("x"),
		ImageColor3 = currentTheme.TextMuted,
		Parent = toast
	})

	-- Progress Bar
	local progressBar = Creator.New("Frame", {
		Name = "ProgressBar",
		BackgroundColor3 = currentTheme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		Parent = toast
	})

	local function dismiss()
		Tween.Play(toast, "Fast", { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 })
		task.wait(0.2)
		toast:Destroy()
	end

	closeBtn.MouseButton1Click:Connect(dismiss)

	-- Action Buttons (if provided)
	if hasActions then
		local actionHolder = Creator.New("Frame", {
			Name = "ActionHolder",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 60),
			Size = UDim2.new(1, -24, 0, 24),
			Parent = toast
		})

		local btnLayout = Creator.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
			Parent = actionHolder
		})

		for actName, actFunc in pairs(config.Actions) do
			local actBtn = Creator.New("TextButton", {
				Name = "Act_" .. actName,
				BackgroundColor3 = currentTheme.GlassHover,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 70, 0, 22),
				Font = currentTheme.FontMedium,
				Text = actName,
				TextColor3 = currentTheme.Accent,
				TextSize = 11,
				AutoButtonColor = false,
				Parent = actionHolder
			})
			Creator.Round(actBtn, 4)
			Creator.Stroke(actBtn, currentTheme.Border, 0.8, 1)

			actBtn.MouseButton1Click:Connect(function()
				task.spawn(actFunc)
				dismiss()
			end)
		end
	end

	-- Slide-in
	Tween.Play(toast, "Smooth", { Position = UDim2.new(0, 0, 0, 0) })
	Tween.Play(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

	task.delay(duration, function()
		if toast and toast.Parent then
			dismiss()
		end
	end)
end

return Notification
