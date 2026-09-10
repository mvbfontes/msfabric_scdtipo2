--Script de criação da procedure usp_LoadDimEstruturaVendas que realiza a carga da dimensão "dim_estrutura_vendas"

CREATE OR ALTER PROCEDURE gold.usp_LoadDimEstruturaVendas

    @EffectiveDate DATE

AS

BEGIN

    -- Validar granularidade da origem
    IF EXISTS
    (
        SELECT [ID_Localizacao]
        FROM stg.estrutura_vendas
        GROUP BY [ID_Localizacao]
        HAVING COUNT(*) > 1
    )
        THROW 50002,
              'Staging contains multiple rows for the same ID Localizacao.',
              1;


    BEGIN TRANSACTION;


    ----------------------------------------------------------------
    -- Step 1: Fechar a versão atual quando o Vendedor mudou
    ----------------------------------------------------------------

    UPDATE d

    SET
        d.EndDate   = DATEADD(DAY, -1, @EffectiveDate),
        d.IsCurrent = 0,
        d.Data_Carga = GETDATE()

    FROM gold.dim_estrutura_vendas AS d

    JOIN stg.estrutura_vendas AS s
        ON s.[ID_Localizacao] = d.[ID_Localizacao]

    WHERE d.IsCurrent = 1

      AND ISNULL(d.Vendedor, '') <> ISNULL(s.Vendedor, '');


    ----------------------------------------------------------------
    -- Step 2: Inserir nova versão
    --
    -- Inclui:
    --   a) novas estruturas
    --   b) estruturas cujo vendedor mudou no Step 1
    ----------------------------------------------------------------

    INSERT INTO gold.dim_estrutura_vendas
    (
        [ID_Localizacao],
        Cidade,
        Regiao,
        [Cod_Estrutura_Venda],
        [Nome_Estrutura_Venda],
        Vendedor,
        StartDate,
        EndDate,
        IsCurrent,
        Data_Carga
    )

    SELECT
        s.[ID_Localizacao],
        s.Cidade,
        s.Regiao,
        s.[Cod_Estrutura_Venda],
        s.[Nome_Estrutura_Venda],
        s.Vendedor,
        @EffectiveDate,
        '9999-12-31',
        1,
        GETDATE()

    FROM stg.estrutura_vendas AS s

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM gold.dim_estrutura_vendas AS d
        WHERE d.[ID_Localizacao] = s.[ID_Localizacao]
          AND d.IsCurrent = 1
    );


    ----------------------------------------------------------------
    -- Step 3: Atributos Tipo 1
    --
    -- Cidade, Região, Código e Nome da Estrutura
    -- são atualizados em todas as versões.
    ----------------------------------------------------------------

    UPDATE d

    SET
        d.Cidade = s.Cidade,
        d.Regiao = s.Regiao,
        d.[Cod_Estrutura_Venda] = s.[Cod_Estrutura_Venda],
        d.[Nome_Estrutura_Venda] = s.[Nome_Estrutura_Venda]

    FROM gold.dim_estrutura_vendas AS d

    JOIN stg.estrutura_vendas AS s
        ON s.[ID_Localizacao] = d.[ID_Localizacao]

    WHERE
           ISNULL(d.Cidade, '') <> ISNULL(s.Cidade, '')
        OR ISNULL(d.Regiao, '') <> ISNULL(s.Regiao, '')
        OR ISNULL(d.[Cod_Estrutura_Venda], '') <> ISNULL(s.[Cod_Estrutura_Venda], '')
        OR ISNULL(d.[Nome_Estrutura_Venda], '') <> ISNULL(s.[Nome_Estrutura_Venda], '');


    COMMIT TRANSACTION;

END;