# SCD Tipo 2 no Microsoft Fabric

Exemplo prático de implementação de **Slowly Changing Dimension (SCD) Tipo 2** no Microsoft Fabric, utilizando Fabric Warehouse, notebooks e arquivos CSV. Apresentação realizada no user group [**Fabric Lusófono**](https://community.fabric.microsoft.com/group/FabricLusfono) no dia 18/09/2026.

## Cenário

Em julho de 2026, um vendedor deixou a empresa e outro assumiu sua carteira de clientes. Como é necessário preservar o histórico de **quem era o vendedor responsável no momento de cada venda**, uma simples sobrescrita da dimensão não é suficiente.

Neste exemplo, a dimensão de estrutura de vendas utiliza **SCD Tipo 2** para manter as diferentes versões do vendedor ao longo do tempo.

## Estrutura do repositório

- **`data/`** — arquivos CSV de origem utilizados no processo de carga do meses de julho/26 (pasta **`novo/`**) e agosto/26 (pasta **`data/`**).
- **`notebooks/`** — notebooks utilizados no processamento dos arquivos.
- **`sql_scripts/`** — scripts T-SQL para criação das tabelas, procedures e execução do processo de carga.

## Tecnologias

- Microsoft Fabric
- Fabric Warehouse
- OneLake
- Power BI
- Python / Notebooks
- T-SQL
- SCD Tipo 2

## Referência

Blog Data Mozart - Nikola Ilic: [Implementing SCD Type 2 in Microsoft Fabric – The Definitive Guide!](https://data-mozart.com/implementing-scd-type-2-in-microsoft-fabric-the-definitive-guide/)
