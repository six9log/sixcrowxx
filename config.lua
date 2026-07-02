-- ========================================================================
-- ⚡ SIXCROW CONFIG | ROTEADOR INTELIGENTE
-- ========================================================================
local GitHubUser = "six9log" 
local RepoName = "sixcrowxx"

-- Lê a mochila global do executor e tenta pegar o ID
local PlaceId = getgenv().SixCrow_ForcedID or game.PlaceId

print("⚡ SixCrow Config: Procurando script para o ID: " .. tostring(PlaceId))

local JogosSuportados = {
    [2753915549] = "bloxfruits.lua", 
    [1550233908] = "grind_simulator.lua",
    [114234929420007] = "bloxstrike.lua"
}

local ArquivoParaCarregar = JogosSuportados[PlaceId]

if ArquivoParaCarregar then
    print("🚀 Script exclusivo encontrado: " .. ArquivoParaCarregar)
else
    print("⚠️ Jogo não mapeado. Carregando Menu Universal...")
    ArquivoParaCarregar = "master_menu.lua"
end

local ModuloURL = "https://raw.githubusercontent.com/" .. GitHubUser .. "/" .. RepoName .. "/main/modulos/" .. ArquivoParaCarregar

local success, err = pcall(function()
    loadstring(game:HttpGet(ModuloURL))()
end)

if not success then
    warn("SixCrow: Erro ao tentar abrir " .. ArquivoParaCarregar .. ": " .. tostring(err))
end

-- Limpa a variável para o próximo uso
getgenv().SixCrow_ForcedID = nil