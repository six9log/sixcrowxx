local GitHubUser = "six9log" -- Seu nome de usuário no GitHub
local RepoName = "sixcrowxx" -- Nome do seu repositório

local function loadModule(moduleName)
    local url = "https://raw.githubusercontent.com/" .. GitHubUser .. "/" .. RepoName .. "/main/" .. moduleName .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("SixCrow: Erro ao carregar o módulo " .. moduleName .. ": " .. result)
    else
        print("SixCrow: " .. moduleName .. " carregado com sucesso!")
    end
end
