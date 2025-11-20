local TweenService = game:GetService("TweenService")
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local coregui = cloneref(game:GetService("CoreGui"))

local ConfirmModule = {}

function ConfirmModule:Show(message: string): boolean
	return coroutine.wrap(function()
		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.ResetOnSpawn = false
		ScreenGui.Parent = coregui

		local Blur = Instance.new("Frame")
		Blur.BackgroundColor3 = Color3.fromRGB(0,0,0)
		Blur.BackgroundTransparency = 0.4
		Blur.Size = UDim2.fromScale(1,1)
		Blur.Parent = ScreenGui

		local Box = Instance.new("Frame")
		Box.Size = UDim2.fromOffset(300,180)
		Box.Position = UDim2.fromScale(0.5,0.5)
		Box.AnchorPoint = Vector2.new(0.5,0.5)
		Box.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Box.Parent = ScreenGui

		local Text = Instance.new("TextLabel")
		Text.Size = UDim2.fromScale(1,0.5)
		Text.Position = UDim2.fromScale(0,0)
		Text.BackgroundTransparency = 1
		Text.Font = Enum.Font.GothamMedium
		Text.TextSize = 20
		Text.Text = message
		Text.Parent = Box

		local Yes = Instance.new("TextButton")
		Yes.Size = UDim2.fromScale(0.5,0.5)
		Yes.Position = UDim2.fromScale(0,0.5)
		Yes.Text = "Confirm"
		Yes.Font = Enum.Font.GothamBold
		Yes.TextSize = 18
		Yes.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		Yes.Parent = Box

		local No = Instance.new("TextButton")
		No.Size = UDim2.fromScale(0.5,0.5)
		No.Position = UDim2.fromScale(0.5,0.5)
		No.Text = "No"
		No.Font = Enum.Font.GothamBold
		No.TextSize = 18
		No.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
		No.Parent = Box

		local result = nil

		Yes.MouseButton1Click:Connect(function()
			result = true
			ScreenGui:Destroy()
		end)

		No.MouseButton1Click:Connect(function()
			result = false
			ScreenGui:Destroy()
		end)

		repeat task.wait() until result ~= nil

		return result
	end)()
end

return ConfirmModule
