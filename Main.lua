-- GeminiHub Main.lua - Refactored Version
-- Optimized with proper functionality and error handling

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local CONFIG = {
    AUTO_FARM_ENABLED = false,
    AUTO_FARM_RADIUS = 50,
    AUTO_FARM_DELAY = 0.5,
    SEA_EVENTS_ENABLED = false,
    COMBAT_ENABLED = false,
    ERROR_HANDLING = true,
    DEBUG_MODE = false
}

-- State Management
local STATE = {
    isRunning = false,
    lastActionTime = 0,
    currentTarget = nil,
    farmingActive = false,
    combatActive = false
}

-- Utility Functions
local function log(message, level)
    level = level or "INFO"
    if CONFIG.DEBUG_MODE or level == "ERROR" then
        print(string.format("[GeminiHub-%s] %s", level, message))
    end
end

local function safeExecute(func, funcName)
    if not CONFIG.ERROR_HANDLING then
        return func()
    end
    
    local success, result = pcall(func)
    if not success then
        log(string.format("Error in %s: %s", funcName, tostring(result)), "ERROR")
        return nil
    end
    return result
end

local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function isPlayer(character)
    if not character or not character:FindFirstChild("Humanoid") then
        return false
    end
    local char = character
    local targetPlayer = Players:FindFirstChild(char.Name)
    return targetPlayer ~= nil
end

-- Auto Farm Functionality
local function findNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = CONFIG.AUTO_FARM_RADIUS
    
    for _, char in pairs(workspace:GetChildren()) do
        if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
            if char ~= character and not isPlayer(char) then
                local distance = getDistance(humanoidRootPart.Position, char.HumanoidRootPart.Position)
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestEnemy = char
                end
            end
        end
    end
    
    return nearestEnemy
end

local function moveTowardTarget(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    local targetPos = target.HumanoidRootPart.Position
    humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(
        CFrame.new(targetPos + Vector3.new(0, 3, 0)),
        0.1
    )
    
    return true
end

local function attackTarget(target)
    if not target or not target:FindFirstChild("Humanoid") then
        return false
    end
    
    local targetHumanoid = target:FindFirstChild("Humanoid")
    if targetHumanoid and targetHumanoid.Health > 0 then
        -- Simulate attack (adjust based on game mechanics)
        log("Attacking " .. target.Name, "INFO")
        
        -- You'll need to adapt this based on your game's combat system
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Humanoid") then
            tool:Activate()
        end
        
        return true
    end
    
    return false
end

local function autoFarm()
    if not STATE.farmingActive then
        return
    end
    
    safeExecute(function()
        local now = tick()
        if now - STATE.lastActionTime < CONFIG.AUTO_FARM_DELAY then
            return
        end
        
        STATE.lastActionTime = now
        
        local target = findNearestEnemy()
        if target then
            STATE.currentTarget = target
            if moveTowardTarget(target) then
                attackTarget(target)
            end
        else
            STATE.currentTarget = nil
        end
    end, "autoFarm")
end

-- Sea Event Handling
local function handleSeaEvent(eventType)
    safeExecute(function()
        if not CONFIG.SEA_EVENTS_ENABLED then
            return
        end
        
        log("Sea Event Detected: " .. eventType, "INFO")
        
        if eventType == "SEA_MONSTER" then
            STATE.combatActive = true
            CONFIG.AUTO_FARM_ENABLED = true
        elseif eventType == "TREASURE" then
            log("Treasure event - navigating to location", "INFO")
        elseif eventType == "DANGER" then
            log("Danger event - taking evasive action", "INFO")
            STATE.combatActive = false
            CONFIG.AUTO_FARM_ENABLED = false
        end
    end, "handleSeaEvent")
end

-- Combat Features
local function initializeCombat()
    safeExecute(function()
        if not CONFIG.COMBAT_ENABLED then
            return
        end
        
        log("Combat system initialized", "INFO")
        
        -- Setup combat listeners here
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                STATE.combatActive = false
                CONFIG.AUTO_FARM_ENABLED = false
                log("Character died - combat disabled", "INFO")
            end)
        end
    end, "initializeCombat")
end

-- Event Listeners
local function setupEventListeners()
    safeExecute(function()
        -- Character respawn
        player.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            STATE.currentTarget = nil
            STATE.farmingActive = false
            STATE.combatActive = false
            log("Character respawned", "INFO")
        end)
        
        -- Input handling
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then
                return
            end
            
            if input.KeyCode == Enum.KeyCode.F then
                CONFIG.AUTO_FARM_ENABLED = not CONFIG.AUTO_FARM_ENABLED
                STATE.farmingActive = CONFIG.AUTO_FARM_ENABLED
                log("Auto farm toggled: " .. tostring(CONFIG.AUTO_FARM_ENABLED), "INFO")
                
            elseif input.KeyCode == Enum.KeyCode.C then
                CONFIG.COMBAT_ENABLED = not CONFIG.COMBAT_ENABLED
                STATE.combatActive = CONFIG.COMBAT_ENABLED
                log("Combat toggled: " .. tostring(CONFIG.COMBAT_ENABLED), "INFO")
                
            elseif input.KeyCode == Enum.KeyCode.S then
                CONFIG.SEA_EVENTS_ENABLED = not CONFIG.SEA_EVENTS_ENABLED
                log("Sea events toggled: " .. tostring(CONFIG.SEA_EVENTS_ENABLED), "INFO")
                
            elseif input.KeyCode == Enum.KeyCode.D then
                CONFIG.DEBUG_MODE = not CONFIG.DEBUG_MODE
                log("Debug mode toggled: " .. tostring(CONFIG.DEBUG_MODE), "INFO")
            end
        end)
    end, "setupEventListeners")
end

-- Main Loop
local function mainLoop()
    RunService.Heartbeat:Connect(function()
        safeExecute(function()
            if not character or not character:FindFirstChild("Humanoid") then
                return
            end
            
            if character.Humanoid.Health <= 0 then
                return
            end
            
            -- Execute active features
            if CONFIG.AUTO_FARM_ENABLED then
                autoFarm()
            end
            
            if CONFIG.COMBAT_ENABLED then
                -- Combat logic runs as part of autoFarm
            end
            
        end, "mainLoop")
    end)
end

-- Initialization
local function initialize()
    safeExecute(function()
        log("Initializing GeminiHub", "INFO")
        
        -- Wait for game to be ready
        repeat
            wait(0.1)
        until character and character:FindFirstChild("Humanoid") and humanoidRootPart
        
        setupEventListeners()
        initializeCombat()
        mainLoop()
        
        log("GeminiHub initialized successfully", "INFO")
        log("Controls: F=Farm | C=Combat | S=Sea Events | D=Debug", "INFO")
        
    end, "initialize")
end

-- Start the script
initialize()

-- Cleanup on script stop
game:BindToClose(function()
    log("GeminiHub shutting down", "INFO")
end)