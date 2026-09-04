--[[
	CastUI • Key System Modal
	The Ventryx Company
	Modern frosted glass key authentication interface
]]

local Creator = require(script.Parent.Parent.Utilities.Creator)
local Tween = require(script.Parent.Parent.Utilities.Tween)
local Theme = require(script.Parent.Parent.Theme)
local Drag = require(script.Parent.Parent.Utilities.Drag)

local KeySystem = {}

function KeySystem.Prompt(parentGui: Instance, config: {
	Title: string?,
	Subtitle: string?,
	Key: string | { string },
	GetKeyLink: string?,
	SaveKey: boolean?,
	OnSuccess: () -> ()
})
	local currentTheme = Theme.Current
	local validKeys = type(config.Key) == "table" and config.Key or { config.Key }

	local savePath = "CastUI_Key.txt"
	local hasFileSystem = rawget(getfenv(), "writefile") ~= nil and rawget(getfenv(), "readfile") ~= nil

	-- Check auto-saved key
	if config.SaveKey and hasFileSystem and rawget(getfenv(), "isfile") and isfile(savePath) then
		local saved = readfile(savePath)
		for _, key in ipairs(validKeys) do
			if saved == key then
				task.spawn(config.OnSuccess)
				return
			end
		end
	end

	-- Fullscreen click-catcher (no dimming, keeps the game visible behind the modal)
	local overlay = Creator.New("Frame", {
		Name = "KeyOverlay",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = parentGui
	})

	local modal = Creator.New("Frame", {
		Name = "KeyModal",
		BackgroundColor3 = currentTheme.Background,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -170, 0.5, -100),
		Size = UDim2.new(0, 340, 0, 200),
		ClipsDescendants = true,
		Parent = overlay
	})

	Creator.Round(modal, 12)
	local stroke = Creator.Stroke(modal, currentTheme.Border, currentTheme.BorderTransparency, 1)
	Creator.Padding(modal, 16, 16, 18, 18)

	Drag.MakeDraggable(modal)

	local titleLabel = Creator.New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 24),
		Font = currentTheme.FontBold,
		Text = config.Title or "Key Verification",
		TextColor3 = currentTheme.TextPrimary,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = modal
	})

	local subLabel = Creator.New("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 20),
		Font = currentTheme.FontRegular,
		Text = config.Subtitle or "Enter your access key to continue",
		TextColor3 = currentTheme.TextSecondary,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = modal
	})

	-- Key Input
	local keyBox = Creator.New("TextBox", {
		Name = "KeyInput",
		BackgroundColor3 = currentTheme.GlassPanel,
		BackgroundTransparency = 0.3,
		Position = UDim2.new(0, 0, 0, 58),
		Size = UDim2.new(1, 0, 0, 38),
		Font = currentTheme.FontRegular,
		PlaceholderText = "Paste key here...",
		PlaceholderColor3 = currentTheme.TextMuted,
		Text = "",
		TextColor3 = currentTheme.TextPrimary,
		TextSize = 13,
		ClearTextOnFocus = false,
		Parent = modal
	})
	Creator.Round(keyBox, 8)
	local boxStroke = Creator.Stroke(keyBox, currentTheme.Border, 0.8, 1)

	local errorLabel = Creator.New("TextLabel", {
		Name = "ErrorMsg",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 100),
		Size = UDim2.new(1, 0, 0, 16),
		Font = currentTheme.FontRegular,
		Text = "",
		TextColor3 = currentTheme.Danger,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = modal
	})

	-- Buttons
	local btnContainer = Creator.New("Frame", {
		Name = "Buttons",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, -40),
		Size = UDim2.new(1, 0, 0, 36),
		Parent = modal
	})

	local verifyBtn = Creator.New("TextButton", {
		Name = "Verify",
		BackgroundColor3 = currentTheme.Accent,
		BorderSizePixel = 0,
		Position = config.GetKeyLink and UDim2.new(0.5, 6, 0, 0) or UDim2.new(0, 0, 0, 0),
		Size = config.GetKeyLink and UDim2.new(0.5, -6, 1, 0) or UDim2.new(1, 0, 1, 0),
		Font = currentTheme.FontBold,
		Text = "Verify Key",
		TextColor3 = Color3.fromRGB(15, 20, 30),
		TextSize = 13,
		AutoButtonColor = false,
		Parent = btnContainer
	})
	Creator.Round(verifyBtn, 8)

	if config.GetKeyLink then
		local getBtn = Creator.New("TextButton", {
			Name = "GetKey",
			BackgroundColor3 = currentTheme.GlassPanel,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0.5, -6, 1, 0),
			Font = currentTheme.FontMedium,
			Text = "Get Key",
			TextColor3 = currentTheme.TextPrimary,
			TextSize = 13,
			AutoButtonColor = false,
			Parent = btnContainer
		})
		Creator.Round(getBtn, 8)
		Creator.Stroke(getBtn, currentTheme.Border, 0.8, 1)

		getBtn.MouseButton1Click:Connect(function()
			local setclip = rawget(getfenv(), "setclipboard") or rawget(getfenv(), "toclipboard")
			if setclip then
				setclip(config.GetKeyLink)
				errorLabel.TextColor3 = Theme.Current.Success
				errorLabel.Text = "Key link copied to clipboard!"
			end
		end)
	end

	verifyBtn.MouseButton1Click:Connect(function()
		local entered = keyBox.Text
		local isValid = false
		for _, k in ipairs(validKeys) do
			if entered == k then
				isValid = true
				break
			end
		end

		if isValid then
			if config.SaveKey and hasFileSystem then
				pcall(writefile, savePath, entered)
			end
			Tween.Play(modal, "Fast", { Size = UDim2.new(0, 340, 0, 0), BackgroundTransparency = 1 })
			Tween.Play(overlay, "Fast", { BackgroundTransparency = 1 })
			task.wait(0.2)
			overlay:Destroy()
			task.spawn(config.OnSuccess)
		else
			errorLabel.TextColor3 = Theme.Current.Danger
			errorLabel.Text = "Invalid key. Please check and retry."
			Tween.Play(boxStroke, "Fast", { Color = Theme.Current.Danger })
		end
	end)
end

return KeySystem
