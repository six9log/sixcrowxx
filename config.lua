-- ========================================================================
-- ⚡ SIXCROW CONFIG | ROTEADOR INTELIGENTE & DEBUGGER
-- ========================================================================
local GitHubUser = "six9log" 
local RepoName = "sixcrowxx"

local PlaceId = getgenv().SixCrow_ForcedID or game.PlaceId
print("⚡ SixCrow Config: Procurando script para o ID: " .. tostring(PlaceId))

local JogosSuportados = {
    [2753915549] = "bloxfruits.lua", 
    [1550233908] = "grind_simulator.lua",
    [114234929420007] = "bloxstrike.lua",
    [142823291] = "MUDER_MM2.lua",
}

local ArquivoParaCarregar = JogosSuportados[PlaceId] or "master_menu.lua"

if ArquivoParaCarregar == "master_menu.lua" then
    print("⚠️ Jogo não mapeado. Carregando Menu Universal...")
else
    print("🚀 Script exclusivo encontrado: " .. ArquivoParaCarregar)
end

local ModuloURL = "https://raw.githubusercontent.com/" .. GitHubUser .. "/" .. RepoName .. "/main/modulos/" .. ArquivoParaCarregar .. "?t=" .. tostring(tick())

-- ========================================================================
-- SISTEMA PROFISSIONAL DE DEPURAÇÃO (DEBUG)
-- ========================================================================
local success, err = pcall(function()
    local respostaGitHub = game:HttpGet(ModuloURL)
    local funcaoDoCodigo, erroDeCompilacao = loadstring(respostaGitHub)
    
    if funcaoDoCodigo then
        funcaoDoCodigo() -- Executa o script se estiver tudo certo
    else
        -- Se falhar, ele vai nos contar EXATAMENTE o porquê:
        warn("❌ Erro crítico ao converter o arquivo " .. ArquivoParaCarregar .. " em código!")
        warn("Motivo do erro: " .. tostring(erroDeCompilacao))
        warn("Conteúdo que o GitHub enviou de volta: " .. tostring(respostaGitHub))
    end
end)

if not success then
    warn("SixCrow: Falha total na conexão: " .. tostring(err))
end

-- Limpa a variável para o próximo uso
getgenv().SixCrow_ForcedID = nil
