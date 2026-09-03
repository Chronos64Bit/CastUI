--[[
	CastUI
	Modern Glass UI Library for Roblox Luau
	Developed by The Ventryx Company
]]

local Services = require(script.Services)
local Theme = require(script.Theme)
local Icons = require(script.Icons)
local Config = require(script.Utilities.Config)
local Creator = require(script.Utilities.Creator)
local Window = require(script.Components.Window)
local Notification = require(script.Components.Notification)
local KeySystem = require(script.Components.KeySystem)

local CastUI = {
	Version = "1.0.0",
	Author = "The Ventryx Company",
	Flags = Config.Flags
}

local ScreenGui = nil

local function getRootGui(): ScreenGui
	if ScreenGui and ScreenGui.Parent then
		return ScreenGui
	end

	local targetParent = Services.GetGuiParent()

	ScreenGui = Creator.New("ScreenGui", {
		Name = "CastUI_Ventryx",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 9999,
		Parent = targetParent
	})

	-- Protect GUI if supported by executor
	local protect = rawget(getfenv(), "protectgui") or rawget(getfenv(), "protect_gui")
	if protect and type(protect) == "function" then
		pcall(protect, ScreenGui)
	end

	Notification.Init(ScreenGui)
	return ScreenGui
end

-- Public API
function CastUI.CreateWindow(config: {
	Title: string?,
	SubTitle: string?,
	Size: UDim2?,
	ToggleKey: Enum.KeyCode?,
	MobileButton: boolean?,
	OnClose: (() -> ())?,
	PromoNotifications: boolean?,
	PromoInterval: number?
})
	local gui = getRootGui()
	return Window.New(gui, config or {})
end

function CastUI.PromptKey(config: {
	Title: string?,
	Subtitle: string?,
	Key: string | { string },
	GetKeyLink: string?,
	SaveKey: boolean?,
	OnSuccess: () -> ()
})
	local gui = getRootGui()
	KeySystem.Prompt(gui, config)
end

function CastUI.Notify(config: {
	Title: string,
	Content: string,
	Duration: number?,
	Icon: string?,
	Actions: { [string]: () -> () }?
})
	getRootGui()
	Notification.Notify(config)
end

function CastUI.SetTheme(themeNameOrTable)
	Theme.SetTheme(themeNameOrTable)
end

function CastUI.SetAccent(accentColor: Color3)
	Theme.SetAccent(accentColor)
end

function CastUI.SaveConfig(name: string?)
	return Config.Save(name)
end

function CastUI.LoadConfig(name: string?)
	return Config.Load(name)
end

function CastUI.SetConfigFolder(folder: string)
	Config.SetFolder(folder)
end

return CastUI
