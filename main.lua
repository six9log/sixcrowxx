-- ========================================================================
-- ⚡ SIXCROW MASTER LOADER & AUTH SYSTEM | v1.1 (Com Input de ID)
-- ========================================================================

local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("SixCrow_Auth") then
    CoreGui.SixCrow_Auth:Destroy()
end

local SenhaCorreta = "1234"
local GitHubUser = "six9log" 
local RepoName = "sixcrowxx"

-- ========================================================================
-- CRIAÇÃO DA INTERFACE 
-- ========================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "SixCrow_Auth"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
Blur.Size = 0
TweenService:Create(Blur, TweenInfo.new(1), {Size = 15}):Play()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(220, 20, 60)
UIStroke.Thickness = 1.5

-- Títulos
local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0.05, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "SIXCROW"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24

local SubTitle = Instance.new("TextLabel", MainFrame)
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0.20, 0)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Font = Enum.Font.GothamSemibold
SubTitle.Text = "Autenticação Premium"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 12

-- 1º Caixa de Texto (KEY)
local KeyInput = Instance.new("TextBox", MainFrame)
KeyInput.AnchorPoint = Vector2.new(0.5, 0)
KeyInput.Position = UDim2.new(0.5, 0, 0.35, 0)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyInput.Font = Enum.Font.GothamSemibold
KeyInput.PlaceholderText = "Sua Senha..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
local KeyStroke = Instance.new("UIStroke", KeyInput)
KeyStroke.Color = Color3.fromRGB(40, 40, 40)
KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- 2º Caixa de Texto (ID DO JOGO MANUAL)
local GameIdInput = Instance.new("TextBox", MainFrame)
GameIdInput.AnchorPoint = Vector2.new(0.5, 0)
GameIdInput.Position = UDim2.new(0.5, 0, 0.55, 0)
GameIdInput.Size = UDim2.new(0.8, 0, 0, 40)
GameIdInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
GameIdInput.Font = Enum.Font.GothamSemibold
GameIdInput.PlaceholderText = "ID do Jogo (Vazio = Automático)"
GameIdInput.Text = ""
GameIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
GameIdInput.TextSize = 12
Instance.new("UICorner", GameIdInput).CornerRadius = UDim.new(0, 6)
local IdStroke = Instance.new("UIStroke", GameIdInput)
IdStroke.Color = Color3.fromRGB(40, 40, 40)
IdStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Botão de Verificar
local SubmitBtn = Instance.new("TextButton", MainFrame)
SubmitBtn.AnchorPoint = Vector2.new(0.5, 0)
SubmitBtn.Position = UDim2.new(0.5, 0, 0.75, 0)
SubmitBtn.Size = UDim2.new(0.8, 0, 0, 40)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Text = "INJETAR"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 300)}):Play()

local function LoadMainCheat()
    SubmitBtn.Text = "CARREGANDO..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    
    -- Usando getgenv() para garantir que qualquer executor entenda
    local TypedID = tonumber(GameIdInput.Text)
    if TypedID then
        getgenv().SixCrow_ForcedID = TypedID
        print("⚡ SixCrow: ID Manual detectado ->", TypedID)
    else
        getgenv().SixCrow_ForcedID = game.PlaceId
        print("⚡ SixCrow: ID Automático ativado ->", game.PlaceId)
    end
    
    task.wait(1)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 0}):Play()
    
    task.wait(0.5)
    ScreenGui:Destroy()
    Blur:Destroy()
    
-- O "?t=" .. tostring(tick()) engana o executor e força ele a baixar a versão atualizada AGORA
    local ConfigURL = "https://raw.githubusercontent.com/" .. GitHubUser .. "/" .. RepoName .. "/main/config.lua?t=" .. tostring(tick())
    
    local success, err = pcall(function() loadstring(game:HttpGet(ConfigURL))() end)
    
    if not success then warn("SixCrow: Erro ao carregar Config: " .. tostring(err)) end
end

SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == SenhaCorreta then
        LoadMainCheat()
    else
        SubmitBtn.Text = "KEY INVÁLIDA!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        KeyStroke.Color = Color3.fromRGB(220, 20, 60)
        task.wait(1)
        SubmitBtn.Text = "INJETAR"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
        KeyStroke.Color = Color3.fromRGB(40, 40, 40)
    end
end)