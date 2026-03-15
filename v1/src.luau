--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

-- Load the library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/doyouknowaboututx/v1/refs/heads/main/v1/src.luau"))()

-- Create the main window
local window = Library.new("My Hub", "MyHubConfigs")

-- Set toggle key (optional, default is RightControl)
window:SetToggleKey(Enum.KeyCode.RightControl)

-- Show welcome notification
chx("Hub loaded successfully",3,"rbxassetid://10709775704")

-- Create sections
local CombatSection = window:CreateSection("Combat")
local PlayerSection = window:CreateSection("Player")

-- Create tabs within sections
local AimbotTab = CombatSection:CreateTab("Aimbot", "rbxassetid://10723407389")
local MovementTab = PlayerSection:CreateTab("Movement", "rbxassetid://10734898355")

-- Add section headers
AimbotTab:CreateSection("Aimbot Settings")

local aimbotEnabled = false
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(enabled)
        aimbotEnabled = enabled
        
        if enabled then
            chx("Auto-aim active",2)
        else
            chx("Auto-aim deactivated",2)
        end
        
    end
})

AimbotTab:CreateSlider({
    Name = "Aim Speed",
    Min = 1,
    Max = 100,
    Default = 50,
    Flag = "AimSpeed",
    Callback = function(value)
        print("Aim speed:", value)
    end
})

AimbotTab:CreateDropdown({
    Name = "Target Priority",
    Options = {
        "Closest",
        "Lowest HP",
        "Highest Threat",
        "Random"
    },
    Callback = function(selected)
        print("Target priority:", selected)
    end
})

MovementTab:CreateConfigSection()
