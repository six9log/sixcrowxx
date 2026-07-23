-- [[ SIX HUB - PROJECT LAZARUS (ZOMBIES) ]]
-- Foco: Headshots Fáceis, Farm de Pontos, Sobrevivência
-- Atalho Menu: HOME

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Six Hub: Lazarus", "BloodTheme")

-- --- VARIÁVEIS GLOBAIS ---
_G.ZombieESP = false
_G.BoxESP = false
_G.BigHead = false
_G.HeadSize = 10
_G.FullBright = false
_G.WalkSpeed = 16
_G.Noclip = false

local Cache = {
    Zombies = {},
    Interactables = {}
}

-- --- ABA 1: COMBATE (FARM DE PONTOS) ---
local Tab1 = Window:NewTab("Combate")
local CombatSec = Tab1:NewSection("Headshot Master")

CombatSec:NewToggle("Cabeção (Zumbis)", "Aumenta a cabeça dos zumbis para HS fácil", function(state)
    _G.BigHead = state
end)

CombatSec:NewSlider("Tamanho da Cabeça", "Mais pontos, mais fácil acertar", 30, 2, function(s)
    _G.HeadSize = s
end)

-- --- ABA 2: VISUAIS (ESP E LUZ) ---
local Tab2 = Window:NewTab("Visuais")
local EspSec = Tab2:NewSection("Rastreadores")

EspSec:NewToggle("ESP Zumbis", "Veja onde a horda está nascendo", function(state)
    _G.ZombieESP = state
    if not state then ClearCache("Zombies") end
end)

EspSec:NewToggle("ESP Caixas/Máquinas", "Acha a Caixa Misteriosa e Perks", function(state)
    _G.BoxESP = state
    if not state then ClearCache("Interactables") end
end)

local LightSec = Tab2:NewSection("Iluminação")
LightSec:NewToggle("FullBright", "Tira a escuridão do mapa", function(state)
    _G.FullBright = state
    if state then
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Ambient = Color3.fromRGB(0, 0, 0)
        game:GetService("Lighting").GlobalShadows = true
    end
end)

-- --- ABA 3: MOVIMENTO E TROLL ---
local Tab3 = Window:NewTab("Sobrevivência")
local MoveSec = Tab3:NewSection("Fuga")

MoveSec:NewSlider("Velocidade", "Fugir quando cercado", 100, 16, function(s)
    _G.WalkSpeed = s
end)

MoveSec:NewToggle("Noclip", "Atravessar paredes (Cuidado com voids)", function(state)
    _G.Noclip = state
end)

-- --- FUNÇÕES BASE ---
function ApplyESP(obj, color, group, customName)
    if not obj or obj:FindFirstChild("SixTag") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SixESP"; highlight.FillColor = color; highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6; highlight.Parent = obj

    local bill = Instance.new("BillboardGui", obj)
    bill.Name = "SixTag"; bill.AlwaysOnTop = true; bill.Size = UDim2.new(0, 150, 0, 40); bill.StudsOffset = Vector3.new(0, 3, 0)
    
    local label = Instance.new("TextLabel", bill)
    label.Name = "DistLabel"; label.BackgroundTransparency = 1; label.Size = UDim2.new(1, 0, 1, 0)
    label.TextColor3 = color; label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold; label.TextSize = 14
    label.Text = customName or obj.Name

    table.insert(Cache[group], obj)
end

function ClearCache(group)
    for _, obj in pairs(Cache[group]) do
        if obj and obj.Parent then
            if obj:FindFirstChild("SixESP") then obj.SixESP:Destroy() end
            if obj:FindFirstChild("SixTag") then obj.SixTag:Destroy() end
        end
    end
    Cache[group] = {}
end

local function IsZombie(v)
    if v:IsA("Model") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
        return true
    end
    return false
end

-- --- LOOPS (SCANNERS) ---
task.spawn(function()
    while true do
        -- AUMENTA A CABEÇA DO ZUMBI
        if _G.BigHead then
            for _, v in pairs(workspace:GetDescendants()) do
                if IsZombie(v) then
                    local head = v:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        head.CanCollide = false
                        head.Transparency = 0.5 -- Transparente para não tapar sua visão inteira
                    end
                end
            end
        end

        -- RASTREADOR DE ZUMBIS E CAIXAS
        for _, v in pairs(workspace:GetDescendants()) do
            if _G.ZombieESP and IsZombie(v) then
                ApplyESP(v, Color3.fromRGB(255, 0, 0), "Zombies", "Zumbi")
            end
            
            if _G.BoxESP then
                -- O Lazarus usa muito SurfaceGui e ProximityPrompt pras armas na parede e caixa
                if v:IsA("ProximityPrompt") then
                    local parentObj = v.Parent
                    if parentObj then
                        local nomeESP = parentObj.Name
                        -- Filtros para limpar o nome
                        if string.find(string.lower(nomeESP), "box") then nomeESP = "Caixa Misteriosa" end
                        if string.find(string.lower(nomeESP), "pack") then nomeESP = "Pack-a-Punch" end
                        ApplyESP(parentObj, Color3.fromRGB(255, 215, 0), "Interactables", nomeESP)
                    end
                end
            end
        end
        
        task.wait(2)
    end
end)

-- --- LOOP FLUIDO (RenderStepped) ---
game:GetService("RunService").RenderStepped:Connect(function()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Atualiza distâncias
        for groupName, groupTable in pairs(Cache) do
            local isEnabled = (_G.ZombieESP and groupName == "Zombies") or (_G.BoxESP and groupName == "Interactables")
            for i, obj in pairs(groupTable) do
                if obj and obj.Parent and obj:FindFirstChild("SixTag") then
                    obj.SixESP.Enabled = isEnabled
                    obj.SixTag.Enabled = isEnabled
                    
                    if isEnabled then
                        local objPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        local dist = math.floor((root.Position - objPos).Magnitude)
                        obj.SixTag.DistLabel.Text = string.format("%s [%dm]", obj.SixTag.DistLabel.Text:split(" [")[1], dist)
                    end
                else
                    table.remove(groupTable, i)
                end
            end
        end
        
        -- Speed
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.WalkSpeed
        end
        
        -- Noclip
        if _G.Noclip then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- --- CONFIGURAÇÕES ---
local Tab4 = Window:NewTab("Config")
Tab4:NewSection("Menu Principal"):NewKeybind("Abrir/Fechar Menu", "HOME", Enum.KeyCode.Home, function()
    Library:ToggleUI()
end)
