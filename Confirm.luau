local TweenService = game:GetService("TweenService")
local cloneref = cloneref or clonereference or function(instance) return instance end
local coregui = cloneref(game:GetService("CoreGui"))

local ConfirmModule = {}
ConfirmModule.__index = ConfirmModule

local ANIMATION_DURATION = 0.3
local EASE_STYLE = Enum.EasingStyle.Quart
local EASE_DIRECTION = Enum.EasingDirection.Out

local DEFAULT_CONFIG = {
	Title = "Confirm Action",
	Message = "Are you sure?",
	ConfirmText = "Confirm",
	CancelText = "Cancel",
	ConfirmColor = Color3.fromRGB(46, 204, 113),
	CancelColor = Color3.fromRGB(231, 76, 60),
	BoxColor = Color3.fromRGB(44, 47, 51),
	TextColor = Color3.fromRGB(255, 255, 255),
BlurTransparency = 0.3
}

local function createUI(config)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ConfirmDialog"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 999
	
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.fromOffset(320, 176)
	Container.Position = UDim2.fromScale(0.5, 0.5)
	Container.AnchorPoint = Vector2.new(0.5, 0.5)
	Container.BackgroundColor3 = config.BoxColor
	Container.BorderSizePixel = 0
	Container.BackgroundTransparency = 1
	Container.Parent = ScreenGui
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 12)
	Corner.Parent = Container
	
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundTransparency = 1
	Shadow.Position = UDim2.fromScale(0.5, 0.5)
	Shadow.Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30)
	Shadow.ZIndex = 0
	Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.ImageTransparency = 0.7
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
	Shadow.Parent = Container
	
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -40, 0, 40)
	Title.Position = UDim2.fromOffset(20, 20)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 22
	Title.Text = config.Title
	Title.TextColor3 = config.TextColor
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTransparency = 1
	Title.Parent = Container
	
	local Message = Instance.new("TextLabel")
	Message.Name = "Message"
	Message.Size = UDim2.new(1, -40, 0, 60)
	Message.Position = UDim2.fromOffset(20, 70)
	Message.BackgroundTransparency = 1
	Message.Font = Enum.Font.Gotham
	Message.TextSize = 16
	Message.Text = config.Message
	Message.TextColor3 = config.TextColor
	Message.TextWrapped = true
	Message.TextXAlignment = Enum.TextXAlignment.Left
	Message.TextYAlignment = Enum.TextYAlignment.Top
	Message.TextTransparency = 1
	Message.Parent = Container
	
	local ButtonContainer = Instance.new("Frame")
	ButtonContainer.Name = "ButtonContainer"
	ButtonContainer.Size = UDim2.new(1, -40, 0, 45)
	ButtonContainer.Position = UDim2.new(0, 20, 1, -65)
	ButtonContainer.BackgroundTransparency = 1
	ButtonContainer.Parent = Container
	
	local ButtonLayout = Instance.new("UIListLayout")
	ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
	ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	ButtonLayout.Padding = UDim.new(0, 10)
	ButtonLayout.Parent = ButtonContainer
	
	local CancelButton = Instance.new("TextButton")
	CancelButton.Name = "CancelButton"
	CancelButton.Size = UDim2.fromOffset(120, 45)
	CancelButton.Text = config.CancelText
	CancelButton.Font = Enum.Font.GothamBold
	CancelButton.TextSize = 16
	CancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CancelButton.BackgroundColor3 = config.CancelColor
	CancelButton.BorderSizePixel = 0
	CancelButton.AutoButtonColor = false
	CancelButton.BackgroundTransparency = 1
	CancelButton.TextTransparency = 1
	CancelButton.Parent = ButtonContainer
	
	local CancelCorner = Instance.new("UICorner")
	CancelCorner.CornerRadius = UDim.new(0, 8)
	CancelCorner.Parent = CancelButton
	
	local ConfirmButton = Instance.new("TextButton")
	ConfirmButton.Name = "ConfirmButton"
	ConfirmButton.Size = UDim2.fromOffset(120, 45)
	ConfirmButton.Text = config.ConfirmText
	ConfirmButton.Font = Enum.Font.GothamBold
	ConfirmButton.TextSize = 16
	ConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ConfirmButton.BackgroundColor3 = config.ConfirmColor
	ConfirmButton.BorderSizePixel = 0
	ConfirmButton.AutoButtonColor = false
	ConfirmButton.BackgroundTransparency = 1
	ConfirmButton.TextTransparency = 1
	ConfirmButton.Parent = ButtonContainer
	
	local ConfirmCorner = Instance.new("UICorner")
	ConfirmCorner.CornerRadius = UDim.new(0, 8)
	ConfirmCorner.Parent = ConfirmButton
	
	return ScreenGui, {
		Container = Container,
		Title = Title,
		Message = Message,
		ConfirmButton = ConfirmButton,
		CancelButton = CancelButton
	}
end

local function animateIn(elements)
	local tweenInfo = TweenInfo.new(ANIMATION_DURATION, EASE_STYLE, EASE_DIRECTION)
	
	elements.Container.Size = UDim2.fromOffset(304, 160)
	TweenService:Create(elements.Container, tweenInfo, {
		Size = UDim2.fromOffset(320, 176),
		BackgroundTransparency = 0
	}):Play()
	
	local textTweenInfo = TweenInfo.new(ANIMATION_DURATION, EASE_STYLE, EASE_DIRECTION, 0, false, 0.1)
	TweenService:Create(elements.Title, textTweenInfo, {TextTransparency = 0}):Play()
	TweenService:Create(elements.Message, textTweenInfo, {TextTransparency = 0.2}):Play()
	
	local buttonTweenInfo = TweenInfo.new(ANIMATION_DURATION, EASE_STYLE, EASE_DIRECTION, 0, false, 0.15)
	TweenService:Create(elements.ConfirmButton, buttonTweenInfo, {
		BackgroundTransparency = 0,
		TextTransparency = 0
	}):Play()
	TweenService:Create(elements.CancelButton, buttonTweenInfo, {
		BackgroundTransparency = 0,
		TextTransparency = 0
	}):Play()
end

local function animateOut(elements, callback)
	local tweenInfo = TweenInfo.new(ANIMATION_DURATION * 0.7, EASE_STYLE, Enum.EasingDirection.In)
	
	local tween = TweenService:Create(elements.Container, tweenInfo, {
		Size = UDim2.fromOffset(304, 160),
		BackgroundTransparency = 1
	})
	
	TweenService:Create(elements.Title, tweenInfo, {TextTransparency = 1}):Play()
	TweenService:Create(elements.Message, tweenInfo, {TextTransparency = 1}):Play()
	TweenService:Create(elements.ConfirmButton, tweenInfo, {
		BackgroundTransparency = 1,
		TextTransparency = 1
	}):Play()
	TweenService:Create(elements.CancelButton, tweenInfo, {
		BackgroundTransparency = 1,
		TextTransparency = 1
	}):Play()
	
	tween.Completed:Connect(callback)
	tween:Play()
end

local function addHoverEffect(button, originalColor)
	local hoverColor = Color3.new(
		math.min(originalColor.R * 1.15, 1),
		math.min(originalColor.G * 1.15, 1),
		math.min(originalColor.B * 1.15, 1)
	)
	
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = hoverColor,
			Size = button.Size + UDim2.fromOffset(4, 2)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = originalColor,
			Size = button.Size - UDim2.fromOffset(4, 2)
		}):Play()
	end)
end

function ConfirmModule:Show(message: string | table): boolean
	return coroutine.wrap(function()
		local config = DEFAULT_CONFIG
		
		if type(message) == "table" then
			for key, value in pairs(message) do
				config[key] = value
			end
		elseif type(message) == "string" then
			config.Message = message
		end
		
		local screenGui, elements = createUI(config)
		
		local success, err = pcall(function()
			screenGui.Parent = coregui
		end)
		
		if not success then
			warn("ConfirmModule: Failed to create UI - " .. tostring(err))
			return false
		end
		
		animateIn(elements)
		
		addHoverEffect(elements.ConfirmButton, config.ConfirmColor)
		addHoverEffect(elements.CancelButton, config.CancelColor)
		
		local result = nil
		local clickConnection1, clickConnection2
		
		clickConnection1 = elements.ConfirmButton.MouseButton1Click:Connect(function()
			result = true
		end)
		
		clickConnection2 = elements.CancelButton.MouseButton1Click:Connect(function()
			result = false
		end)
		
		repeat
			task.wait()
		until result ~= nil
		
		if clickConnection1 then clickConnection1:Disconnect() end
		if clickConnection2 then clickConnection2:Disconnect() end
		
		animateOut(elements, function()
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
		
		return result
	end)()
end

function ConfirmModule:ShowAsync(message: string | table)
	return Promise.new(function(resolve)
		local result = ConfirmModule:Show(message)
		resolve(result)
	end)
end

return ConfirmModule
