local Services = require(script.Parent.Parent.Services)
local UserInputService = Services.UserInputService
local Tween = require(script.Parent.Tween)

local Drag = {}

function Drag.MakeDraggable(handle: GuiObject, target: GuiObject?)
	local frame = target or handle
	local dragging = false
	local dragStart = nil
	local startPos = nil

	local function update(input)
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		Tween.Play(frame, "Fast", { Position = newPos })
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			local endedConn
			local changedConn

			endedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if endedConn then endedConn:Disconnect() end
					if changedConn then changedConn:Disconnect() end
				end
			end)

			changedConn = UserInputService.InputChanged:Connect(function(moveInput)
				if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
					update(moveInput)
				end
			end)
		end
	end)
end

return Drag
