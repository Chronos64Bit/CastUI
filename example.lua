--[[
	CastUI • Full Showcase Example
	Developed by The Ventryx Company
	Modern Glass Aesthetic • High Performance
]]

-- Load CastUI (Replace with your GitHub raw URL when hosting)
local CastUI = loadfile("dist/CastUI.lua")() 
-- Or via loadstring:
-- local CastUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/CastUI/main/dist/CastUI.lua"))()

-- Optional: Set custom configuration folder
CastUI.SetConfigFolder("Ventryx_Hub")

-- Optional Key System Demo (Uncomment if you want to protect your script)
--[[
CastUI.PromptKey({
	Title = "Authentication Required",
	Subtitle = "Enter your Ventryx Access Key to proceed",
	Key = { "VENTRYX-FREE-2026", "VIP-PASS-CAST" },
	GetKeyLink = "https://discord.gg/ventryx",
	SaveKey = true,
	OnSuccess = function()
		print("[Ventryx] Key verified successfully!")
	end
})
]]

-- Create Main Glass Window
local Window = CastUI.CreateWindow({
	Title = "Universal Hub",
	SubTitle = "v1.0.0",
	Size = UDim2.new(0, 640, 0, 440),
	ToggleKey = Enum.KeyCode.RightControl,
	MobileButton = true, -- Shows floating toggle button for mobile/touch users
	OnClose = function()
		print("[CastUI] Window closed by user")
	end
})

-- Welcome Notification
CastUI.Notify({
	Title = "CastUI Initialized",
	Content = "Welcome to CastUI by The Ventryx Company. Press RightControl to toggle.",
	Duration = 5,
	Icon = "sparkles",
	Actions = {
		["Got it!"] = function()
			print("[CastUI] User acknowledged notification.")
		end
	}
})

-- ====================================================================
-- TAB 1: MAIN FEATURES
-- ====================================================================
local MainTab = Window:CreateTab({
	Title = "Main",
	Icon = "home"
})

MainTab:AddParagraph({
	Title = "Modern Glass Engine",
	Content = "CastUI features an ultra-sleek acrylic frosted glass design, micro-interactions, hardware-accelerated dragging, and zero memory leaks."
})

MainTab:AddSection({ Title = "Core Features" })

MainTab:AddButton({
	Title = "Instant Action Button",
	Description = "Triggers an instant callback with click ripple feedback",
	Icon = "zap",
	Callback = function()
		CastUI.Notify({
			Title = "Button Clicked",
			Content = "The instant action was executed with zero latency!",
			Duration = 3,
			Icon = "check"
		})
	end
})

MainTab:AddToggle({
	Title = "Speed Boost",
	Description = "Smooth animated pill switch with real-time state",
	Default = false,
	Flag = "SpeedBoostEnabled",
	Callback = function(enabled)
		print("[Toggle] Speed Boost state:", enabled)
	end
})

MainTab:AddSlider({
	Title = "Player WalkSpeed",
	Min = 16,
	Max = 150,
	Default = 24,
	Increment = 1,
	Suffix = " studs/s",
	Flag = "PlayerWalkSpeed",
	Callback = function(val)
		print("[Slider] WalkSpeed set to:", val)
	end
})

MainTab:AddDropdown({
	Title = "Movement Mode",
	Options = { "Legit Walk", "Bhop Velocity", "Teleport Step", "Flight Vector" },
	Default = "Legit Walk",
	MultiSelect = false,
	Flag = "MovementMode",
	Callback = function(selected)
		print("[Dropdown] Movement Mode:", selected)
	end
})

MainTab:AddInput({
	Title = "Target Username",
	Placeholder = "Enter player name...",
	Default = "",
	FinishedOnly = true,
	Flag = "TargetUser",
	Callback = function(text)
		print("[Input] Target set to:", text)
	end
})

-- ====================================================================
-- TAB 2: VISUALS & COMBAT
-- ====================================================================
local VisualsTab = Window:CreateTab({
	Title = "Visuals",
	Icon = "eye"
})

VisualsTab:AddSection({ Title = "ESP Settings" })

VisualsTab:AddToggle({
	Title = "Box ESP",
	Description = "Draw 2D bounding boxes around players",
	Default = true,
	Flag = "BoxESP",
	Callback = function(val)
		print("[ESP] Box ESP:", val)
	end
})

VisualsTab:AddColorpicker({
	Title = "ESP Color",
	Default = Color3.fromRGB(0, 209, 255),
	Flag = "ESPColor",
	Callback = function(color)
		print("[Colorpicker] New ESP Color:", color:ToHex())
	end
})

VisualsTab:AddKeybind({
	Title = "Triggerbot Keybind",
	Default = Enum.KeyCode.F,
	Mode = "Hold",
	Flag = "TriggerbotKey",
	Callback = function(active, key)
		print("[Keybind] Triggerbot is now:", active and "ACTIVE" or "INACTIVE")
	end
})

-- ====================================================================
-- TAB 3: THEMES & CONFIGURATION
-- ====================================================================
local SettingsTab = Window:CreateTab({
	Title = "Settings",
	Icon = "settings"
})

SettingsTab:AddSection({ Title = "Appearance" })

SettingsTab:AddDropdown({
	Title = "Theme Preset",
	Options = { "Monochrome (Default)", "Midnight Violet", "Emerald Frost" },
	Default = "Monochrome (Default)",
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

SettingsTab:AddSection({ Title = "Configuration System" })

SettingsTab:AddButton({
	Title = "Save Configuration",
	Description = "Saves all flags to your executor filesystem as JSON",
	Icon = "download",
	Callback = function()
		local success, err = CastUI.SaveConfig("my_config")
		if success then
			CastUI.Notify({
				Title = "Config Saved",
				Content = "Successfully saved settings to Ventryx_Hub/my_config.json",
				Duration = 3,
				Icon = "check"
			})
		else
			CastUI.Notify({
				Title = "Config Notice",
				Content = tostring(err),
				Duration = 3,
				Icon = "alert"
			})
		end
	end
})

SettingsTab:AddButton({
	Title = "Load Configuration",
	Description = "Reloads all saved flags from the filesystem",
	Icon = "upload",
	Callback = function()
		local success, err = CastUI.LoadConfig("my_config")
		if success then
			CastUI.Notify({
				Title = "Config Loaded",
				Content = "Settings successfully restored!",
				Duration = 3,
				Icon = "check"
			})
		else
			CastUI.Notify({
				Title = "Config Notice",
				Content = tostring(err),
				Duration = 3,
				Icon = "alert"
			})
		end
	end
})

print("[CastUI] Ready! Developed by The Ventryx Company.")
