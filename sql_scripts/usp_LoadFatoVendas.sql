--Script de criação da procedure usp_LoadFatoVendas que realiza a carga da fato "fato_vendas"

CREATE OR ALTER PROCEDURE gold.usp_LoadFatoVendas
    @StartDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EndDate DATE = DATEADD(MONTH, 1, @StartDate);

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Inativa a versão atualmente ativa da competência
        ------------------------------------------------------------
        UPDATE gold.fato_vendas
        SET fl_inativo = 1
        WHERE Data >= @StartDate
          AND Data < @EndDate
          AND fl_inativo = 0;


        ------------------------------------------------------------
        -- 2. Insere a nova versão da competência
        ------------------------------------------------------------
        INSERT INTO gold.fato_vendas
        (
            ID_Localizacao,
            Data,
            Valor,
            SK_Estrutura_Vendas,
            fl_inativo,
            Data_Carga
        )
        SELECT
            f.ID_Localizacao,
            f.Data,
            f.Valor,
            d.SK_Estrutura_Vendas,
            0 AS fl_inativo,
            GETDATE()
        FROM stg.fato_vendas AS f

        INNER JOIN gold.dim_estrutura_vendas AS d
            ON d.ID_Localizacao = f.ID_Localizacao
           AND f.Data >= d.StartDate
           AND f.Data < d.EndDate

        WHERE f.Data >= @StartDate
          AND f.Data < @EndDate;


        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;