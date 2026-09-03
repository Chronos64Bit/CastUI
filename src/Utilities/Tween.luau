local Services = require(script.Parent.Parent.Services)
local TweenService = Services.TweenService

local Tween = {}

local Presets = {
	Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Modal = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

Tween.Presets = Presets

function Tween.Play(inst: Instance, info: TweenInfo | string, goals: { [string]: any }): Tween
	local tInfo = if type(info) == "string" then (Presets[info] or Presets.Normal) else info
	local tw = TweenService:Create(inst, tInfo, goals)
	tw:Play()
	return tw
end

return Tween
