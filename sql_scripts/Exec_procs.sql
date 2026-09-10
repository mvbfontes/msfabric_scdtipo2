--Comando para executar procedure usp_LoadStagingVendas

--Substituir <workspaceid> e <lakehouseid> pelos ids do seu ambiente

EXEC gold.usp_LoadStagingVendas
    @LakehouseFilesPath =
        'https://onelake.dfs.fabric.microsoft.com/<workspaceid>/<lakehouseid>/Files/novo';

--Comando para executar procedure usp_LoadDimEstruturaVendas
        
EXEC gold.usp_LoadDimEstruturaVendas '2026-07-01'

--Comando para executar procedure usp_LoadFatoVendas

EXEC gold.usp_LoadFatoVendas '2026-07-01'