-- [[ NIGHTMARE HUB V2 - SURVIVAL/HORROR EDITION ]]
-- Atalho Menu: HOME

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Nightmare Hub V2", "BloodTheme")

-- --- VARIÁVEIS GLOBAIS ---
_G.AnimatronicESP = false
_G.PlayerESP = false
_G.ItemESP = false
_G.WalkSpeed = 16
_G.SuperFullBright = false
_G.Noclip = false
_G.AntiJumpscare = false

local Cache = {
    Monsters = {},
    Players = {},
    Items = {}
}

-- --- ABA 1: VISUAIS E ESP ---
local Tab1 = Window:NewTab("Visuals")
local EspSection = Tab1:NewSection("Rastreadores Inteligentes")

EspSection:NewToggle("ESP Animatronics (Monstros)", "Mostra a localização dos inimigos", function(state)
    _G.AnimatronicESP = state
    if not state then ClearCache("Monsters") end
end)

EspSection:NewToggle("ESP Players (Aliados)", "Mostra outros jogadores", function(state)
    _G.PlayerESP = state
    if not state then ClearCache("Players") end
end)

EspSection:NewToggle("ESP Itens (Filtro 3s)", "Mostra ferramentas e botões", function(state)
    _G.ItemESP = state
    if not state then ClearCache("Items") end
end)

local LightSection = Tab1:NewSection("Iluminação do Mapa")
LightSection:NewToggle("Super FullBright", "Remove escuridão, neblina e atmosfera", function(state)
    _G.SuperFullBright = state
    if state then
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        
        -- Remove atmosfera escura comum em jogos de terror
        if game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere") then
            game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere").Density = 0
        end
    else
        -- Restaura o básico se desligar (pode não voltar exato como original)
        game:GetService("Lighting").Ambient = Color3.fromRGB(0, 0, 0)
        game:GetService("Lighting").FogEnd = 1000
        game:GetService("Lighting").GlobalShadows = true
    end
end)

-- --- ABA 2: PERSONAGEM E SOBREVIVÊNCIA ---
local Tab2 = Window:NewTab("Sobrevivência")
local MoveSec = Tab2:NewSection("Movimentação")

MoveSec:NewSlider("Velocidade (WalkSpeed)", "Corra dos Animatronics", 150, 16, function(s)
    _G.WalkSpeed = s
end)

MoveSec:NewToggle("Noclip", "Atravessar paredes", function(state)
    _G.Noclip = state
end)

local UtilSec = Tab2:NewSection("Defesa")
UtilSec:NewToggle("Anti-Jumpscare", "Oculta imagens de susto repentinas", function(state)
    _G.AntiJumpscare = state
end)

UtilSec:NewButton("Ir para Safe Zone (Céu)", "Foge instantaneamente", function()
    local lp = game.Players.LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 500, 0)
    end
end)

-- --- FUNÇÕES DO ESP E CACHE ---
function ApplyESP(obj, color, group, customName)
    if not obj or obj:FindFirstChild("SixTag") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SixESP"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = obj

    local bill = Instance.new("BillboardGui", obj)
    bill.Name = "SixTag"
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 150, 0, 40)
    bill.StudsOffset = Vector3.new(0, 4, 0)
    
    local label = Instance.new("TextLabel", bill)
    label.Name = "DistLabel"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.Code
    label.TextSize = 16
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

-- Lógica para descobrir se é um Animatronic (Filtro Melhorado)
local function IsMonster(v)
    if not v:IsA("Model") then return false end
    if v == game.Players.LocalPlayer.Character then return false end
    if game.Players:GetPlayerFromCharacter(v) then return false end
    
    -- Se tiver Humanoid ou AnimationController e não for player, tem 90% de chance de ser o Animatronic
    if v:FindFirstChild("Humanoid") or v:FindFirstChild("AnimationController") or v:FindFirstChild("HumanoidRootPart") then
        return true
    end
    
    -- Checa por nomes comuns de inimigos
    local name = string.lower(v.Name)
    if string.find(name, "animatronic") or string.find(name, "enemy") or string.find(name, "monster") or string.find(name, "killer") then
        return true
    end
    
    return false
end

-- --- LOOPS DE VERIFICAÇÃO (SCANNERS) ---

-- Scanner Lento: Itens e Animatronics (Evita lag usando GetDescendants com cuidado)
task.spawn(function()
    while true do
        if _G.ItemESP or _G.AnimatronicESP then
            -- Busca profunda no mapa
            for _, v in pairs(workspace:GetDescendants()) do
                if _G.AnimatronicESP and IsMonster(v) then
                    ApplyESP(v, Color3.fromRGB(255, 0, 0), "Monsters", v.Name)
                end
                
                if _G.ItemESP then
                    if v:IsA("Tool") or v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
                        -- Coloca o ESP no objeto pai do botão/item para brilhar
                        local parentObj = v:IsA("Tool") and v or v.Parent
                        if parentObj and parentObj:IsA("Model") or parentObj:IsA("BasePart") then
                            ApplyESP(parentObj, Color3.fromRGB(255, 215, 0), "Items", parentObj.Name)
                        end
                    end
                end
            end
        end
        task.wait(3) -- Atualiza a cada 3 segundos para não pesar o mapa
    end
end)

-- Scanner de Players
task.spawn(function()
    while true do
        if _G.PlayerESP then
            local lp = game.Players.LocalPlayer
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    ApplyESP(v.Character, Color3.fromRGB(0, 255, 0), "Players", v.Name)
                end
            end
        end
        task.wait(2)
    end
end)

-- --- LOOP PRINCIPAL: ATUALIZAÇÕES POR FRAME (Sem lag) ---
game:GetService("RunService").RenderStepped:Connect(function()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- 1. Atualizar distâncias das Tags
        for groupName, groupTable in pairs(Cache) do
            local isEnabled = (_G.AnimatronicESP and groupName == "Monsters") or (_G.PlayerESP and groupName == "Players") or (_G.ItemESP and groupName == "Items")
            
            for i, obj in pairs(groupTable) do
                if obj and obj.Parent and obj:FindFirstChild("SixTag") then
                    obj.SixESP.Enabled = isEnabled
                    obj.SixTag.Enabled = isEnabled
                    
                    if isEnabled then
                        -- Pega a posição com segurança
                        local objPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        local dist = math.floor((root.Position - objPos).Magnitude)
                        obj.SixTag.DistLabel.Text = string.format("%s\n[%dm]", obj.Name, dist)
                    end
                else
                    table.remove(groupTable, i)
                end
            end
        end
        
        -- 2. Atributos do Player (Velocidade)
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.WalkSpeed
        end
        
        -- 3. Noclip Otimizado
        if _G.Noclip then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    
    -- 4. Anti-Jumpscare (Oculta qualquer tela grande que piscar na PlayerGui)
    if _G.AntiJumpscare and lp:FindFirstChild("PlayerGui") then
        for _, gui in pairs(lp.PlayerGui:GetDescendants()) do
            if gui:IsA("ImageLabel") or gui:IsA("VideoFrame") then
                -- Se a imagem ocupar a tela toda, esconde
                if gui.Size.X.Scale >= 1 and gui.Size.Y.Scale >= 1 then
                    gui.Visible = false
                end
            end
        end
    end
    
    -- 5. Forçar Atmosfera clara (alguns jogos recriam a atmosfera a cada frame)
    if _G.SuperFullBright then
        game:GetService("Lighting").FogEnd = 100000
    end
end)

-- --- ABA 3: CONFIGURAÇÕES ---
local Tab3 = Window:NewTab("Config")
Tab3:NewSection("Atalhos"):NewKeybind("Abrir / Fechar Menu", "Aperte HOME", Enum.KeyCode.Home, function()
    Library:ToggleUI()
end)
