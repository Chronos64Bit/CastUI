local Services = {}

local cloneref = rawget(getfenv(), "cloneref")
local function getService(name: string)
	local service = game:GetService(name)
	return if (cloneref and type(cloneref) == "function") then cloneref(service) else service
end

Services.TweenService = getService("TweenService")
Services.UserInputService = getService("UserInputService")
Services.RunService = getService("RunService")
Services.HttpService = getService("HttpService")
Services.Players = getService("Players")
Services.CoreGui = getService("CoreGui")
Services.LocalPlayer = Services.Players.LocalPlayer

function Services.GetGuiParent(): Instance
	local gethui = rawget(getfenv(), "gethui")
	if gethui and type(gethui) == "function" then
		local ok, res = pcall(gethui)
		if ok and res then return res end
	end

	local ok = pcall(function() return Services.CoreGui:GetChildren() end)
	if ok then return Services.CoreGui end

	if Services.LocalPlayer then
		local pgui = Services.LocalPlayer:FindFirstChild("PlayerGui")
		if pgui then return pgui end
	end

	return Services.CoreGui
end

return Services
