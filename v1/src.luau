-- service
local sv = {
	plrs = game:GetService("Players"),
	plr = game:GetService("Players").LocalPlayer,
	rs = game:GetService("RunService"),
	hs = game:GetService("HttpService"),
	r = game:GetService("ReplicatedStorage"),
	vim = game:GetService("VirtualInputManager"),
	pg = game:GetService("Players").LocalPlayer.PlayerGui,
	c = workspace.CurrentCamera,
	gc = game:GetService("GuiService"),
	cg = game:GetService("CoreGui"),
}

-- hrp 
hrp = sv.plr.Character and sv.plr.Character:WaitForChild("HumanoidRootPart") or sv.plr.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")

-- workspace folders
local ws = {
    petsFolder = workspace:WaitForChild("RoamingPets"):WaitForChild("Pets")
}

-- replicatedstorage folders
local rsf = {
    pet = sv.r:WaitForChild("Assets"):WaitForChild("Pets")
}

-- require module scripts
local plrsc = {
    Equip = require(sv.plr.PlayerScripts.Controllers.UI.toolbarUI.equipLogic)
}

-- only use important remotes
function getAllRemotes()
    local remotesFolder = sv.r:WaitForChild("Remotes")
    local found = {}
    for _, obj in ipairs(remotesFolder:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            found[obj.Name] = obj
        end
    end
    return found
end
remotes = getAllRemotes()

-- table locals 
local st = {
    closestPet = nil,
    closestDistance = math.huge
}

_G.Rarity = {
    "Common",
    "Rare",
    "Epic",
    "Legendary",
    "Mythical",
    "Boss",
}

function closestpet()
    st.closestPet = nil
    st.closestDistance = math.huge

    for _, pet in pairs(ws.petsFolder:GetChildren()) do
        if pet:IsA("Model") then
            local pivot = pet:GetPivot().Position
            local dist = (pivot - hrp.Position).Magnitude

            if dist < st.closestDistance then
                st.closestDistance = dist
                st.closestPet = pet
            end
        end
    end

    if st.closestPet then
        local worldPos = st.closestPet:GetPivot().Position
        local screenPos, visible = sv.c:WorldToViewportPoint(worldPos)

        if visible then
            sv.vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
            sv.vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
        end
    end
end

_G.petnames = {}
for _, pet in pairs(rsf.pet:GetChildren()) do
    table.insert(_G.petnames, pet.Name)
end

table.sort(_G.petnames)

function MiniGameTracking()
    local trackedFillBars = {}

    sv.pg.ChildAdded:Connect(function(gui)
        if gui.Name:lower():find("lassominigame") then
            local holder = gui:WaitForChild("Holder")
            for _, bar in pairs(holder:GetChildren()) do
                if bar:IsA("Frame") and bar.Name == "FillBar" then
                    trackedFillBars[bar] = {previousWidth = bar.AbsoluteSize.X, tracked = false, progress = {}}

                    bar:GetPropertyChangedSignal("Size"):Connect(function()
                        local data = trackedFillBars[bar]
                        local currentWidth = bar.AbsoluteSize.X

                        if not data.tracked and currentWidth > data.previousWidth then
                            data.tracked = true
                        end

                        if data.tracked then
                            if currentWidth > data.previousWidth then
                                table.insert(data.progress, currentWidth)
                            end

                            if currentWidth == 0 then
                                data.tracked = false
                                data.progress = {}
                            end
                        end

                        data.previousWidth = currentWidth
                    end)
                end
            end
        end
    end)
    return trackedFillBars
end

local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/doyouknowaboututx/v1/refs/heads/main/v1/src.luau"))()
local win = Window.new("Chloe X [v0.0.1] [discord.gg/chloex] [discord.gg/chloexstore]", "CatchAndTame")

-- Shorcut
local s = {} 
local t = {}

-- Section  
s.plr = win:Section("Player")
s.mm = win:Section("Minigames")
s.cfg = win:Section("Configuration")
-- Tab
t.info = s.plr:Tab("Information")
t.menu = s.mm:Tab("Menu")
t.cfrg = s.cfg:Tab("Config")

t.info:Section("Information Official Discord")
t.info:Paragraph({
    Name = "Chloe X | Community",
    Content = "Join discord for ask some features or more service",
    Image = "rbxassetid://137536764529569",
})

t.info:Button({
    Name = "Click for get link discord",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/chloex")
            chx("Succesfully copied into clipboard :3", 2)
        end
    end
})

t.info:Paragraph({
    Name = "Chloe X Store | Best Price for boost your game!",
    Content = "Join discord for looking BEST PRICE GIG & ROBUX and more for boost your experience game ",
    Image = "rbxassetid://137536764529569",
})

t.info:Button({
    Name = "Click for get link discord",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/ryzsqYYVuH")
            chx("Succesfully copied into clipboard :3", 2)
        end
    end
})

t.menu:Section("Filter Catch Features")
t.menu:Dropdown({
    Name = "Filter Rarity",
    Options = _G.Rarity,
    Default = _G.Rarity[1],
    Callback = function(selected)
        _G.SelectedRarity = selected
    end
})

t.menu:Dropdown({
    Name = "Filter Pet",
    Options = _G.petnames,
    Default = _G.petnames[1],
    Callback = function(selected)
        _G.SelectedPet = selected
    end
})

t.cfrg:Section("Keybind")
t.cfrg:Keybind({
    Name = "Set Keybind",
    Default = Enum.KeyCode.F3,
    Callback = function()
    win:Toggle()
end})

t.cfrg:ConfigSection()
