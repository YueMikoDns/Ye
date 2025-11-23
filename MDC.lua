local Module = {}

Module.Weights = {
    bodyParts = 0.4,
    accessories = 0.3,
    clothing = 0.2,
    colors = 0.1
}

local function sameVec3(a, b, eps)
    eps = eps or 0.01
    return (a - b).Magnitude < eps
end

local function getAccessory(char)
    local acc = {}
    for _, v in char:GetChildren() do
        if v:IsA("Accessory") then
            local h = v:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh")
                if m then
                    table.insert(acc, {
                        mesh = m.MeshId,
                        texture = m.TextureId,
                        name = v.Name
                    })
                end
            end
        end
    end
    return acc
end

local function normalizeAsset(id)
    if not id then return nil end
    return tostring(id):match("%d+")
end

local function getClothing(char)
    local shirt = char:FindFirstChildOfClass("Shirt")
    local pants = char:FindFirstChildOfClass("Pants")
    local tshirt = char:FindFirstChildOfClass("ShirtGraphic")
    
    return {
        shirt = normalizeAsset(shirt and shirt.ShirtTemplate),
        pants = normalizeAsset(pants and pants.PantsTemplate),
        tshirt = normalizeAsset(tshirt and tshirt.Graphic)
    }
end

local function getBodyColors(char)
    local bc = char:FindFirstChildOfClass("BodyColors")
    if not bc then return nil end
    
    return {
        head = bc.HeadColor3,
        torso = bc.TorsoColor3,
        leftArm = bc.LeftArmColor3,
        rightArm = bc.RightArmColor3,
        leftLeg = bc.LeftLegColor3,
        rightLeg = bc.RightLegColor3
    }
end

local function getBodyParts(char)
    local parts = {}
    local bodyParts = {
        "Head", "Torso", "UpperTorso", "LowerTorso",
        "Left Arm", "Right Arm", "LeftUpperArm", "RightUpperArm",
        "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand",
        "Left Leg", "Right Leg", "LeftUpperLeg", "RightUpperLeg",
        "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"
    }
    
    for _, name in bodyParts do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                parts[name] = {
                    mesh = mesh.MeshId,
                    texture = mesh.TextureId,
                    scale = mesh.Scale
                }
            end
        end
    end
    
    return parts
end

local function collectAppearance(model)
    return {
        clothing = getClothing(model),
        accessories = getAccessory(model),
        colors = getBodyColors(model),
        parts = getBodyParts(model)
    }
end

local function mapAccessories(acc)
    local map = {}
    for _, a in acc do
        map[a.mesh .. "|" .. a.texture .. "|" .. a.name] = true
    end
    return map
end

local function compareAccessories(acc1, acc2)
    if #acc1 == 0 and #acc2 == 0 then return 0, 0 end
    
    local map1 = mapAccessories(acc1)
    local map2 = mapAccessories(acc2)
    local match = 0
    local allKeys = {}
    
    for _, a in acc1 do
        allKeys[a.mesh .. "|" .. a.texture .. "|" .. a.name] = true
    end
    for _, a in acc2 do
        allKeys[a.mesh .. "|" .. a.texture .. "|" .. a.name] = true
    end
    
    local total = 0
    for key in allKeys do
        total = total + 1
        if map1[key] and map2[key] then
            match = match + 1
        end
    end
    
    return match, total
end

local function compareColors(c1, c2)
    if not c1 or not c2 then return 0, 0 end
    
    local match = 0
    local total = 0
    local keys = {"head", "torso", "leftArm", "rightArm", "leftLeg", "rightLeg"}
    
    for _, k in keys do
        if c1[k] and c2[k] then
            total = total + 1
            if c1[k] == c2[k] then
                match = match + 1
            end
        end
    end
    
    return match, total
end

local function compareBodyParts(p1, p2)
    local match = 0
    local total = 0
    local allKeys = {}
    
    for name in p1 do
        allKeys[name] = true
    end
    for name in p2 do
        allKeys[name] = true
    end
    
    for name in allKeys do
        local data1 = p1[name]
        local data2 = p2[name]
        
        if data1 or data2 then
            total = total + 1
            if data1 and data2 then
                if data1.mesh == data2.mesh and data1.texture == data2.texture and sameVec3(data1.scale, data2.scale) then
                    match = match + 1
                end
            end
        end
    end
    
    return match, total
end

local function compareClothing(c1, c2)
    local match = 0
    local total = 0
    local items = {"shirt", "pants", "tshirt"}
    
    for _, item in items do
        local v1 = c1[item]
        local v2 = c2[item]
        
        if v1 ~= nil or v2 ~= nil then
            total = total + 1
            if v1 == v2 then
                match = match + 1
            end
        end
    end
    
    return match, total
end

function Module.Compare(model1, model2, useWeights)
    if not model1 or not model2 then return 0 end
    
    local app1 = collectAppearance(model1)
    local app2 = collectAppearance(model2)
    
    local clothingMatch, clothingTotal = compareClothing(app1.clothing, app2.clothing)
    local accMatch, accTotal = compareAccessories(app1.accessories, app2.accessories)
    local colorMatch, colorTotal = compareColors(app1.colors, app2.colors)
    local partsMatch, partsTotal = compareBodyParts(app1.parts, app2.parts)
    
    if not useWeights then
        local totalScore = clothingMatch + accMatch + colorMatch + partsMatch
        local maxScore = clothingTotal + accTotal + colorTotal + partsTotal
        
        if maxScore == 0 then return 0 end
        return math.floor((totalScore / maxScore) * 100)
    end
    
    local w = Module.Weights
    local score = 0
    
    if partsTotal > 0 then
        score = score + (partsMatch / partsTotal) * w.bodyParts
    end
    
    if accTotal > 0 then
        score = score + (accMatch / accTotal) * w.accessories
    end
    
    if clothingTotal > 0 then
        score = score + (clothingMatch / clothingTotal) * w.clothing
    end
    
    if colorTotal > 0 then
        score = score + (colorMatch / colorTotal) * w.colors
    end
    
    local totalWeight = 0
    if partsTotal > 0 then totalWeight = totalWeight + w.bodyParts end
    if accTotal > 0 then totalWeight = totalWeight + w.accessories end
    if clothingTotal > 0 then totalWeight = totalWeight + w.clothing end
    if colorTotal > 0 then totalWeight = totalWeight + w.colors end
    
    if totalWeight == 0 then return 0 end
    
    return math.floor((score / totalWeight) * 100)
end

function Module.CompareDetailed(model1, model2)
    if not model1 or not model2 then return nil end
    
    local app1 = collectAppearance(model1)
    local app2 = collectAppearance(model2)
    
    local result = {
        clothing = {},
        accessories = {},
        bodyColors = {},
        bodyParts = {}
    }
    
    local items = {"shirt", "pants", "tshirt"}
    for _, item in items do
        local v1 = app1.clothing[item]
        local v2 = app2.clothing[item]
        
        if v1 ~= nil or v2 ~= nil then
            result.clothing[item] = v1 == v2
        end
    end
    
    local map2 = mapAccessories(app2.accessories)
    for _, a1 in app1.accessories do
        result.accessories[a1.name] = map2[a1.mesh .. "|" .. a1.texture .. "|" .. a1.name] == true
    end
    
    if app1.colors and app2.colors then
        local keys = {"head", "torso", "leftArm", "rightArm", "leftLeg", "rightLeg"}
        for _, k in keys do
            if app1.colors[k] and app2.colors[k] then
                result.bodyColors[k] = app1.colors[k] == app2.colors[k]
            end
        end
    end
    
    local allKeys = {}
    for name in app1.parts do allKeys[name] = true end
    for name in app2.parts do allKeys[name] = true end
    
    for name in allKeys do
        local data1 = app1.parts[name]
        local data2 = app2.parts[name]
        
        if data1 and data2 then
            result.bodyParts[name] = data1.mesh == data2.mesh and data1.texture == data2.texture and sameVec3(data1.scale, data2.scale)
        elseif data1 or data2 then
            result.bodyParts[name] = false
        end
    end
    
    local totalScore = 0
    local maxScore = 0
    
    for _, v in pairs(result.clothing) do
        maxScore = maxScore + 1
        if v then totalScore = totalScore + 1 end
    end
    
    for _, v in pairs(result.accessories) do
        maxScore = maxScore + 1
        if v then totalScore = totalScore + 1 end
    end
    
    for _, v in pairs(result.bodyColors) do
        maxScore = maxScore + 1
        if v then totalScore = totalScore + 1 end
    end
    
    for _, v in pairs(result.bodyParts) do
        maxScore = maxScore + 1
        if v then totalScore = totalScore + 1 end
    end
    
    result.percentage = maxScore > 0 and math.floor((totalScore / maxScore) * 100) or 0
    result.matchCount = totalScore
    result.totalCount = maxScore
    
    return result
end

return Module
