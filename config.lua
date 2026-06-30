-- ========================================================================
-- ⚡ SIXCROW CONFIG | ROTEADOR DE JOGOS
-- ========================================================================
local PlaceId = game.PlaceId
local GitHubUser = "six9log" 
local RepoName = "sixcrowxx"

print("⚡ SixCrow: Identificando jogo (PlaceId: " .. PlaceId .. ")")

local JogosSuportados = {
    [2753915549] = "bloxfruits.lua", 
    [1550233908] = "grind_simulator.lua",
    [114234929420007] = "bloxstrike.lua" -- Aqui está o seu jogo novo!
}

-- Lógica inteligente: Se o ID do jogo estiver na lista, ele puxa o arquivo específico.
-- Se não estiver na lista, ele puxa o "master_menu.lua" como padrão (Universal).
local ArquivoParaCarregar = JogosSuportados[PlaceId] or "master_menu.lua"

local ModuloURL = "https://raw.githubusercontent.com/" .. GitHubUser .. "/" .. RepoName .. "/main/modulos/" .. ArquivoParaCarregar

print("🚀 Redirecionando para o módulo: " .. ArquivoParaCarregar)

local success, err = pcall(function()
    loadstring(game:HttpGet(ModuloURL))()
end)

if not success then
    warn("SixCrow: Erro ao tentar abrir " .. ArquivoParaCarregar .. ": " .. tostring(err))
end