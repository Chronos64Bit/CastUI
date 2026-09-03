--[[
	CastUI • Local UI Preview
	Loads the locally-hosted dist bundle, gates it behind the key system, then
	shows every element type. Every callback below only prints or shows a
	notification — nothing else.
]]

local CastUI = loadstring(game:HttpGet("http://localhost:8787/CastUI.lua"))()

CastUI.SetConfigFolder("CastUI_Preview")

local function BuildUI()

local Window = CastUI.CreateWindow({
	Title = "CastUI Preview",
	SubTitle = "v1.0.0",
	Size = UDim2.new(0, 640, 0, 440),
	ToggleKey = Enum.KeyCode.RightControl,
	MobileButton = true,
	OnClose = function()
		print("[Preview] Window closed")
	end
})

CastUI.Notify({
	Title = "CastUI Loaded",
	Content = "Press RightControl to toggle the window.",
	Duration = 5,
	Icon = "sparkles"
})

-- ============================================================
-- TAB 1: ELEMENTS
-- ============================================================
local ElementsTab = Window:CreateTab({ Title = "Elements", Icon = "layout-grid" })

ElementsTab:AddParagraph({
	Title = "About CastUI",
	Content = "This tab showcases every element type. Nothing here modifies gameplay."
})

ElementsTab:AddSection({ Title = "Basics" })

ElementsTab:AddButton({
	Title = "Sample Button",
	Description = "Shows a notification when clicked",
	Icon = "mouse-pointer-click",
	Callback = function()
		CastUI.Notify({ Title = "Button Clicked", Content = "This is a demo callback.", Duration = 3, Icon = "check" })
	end
})

ElementsTab:AddToggle({
	Title = "Sample Toggle",
	Description = "Prints its state to the console",
	Default = false,
	Flag = "SampleToggle",
	Callback = function(enabled)
		print("[Preview] Toggle:", enabled)
	end
})

ElementsTab:AddSlider({
	Title = "Sample Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Suffix = "%",
	Flag = "SampleSlider",
	Callback = function(val)
		print("[Preview] Slider:", val)
	end
})

ElementsTab:AddDropdown({
	Title = "Sample Dropdown",
	Options = { "Option A", "Option B", "Option C" },
	Default = "Option A",
	MultiSelect = false,
	Flag = "SampleDropdown",
	Callback = function(selected)
		print("[Preview] Dropdown:", selected)
	end
})

ElementsTab:AddInput({
	Title = "Sample Text Input",
	Placeholder = "Type something...",
	Default = "",
	FinishedOnly = true,
	Flag = "SampleInput",
	Callback = function(text)
		print("[Preview] Input:", text)
	end
})

ElementsTab:AddKeybind({
	Title = "Sample Keybind",
	Default = Enum.KeyCode.F,
	Mode = "Toggle",
	Flag = "SampleKeybind",
	Callback = function(active, key)
		print("[Preview] Keybind active:", active)
	end
})

ElementsTab:AddColorpicker({
	Title = "Sample Colorpicker",
	Default = Color3.fromRGB(0, 209, 255),
	Flag = "SampleColor",
	Callback = function(color)
		print("[Preview] Color:", color:ToHex())
	end
})

-- ============================================================
-- TAB 2: SETTINGS
-- ============================================================
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "settings" })

SettingsTab:AddSection({ Title = "Appearance" })

SettingsTab:AddDropdown({
	Title = "Theme Preset",
	Options = { "Modern Glass (Default)", "Midnight Violet", "Emerald Frost" },
	Default = "Modern Glass (Default)",
	Callback = function(themeName)
		CastUI.SetTheme(themeName)
	end
})

SettingsTab:AddColorpicker({
	Title = "Custom Accent Color",
	Default = Color3.fromRGB(0, 209, 255),
	Callback = function(color)
		CastUI.SetAccent(color)
	end
})

SettingsTab:AddSection({ Title = "Configuration" })

SettingsTab:AddButton({
	Title = "Save Configuration",
	Description = "Saves all flags to the executor filesystem as JSON",
	Icon = "download",
	Callback = function()
		local success, err = CastUI.SaveConfig("preview_config")
		CastUI.Notify({
			Title = success and "Config Saved" or "Config Notice",
			Content = success and "Saved to CastUI_Preview/preview_config.json" or tostring(err),
			Duration = 3,
			Icon = success and "check" or "alert"
		})
	end
})

SettingsTab:AddButton({
	Title = "Load Configuration",
	Description = "Reloads saved flags from the filesystem",
	Icon = "upload",
	Callback = function()
		local success, err = CastUI.LoadConfig("preview_config")
		CastUI.Notify({
			Title = success and "Config Loaded" or "Config Notice",
			Content = success and "Settings restored." or tostring(err),
			Duration = 3,
			Icon = success and "check" or "alert"
		})
	end
})

print("[CastUI Preview] Ready.")

end

CastUI.PromptKey({
	Title = "CastUI Preview",
	Subtitle = "Enter the preview key to continue",
	Key = "test",
	SaveKey = false,
	OnSuccess = BuildUI
})
