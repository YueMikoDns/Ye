local RunService = game:GetService("RunService")

local FLAG = "BETTER_DRAWING"
local DrawingObjects = {}

local BetterDrawing = {
    FLAG = FLAG,
    _active = false,
    _callback = nil
}

local Drawing = getgenv().Drawing
local hookfunction = getgenv().hookfunction

if not (hookfunction and Drawing) then
    warn("[BetterDrawing] Missing required functions: hookfunction or Drawing")
    return BetterDrawing
end

local cleardrawcache = getgenv().cleardrawcache or (function()
    local OriginalNew = hookfunction(Drawing.new, function(Type, PotentialFlag)
        local Object = OriginalNew(Type)
        
        if PotentialFlag == FLAG then
            table.insert(DrawingObjects, Object)
        end
        
        return Object
    end)
    
    return function()
        for i = #DrawingObjects, 1, -1 do
            local Object = DrawingObjects[i]
            if Object then
                pcall(function() Object:Destroy() end)
            end
            DrawingObjects[i] = nil
        end
    end
end)()

local Tween = {}

local Lerp = {
    Number = function(Start, End, Alpha)
        return Start + (End - Start) * Alpha
    end,
    
    Vector2 = function(Start, End, Alpha)
        return Vector2.new(
            Start.X + (End.X - Start.X) * Alpha,
            Start.Y + (End.Y - Start.Y) * Alpha
        )
    end,
    
    Color3 = function(Start, End, Alpha)
        return Color3.new(
            Start.R + (End.R - Start.R) * Alpha,
            Start.G + (End.G - Start.G) * Alpha,
            Start.B + (End.B - Start.B) * Alpha
        )
    end
}

function Tween:Cubic(T)
    if T < 0.5 then
        return 4 * T * T * T
    else
        local F = (2 * T) - 2
        return 0.5 * F * F * F + 1
    end
end

function Tween:SetValue(DrawingObject, Property, Destination, Duration)
    local Start = DrawingObject[Property]
    if not Start then
        warn("[BetterDrawing] Property '" .. Property .. "' not found on Drawing object")
        return
    end
    
    local StartTime = os.clock()
    local Type = typeof(Destination)
    local LerpFunc = Lerp[Type] or Lerp.Number
    
    local Connection
    Connection = RunService.PreSimulation:Connect(function()
        local Elapsed = os.clock() - StartTime
        local Progress = math.min(Elapsed / Duration, 1)
        local Alpha = self:Cubic(Progress)
        
        DrawingObject[Property] = LerpFunc(Start, Destination, Alpha)
        
        if Progress >= 1 then
            Connection:Disconnect()
            DrawingObject[Property] = Destination
        end
    end)
    
    return Connection
end

BetterDrawing.Tween = Tween

function BetterDrawing:Init(UpdateCallback)
    if self._active then
        warn("[BetterDrawing] Already initialized. Call :Stop() first.")
        return
    end
    
    if not UpdateCallback or type(UpdateCallback) ~= "function" then
        warn("[BetterDrawing] UpdateCallback must be a function")
        return
    end
    
    self._callback = UpdateCallback
    self._active = true
    
    RunService:BindToRenderStep("BetterDrawing", Enum.RenderPriority.Camera.Value + 1, function(DeltaTime)
        if not self._active then return end
        
        local success, err = pcall(function()
            cleardrawcache()
            self._callback(DeltaTime)
        end)
        
        if not success then
            warn("[BetterDrawing] Error in update callback:", err)
        end
    end)
    
    return true
end

function BetterDrawing:Stop()
    RunService:UnbindFromRenderStep("BetterDrawing")
    
    cleardrawcache()
    self._active = false
    self._callback = nil
end

function BetterDrawing:IsActive()
    return self._active
end

function BetterDrawing:GetDrawingCount()
    return #DrawingObjects
end

return BetterDrawing
