CREATE SCHEMA stg;

GO

CREATE SCHEMA gold;

GO

CREATE TABLE stg.estrutura_vendas
(
    ID_Localizacao       INT,
    Cidade               VARCHAR(100),
    Regiao               VARCHAR(100),
    Cod_Estrutura_Venda  VARCHAR(50),
    Nome_Estrutura_Venda VARCHAR(200),
    Vendedor              VARCHAR(200)
);

GO

CREATE TABLE stg.fato_vendas
(
    ID_Localizacao INT,
    Data           DATE,
    Valor          DECIMAL(18,2)
);

GO


CREATE TABLE gold.dim_estrutura_vendas
(
SK_Estrutura_Vendas BIGINT IDENTITY,
ID_Localizacao INT,
Cidade VARCHAR(100),
Regiao VARCHAR(100),
Cod_Estrutura_Venda VARCHAR(10),
Nome_Estrutura_Venda VARCHAR(100),
Vendedor VARCHAR(100),
StartDate DATETIME2(6),
EndDate DATETIME2(6),
IsCurrent BIT,
Data_Carga DATETIME2(6)
);

GO


CREATE TABLE gold.fato_vendas
(
ID_Localizacao INT,
Data DATE,
Valor DECIMAL(18,2),
SK_Estrutura_Vendas BIGINT,
fl_inativo BIT,
Data_Carga DATETIME2(6)
);
