local RunService = game:GetService("RunService")

local BetterDrawing = { FLAG = "BETTER_DRAWING" }

local Drawing = getgenv().Drawing
local hookfunction = getgenv().hookfunction

if not (Drawing and hookfunction) then
    warn("[BetterDrawing] Drawing or hookfunction not available")
    BetterDrawing.new = Drawing and Drawing.new or nil
    return BetterDrawing
end

local TrackedObjects = {}

local OriginalDrawingNew = hookfunction(Drawing.new, function(Type, FlagArg)
    local Object = OriginalDrawingNew(Type)

    if FlagArg == BetterDrawing.FLAG then
        table.insert(TrackedObjects, Object)
    end

    return Object
end)

function BetterDrawing.new(Type: string)
    return Drawing.new(Type, BetterDrawing.FLAG)
end

local function ClearTracked()
    for _, Object in TrackedObjects do
        pcall(function() Object:Remove() end)  -- most exploits use :Remove(), change to :Destroy() if yours uses that
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
        if t < 0.5 then
            return 4 * t * t * t
        else
            return 1 - math.pow(-2 * t + 2, 3) / 2
        end
    end,
    InQuad = function(t) return t * t end,
    OutQuad = function(t) return t * (2 - t) end,
    InOutQuad = function(t)
        if t < 0.5 then return 2 * t * t end
        return 1 - (-2 * t + 2) ^ 2 / 2
    end,
}

BetterDrawing.Easings = Easings

local function Interpolate(start, goal, alpha)
    local ty = typeof(start)
    if ty == "Color3" then
        return start:Lerp(goal, alpha)
    elseif ty == "number" or ty == "Vector2" or ty == "Vector3" or ty == "UDim2" then
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
        local progress = elapsed / tween.Duration

        if progress >= 1 then
            for prop, data in tween.Props do
                tween.Object[prop] = data.Dest
            end
            table.remove(ActiveTweens, i)
        else
            local alpha = tween.Easing(math.clamp(progress, 0, 1))
            for prop, data in tween.Props do
                tween.Object[prop] = Interpolate(data.Start, data.Dest, alpha)
            end
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
        ClearTracked()
        UpdateTweens()
        UpdateFunction(deltaTime)
    end)
end

function BetterDrawing:Stop()
    RunService:UnbindFromRenderStep(RenderStepName)
    ClearTracked()
    table.clear(ActiveTweens)
end

return BetterDrawing
