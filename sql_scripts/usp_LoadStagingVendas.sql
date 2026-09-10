
--Script de criação da procedure usp_LoadStagingVendas que realiza a carga das tabelas de stage "estruta_vendas" e "fato_vendas"

CREATE OR ALTER PROCEDURE gold.usp_LoadStagingVendas
    @LakehouseFilesPath VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL VARCHAR(8000);

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Limpa o staging
        ------------------------------------------------------------

        TRUNCATE TABLE stg.estrutura_vendas;

        TRUNCATE TABLE stg.fato_vendas;


        ------------------------------------------------------------
        -- 2. Estrutura de Vendas - Julho/2026
        ------------------------------------------------------------

        SET @SQL = '
            COPY INTO stg.estrutura_vendas
            FROM ''' +
            @LakehouseFilesPath +
            '/dim_estrutura_vendas.csv''
            WITH
            (
                FILE_TYPE = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"''
            );
        ';

        EXEC(@SQL);


        ------------------------------------------------------------
        -- 3. Fato de Vendas - Julho/2026
        ------------------------------------------------------------

        SET @SQL = '
            COPY INTO stg.fato_vendas
            FROM ''' +
            @LakehouseFilesPath +
            '/fato_vendas.csv''
            WITH
            (
                FILE_TYPE = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"''
            );
        ';

        EXEC(@SQL);


        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;
