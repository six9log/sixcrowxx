-- ========================================================================
-- ⚡ SIXCROW MASTER LOADER & AUTH SYSTEM | v1.0
-- ========================================================================

local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Evita abrir duas vezes e bugar a tela
if CoreGui:FindFirstChild("SixCrow_Auth") then
    CoreGui.SixCrow_Auth:Destroy()
end

-- Configurações da Key e Repositório
local SenhaCorreta = "1234"
local GitHubUser = "six9log" 
local RepoName = "sixcrowxx"

-- ========================================================================
-- CRIAÇÃO DA INTERFACE (Totalmente Interna e Protegida)
-- ========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SixCrow_Auth"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Fundo Desfocado (Estética Premium)
local Blur = Instance.new("BlurEffect")
Blur.Parent = game:GetService("Lighting")
Blur.Size = 0
TweenService:Create(Blur, TweenInfo.new(1), {Size = 15}):Play()

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Começa pequeno para a animação
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(220, 20, 60) -- Vermelho SixCrow
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0.1, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "SIXCROW"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = MainFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0.25, 0)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Font = Enum.Font.GothamSemibold
SubTitle.Text = "Insira sua Premium Key"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 12

-- Caixa de Texto (Input da Key)
local KeyInput = Instance.new("TextBox")
KeyInput.Parent = MainFrame
KeyInput.AnchorPoint = Vector2.new(0.5, 0)
KeyInput.Position = UDim2.new(0.5, 0, 0.45, 0)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyInput.Font = Enum.Font.GothamSemibold
KeyInput.PlaceholderText = "Sua Key aqui..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
local InputStroke = Instance.new("UIStroke", KeyInput)
InputStroke.Color = Color3.fromRGB(40, 40, 40)
InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Botão de Verificar
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Parent = MainFrame
SubmitBtn.AnchorPoint = Vector2.new(0.5, 0)
SubmitBtn.Position = UDim2.new(0.5, 0, 0.7, 0)
SubmitBtn.Size = UDim2.new(0.8, 0, 0, 40)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Text = "VERIFICAR KEY"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

-- ========================================================================
-- ANIMAÇÕES E LÓGICA DE CARREGAMENTO
-- ========================================================================
-- Animação de Entrada
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 250)}):Play()

-- Função de Carregar o Cheat após validar a Key
local function LoadMainCheat()
    SubmitBtn.Text = "AUTENTICADO! CARREGANDO..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Verde
    
    -- Animação de saída
    task.wait(1)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 0}):Play()
    
    task.wait(0.5)
    ScreenGui:Destroy()
    Blur:Destroy()
    
    -- Carrega o menu principal da pasta modules
    local MasterMenuURL = "https://raw.githubusercontent.com/" .. GitHubUser .. "/" .. RepoName .. "/main/modulos/master_menu.lua"
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(MasterMenuURL))()
    end)
    
    if not success then
        warn("SixCrow: Erro fatal ao carregar o Menu Principal: " .. tostring(err))
    end
end

-- Lógica do Clique
SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == SenhaCorreta then
        LoadMainCheat()
    else
        -- Animação de Erro (Fica Vermelho Escuro e treme)
        SubmitBtn.Text = "KEY INVÁLIDA!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        InputStroke.Color = Color3.fromRGB(220, 20, 60)
        
        task.wait(1)
        SubmitBtn.Text = "VERIFICAR KEY"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
        InputStroke.Color = Color3.fromRGB(40, 40, 40)
    end
end)