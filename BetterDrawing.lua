local RunService = game:GetService("RunService")

local BetterDrawing = { FLAG = "BETTER_DRAWING" }

local Drawing = getgenv().Drawing
local hookfunction = getgenv().hookfunction

if not (Drawing and hookfunction) then return end

local TrackedObjects = {}
local RealDrawingNew = Drawing.new

hookfunction(Drawing.new, function(Type, FlagArg)
    if FlagArg == "BETTER_DRAWING" then
        local Object = RealDrawingNew(Type)
        table.insert(TrackedObjects, Object)
        return Object
    end

    return RealDrawingNew(Type)
end)

function BetterDrawing.new(Type: string)
    return Drawing.new(Type, BetterDrawing.FLAG)
end

local function ClearTracked()
    for _, Object in ipairs(TrackedObjects) do
        pcall(function()
            if Object.Remove then
                Object:Remove()
            elseif Object.Destroy then
                Object:Destroy()
            end
        end)
    end
    table.clear(TrackedObjects)
end

local ActiveTweens = {}

local Easings = {
    Linear = function(t) return t end,
    InSine = function(t) return 1 - math.cos((t * math.pi) / 2) end,
    OutSine = function(t) return math.sin((t * math.pi) / 2) end,
    InOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,
    InCubic = function(t) return t * t * t end,
    OutCubic = function(t) return 1 - (1 - t) ^ 3 end,
    InOutCubic = function(t)
        return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
    end,
    InQuad = function(t) return t * t end,
    OutQuad = function(t) return t * (2 - t) end,
    InOutQuad = function(t)
        return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2) ^ 2 / 2
    end,
}

BetterDrawing.Easings = Easings

local function Interpolate(start, goal, alpha)
    local ty = typeof(start)
    if ty == "Color3" then
        return start:Lerp(goal, alpha)
    elseif ty == "number" then
        return start + (goal - start) * alpha
    elseif ty == "Vector2" or ty == "Vector3" or ty == "UDim2" then
        return start + (goal - start) * alpha
    else
        return alpha >= 1 and goal or start
    end
end

local function UpdateTweens()
    local time = tick()

    for i = #ActiveTweens, 1, -1 do
        local tween = ActiveTweens[i]
        local elapsed = time - tween.StartTime
        local progress = math.clamp(elapsed / tween.Duration, 0, 1)

        local alpha = tween.Easing(progress)

        for prop, data in tween.Props do
            tween.Object[prop] = Interpolate(data.Start, data.Dest, alpha)
        end

        if progress >= 1 then
            for prop, data in tween.Props do
                tween.Object[prop] = data.Dest
            end
            table.remove(ActiveTweens, i)
        end
    end
end

function BetterDrawing.Tween(Object, Properties, Duration: number, Easing: any?)
    local easingFunc = (typeof(Easing) == "string" and Easings[Easing]) or Easing or Easings.InOutCubic

    local tween = {
        Object = Object,
        StartTime = tick(),
        Duration = Duration,
        Easing = easingFunc,
        Props = {},
    }

    for Property, Goal in Properties do
        local Start = Object[Property]
        if Start ~= nil then
            tween.Props[Property] = {Start = Start, Dest = Goal}
        end
    end

    if next(tween.Props) then
        table.insert(ActiveTweens, tween)
    end
end

local RenderStepName = "BetterDrawing_Render"

function BetterDrawing:Init(UpdateFunction)
    RunService:UnbindFromRenderStep(RenderStepName)

    RunService:BindToRenderStep(RenderStepName, 2000, function(deltaTime)
        UpdateTweens()
        ClearTracked()
        UpdateFunction(deltaTime)
    end)
end

function BetterDrawing:Stop()
    RunService:UnbindFromRenderStep(RenderStepName)
    ClearTracked()
    table.clear(ActiveTweens)
end

return BetterDrawing
