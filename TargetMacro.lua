local targets = {}
local target = nil
local MACRO_NAME = "TargetMacro"
local MACRO_ICON = "SPELL_MISC_FOOD"
local f = CreateFrame("Frame", "TargetMacro")
local COUNTER_START = 1

_G["TM"] = {}

f:SetScript(
    "OnEvent",
    function(self, event)
        if event == "PLAYER_TARGET_CHANGED" then
            target = UnitName("target")
        end
    end
)
f:RegisterEvent("PLAYER_TARGET_CHANGED")

function TM:init()
    body = GetMacroBody("TargetMacro")
    if body == nil then
        TM:CreateMacro(MACRO_NAME, MACRO_ICON, "", nil, nil)
        return
    end
    counter = 1
    for word in string.gmatch(body, "tar%s[%w%s]+") do
        targets[counter] = string.sub(word, 5, #word - 1)
        what = string.sub(word, 5, #word)
        counter = counter + 1
    end
    TM:CreateMacro()
end

function TM:z(i)
    TM:Switch(i)
    if GetRaidTargetIndex("target") == i then
        return
    else
        SetRaidTarget("target", i)
    end
end

function TM:Switch(i)
    if i - (COUNTER_START - 1) == #targets then
        if UnitIsTapDenied("target") or UnitIsDead("target") then
            TM:Cycle()
        end
    end
end

function TM:ClearAllAndAdd()
    local validate = TM:Validate()
    if validate ~= nil then
        print(validate)
        return
    end
    print(">>> " .. target)
    targets = {}
    targets[1] = target
    TM:CreateMacro()
end

function TM:Add()
    local validate = TM:Validate()
    if validate ~= nil then
        print(validate)
        return
    end
    print("+++ " .. target)
    for k, v in pairs(targets) do
        if v == target then
            return
        end
    end
    targets[#targets + 1] = target
    TM:CreateMacro()
end

function TM:Remove()
    local validate = TM:Validate()
    if validate ~= nil then
        print(validate)
        return
    end
    print("--- " .. target)
    new_targets = {}
    local counter = 1
    for k, v in pairs(targets) do
        if v ~= target then
            new_targets[counter] = v
            counter = counter + 1
        end
    end
    targets = new_targets
    TM:CreateMacro()
end

function TM:Validate()
    if UnitAffectingCombat("player") then
        return "In Combat"
    end
    if target == nil then
        return "No Target"
    end
    return nil
end

function TM:Cycle()
    new_targets = {}
    local counter = 1
    for k, v in pairs(targets) do
        new_targets[(counter % #targets) + 1] = v
        counter = counter + 1
    end
    targets = new_targets
    TM:CreateMacro()
end

function TM:CreateMacro()
    local targetString = TM:GenString(targets)
    EditMacro(MACRO_NAME, nil, MACRO_ICON, targetString, nil)
end

function TM:GenString(targets)
    targetString = ""
    local currentMarker = COUNTER_START
    for i = 1, #targets, 1 do
        targetString = targetString .. "/tar " .. targets[i] .. "\n" .. "/run TM:z(" .. currentMarker .. ")" .. "\n"
        currentMarker = currentMarker + 1
        if currnetMarker == 9 then
            currnetMarker = 1
        end
    end
    return targetString
end

function TM:Zygor()
    print(">> Zygor Add <<")
    targets = {}

    local numSteps = TM:GetNumSteps()
    for counter = 1, numSteps do
        local step = "ZygorGuidesViewerFrame_Step" .. counter
        for lineNum = 1, 30 do
            local line = _G[step]["lines"][lineNum]
            if line ~= nil then
                local goal = line["goal"]
                if goal ~= nil then
                    target = goal["target"]
                    local action = goal["action"]
                    if target ~= nil and action == "kill" then
                        target = string.sub(target, 0, #target - 1)
                        TM:Add()
                    else
                        local text = goal["text"]
                        if text ~= nil then
                            local match = string.match(text, "Kill%s[%s%w]+%senemies")
                            if match ~= nil then
                                match = string.sub(match, 6, -9)
                                if match ~= nil then
                                    target = match
                                    TM:Add()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    target = UnitName("target")
end

function TM:GetNumSteps()
    counter = 0
    for __stepframenum = 1, 20 do
        repeat
            local frame = ZGV.stepframes[__stepframenum]
            local stepdata = frame.step

            if stepdata and ZGV:IsStepFocused(stepdata) then
                counter = __stepframenum
            end
        until true
    end
    return counter
end
