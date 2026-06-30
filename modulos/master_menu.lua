if not game:IsLoaded() then game.Loaded:Wait() end

--global

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local Mouse = LP:GetMouse()

--gbl

local GGPVP = {
    -- COMBATE
    Aimbot = {
        Enabled = false,
        Keybind = Enum.UserInputType.MouseButton2, 
        TargetPart = "Head",
        Smoothness = 0.5,
        MaxDist = 1500,
        WallCheck = true,
        CheckAlive = true,
        PredictMovement = false,
        PredictionVelocity = 0.165,
        Deadzone = 5 -- Evita a tela tremer
    },
    Recoil = {
        Enabled = false,
        Intensity = 0.5,
        Shake = false
    },
    TriggerBot = {
        Enabled = false,
        Delay = 0.05,
        Distance = 500
    },
    FOV = {
        Enabled = true,
        Radius = 150,
        Color = Color3.fromRGB(255, 50, 50),
        Rainbow = false
    },
    -- visual
    ESP = {
        Master = false,
        Boxes = false,
        BoxType = "Corner",
        Names = false,
        HealthBar = false,
        Distance = false,
        Tracers = false,
        TracerOrigin = "Bottom",
        Color = Color3.fromRGB(255, 255, 255),
        Rainbow = false
    },
    Radar = {
        Enabled = false,
        Scale = 1,
        Radius = 100,
        BlipColor = Color3.fromRGB(255, 0, 0)
    },
    Crosshair = {
        Enabled = false,
        Size = 10,
        Gap = 3,
        Color = Color3.fromRGB(255, 0, 0)
    },
    -- movimento
    Movement = {
        SpeedEnabled = false,
        Speed = 16,
        FlyEnabled = false,
        FlySpeed = 50,
        Noclip = false,
        InfJump = false
    },
    -- UI
    UI = {
        Keybind = Enum.KeyCode.RightShift,
        ThemeColor = Color3.fromRGB(220, 20, 60), 
        BgColor = Color3.fromRGB(15, 15, 15),
        AccentColor = Color3.fromRGB(25, 25, 25),
        TextColor = Color3.fromRGB(240, 240, 240)
    }
}

local LockedTarget = nil
local IsAiming = false
local IsShooting = false
local ESP_Table = {}
local Radar_Table = {}

--funçao

local function GetRainbow(speed)
    return Color3.fromHSV((tick() * (speed or 0.5)) % 1, 1, 1)
end

local function CreateTween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

--motor

local Library = {}
local ActiveTab = nil

function Library:CreateWindow(titleText)
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "GGPVP_BLACK_EDITION" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GGPVP_BLACK_EDITION"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = GGPVP.UI.BgColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = GGPVP.UI.ThemeColor
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.2
    UIStroke.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = GGPVP.UI.AccentColor
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    local TopFix = Instance.new("Frame")
    TopFix.Size = UDim2.new(1, 0, 0, 10)
    TopFix.Position = UDim2.new(0, 0, 1, -10)
    TopFix.BackgroundColor3 = GGPVP.UI.AccentColor
    TopFix.BorderSizePixel = 0
    TopFix.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = GGPVP.UI.ThemeColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local Watermark = Instance.new("TextLabel")
    Watermark.Size = UDim2.new(0, 150, 1, 0)
    Watermark.Position = UDim2.new(1, -160, 0, 0)
    Watermark.BackgroundTransparency = 1
    Watermark.Text = "FPS: 60 | PING: 0ms"
    Watermark.TextColor3 = Color3.fromRGB(150, 150, 150)
    Watermark.Font = Enum.Font.GothamSemibold
    Watermark.TextSize = 12
    Watermark.TextXAlignment = Enum.TextXAlignment.Right
    Watermark.Parent = TopBar

    task.spawn(function()
        while task.wait(1) do
            local ping = tonumber(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+"))
            local fps = math.floor(workspace:GetRealPhysicsFPS())
            Watermark.Text = "FPS: " .. tostring(fps) .. " | PING: " .. tostring(ping) .. "ms"
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 2)
    SidebarLayout.Parent = Sidebar

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -140, 1, -40)
    Container.Position = UDim2.new(0, 140, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == GGPVP.UI.Keybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local WindowObj = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Sidebar = Sidebar,
        Container = Container
    }

    function WindowObj:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName.."_Btn"
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar

        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator" 
        Indicator.Size = UDim2.new(0, 3, 1, 0)
        Indicator.BackgroundColor3 = GGPVP.UI.ThemeColor
        Indicator.BorderSizePixel = 0
        Indicator.BackgroundTransparency = 1
        Indicator.Parent = TabBtn

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = tabName.."_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = GGPVP.UI.ThemeColor
        TabPage.Visible = false
        TabPage.Parent = Container

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.Parent = TabPage

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.Parent = TabPage

        TabBtn.MouseButton1Click:Connect(function()
            if ActiveTab then
                CreateTween(ActiveTab.Btn, {TextColor3 = Color3.fromRGB(180, 180, 180)})
                CreateTween(ActiveTab.Indicator, {BackgroundTransparency = 1})
                ActiveTab.Page.Visible = false
            end
            CreateTween(TabBtn, {TextColor3 = GGPVP.UI.ThemeColor})
            CreateTween(Indicator, {BackgroundTransparency = 0})
            TabPage.Visible = true
            ActiveTab = {Btn = TabBtn, Page = TabPage, Indicator = Indicator}
        end)

        if not ActiveTab then
            TabBtn.TextColor3 = GGPVP.UI.ThemeColor
            Indicator.BackgroundTransparency = 0
            TabPage.Visible = true
            ActiveTab = {Btn = TabBtn, Page = TabPage, Indicator = Indicator}
        end

        local TabObj = {}

        function TabObj:CreateSection(sectionName)
            local Sec = Instance.new("TextLabel")
            Sec.Size = UDim2.new(0.95, 0, 0, 25)
            Sec.BackgroundTransparency = 1
            Sec.Text = sectionName
            Sec.TextColor3 = GGPVP.UI.ThemeColor
            Sec.Font = Enum.Font.GothamBold
            Sec.TextSize = 12
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.Parent = TabPage
        end

        function TabObj:CreateToggle(toggleName, defaultState, callback)
            local state = defaultState or false
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(0.95, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = GGPVP.UI.AccentColor
            ToggleFrame.Parent = TabPage
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleName
            Label.TextColor3 = GGPVP.UI.TextColor
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local SwitchBG = Instance.new("Frame")
            SwitchBG.Size = UDim2.new(0, 36, 0, 18)
            SwitchBG.Position = UDim2.new(1, -46, 0.5, -9)
            SwitchBG.BackgroundColor3 = state and GGPVP.UI.ThemeColor or Color3.fromRGB(40, 40, 40)
            SwitchBG.Parent = ToggleFrame
            Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = SwitchBG
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = ToggleFrame

            Btn.MouseButton1Click:Connect(function()
                state = not state
                CreateTween(SwitchBG, {BackgroundColor3 = state and GGPVP.UI.ThemeColor or Color3.fromRGB(40, 40, 40)})
                CreateTween(Circle, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                if callback then callback(state) end
            end)
            if callback then callback(state) end
        end

        function TabObj:CreateSlider(sliderName, min, max, default, callback)
            local value = default or min
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(0.95, 0, 0, 50)
            SliderFrame.BackgroundColor3 = GGPVP.UI.AccentColor
            SliderFrame.Parent = TabPage
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 0, 25)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = sliderName
            Label.TextColor3 = GGPVP.UI.TextColor
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.5, -10, 0, 25)
            ValLabel.Position = UDim2.new(0.5, 0, 0, 0)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(value)
            ValLabel.TextColor3 = GGPVP.UI.ThemeColor
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 13
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = SliderFrame

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -20, 0, 6)
            Track.Position = UDim2.new(0, 10, 0, 32)
            Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Track.Parent = SliderFrame
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            local pct = (value - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            Fill.BackgroundColor3 = GGPVP.UI.ThemeColor
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Track

            local dragging = false
            local function Update(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(min + ((max - min) * pos))
                CreateTween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                ValLabel.Text = tostring(newVal)
                if callback then callback(newVal) end
            end

            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true; Update(input)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
            end)
            if callback then callback(value) end
        end

        function TabObj:CreateDropdown(dropName, options, default, callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(0.95, 0, 0, 35)
            DropFrame.BackgroundColor3 = GGPVP.UI.AccentColor
            DropFrame.Parent = TabPage
            DropFrame.ClipsDescendants = true
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 0, 35)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = dropName
            Label.TextColor3 = GGPVP.UI.TextColor
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropFrame

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.5, -30, 0, 35)
            SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = default or options[1]
            SelectedLabel.TextColor3 = GGPVP.UI.ThemeColor
            SelectedLabel.Font = Enum.Font.GothamBold
            SelectedLabel.TextSize = 12
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.Parent = DropFrame

            local Icon = Instance.new("TextLabel")
            Icon.Size = UDim2.new(0, 20, 0, 35)
            Icon.Position = UDim2.new(1, -25, 0, 0)
            Icon.BackgroundTransparency = 1
            Icon.Text = "▼"
            Icon.TextColor3 = Color3.fromRGB(150, 150, 150)
            Icon.Font = Enum.Font.GothamBold
            Icon.TextSize = 10
            Icon.Parent = DropFrame

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = DropFrame

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, #options * 30)
            Container.Position = UDim2.new(0, 0, 0, 35)
            Container.BackgroundTransparency = 1
            Container.Parent = DropFrame

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = Container

            local isOpen = false
            Btn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                CreateTween(DropFrame, {Size = isOpen and UDim2.new(0.95, 0, 0, 35 + (#options * 30)) or UDim2.new(0.95, 0, 0, 35)})
                Icon.Text = isOpen and "▲" or "▼"
            end)

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 30)
                OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                OptBtn.BorderSizePixel = 0
                OptBtn.Text = opt
                OptBtn.TextColor3 = GGPVP.UI.TextColor
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                OptBtn.Parent = Container

                OptBtn.MouseButton1Click:Connect(function()
                    SelectedLabel.Text = opt
                    isOpen = false
                    CreateTween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 35)})
                    Icon.Text = "▼"
                    if callback then callback(opt) end
                end)
            end
            if callback then callback(default or options[1]) end
        end

        return TabObj
    end

    function WindowObj:Notify(title, text)
        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.new(0, 250, 0, 60)
        Notif.Position = UDim2.new(1, 10, 1, -80)
        Notif.BackgroundColor3 = GGPVP.UI.AccentColor
        Notif.Parent = ScreenGui
        Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 6)
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = GGPVP.UI.ThemeColor
        Stroke.Thickness = 1
        Stroke.Parent = Notif

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(1, -10, 0, 20)
        T.Position = UDim2.new(0, 10, 0, 5)
        T.BackgroundTransparency = 1
        T.Text = title
        T.TextColor3 = GGPVP.UI.ThemeColor
        T.Font = Enum.Font.GothamBold
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = Notif

        local D = Instance.new("TextLabel")
        D.Size = UDim2.new(1, -10, 0, 30)
        D.Position = UDim2.new(0, 10, 0, 25)
        D.BackgroundTransparency = 1
        D.Text = text
        D.TextColor3 = GGPVP.UI.TextColor
        D.Font = Enum.Font.Gotham
        D.TextSize = 12
        D.TextXAlignment = Enum.TextXAlignment.Left
        D.TextWrapped = true
        D.Parent = Notif

        CreateTween(Notif, {Position = UDim2.new(1, -260, 1, -80)}, 0.4)
        task.delay(4, function()
            local tw = CreateTween(Notif, {Position = UDim2.new(1, 10, 1, -80)}, 0.4)
            tw.Completed:Wait()
            Notif:Destroy()
        end)
    end

    return WindowObj
end

--interface

local GUI = Library:CreateWindow("GGPVP V2 | BLACK EDITION")

local TabCombat = GUI:CreateTab("Combate")
local TabVisuals = GUI:CreateTab("Visuais")
local TabRadar = GUI:CreateTab("Radar & UI")
local TabMovement = GUI:CreateTab("Movimento")

-- ABA COMBATE
TabCombat:CreateSection("Assistência de Mira (Aimbot)")
TabCombat:CreateToggle("Ativar Aimbot", false, function(v) GGPVP.Aimbot.Enabled = v; LockedTarget = nil end)
TabCombat:CreateDropdown("Botão do Aimbot", {"Mouse2 (Direito)", "Mouse1 (Esquerdo)"}, "Mouse2 (Direito)", function(v)
    if v == "Mouse2 (Direito)" then
        GGPVP.Aimbot.Keybind = Enum.UserInputType.MouseButton2
    else
        GGPVP.Aimbot.Keybind = Enum.UserInputType.MouseButton1
    end
end)
TabCombat:CreateDropdown("Parte do Corpo", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v) GGPVP.Aimbot.TargetPart = v end)
TabCombat:CreateToggle("Checar Paredes (WallCheck)", true, function(v) GGPVP.Aimbot.WallCheck = v end)
TabCombat:CreateSlider("Suavidade da Mira (Smooth)", 1, 100, 50, function(v) GGPVP.Aimbot.Smoothness = v / 100 end)
TabCombat:CreateToggle("Previsão de Movimento", false, function(v) GGPVP.Aimbot.PredictMovement = v end)

TabCombat:CreateSection("Controle de Recuo (Anti-Recoil Câmera)")
TabCombat:CreateToggle("Ativar Compensador", false, function(v) GGPVP.Recoil.Enabled = v end)
TabCombat:CreateSlider("Intensidade do Recuo", 1, 100, 20, function(v) GGPVP.Recoil.Intensity = v / 100 end)

TabCombat:CreateSection("TriggerBot (Atirar Sozinho)")
TabCombat:CreateToggle("Ativar TriggerBot", false, function(v) GGPVP.TriggerBot.Enabled = v end)
TabCombat:CreateSlider("Delay de Disparo", 0, 100, 5, function(v) GGPVP.TriggerBot.Delay = v / 100 end)

-- ABA VISUAIS
TabVisuals:CreateSection("ESP Mestre")
TabVisuals:CreateToggle("Ativar ESP", false, function(v) GGPVP.ESP.Master = v end)
TabVisuals:CreateDropdown("Estilo da Caixa", {"Corner", "Full"}, "Corner", function(v) GGPVP.ESP.BoxType = v end)
TabVisuals:CreateToggle("Mostrar Caixas", false, function(v) GGPVP.ESP.Boxes = v end)
TabVisuals:CreateToggle("Mostrar Barra de Vida", false, function(v) GGPVP.ESP.HealthBar = v end)
TabVisuals:CreateToggle("Mostrar Nomes", false, function(v) GGPVP.ESP.Names = v end)
TabVisuals:CreateToggle("Mostrar Linhas (Tracers)", false, function(v) GGPVP.ESP.Tracers = v end)
TabVisuals:CreateToggle("Modo Rainbow (ESP)", false, function(v) GGPVP.ESP.Rainbow = v end)

TabVisuals:CreateSection("Campo de Visão (FOV)")
TabVisuals:CreateToggle("Mostrar FOV", true, function(v) GGPVP.FOV.Enabled = v end)
TabVisuals:CreateSlider("Tamanho do FOV", 50, 1000, 150, function(v) GGPVP.FOV.Radius = v end)
TabVisuals:CreateToggle("Modo Rainbow (FOV)", false, function(v) GGPVP.FOV.Rainbow = v end)

-- ABA RADAR E UI
TabRadar:CreateSection("Radar 2D (Mini-Mapa)")
TabRadar:CreateToggle("Ativar Radar", false, function(v) GGPVP.Radar.Enabled = v end)
TabRadar:CreateSlider("Tamanho do Radar", 100, 300, 150, function(v) GGPVP.Radar.Radius = v end)
TabRadar:CreateSlider("Zoom do Radar", 1, 10, 3, function(v) GGPVP.Radar.Scale = v end)

TabRadar:CreateSection("Crosshair Customizada")
TabRadar:CreateToggle("Ativar Crosshair", false, function(v) GGPVP.Crosshair.Enabled = v end)
TabRadar:CreateSlider("Tamanho da Linha", 5, 30, 10, function(v) GGPVP.Crosshair.Size = v end)
TabRadar:CreateSlider("Abertura (Gap)", 0, 20, 4, function(v) GGPVP.Crosshair.Gap = v end)

-- ABA MOVIMENTO
TabMovement:CreateSection("Modificações de Velocidade")
TabMovement:CreateToggle("Ativar SpeedHack", false, function(v) GGPVP.Movement.SpeedEnabled = v end)
TabMovement:CreateSlider("Velocidade", 16, 200, 50, function(v) GGPVP.Movement.Speed = v end)

TabMovement:CreateSection("Física Extrema")
TabMovement:CreateToggle("Fly (Voo)", false, function(v) GGPVP.Movement.FlyEnabled = v end)
TabMovement:CreateToggle("Pulo Infinito", false, function(v) GGPVP.Movement.InfJump = v end)
TabMovement:CreateToggle("Noclip (Atravessar Paredes)", false, function(v) GGPVP.Movement.Noclip = v end)

--funçao 

-- FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false

-- esp linha
local CrossX = Drawing.new("Line")
local CrossY = Drawing.new("Line")
local CrossL = Drawing.new("Line")
local CrossR = Drawing.new("Line")

local function UpdateCrosshair()
    if GGPVP.Crosshair.Enabled then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local c = GGPVP.Crosshair.Color
        local s = GGPVP.Crosshair.Size
        local g = GGPVP.Crosshair.Gap

        CrossX.Visible = true; CrossY.Visible = true; CrossL.Visible = true; CrossR.Visible = true
        CrossX.Color = c; CrossY.Color = c; CrossL.Color = c; CrossR.Color = c
        CrossX.Thickness = 1.5; CrossY.Thickness = 1.5; CrossL.Thickness = 1.5; CrossR.Thickness = 1.5

        CrossX.From = Vector2.new(center.X, center.Y - g)
        CrossX.To = Vector2.new(center.X, center.Y - g - s)

        CrossY.From = Vector2.new(center.X, center.Y + g)
        CrossY.To = Vector2.new(center.X, center.Y + g + s)

        CrossL.From = Vector2.new(center.X - g, center.Y)
        CrossL.To = Vector2.new(center.X - g - s, center.Y)

        CrossR.From = Vector2.new(center.X + g, center.Y)
        CrossR.To = Vector2.new(center.X + g + s, center.Y)
    else
        CrossX.Visible = false; CrossY.Visible = false; CrossL.Visible = false; CrossR.Visible = false
    end
end

-- radar
local RadarBG = Drawing.new("Square")
RadarBG.Filled = true
RadarBG.Color = Color3.fromRGB(15, 15, 15)
RadarBG.Transparency = 0.7
RadarBG.Thickness = 0

local RadarOutline = Drawing.new("Square")
RadarOutline.Filled = false
RadarOutline.Color = GGPVP.UI.ThemeColor
RadarOutline.Thickness = 2
RadarOutline.Transparency = 1

local function UpdateRadarUI()
    if GGPVP.Radar.Enabled then
        RadarBG.Visible = true; RadarOutline.Visible = true
        local s = GGPVP.Radar.Radius * 2
        local pos = Vector2.new(20, (Camera.ViewportSize.Y / 2) - GGPVP.Radar.Radius)
        
        RadarBG.Size = Vector2.new(s, s)
        RadarBG.Position = pos
        RadarOutline.Size = Vector2.new(s, s)
        RadarOutline.Position = pos
    else
        RadarBG.Visible = false; RadarOutline.Visible = false
    end
end

--combate aimbot


local function ValidateTarget(part)
    if not part or not part.Parent then return false end
    local char = part.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not root or not hum or hum.Health <= 0 then return false end
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = LP.Character.HumanoidRootPart
        if (root.Position - myRoot.Position).Magnitude > GGPVP.Aimbot.MaxDist then return false end
    end
    
    if GGPVP.Aimbot.WallCheck then 
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LP.Character, char}
        params.IgnoreWater = true
        local cast = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
        if cast then return false end
    end
    return true
end

local function GetClosestTarget()
    local target, shortest = nil, GGPVP.FOV.Radius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(GGPVP.Aimbot.TargetPart) then
            local part = v.Character[GGPVP.Aimbot.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and ValidateTarget(part) then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < shortest then 
                    shortest = mag
                    target = part 
                end
            end
        end
    end
    return target
end

--ESP

local function CreateESP(player)
    ESP_Table[player] = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Line1 = Drawing.new("Line"), Line2 = Drawing.new("Line"),
        Line3 = Drawing.new("Line"), Line4 = Drawing.new("Line"),
        Line5 = Drawing.new("Line"), Line6 = Drawing.new("Line"),
        Line7 = Drawing.new("Line"), Line8 = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        HealthBG = Drawing.new("Square"),
        Health = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    
    local e = ESP_Table[player]
    e.BoxOutline.Thickness = 2.5; e.BoxOutline.Filled = false; e.BoxOutline.Color = Color3.new(0,0,0)
    e.Box.Thickness = 1; e.Box.Filled = false
    e.Name.Center = true; e.Name.Outline = true; e.Name.Size = 13
    e.Dist.Center = true; e.Dist.Outline = true; e.Dist.Size = 12
    e.HealthBG.Filled = true; e.HealthBG.Color = Color3.new(0,0,0)
    e.Health.Filled = true
    e.Tracer.Thickness = 1.5
    
    for i = 1, 8 do
        e["Line"..i].Thickness = 1.5
    end
end

local function RemoveESP(player)
    if ESP_Table[player] then
        for _, v in pairs(ESP_Table[player]) do v:Remove() end
        ESP_Table[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESP)

local function UpdateESP()
    local rainbow = GetRainbow()
    local color = GGPVP.ESP.Rainbow and rainbow or GGPVP.ESP.Color
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if not ESP_Table[p] then CreateESP(p) end
            local e = ESP_Table[p]
            local char = p.Character
            
            if GGPVP.ESP.Master and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local root = char.HumanoidRootPart
                local hum = char.Humanoid
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen and hum.Health > 0 then
                    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
                    
                    local H = Camera.ViewportSize.Y / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 2.5
                    local W = H * 0.6
                    local X, Y = pos.X - W/2, pos.Y - H/2
                    
                    if GGPVP.ESP.Boxes and GGPVP.ESP.BoxType == "Full" then
                        e.BoxOutline.Visible = true; e.Box.Visible = true
                        e.BoxOutline.Size = Vector2.new(W, H); e.BoxOutline.Position = Vector2.new(X, Y)
                        e.Box.Size = Vector2.new(W, H); e.Box.Position = Vector2.new(X, Y)
                        e.Box.Color = color
                        for i=1,8 do e["Line"..i].Visible = false end
                    elseif GGPVP.ESP.Boxes and GGPVP.ESP.BoxType == "Corner" then
                        e.BoxOutline.Visible = false; e.Box.Visible = false
                        local L = W / 3
                        e.Line1.Visible = true; e.Line1.From = Vector2.new(X, Y); e.Line1.To = Vector2.new(X + L, Y); e.Line1.Color = color
                        e.Line2.Visible = true; e.Line2.From = Vector2.new(X, Y); e.Line2.To = Vector2.new(X, Y + L); e.Line2.Color = color
                        e.Line3.Visible = true; e.Line3.From = Vector2.new(X + W, Y); e.Line3.To = Vector2.new(X + W - L, Y); e.Line3.Color = color
                        e.Line4.Visible = true; e.Line4.From = Vector2.new(X + W, Y); e.Line4.To = Vector2.new(X + W, Y + L); e.Line4.Color = color
                        e.Line5.Visible = true; e.Line5.From = Vector2.new(X, Y + H); e.Line5.To = Vector2.new(X + L, Y + H); e.Line5.Color = color
                        e.Line6.Visible = true; e.Line6.From = Vector2.new(X, Y + H); e.Line6.To = Vector2.new(X, Y + H - L); e.Line6.Color = color
                        e.Line7.Visible = true; e.Line7.From = Vector2.new(X + W, Y + H); e.Line7.To = Vector2.new(X + W - L, Y + H); e.Line7.Color = color
                        e.Line8.Visible = true; e.Line8.From = Vector2.new(X + W, Y + H); e.Line8.To = Vector2.new(X + W, Y + H - L); e.Line8.Color = color
                    else
                        e.BoxOutline.Visible = false; e.Box.Visible = false
                        for i=1,8 do e["Line"..i].Visible = false end
                    end
                    
                    if GGPVP.ESP.HealthBar then
                        e.HealthBG.Visible = true; e.Health.Visible = true
                        local pct = hum.Health / hum.MaxHealth
                        e.HealthBG.Size = Vector2.new(3, H); e.HealthBG.Position = Vector2.new(X - 6, Y)
                        e.Health.Size = Vector2.new(1, H * pct); e.Health.Position = Vector2.new(X - 5, Y + (H - (H * pct)))
                        e.Health.Color = Color3.fromRGB(255 - (pct * 255), pct * 255, 0)
                    else
                        e.HealthBG.Visible = false; e.Health.Visible = false
                    end
                    
                    if GGPVP.ESP.Names then
                        e.Name.Visible = true; e.Name.Text = p.Name
                        e.Name.Position = Vector2.new(pos.X, Y - 18)
                        e.Name.Color = color
                    else e.Name.Visible = false end
                    
                    if GGPVP.ESP.Distance then
                        e.Dist.Visible = true; e.Dist.Text = math.floor(dist) .. "m"
                        e.Dist.Position = Vector2.new(pos.X, Y + H + 2)
                        e.Dist.Color = Color3.fromRGB(180, 180, 180)
                    else e.Dist.Visible = false end
                    
                    if GGPVP.ESP.Tracers then
                        e.Tracer.Visible = true
                        e.Tracer.Color = color
                        e.Tracer.To = Vector2.new(pos.X, Y + H)
                        if GGPVP.ESP.TracerOrigin == "Bottom" then e.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        elseif GGPVP.ESP.TracerOrigin == "Top" then e.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        elseif GGPVP.ESP.TracerOrigin == "Mouse" then e.Tracer.From = UIS:GetMouseLocation() end
                    else e.Tracer.Visible = false end

                else
                    for _, v in pairs(e) do v.Visible = false end
                end
            elseif e then
                for _, v in pairs(e) do v.Visible = false end
            end
        end
    end
end

-- BUG DO RADAR SUMIR RESOLVIDO

local function UpdateRadarBlips()
    if not GGPVP.Radar.Enabled then
        for _, blip in pairs(Radar_Table) do blip.Visible = false end
        return
    end
    
    local center = RadarBG.Position + (RadarBG.Size / 2)
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if not Radar_Table[p] then
                local blip = Drawing.new("Circle")
                blip.Filled = true; blip.Radius = 3; blip.Thickness = 1
                Radar_Table[p] = blip
            end
            
            local blip = Radar_Table[p]
            local char = p.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local relPos = root.Position - myRoot.Position
                local dist = relPos.Magnitude
                
                -- Limite do radar
                if dist <= (GGPVP.Radar.Radius * GGPVP.Radar.Scale) then
                    local camY = math.atan2(Camera.CFrame.LookVector.X, Camera.CFrame.LookVector.Z)
                    local objY = math.atan2(relPos.X, relPos.Z)
                    local angle = objY - camY
                    
                    local scaledDist = dist / GGPVP.Radar.Scale
                    local x = math.sin(angle) * scaledDist
                    local y = math.cos(angle) * scaledDist
                    
                    -- Previne sumir limitando ao raio interno da borda
                    local drawDist = math.sqrt(x^2 + y^2)
                    if drawDist > GGPVP.Radar.Radius - 3 then
                        local fixAngle = math.atan2(y, x)
                        x = math.cos(fixAngle) * (GGPVP.Radar.Radius - 3)
                        y = math.sin(fixAngle) * (GGPVP.Radar.Radius - 3)
                    end
                    
                    blip.Visible = true
                    blip.Position = Vector2.new(center.X + x, center.Y - y)
                    blip.Color = GGPVP.Radar.BlipColor
                else
                    blip.Visible = false
                end
            else
                blip.Visible = false
            end
        end
    end
end

--loop eventos

UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.UserInputType == GGPVP.Aimbot.Keybind then IsAiming = true end
    if not gp and input.UserInputType == Enum.UserInputType.MouseButton1 then IsShooting = true end
end)

UIS.InputEnded:Connect(function(input, gp)
    if input.UserInputType == GGPVP.Aimbot.Keybind then IsAiming = false; LockedTarget = nil end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then IsShooting = false end
end)

UIS.JumpRequest:Connect(function()
    if GGPVP.Movement.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    local rainbow = GetRainbow()
    
    -- Atualiza FOV (CENTRALIZADO)
    FOVCircle.Visible = GGPVP.FOV.Enabled
    FOVCircle.Radius = GGPVP.FOV.Radius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = GGPVP.FOV.Rainbow and rainbow or GGPVP.FOV.Color
    
    UpdateCrosshair()
    UpdateRadarUI()
    UpdateRadarBlips()
    UpdateESP()
    
    -- logica AIMBOT
    if GGPVP.Aimbot.Enabled and IsAiming then
        if LockedTarget and ValidateTarget(LockedTarget) then
            local targetPos = LockedTarget.Position
            
            if GGPVP.Aimbot.PredictMovement then
                local vel = LockedTarget.Parent.HumanoidRootPart.Velocity
                targetPos = targetPos + (vel * GGPVP.Aimbot.PredictionVelocity)
            end
            
            -- Sistema de Deadzone (Não treme a tela se estiver muito perto)
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

            if distFromCenter > GGPVP.Aimbot.Deadzone then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), GGPVP.Aimbot.Smoothness)
            end
        else
            LockedTarget = GetClosestTarget()
        end
    else
        LockedTarget = nil
    end
    
    -- FUNÇAO NO RECOIL
    
    if GGPVP.Recoil.Enabled and IsShooting then
        local recoilY = GGPVP.Recoil.Intensity
        local recoilX = GGPVP.Recoil.Shake and (math.random(-10, 10) * 0.01 * GGPVP.Recoil.Intensity) or 0
        Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(recoilY), math.rad(recoilX), 0)
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        local hum = char.Humanoid
        local root = char.HumanoidRootPart
        
        if GGPVP.Movement.SpeedEnabled then
            hum.WalkSpeed = GGPVP.Movement.Speed
        end
        
        if GGPVP.Movement.Noclip then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        
        if GGPVP.Movement.FlyEnabled then
            hum.PlatformStand = true
            local bv = root:FindFirstChild("GG_Fly") or Instance.new("BodyVelocity", root)
            bv.Name = "GG_Fly"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            local vel = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then vel += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then vel -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then vel += Camera.CFrame.RightVector end
            
            if vel.Magnitude > 0 then bv.Velocity = vel.Unit * GGPVP.Movement.FlySpeed else bv.Velocity = Vector3.zero end
        else
            hum.PlatformStand = false
            if root:FindFirstChild("GG_Fly") then root.GG_Fly:Destroy() end
        end
    end
    
    if GGPVP.TriggerBot.Enabled and not IsAiming then
        local target = Mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            if (target.Position - LP.Character.HumanoidRootPart.Position).Magnitude <= GGPVP.TriggerBot.Distance then
                mouse1click()
                task.wait(GGPVP.TriggerBot.Delay)
            end
        end
    end
end)

GUI:Notify("GGPVP V2 INJETADO", "Aperte RightShift para abrir/fechar o menu.")