-- [[ SIX HUB V6 - REBORN ]]
-- Foco: Aimbot (Faca/Pistola) + ESP Completo

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Six Hub: MM2 Reborn", "BloodTheme")

-- --- VARIABLES ---
_G.Aimbot = false
_G.AimSmoothness = 0.5 
_G.FOV_Size = 100
_G.Show_FOV = false
_G.FOV_Color = Color3.fromRGB(255, 0, 0)

_G.ESP_Box = false
_G.ESP_Name = false
_G.ESP_Role = false
_G.ESP_Dist = false

_G.Speed = 16
_G.NoClip = false

-- --- TABS ---
local TabCombat = Window:NewTab("Combat")
local TabVisuals = Window:NewTab("(ESP)")
local TabMove = Window:NewTab(" (Troll)")
local TabApperance = Window:NewTab("Aparência")
local TabSettings = Window:NewTab("Config")

-- [[ COMBAT SECTION - AGORA COM MOSTRAR FOV ]]
local Combat = TabCombat:NewSection("Aimbot Master")

Combat:NewToggle("Ativar Aimbot", "Puxa na Faca e na Pistola", function(state)
    _G.Aimbot = state
end)

Combat:NewToggle("Mostrar FOV", "Ver o círculo de mira", function(state) -- ADICIONADO AQUI
    _G.Show_FOV = state
end)

Combat:NewSlider("Puxar Mira (Smoothness)", "O quanto a mira 'cola'", 100, 1, function(s)
    _G.AimSmoothness = s / 100
end)

Combat:NewSlider("Tamanho do FOV", "Área de detecção", 500, 50, function(s)
    _G.FOV_Size = s
end)

-- [[ VISUALS SECTION ]]
local Visuals = TabVisuals:NewSection("ESP MM2")
Visuals:NewToggle("ESP Box", "Caixa de destaque", function(state) _G.ESP_Box = state end)
Visuals:NewToggle("Mostrar Nomes", "Nome do Jogador", function(state) _G.ESP_Name = state end)
Visuals:NewToggle("Mostrar Cargos", "Assassino/Sheriff", function(state) _G.ESP_Role = state end)
Visuals:NewToggle("Mostrar Distância", "Distância real", function(state) _G.ESP_Dist = state end)

-- [[ MOVEMENT SECTION ]]
local Move = TabMove:NewSection("Troll & Speed")
Move:NewSlider("Velocidade", "Até 100", 100, 16, function(s) _G.Speed = s end)
Move:NewToggle("NoClip", "Atravessar paredes", function(state) _G.NoClip = state end)

-- [[ APPEARANCE SECTION ]]
local AppSection = TabApperance:NewSection("Customização")
AppSection:NewColorPicker("Cor do FOV", "Cor do círculo", Color3.fromRGB(255, 0, 0), function(color)
    _G.FOV_Color = color
end)

-- [[ SETTINGS SECTION ]]
local Settings = TabSettings:NewSection("Teclas")
Settings:NewKeybind("Minimizar Menu", "HOME para fechar/abrir", Enum.KeyCode.Home, function()
    Library:ToggleUI()
end)

-- ==========================================================
-- LOGICA DO SISTEMA (NÃO ALTERAR)
-- ==========================================================

local function GetRole(plr)
    if not plr or not plr:FindFirstChild("Backpack") then return "Innocent", Color3.new(0,1,0) end
    local char = plr.Character
    if (plr.Backpack:FindFirstChild("Knife") or (char and char:FindFirstChild("Knife"))) then
        return "MURDERER", Color3.new(1,0,0)
    elseif (plr.Backpack:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Revolver") or (char and char:FindFirstChild("Gun")) or (char and char:FindFirstChild("Revolver"))) then
        return "SHERIFF", Color3.new(0,0,1)
    end
    return "Innocent", Color3.new(0,1,0)
end

local FOVring = Drawing.new("Circle")
FOVring.Thickness = 1.5
FOVring.Filled = false
FOVring.Transparency = 1

game:GetService("RunService").RenderStepped:Connect(function()
    FOVring.Visible = _G.Show_FOV
    FOVring.Radius = _G.FOV_Size
    FOVring.Color = _G.FOV_Color
    FOVring.Position = game:GetService("UserInputService"):GetMouseLocation()

    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = _G.Speed
        if _G.NoClip then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end

    local target = nil
    local shortestDist = _G.FOV_Size

    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local head = plr.Character.Head
                local role, color = GetRole(plr)
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                local distFromMouse = (Vector2.new(pos.X, pos.Y) - FOVring.Position).Magnitude

                if onScreen and distFromMouse < shortestDist then
                    target = hrp
                    shortestDist = distFromMouse
                end

                local bill = head:FindFirstChild("SixTag")
                if not bill then
                    bill = Instance.new("BillboardGui", head)
                    bill.Name = "SixTag"; bill.AlwaysOnTop = true; bill.Size = UDim2.new(0, 200, 0, 50); bill.StudsOffset = Vector3.new(0, 3, 0)
                    local t = Instance.new("TextLabel", bill)
                    t.Name = "Text"; t.BackgroundTransparency = 1; t.Size = UDim2.new(1, 0, 1, 0)
                    t.Font = Enum.Font.SourceSansBold; t.TextSize = 14; t.TextStrokeTransparency = 0
                end
                
                local label = bill:FindFirstChild("Text")
                if label then
                    if _G.ESP_Name or _G.ESP_Role or _G.ESP_Dist then
                        label.Visible = true
                        label.TextColor3 = color
                        local content = ""
                        if _G.ESP_Name then content = content .. plr.Name .. "\n" end
                        if _G.ESP_Role then content = content .. "[" .. role .. "] " end
                        if _G.ESP_Dist then 
                            local d = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            content = content .. "(" .. d .. "m)" 
                        end
                        label.Text = content
                    else
                        label.Visible = false
                    end
                end

                local high = plr.Character:FindFirstChild("SixBox")
                if _G.ESP_Box then
                    if not high then
                        high = Instance.new("Highlight", plr.Character)
                        high.Name = "SixBox"
                    end
                    high.Enabled = true
                    high.FillColor = color
                elseif high then
                    high.Enabled = false
                end
            end
        end
    end

    if _G.Aimbot and target then
        local lChar = game.Players.LocalPlayer.Character
        if lChar:FindFirstChild("Knife") or lChar:FindFirstChild("Gun") or lChar:FindFirstChild("Revolver") then
            local cam = workspace.CurrentCamera
            local targetPos = CFrame.new(cam.CFrame.Position, target.Position)
            cam.CFrame = cam.CFrame:Lerp(targetPos, _G.AimSmoothness)
        end
    end
end)
