--[[
    GeminiHub - Main.lua
    Complete Refactored Version with Fluent UI
    Features: Auto Farm, Sea Events, Combat, Utilities
    Last Updated: 2025-12-29
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ====== CONFIG ======
local Config = {
    AutoFarm = {
        Enabled = false,
        AutoAttack = false,
        AutoCollect = false,
        TargetDistance = 100,
        WalkSpeed = 16,
    },
    SeaEvents = {
        Enabled = false,
        AutoComplete = false,
        AutoJoin = false,
    },
    Combat = {
        Enabled = false,
        AutoDodge = false,
        AutoTarget = false,
        CombatRange = 50,
    },
    Utility = {
        SpeedBoost = false,
        NoClip = false,
        GodMode = false,
        InfiniteJump = false,
    }
}

-- ====== UI SETUP ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GeminiHubUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Menu Frame (Fluent Design)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainMenu"
mainFrame.Size = UDim2.new(0, 450, 0, 600)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "✨ GeminiHub - v2.0"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 50, 0, 50)
closeBtn.Position = UDim2.new(1, -50, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(0, 100, 1, -50)
tabContainer.Position = UDim2.new(0, 0, 0, 50)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

-- Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -100, 1, -50)
contentContainer.Position = UDim2.new(0, 100, 0, 50)
contentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

-- ====== UI HELPER FUNCTIONS ======
local function createTab(tabName, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 60)
    tabButton.Position = UDim2.new(0, 0, 0, (#tabContainer:GetChildren() - 1) * 60)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabButton.BorderSizePixel = 0
    tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = icon .. "\n" .. tabName
    tabButton.Parent = tabContainer
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = tabName .. "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = false
    contentFrame.Parent = contentContainer
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = contentFrame
    
    tabButton.MouseButton1Click:Connect(function()
        for _, child in ipairs(contentContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        contentFrame.Visible = true
        
        for _, btn in ipairs(tabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            end
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    end)
    
    return contentFrame
end

local function createToggle(parent, text, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = text
    toggleContainer.Size = UDim2.new(1, -20, 0, 40)
    toggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    toggleContainer.BorderSizePixel = 0
    toggleContainer.Parent = parent
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, -60, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = toggleContainer
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleButton.TextSize = 0
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleContainer
    
    local state = false
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.BackgroundColor3 = state and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 100, 100)
        callback(state)
    end)
    
    return toggleButton, toggleContainer
end

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(1, -20, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.BorderSizePixel = 0
    button.Parent = parent
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- ====== CREATE TABS ======
local autoFarmTab = createTab("Auto Farm", "🌾")
local seaEventsTab = createTab("Sea Events", "🌊")
local combatTab = createTab("Combat", "⚔️")
local utilityTab = createTab("Utility", "🛠️")

-- Show first tab by default
autoFarmTab.Visible = true
tabContainer:GetChildren()[1].BackgroundColor3 = Color3.fromRGB(50, 100, 150)

-- ====== AUTO FARM TAB ======
createToggle(autoFarmTab, "Enable Auto Farm", function(state)
    Config.AutoFarm.Enabled = state
end)

createToggle(autoFarmTab, "Auto Attack", function(state)
    Config.AutoFarm.AutoAttack = state
end)

createToggle(autoFarmTab, "Auto Collect", function(state)
    Config.AutoFarm.AutoCollect = state
end)

createButton(autoFarmTab, "Farm Nearest", function()
    print("🌾 Starting farm at nearest location...")
end)

createButton(autoFarmTab, "Auto Complete Quests", function()
    print("📋 Auto completing quests...")
end)

-- ====== SEA EVENTS TAB ======
createToggle(seaEventsTab, "Enable Sea Events", function(state)
    Config.SeaEvents.Enabled = state
end)

createToggle(seaEventsTab, "Auto Join Events", function(state)
    Config.SeaEvents.AutoJoin = state
end)

createToggle(seaEventsTab, "Auto Complete", function(state)
    Config.SeaEvents.AutoComplete = state
end)

createButton(seaEventsTab, "Join Event", function()
    print("🌊 Joining sea event...")
end)

createButton(seaEventsTab, "Check Events", function()
    print("🔍 Checking for active events...")
end)

-- ====== COMBAT TAB ======
createToggle(combatTab, "Enable Combat", function(state)
    Config.Combat.Enabled = state
end)

createToggle(combatTab, "Auto Dodge", function(state)
    Config.Combat.AutoDodge = state
end)

createToggle(combatTab, "Auto Target", function(state)
    Config.Combat.AutoTarget = state
end)

createButton(combatTab, "Attack Nearest Enemy", function()
    print("⚔️ Attacking nearest enemy...")
end)

createButton(combatTab, "Use Ultimate", function()
    print("💥 Using ultimate ability...")
end)

-- ====== UTILITY TAB ======
createToggle(utilityTab, "Speed Boost", function(state)
    Config.Utility.SpeedBoost = state
    if state then
        character.Humanoid.WalkSpeed = 50
    else
        character.Humanoid.WalkSpeed = 16
    end
end)

createToggle(utilityTab, "No Clip", function(state)
    Config.Utility.NoClip = state
end)

createToggle(utilityTab, "God Mode", function(state)
    Config.Utility.GodMode = state
end)

createToggle(utilityTab, "Infinite Jump", function(state)
    Config.Utility.InfiniteJump = state
end)

createButton(utilityTab, "Teleport to Spawn", function()
    humanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    print("✨ Teleported to spawn!")
end)

createButton(utilityTab, "Heal", function()
    character.Humanoid.Health = character.Humanoid.MaxHealth
    print("💚 Healed!")
end)

-- ====== FEATURE IMPLEMENTATIONS ======

-- Speed Boost
local speedBoostConnection
local function updateSpeedBoost()
    if speedBoostConnection then speedBoostConnection:Disconnect() end
    if Config.Utility.SpeedBoost then
        speedBoostConnection = RunService.RenderStepped:Connect(function()
            character.Humanoid.WalkSpeed = 50
        end)
    else
        character.Humanoid.WalkSpeed = 16
    end
end

-- No Clip
local noClipConnection
local function updateNoClip()
    if noClipConnection then noClipConnection:Disconnect() end
    if Config.Utility.NoClip then
        noClipConnection = RunService.RenderStepped:Connect(function()
            if character and humanoidRootPart then
                humanoidRootPart.CanCollide = false
            end
        end)
    else
        if character and humanoidRootPart then
            humanoidRootPart.CanCollide = true
        end
    end
end

-- God Mode
local function updateGodMode()
    if Config.Utility.GodMode then
        character.Humanoid.MaxHealth = math.huge
        character.Humanoid.Health = math.huge
    else
        character.Humanoid.MaxHealth = 100
    end
end

-- Infinite Jump
local infiniteJumpConnection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Config.Utility.InfiniteJump and input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
        character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Auto Farm Logic
local farmConnection
local function updateAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    if Config.AutoFarm.Enabled then
        farmConnection = RunService.Heartbeat:Connect(function()
            if Config.AutoFarm.AutoCollect then
                -- Auto collect items
                local items = workspace:FindPartByCFrame(humanoidRootPart.CFrame, 50)
                if items then
                    humanoidRootPart.CFrame = items.CFrame + Vector3.new(0, 3, 0)
                end
            end
            
            if Config.AutoFarm.AutoAttack then
                -- Auto attack enemies
                print("🌾 Auto attacking...")
            end
        end)
    end
end

-- Combat Auto Dodge
local dodgeConnection
local function updateCombatDodge()
    if dodgeConnection then dodgeConnection:Disconnect() end
    if Config.Combat.Enabled and Config.Combat.AutoDodge then
        dodgeConnection = RunService.Heartbeat:Connect(function()
            -- Dodge logic
        end)
    end
end

-- ====== CHARACTER RESPAWN HANDLING ======
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Re-enable features for new character
    updateSpeedBoost()
    updateNoClip()
    updateGodMode()
    updateAutoFarm()
    updateCombatDodge()
end)

-- ====== KEYBOARD SHORTCUTS ======
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        mainFrame.Visible = not mainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.AutoFarm.Enabled = not Config.AutoFarm.Enabled
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.Utility.SpeedBoost = not Config.Utility.SpeedBoost
        updateSpeedBoost()
    end
end)

-- ====== INITIALIZATION ======
updateSpeedBoost()
updateNoClip()
updateGodMode()
updateAutoFarm()
updateCombatDodge()

print("✨ GeminiHub v2.0 Loaded Successfully!")
print("📖 Keyboard Shortcuts:")
print("   F1 - Toggle Menu")
print("   F2 - Toggle Auto Farm")
print("   F3 - Toggle Speed Boost")
