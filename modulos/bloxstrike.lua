-- [[ SIXCROW V9.5 | BLOXSTRIKE PRO ]]
-- Clean UI, Color Pickers RGB e Aimbot Clássico
-- Otimizado para POCO M7 / Codex / Delta

if not game:IsLoaded() then game.Loaded:Wait() end

local Config = {
    -- Combate (Lógica Clássica)
    Aimbot = false,
    AimMethod = "Mobile", 
    TargetPart = "Head",
    RequireAiming = false, -- Volta do clássico: Só atira quando clica/toca
    Prediction = true, 
    BulletSpeed = 2500,
    
    -- Filtros e FOV
    ShowFov = false,
    Fov = 150,
    FovColor = Color3.fromRGB(0, 255, 100),
    FovRainbow = false,
    Smoothness = 0.5, 
    WallCheck = true,
    TargetNPCs = true,
    MaxDistance = 2500,

    -- Visuais (ESP)
    ESP_Chams = false, 
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Tracer = false,
    ESP_Distance = false,
    ESPColor = Color3.fromRGB(0, 255, 100),
    ESPRainbow = false,

    -- Apelação
    NoClip = false,
    GodMode = false,

    -- Sistema
    MenuKeybind = Enum.KeyCode.Insert,
    ShowMobileButton = true, 
    MenuColor = Color3.fromRGB(0, 255, 100),
    SaveFileName = "SixCrow_BloxStrike_V95.json"
}

-- ========================================================================
-- SERVIÇOS CORE E GERENCIAMENTO DE TEMA
-- ========================================================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LockedTarget, IsAiming, IsBindingMenu = nil, false, false
local ActiveEntities, Highlights, Drawings = {}, {}, {}
local ThemeElements = {} 

local function AddThemeElement(instance, prop, conditional)
    table.insert(ThemeElements, {obj = instance, prop = prop, cond = conditional})
end

local function UpdateMenuColor(newColor)
    Config.MenuColor = newColor
    for _, item in pairs(ThemeElements) do
        if item.obj and item.obj.Parent then 
            if not item.cond or item.cond() then
                item.obj[item.prop] = newColor 
            end
        end
    end
end

local function RandomName() return HttpService:GenerateGUID(false):gsub("-", "") end
local function Notify(title, text) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 4}) end) end

local SafeGUI_Parent
pcall(function() SafeGUI_Parent = (gethui and gethui()) or CoreGui end)
if not SafeGUI_Parent then SafeGUI_Parent = LP:WaitForChild("PlayerGui") end

local StealthGUI = Instance.new("ScreenGui")
StealthGUI.Name = RandomName()
StealthGUI.ResetOnSpawn = false
StealthGUI.IgnoreGuiInset = true 
StealthGUI.Parent = SafeGUI_Parent

-- ========================================================================
-- INTERFACE GRÁFICA (CLEAN & PROFISSIONAL)
-- ========================================================================
local MobileBtn = Instance.new("TextButton", StealthGUI)
MobileBtn.Size, MobileBtn.Position = UDim2.new(0, 50, 0, 50), UDim2.new(0, 15, 0, 15)
MobileBtn.BackgroundColor3, MobileBtn.Text = Color3.fromRGB(20, 20, 20), "SC"
MobileBtn.TextColor3, MobileBtn.Font, MobileBtn.TextSize = Config.MenuColor, Enum.Font.GothamBold, 20
MobileBtn.Visible, MobileBtn.Active, MobileBtn.Draggable = Config.ShowMobileButton, true, true 
Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(1, 0)
local mBtnStroke = Instance.new("UIStroke", MobileBtn)
mBtnStroke.Color, mBtnStroke.Thickness = Config.MenuColor, 2
AddThemeElement(MobileBtn, "TextColor3")
AddThemeElement(mBtnStroke, "Color")

local FOVFrame = Instance.new("Frame", StealthGUI)
FOVFrame.BackgroundTransparency, FOVFrame.AnchorPoint = 1, Vector2.new(0.5, 0.5) 
FOVFrame.Position, FOVFrame.Size = UDim2.new(0.5, 0, 0.5, 0), UDim2.new(0, Config.Fov * 2, 0, Config.Fov * 2)
FOVFrame.Visible = Config.ShowFov
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0) 
local fovStroke = Instance.new("UIStroke", FOVFrame)
fovStroke.Color, fovStroke.Thickness, fovStroke.Transparency = Config.FovColor, 1.2, 0.5

local MainFrame = Instance.new("Frame", StealthGUI)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 360, 0, 480), UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3, MainFrame.BorderSizePixel, MainFrame.Active = Color3.fromRGB(18, 18, 18), 0, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(40, 40, 40)

MobileBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size, TitleBar.BackgroundColor3 = UDim2.new(1, 0, 0, 40), Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 6)
local fix = Instance.new("Frame", TitleBar)
fix.Size, fix.Position, fix.BackgroundColor3, fix.BorderSizePixel = UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 1, -6), Color3.fromRGB(22, 22, 22), 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size, Title.Position, Title.BackgroundTransparency = UDim2.new(1, -20, 1, 0), UDim2.new(0, 15, 0, 0), 1
Title.Text, Title.TextColor3, Title.Font, Title.TextSize = "SIXCROW | BLOXSTRIKE", Config.MenuColor, Enum.Font.GothamBold, 13
Title.TextXAlignment = Enum.TextXAlignment.Left
AddThemeElement(Title, "TextColor3")

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

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size, TabBar.Position, TabBar.BackgroundColor3 = UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 40), Color3.fromRGB(15, 15, 15)
local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection, TabListLayout.SortOrder = Enum.FillDirection.Horizontal, Enum.SortOrder.LayoutOrder

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size, ContentContainer.Position, ContentContainer.BackgroundTransparency = UDim2.new(1, 0, 1, -75), UDim2.new(0, 0, 0, 75), 1

local Tabs, CurrentTab = {}, nil

-- ========================================================================
-- COMPONENTES DA UI (Com visual Flat/Limpo)
-- ========================================================================
local function CreateTab(name, layoutOrder)
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Size, TabBtn.BackgroundColor3, TabBtn.Text = UDim2.new(1/4, 0, 1, 0), Color3.fromRGB(15, 15, 15), name
    TabBtn.TextColor3, TabBtn.Font, TabBtn.TextSize, TabBtn.LayoutOrder = Color3.fromRGB(130, 130, 130), Enum.Font.GothamSemibold, 11, layoutOrder

    local ScrollFrame = Instance.new("ScrollingFrame", ContentContainer)
    ScrollFrame.Size, ScrollFrame.BackgroundTransparency, ScrollFrame.ScrollBarThickness = UDim2.new(1, 0, 1, 0), 1, 3
    ScrollFrame.ScrollBarImageColor3, ScrollFrame.CanvasSize = Config.MenuColor, UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize, ScrollFrame.Visible = Enum.AutomaticSize.Y, false
    AddThemeElement(ScrollFrame, "ScrollBarImageColor3")

    local uiList = Instance.new("UIListLayout", ScrollFrame)
    uiList.Padding, uiList.HorizontalAlignment, uiList.SortOrder = UDim.new(0, 6), Enum.HorizontalAlignment.Center, Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", ScrollFrame).PaddingTop = UDim.new(0, 10)
    Instance.new("UIPadding", ScrollFrame).PaddingBottom = UDim.new(0, 15)

    TabBtn.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Btn.TextColor3, CurrentTab.Btn.BackgroundColor3, CurrentTab.Scroll.Visible = Color3.fromRGB(130, 130, 130), Color3.fromRGB(15, 15, 15), false
        end
        TabBtn.TextColor3, TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255), Color3.fromRGB(25, 25, 25)
        ScrollFrame.Visible, CurrentTab = true, {Btn = TabBtn, Scroll = ScrollFrame}
    end)
    table.insert(Tabs, {Btn = TabBtn, Scroll = ScrollFrame})
    return ScrollFrame
end

local function CreateSubCategory(parent, text)
    local Lbl = Instance.new("TextLabel", parent)
    Lbl.Size, Lbl.BackgroundTransparency, Lbl.Text = UDim2.new(0.9, 0, 0, 20), 1, text
    Lbl.TextColor3, Lbl.Font, Lbl.TextSize = Color3.fromRGB(180, 180, 180), Enum.Font.GothamSemibold, 11
    Lbl.TextXAlignment, Lbl.LayoutOrder = Enum.TextXAlignment.Left, #parent:GetChildren()
end

local function CreateToggle(parent, name, key, cb)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size, Btn.BackgroundColor3, Btn.Text = UDim2.new(0.9, 0, 0, 34), Color3.fromRGB(24, 24, 24), "   " .. name
    Btn.TextColor3 = Config[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Btn.Font, Btn.TextSize, Btn.TextXAlignment, Btn.LayoutOrder = Enum.Font.Gotham, 12, Enum.TextXAlignment.Left, #parent:GetChildren()
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local btnStroke = Instance.new("UIStroke", Btn)
    btnStroke.Color = Config[key] and Config.MenuColor or Color3.fromRGB(45, 45, 45)

    local Status = Instance.new("TextLabel", Btn)
    Status.Size, Status.Position, Status.BackgroundTransparency = UDim2.new(0, 40, 1, 0), UDim2.new(1, -45, 0, 0), 1
    Status.Text, Status.Font, Status.TextSize = Config[key] and "ON" or "OFF", Enum.Font.GothamBold, 11
    Status.TextColor3 = Config[key] and Config.MenuColor or Color3.fromRGB(100, 100, 100)

    local function UpdateVisuals()
        Btn.TextColor3 = Config[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        btnStroke.Color = Config[key] and Config.MenuColor or Color3.fromRGB(45, 45, 45)
        Status.Text = Config[key] and "ON" or "OFF"
        Status.TextColor3 = Config[key] and Config.MenuColor or Color3.fromRGB(100, 100, 100)
    end

    Btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        UpdateVisuals()
        if cb then cb(Config[key]) end
    end)
    
    AddThemeElement(Status, "TextColor3", function() return Config[key] end)
    AddThemeElement(btnStroke, "Color", function() return Config[key] end)
end

local function CreateButton(parent, text, cb, color)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size, Btn.BackgroundColor3, Btn.Text = UDim2.new(0.9, 0, 0, 34), color or Color3.fromRGB(30, 30, 30), text
    Btn.TextColor3, Btn.Font, Btn.TextSize, Btn.LayoutOrder = Color3.fromRGB(220, 220, 220), Enum.Font.Gotham, 12, #parent:GetChildren()
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(50, 50, 50)
    if cb then Btn.MouseButton1Click:Connect(cb) end
    return Btn
end

local function CreateSlider(parent, name, key, min, max, isFloat)
    local Frame = Instance.new("Frame", parent)
    Frame.Size, Frame.BackgroundColor3, Frame.LayoutOrder = UDim2.new(0.9, 0, 0, 45), Color3.fromRGB(24, 24, 24), #parent:GetChildren()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(45, 45, 45)

    local Txt = Instance.new("TextLabel", Frame)
    Txt.Size, Txt.Position, Txt.BackgroundTransparency, Txt.TextXAlignment = UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 5), 1, Enum.TextXAlignment.Left
    Txt.Text, Txt.TextColor3, Txt.Font, Txt.TextSize = name .. ": " .. tostring(Config[key]), Color3.fromRGB(200, 200, 200), Enum.Font.Gotham, 11

    local BG = Instance.new("TextButton", Frame)
    BG.Size, BG.Position, BG.BackgroundColor3, BG.Text = UDim2.new(1, -20, 0, 4), UDim2.new(0, 10, 0, 30), Color3.fromRGB(15, 15, 15), ""
    Instance.new("UICorner", BG).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", BG)
    Fill.Size, Fill.BackgroundColor3 = UDim2.new((Config[key] - min) / (max - min), 0, 1, 0), Config.MenuColor
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    AddThemeElement(Fill, "BackgroundColor3")

    local drag = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        val = isFloat and (math.floor(val * 100) / 100) or math.floor(val)
        Fill.Size, Config[key], Txt.Text = UDim2.new(pos, 0, 1, 0), val, name .. ": " .. tostring(val)
    end  
    BG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true Update(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
end

-- ========================================================================
-- O SELETOR DE CORES PROFISSIONAL (RGB HUE PICKER)
-- ========================================================================
local function CreateColorPicker(parent, name, key, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size, Frame.BackgroundColor3, Frame.LayoutOrder = UDim2.new(0.9, 0, 0, 50), Color3.fromRGB(24, 24, 24), #parent:GetChildren()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(45, 45, 45)

    local Txt = Instance.new("TextLabel", Frame)
    Txt.Size, Txt.Position, Txt.BackgroundTransparency, Txt.TextXAlignment = UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 5), 1, Enum.TextXAlignment.Left
    Txt.Text, Txt.TextColor3, Txt.Font, Txt.TextSize = name, Color3.fromRGB(200, 200, 200), Enum.Font.Gotham, 11

    local Display = Instance.new("Frame", Frame)
    Display.Size, Display.Position, Display.BackgroundColor3 = UDim2.new(0, 16, 0, 16), UDim2.new(1, -26, 0, 7), Config[key]
    Instance.new("UICorner", Display).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", Display).Color = Color3.fromRGB(50, 50, 50)

    local SliderBG = Instance.new("TextButton", Frame)
    SliderBG.Size, SliderBG.Position, SliderBG.Text = UDim2.new(1, -20, 0, 8), UDim2.new(0, 10, 0, 32), ""
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
    
    local UIGradient = Instance.new("UIGradient", SliderBG)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })

    local drag = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local newColor = Color3.fromHSV(pos, 1, 1)
        Config[key] = newColor
        Display.BackgroundColor3 = newColor
        if callback then callback(newColor) end
    end
    SliderBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true Update(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
end

-- ========================================================================
-- MONTAGEM DAS ABAS
-- ========================================================================
local TabC = CreateTab("AIMBOT", 1)
local TabV = CreateTab("VISUAIS", 2)
local TabA = CreateTab("APELAÇÃO", 3) 
local TabS = CreateTab("CONFIG", 4)

Tabs[1].Btn.TextColor3, Tabs[1].Btn.BackgroundColor3, Tabs[1].Scroll.Visible, CurrentTab = Color3.fromRGB(255, 255, 255), Color3.fromRGB(25, 25, 25), true, Tabs[1]

-- ================== ABA 1: COMBATE ==================
CreateSubCategory(TabC, "MOTOR PRINCIPAL")
CreateToggle(TabC, "Ativar Aimbot", "Aimbot", function(s) if not s then LockedTarget = nil end end)

local AimMethodBtn = CreateButton(TabC, "SISTEMA: " .. (Config.AimMethod == "Mobile" and "MOBILE (CFrame)" or "PC (Mouse)"), nil)
AimMethodBtn.MouseButton1Click:Connect(function()
    Config.AimMethod = Config.AimMethod == "Mobile" and "PC" or "Mobile"
    AimMethodBtn.Text = "SISTEMA: " .. (Config.AimMethod == "Mobile" and "MOBILE (CFrame)" or "PC (Mouse)")
end)

CreateSubCategory(TabC, "CONFIGURAÇÃO DE MIRA")
local TargetPartBtn = CreateButton(TabC, "MIRA NO: " .. (Config.TargetPart == "Head" and "CABEÇA (Head)" or "PEITO (Torso)"), nil)
TargetPartBtn.MouseButton1Click:Connect(function()
    Config.TargetPart = Config.TargetPart == "Head" and "Torso" or "Head"
    TargetPartBtn.Text = "MIRA NO: " .. (Config.TargetPart == "Head" and "CABEÇA (Head)" or "PEITO (Torso)")
end)

CreateToggle(TabC, "Exigir Clique na Tela para Mirar", "RequireAiming")
CreateToggle(TabC, "Mirar em NPCs e Facções", "TargetNPCs")
CreateToggle(TabC, "Predição (Calcular Trajetória)", "Prediction")
CreateToggle(TabC, "Ocultar Alvos Atrás da Parede", "WallCheck")

CreateSubCategory(TabC, "AJUSTES FINOS")
CreateToggle(TabC, "Mostrar Circulo FOV", "ShowFov")
CreateColorPicker(TabC, "Cor do FOV", "FovColor")
CreateToggle(TabC, "Ativar FOV Rainbow", "FovRainbow")
CreateSlider(TabC, "Tamanho do FOV", "Fov", 50, 600, false)
CreateSlider(TabC, "Suavidade / Velocidade", "Smoothness", 0.01, 1.0, true)

-- ================== ABA 2: VISUAIS ==================
CreateSubCategory(TabV, "ESP GLOBAL")
CreateToggle(TabV, "Pintar Jogadores (Chams)", "ESP_Chams", function(s) if not s then for _, hl in pairs(Highlights) do hl:Destroy() end table.clear(Highlights) end end)
CreateToggle(TabV, "Caixa de Seleção (Box)", "ESP_Box")
CreateToggle(TabV, "Linhas até o alvo (Tracers)", "ESP_Tracer")
CreateToggle(TabV, "Mostrar Esqueleto (Skeleton)", "ESP_Skeleton")
CreateToggle(TabV, "Mostrar Distância", "ESP_Distance")

CreateSubCategory(TabV, "CORES DO ESP")
CreateColorPicker(TabV, "Cor Principal ESP", "ESPColor")
CreateToggle(TabV, "Ativar ESP Rainbow", "ESPRainbow")

-- ================== ABA 3: APELAÇÃO ==================
CreateSubCategory(TabA, "MODOS ROUBADOS")
CreateToggle(TabA, "God Mode (Vida Infinita / Auto-Heal)", "GodMode")
CreateToggle(TabA, "Ativar No-Clip (Atravessar Paredes)", "NoClip", function(s) Notify("No-Clip", s and "Ativado" or "Desativado") end)

-- ================== ABA 4: CONFIG ==================
CreateSubCategory(TabS, "MENU E TECLAS")
CreateColorPicker(TabS, "Cor do Tema (Geral)", "MenuColor", function(c) UpdateMenuColor(c) end)

local BindBtn = CreateButton(TabS, "Ocultar Menu: " .. Config.MenuKeybind.Name, nil)
BindBtn.MouseButton1Click:Connect(function() IsBindingMenu, BindBtn.Text = true, "Pressione a nova tecla..." end)

UIS.InputBegan:Connect(function(input, gp)
    if IsBindingMenu and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.MenuKeybind, BindBtn.Text, IsBindingMenu = input.KeyCode, "Ocultar Menu: " .. input.KeyCode.Name, false
        Notify("Configuração", "Tecla alterada com sucesso!")
    elseif not gp and input.KeyCode == Config.MenuKeybind then
        MainFrame.Visible = not MainFrame.Visible
    end
    -- Lógica do RequireAiming Clássico
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then IsAiming = true end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        IsAiming, LockedTarget = false, nil 
    end
end)

CreateToggle(TabS, "Botão Flutuante (Mobile)", "ShowMobileButton", function(s) MobileBtn.Visible = s end)

-- ========================================================================
-- SISTEMA DINÂMICO E ESP COMPLETO
-- ========================================================================
local function AddEntity(obj)
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and (obj:FindFirstChild("Head") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")) then
        if not table.find(ActiveEntities, obj) and obj ~= LP.Character then table.insert(ActiveEntities, obj) end
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
            if Drawings[char] then 
                Drawings[char].Box:Remove() Drawings[char].Text:Remove() Drawings[char].Tracer:Remove()
                for _, line in pairs(Drawings[char].Skeleton) do line:Remove() end
                Drawings[char] = nil 
            end
        end
    end
end

local function Validate(part, char)
    if not part or not char or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local dist = (part.Position - LP.Character.HumanoidRootPart.Position).Magnitude
    if dist > Config.MaxDistance then return false end
    
    local isPlayer = Players:GetPlayerFromCharacter(char)
    if not Config.TargetNPCs and not isPlayer then return false end

    if Config.WallCheck then 
        local params = RaycastParams.new()
        params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, {LP.Character, char}
        local cast = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
        if cast and cast.Instance then return false end
    end
    return true
end

local skeletonConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function GetClosest()
    local target, shortest = nil, Config.Fov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, char in pairs(ActiveEntities) do
        local pName = (Config.TargetPart == "Torso" and not char:FindFirstChild("Torso")) and "UpperTorso" or Config.TargetPart
        local part = char:FindFirstChild(pName)
        if part and Validate(part, char) then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < shortest then shortest, target = mag, part end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        Camera = workspace.CurrentCamera
        local rainbowHue = Color3.fromHSV(tick() % 4 / 4, 1, 1)
        local currentFovColor = Config.FovRainbow and rainbowHue or Config.FovColor
        local currentESPColor = Config.ESPRainbow and rainbowHue or Config.ESPColor

        FOVFrame.Size, FOVFrame.Visible = UDim2.new(0, Config.Fov * 2, 0, Config.Fov * 2), Config.ShowFov
        fovStroke.Color = currentFovColor
        
        CleanEntities()

        for _, char in pairs(ActiveEntities) do
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            
            if Config.ESP_Chams then
                if not Highlights[char] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency, hl.OutlineTransparency, hl.Parent = 0.5, 0, SafeGUI_Parent
                    Highlights[char] = hl
                end
                Highlights[char].Adornee, Highlights[char].FillColor, Highlights[char].OutlineColor, Highlights[char].Enabled = char, currentESPColor, currentESPColor, true
            else
                if Highlights[char] then Highlights[char].Enabled = false end
            end

            if Drawing and hrp then
                if not Drawings[char] then
                    Drawings[char] = { Box = Drawing.new("Square"), Text = Drawing.new("Text"), Tracer = Drawing.new("Line"), Skeleton = {} }
                    Drawings[char].Box.Thickness, Drawings[char].Box.Filled = 1.5, false
                    Drawings[char].Text.Size, Drawings[char].Text.Center, Drawings[char].Text.Outline = 13, true, true
                    Drawings[char].Tracer.Thickness = 1.5
                    for i = 1, #skeletonConnections do table.insert(Drawings[char].Skeleton, Drawing.new("Line")) end
                end

                local esp = Drawings[char]
                local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                
                if onS then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local h, w = 4000 / dist, (4000 / dist) * 0.6
                    
                    esp.Box.Size, esp.Box.Position, esp.Box.Color, esp.Box.Visible = Vector2.new(w, h), Vector2.new(pos.X - w/2, pos.Y - h/2), currentESPColor, Config.ESP_Box
                    esp.Text.Text, esp.Text.Position, esp.Text.Color, esp.Text.Visible = string.format("[%d M]", math.floor(dist)), Vector2.new(pos.X, pos.Y + h/2 + 5), Color3.fromRGB(255,255,255), Config.ESP_Distance
                    esp.Tracer.From, esp.Tracer.To, esp.Tracer.Color, esp.Tracer.Visible = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), Vector2.new(pos.X, pos.Y + h/2), currentESPColor, Config.ESP_Tracer

                    for i, conn in ipairs(skeletonConnections) do
                        local partA, partB = char:FindFirstChild(conn[1]), char:FindFirstChild(conn[2])
                        if Config.ESP_Skeleton and partA and partB then
                            local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                            local posB, visB = Camera:WorldToViewportPoint(partB.Position)
                            if visA or visB then
                                esp.Skeleton[i].Thickness = 1.5
                                esp.Skeleton[i].From, esp.Skeleton[i].To, esp.Skeleton[i].Color, esp.Skeleton[i].Visible = Vector2.new(posA.X, posA.Y), Vector2.new(posB.X, posB.Y), currentESPColor, true
                            else esp.Skeleton[i].Visible = false end
                        else esp.Skeleton[i].Visible = false end
                    end
                else
                    esp.Box.Visible, esp.Text.Visible, esp.Tracer.Visible = false, false, false
                    for _, line in pairs(esp.Skeleton) do line.Visible = false end
                end
            end
        end

        -- LÓGICA DO AIMBOT CLÁSSICO
        local canAim = Config.Aimbot
        if Config.RequireAiming and not IsAiming then canAim = false; LockedTarget = nil end

        if canAim then
            if not LockedTarget or not Validate(LockedTarget, LockedTarget.Parent) then LockedTarget = GetClosest() end
            
            if LockedTarget then
                local aimPosition = LockedTarget.Position
                if Config.Prediction and LockedTarget.Parent:FindFirstChild("HumanoidRootPart") then
                    local velocity = LockedTarget.Parent.HumanoidRootPart.AssemblyLinearVelocity
                    aimPosition = aimPosition + (velocity * ((Camera.CFrame.Position - aimPosition).Magnitude / Config.BulletSpeed)) 
                end

                local pos, onScreen = Camera:WorldToViewportPoint(aimPosition)
                if onScreen then
                    if Config.AimMethod == "Mobile" then
                        local newCFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
                        Camera.CFrame = Config.Smoothness >= 1 and newCFrame or Camera.CFrame:Lerp(newCFrame, Config.Smoothness)
                    elseif Config.AimMethod == "PC" and mousemoverel then
                        mousemoverel(((pos.X - (Camera.ViewportSize.X/2)) / 2) * Config.Smoothness, ((pos.Y - (Camera.ViewportSize.Y/2)) / 2) * Config.Smoothness)
                    end
                end
            end
        end
    end)
end)

-- LÓGICA DO NO-CLIP E GOD MODE
RunService.Stepped:Connect(function()
    if LP.Character then
        if Config.GodMode and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health = LP.Character.Humanoid.MaxHealth end
        if Config.NoClip then
            for _, part in pairs(LP.Character:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end
        end
    end
end)

UpdateMenuColor(Config.MenuColor)
Notify("SIXCROW", "BloxStrike Pro Carregado! UI Clean + RGB Ativo.")
