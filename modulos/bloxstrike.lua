-- [[ GGPVP | BY DNLL & SIX V 8.0 - BHRM5 APEX (UI REWORK) ]]
-- Motor Robusto, ESP Infinito e UI Mega Intuitiva (PC/Mobile)
-- Otimizado para POCO M7 / Codex / Delta

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Config = {
    -- Combate
    Aimbot = false,
    AimMethod = "Mobile", -- "Mobile" (CFrame) ou "PC" (Mousemoverel)
    TargetPart = "Head", -- "Head" ou "Torso"
    RequireAiming = false, -- Agora vem DESLIGADO por padrão (Auto-Lock ativo)
    Prediction = true, 
    BulletSpeed = 2500,
    
    -- Filtros e FOV
    ShowFov = false,
    Fov = 150,
    Smoothness = 0.5, 
    WallCheck = true,
    TargetNPCs = true,
    MaxDistance = 2500,

    -- Visuais
    ESP_Chams = false, 
    EnemyColor = Color3.fromRGB(200, 50, 255), -- Roxo apelação
    ESP_Box = false,
    ESP_Distance = false,
    BoxColor = Color3.fromRGB(255, 255, 255),

    -- Apelação [NOVO]
    NoClip = false,

    -- Sistema
    MenuKeybind = Enum.KeyCode.Insert,
    ShowMobileButton = true, 
    SaveFileName = "GGPVP_BHRM5_V8.json"
}

-- ========================================================================
-- SERVIÇOS CORE E SAVE SYSTEM
-- ========================================================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LockedTarget = nil 
local IsAiming = false 
local IsBindingMenu = false
local ActiveEntities = {} 
local Highlights = {}
local Drawings = {}

local function RandomName() return HttpService:GenerateGUID(false):gsub("-", "") end

local function Notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
end

local function SaveConfig()
    if writefile then
        pcall(function()
            local json = HttpService:JSONEncode(Config)
            writefile(Config.SaveFileName, json)
            Notify("GGPVP", "Configurações Salvas!")
        end)
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(Config.SaveFileName) then
        pcall(function()
            local json = readfile(Config.SaveFileName)
            local decoded = HttpService:JSONDecode(json)
            for k, v in pairs(decoded) do
                if Config[k] ~= nil then Config[k] = v end
            end
        end)
    end
end
LoadConfig()

local SafeGUI_Parent
pcall(function() SafeGUI_Parent = (gethui and gethui()) or CoreGui end)
if not SafeGUI_Parent then SafeGUI_Parent = LP:WaitForChild("PlayerGui") end

local StealthGUI = Instance.new("ScreenGui")
StealthGUI.Name = RandomName()
StealthGUI.ResetOnSpawn = false
StealthGUI.IgnoreGuiInset = true 
StealthGUI.Parent = SafeGUI_Parent

-- ========================================================================
-- INTERFACE GRÁFICA (UI ROBUSTA E BELEZA)
-- ========================================================================

-- BOTÃO MOBILE
local MobileBtn = Instance.new("TextButton", StealthGUI)
MobileBtn.Size = UDim2.new(0, 50, 0, 50)
MobileBtn.Position = UDim2.new(0, 15, 0, 15)
MobileBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MobileBtn.Text = "GG"
MobileBtn.TextColor3 = Color3.fromRGB(200, 50, 255)
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.TextSize = 22
MobileBtn.Visible = Config.ShowMobileButton
MobileBtn.Active = true
MobileBtn.Draggable = true 
Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MobileBtn).Color = Color3.fromRGB(200, 50, 255)
Instance.new("UIStroke", MobileBtn).Thickness = 2

-- FOV VISUAL
local FOVFrame = Instance.new("Frame", StealthGUI)
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Config.Fov * 2, 0, Config.Fov * 2)
FOVFrame.Visible = Config.ShowFov
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0) 
local fovStroke = Instance.new("UIStroke", FOVFrame)
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.2
fovStroke.Transparency = 0.5

-- FRAME PRINCIPAL
local MainFrame = Instance.new("Frame", StealthGUI)
MainFrame.Size = UDim2.new(0, 350, 0, 480)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 50, 50)
Instance.new("UIStroke", MainFrame).Thickness = 1

MobileBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- BARRA DE TÍTULO
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)
local fix = Instance.new("Frame", TitleBar)
fix.Size = UDim2.new(1, 0, 0, 8)
fix.Position = UDim2.new(0, 0, 1, -8)
fix.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
fix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GGPVP V8 | MILSIM PREDATOR"
Title.TextColor3 = Color3.fromRGB(200, 50, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ARRASTAR MENU
local dragging, startPos, startMousePos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, startPos, startMousePos = true, MainFrame.Position, Vector2.new(input.Position.X, input.Position.Y)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - startMousePos
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- BARRA DE ABAS
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- CONTAINER DE CONTEÚDO
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, 0, 1, -85)
ContentContainer.Position = UDim2.new(0, 0, 0, 85)
ContentContainer.BackgroundTransparency = 1

local Tabs, CurrentTab = {}, nil

-- ========================================================================
-- FUNÇÕES DE CRIAÇÃO UI
-- ========================================================================
local function CreateTab(name, layoutOrder)
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Size = UDim2.new(1/4, 0, 1, 0) -- Ajustado para caber 4 abas perfeitamente
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.LayoutOrder = layoutOrder

    local ScrollFrame = Instance.new("ScrollingFrame", ContentContainer)
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 255)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Visible = false

    local uiList = Instance.new("UIListLayout", ScrollFrame)
    uiList.Padding = UDim.new(0, 8)
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", ScrollFrame).PaddingTop = UDim.new(0, 10)
    Instance.new("UIPadding", ScrollFrame).PaddingBottom = UDim.new(0, 15)

    TabBtn.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            CurrentTab.Scroll.Visible = false
        end
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ScrollFrame.Visible = true
        CurrentTab = {Btn = TabBtn, Scroll = ScrollFrame}
    end)
    table.insert(Tabs, {Btn = TabBtn, Scroll = ScrollFrame})
    return ScrollFrame
end

local function CreateSubCategory(parent, text)
    local Lbl = Instance.new("TextLabel", parent)
    Lbl.Size = UDim2.new(0.9, 0, 0, 25)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "■ " .. text
    Lbl.TextColor3 = Color3.fromRGB(200, 50, 255)
    Lbl.Font = Enum.Font.GothamBlack
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function CreateToggle(parent, name, key, cb)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(0.9, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = "  " .. name
    Btn.TextColor3 = Config[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Btn).Color = Config[key] and Color3.fromRGB(200, 50, 255) or Color3.fromRGB(50, 50, 50)

    local Status = Instance.new("TextLabel", Btn)
    Status.Size = UDim2.new(0, 50, 1, 0)
    Status.Position = UDim2.new(1, -55, 0, 0)
    Status.BackgroundTransparency = 1
    Status.Text = Config[key] and "ON" or "OFF"
    Status.TextColor3 = Config[key] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 13

    Btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        Btn.TextColor3 = Config[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        Btn.UIStroke.Color = Config[key] and Color3.fromRGB(200, 50, 255) or Color3.fromRGB(50, 50, 50)
        Status.Text = Config[key] and "ON" or "OFF"
        Status.TextColor3 = Config[key] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        if cb then cb(Config[key]) end
    end)
end

local function CreateButton(parent, text, cb, color)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size, Btn.BackgroundColor3 = UDim2.new(0.9, 0, 0, 38), color or Color3.fromRGB(40, 40, 40)
    Btn.Text, Btn.TextColor3 = text, Color3.fromRGB(255, 255, 255)
    Btn.Font, Btn.TextSize = Enum.Font.GothamBold, 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(80, 80, 80)
    Btn.MouseButton1Click:Connect(cb)
    return Btn
end

local function CreateSlider(parent, name, key, min, max, isFloat)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.9, 0, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(50, 50, 50)

    local Txt = Instance.new("TextLabel", Frame)
    Txt.Size, Txt.Position = UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 5)
    Txt.BackgroundTransparency, Txt.TextXAlignment = 1, Enum.TextXAlignment.Left
    Txt.Text = name .. ": " .. tostring(Config[key])
    Txt.TextColor3, Txt.Font, Txt.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.GothamSemibold, 12

    local BG = Instance.new("TextButton", Frame)
    BG.Size, BG.Position = UDim2.new(1, -20, 0, 6), UDim2.new(0, 10, 0, 35)
    BG.BackgroundColor3, BG.Text = Color3.fromRGB(15, 15, 15), ""
    Instance.new("UICorner", BG).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", BG)
    Fill.Size = UDim2.new((Config[key] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(200, 50, 255)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local drag = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        val = isFloat and (math.floor(val * 100) / 100) or math.floor(val)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Config[key] = val
        Txt.Text = name .. ": " .. tostring(val)
    end  
    BG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true Update(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
end

-- ========================================================================
-- MONTAGEM DAS ABAS (Onde a Mágica Acontece)
-- ========================================================================
local TabC = CreateTab("⚔️ AIMBOT", 1)
local TabV = CreateTab("👁️ VISUAIS", 2)
local TabA = CreateTab("🔥 APELAÇÃO", 3) -- [NOVA ABA ADICIONADA]
local TabS = CreateTab("⚙️ CONFIG", 4)

Tabs[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Tabs[1].Scroll.Visible = true
CurrentTab = Tabs[1]

-- ================== ABA 1: COMBATE ==================
CreateSubCategory(TabC, "MOTOR PRINCIPAL")
CreateToggle(TabC, "Ativar Aimbot", "Aimbot", function(s) if not s then LockedTarget = nil end end)

CreateButton(TabC, "SISTEMA: " .. (Config.AimMethod == "Mobile" and "MOBILE (CFrame)" or "PC (Mouse)"), function()
    Config.AimMethod = Config.AimMethod == "Mobile" and "PC" or "Mobile"
    TabC:GetChildren()[4].Text = "SISTEMA: " .. (Config.AimMethod == "Mobile" and "MOBILE (CFrame)" or "PC (Mouse)")
    Notify("Aimbot", "SISTEMA ALTERADO PARA: " .. Config.AimMethod)
end, Color3.fromRGB(80, 30, 100))

CreateSubCategory(TabC, "CONFIGURAÇÃO DE MIRA")
CreateButton(TabC, "MIRA NO: " .. (Config.TargetPart == "Head" and "CABEÇA (Head)" or "PEITO (Torso)"), function()
    Config.TargetPart = Config.TargetPart == "Head" and "Torso" or "Head"
    TabC:GetChildren()[7].Text = "MIRA NO: " .. (Config.TargetPart == "Head" and "CABEÇA (Head)" or "PEITO (Torso)")
end, Color3.fromRGB(40, 40, 40))

CreateToggle(TabC, "Exigir Clique na Tela para Mirar", "RequireAiming")
CreateToggle(TabC, "Mirar em NPCs e Facções", "TargetNPCs")
CreateToggle(TabC, "Predição (Calcular Trajetória)", "Prediction")
CreateToggle(TabC, "Ocultar Alvos Atrás da Parede", "WallCheck")

CreateSubCategory(TabC, "AJUSTES FINOS")
CreateToggle(TabC, "Mostrar Circulo FOV", "ShowFov")
CreateSlider(TabC, "Tamanho do FOV", "Fov", 50, 600, false)
CreateSlider(TabC, "Velocidade da Mira (1 = Rápido)", "Smoothness", 0.01, 1.0, true)

-- ================== ABA 2: VISUAIS ==================
CreateSubCategory(TabV, "ESP GLOBAL")
CreateToggle(TabV, "Pintar Jogadores/NPCs (Chams)", "ESP_Chams", function(s)
    if not s then for _, hl in pairs(Highlights) do hl:Destroy() end table.clear(Highlights) end
end)
CreateToggle(TabV, "Caixa de Seleção (Box)", "ESP_Box")
CreateToggle(TabV, "Mostrar Distância", "ESP_Distance")

-- ================== ABA 3: APELAÇÃO [NOVO] ==================
CreateSubCategory(TabA, "MODOS ROUBADOS")
CreateToggle(TabA, "Ativar No-Clip (Atravessar Paredes)", "NoClip", function(s)
    Notify("No-Clip", s and "Você agora é um fantasma!" or "Física Restaurada.")
end)

-- ================== ABA 4: CONFIG ==================
CreateSubCategory(TabS, "MENU E TECLAS")
local BindBtn = CreateButton(TabS, "Ocultar Menu: " .. Config.MenuKeybind.Name, function()
    IsBindingMenu = true
    TabS:GetChildren()[3].Text = "Pressione a nova tecla..."
end)

UIS.InputBegan:Connect(function(input, gp)
    if IsBindingMenu and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.MenuKeybind = input.KeyCode
        BindBtn.Text = "Ocultar Menu: " .. Config.MenuKeybind.Name
        IsBindingMenu = false
        Notify("Configuração", "Tecla alterada com sucesso!")
    elseif not gp and input.KeyCode == Config.MenuKeybind then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    -- Lógica do RequireAiming (Registra qualquer clique ou toque na tela)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        IsAiming = true 
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        IsAiming = false 
        LockedTarget = nil 
    end
end)
CreateToggle(TabS, "Botão Flutuante (Mobile)", "ShowMobileButton", function(s) MobileBtn.Visible = s end)
CreateSubCategory(TabS, "DADOS")
CreateButton(TabS, "💾 SALVAR TODAS CONFIGURAÇÕES", SaveConfig, Color3.fromRGB(50, 150, 50))

-- ========================================================================
-- SISTEMA DINÂMICO DE ENTIDADES (ESP INFINITO)
-- ========================================================================
local function AddEntity(obj)
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and (obj:FindFirstChild("Head") or obj:FindFirstChild("Torso")) then
        if not table.find(ActiveEntities, obj) and obj ~= LP.Character then
            table.insert(ActiveEntities, obj)
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do if p.Character then AddEntity(p.Character) end end
for _, obj in pairs(workspace:GetDescendants()) do AddEntity(obj) end

workspace.DescendantAdded:Connect(AddEntity)
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(AddEntity) end)

local function CleanEntities()
    for i = #ActiveEntities, 1, -1 do
        local char = ActiveEntities[i]
        if not char or not char.Parent or not char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then
            table.remove(ActiveEntities, i)
            if Highlights[char] then Highlights[char]:Destroy() Highlights[char] = nil end
            if Drawings[char] then Drawings[char].Box.Visible = false Drawings[char].Text.Visible = false Drawings[char] = nil end
        end
    end
end

-- ========================================================================
-- LÓGICA DO AIMBOT E ESP
-- ========================================================================
local function Validate(part, char)
    if not part or not char then return false end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    -- [NOVO: TRAVA DE SEGURANÇA] Impede de mirar em cadáveres ou mortos
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local dist = (part.Position - LP.Character.HumanoidRootPart.Position).Magnitude
    if dist > Config.MaxDistance then return false end
    
    local isPlayer = Players:GetPlayerFromCharacter(char)
    if isPlayer and Config.TeamCheck and LP.Team and isPlayer.Team == LP.Team then return false end
    if not Config.TargetNPCs and not isPlayer then return false end

    if Config.WallCheck then 
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LP.Character, char}
        local cast = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
        if cast and cast.Instance then return false end
    end
    return true
end

local function GetClosest()
    local target, shortest = nil, Config.Fov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, char in pairs(ActiveEntities) do
        -- Suporte dinâmico para R6 ou R15
        local partName = Config.TargetPart
        if partName == "Torso" and not char:FindFirstChild("Torso") then partName = "UpperTorso" end
        
        local part = char:FindFirstChild(partName)
        if part and Validate(part, char) then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < shortest then shortest = mag; target = part end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        Camera = workspace.CurrentCamera
        FOVFrame.Size = UDim2.new(0, Config.Fov * 2, 0, Config.Fov * 2)
        FOVFrame.Visible = Config.ShowFov
        
        CleanEntities()

        -- RENDERIZAÇÃO ESP
        for _, char in pairs(ActiveEntities) do
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            
            if Config.ESP_Chams then
                if not Highlights[char] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency, hl.OutlineTransparency = 0.5, 0
                    hl.Parent = SafeGUI_Parent
                    Highlights[char] = hl
                end
                Highlights[char].Adornee = char
                Highlights[char].FillColor = Config.EnemyColor
                Highlights[char].OutlineColor = Config.EnemyColor
                Highlights[char].Enabled = true
            else
                if Highlights[char] then Highlights[char].Enabled = false end
            end

            if Drawing and hrp then
                if not Drawings[char] then
                    Drawings[char] = {Box = Drawing.new("Square"), Text = Drawing.new("Text")}
                    Drawings[char].Box.Thickness = 1.5
                    Drawings[char].Box.Filled = false
                    Drawings[char].Text.Size, Drawings[char].Text.Center, Drawings[char].Text.Outline = 16, true, true
                end
                local esp = Drawings[char]
                local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                if onS then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local h = 4000 / dist
                    local w = h * 0.6
                    
                    if Config.ESP_Box then
                        esp.Box.Size, esp.Box.Position = Vector2.new(w, h), Vector2.new(pos.X - w/2, pos.Y - h/2)
                        esp.Box.Color, esp.Box.Visible = Config.EnemyColor, true
                    else esp.Box.Visible = false end

                    if Config.ESP_Distance then
                        esp.Text.Text, esp.Text.Position = string.format("[%d M]", math.floor(dist)), Vector2.new(pos.X, pos.Y + h/2 + 5)
                        esp.Text.Color, esp.Text.Visible = Color3.fromRGB(255,255,255), true
                    else esp.Text.Visible = false end
                else
                    esp.Box.Visible, esp.Text.Visible = false, false
                end
            end
        end

        -- LÓGICA DO AIMBOT
        local canAim = Config.Aimbot
        if Config.RequireAiming and not IsAiming then canAim = false; LockedTarget = nil end

        if canAim then
            if not LockedTarget or not Validate(LockedTarget, LockedTarget.Parent) then LockedTarget = GetClosest() end
            
            if LockedTarget then
                local aimPosition = LockedTarget.Position
                
                -- PREDIÇÃO DE MOVIMENTO (SNIPER)
                if Config.Prediction and LockedTarget.Parent:FindFirstChild("HumanoidRootPart") then
                    local velocity = LockedTarget.Parent.HumanoidRootPart.AssemblyLinearVelocity
                    local distance = (Camera.CFrame.Position - aimPosition).Magnitude
                    local timeToHit = distance / Config.BulletSpeed
                    aimPosition = aimPosition + (velocity * timeToHit) 
                end

                local pos, onScreen = Camera:WorldToViewportPoint(aimPosition)
                
                if onScreen then
                    if Config.AimMethod == "Mobile" then
                        -- CFrame Force (Codex/Mobile)
                        local newCFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
                        if Config.Smoothness >= 1 then
                            Camera.CFrame = newCFrame
                        else
                            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Config.Smoothness)
                        end
                    elseif Config.AimMethod == "PC" and mousemoverel then
                        -- Mouse Mover (Emulador/PC)
                        local div = 2 
                        local dX = ((pos.X - (Camera.ViewportSize.X/2)) / div) * Config.Smoothness
                        local dY = ((pos.Y - (Camera.ViewportSize.Y/2)) / div) * Config.Smoothness
                        mousemoverel(dX, dY)
                    end
                end
            end
        end
    end)
end)

-- ========================================================================
-- LÓGICA DO NO-CLIP (Atravessar Paredes) [NOVO]
-- ========================================================================
-- Rodando no "Stepped" ele desativa as colisões exatamente um milissegundo 
-- antes do Roblox calcular a física, deixando liso em qualquer celular.
RunService.Stepped:Connect(function()
    if Config.NoClip and LP.Character then
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

Notify("GGPVP PREDATOR", "Aimbot Otimizado + NO-CLIP ATIVO! Interface V8 Carregada.")
