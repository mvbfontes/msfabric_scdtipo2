# Tutorial — SCD Tipo 2 no Microsoft Fabric

Este tutorial demonstra a implementação de uma dimensão **Slowly Changing Dimension (SCD) Tipo 2** no Microsoft Fabric, utilizando Lakehouse, Warehouse, notebooks, pipelines e Power BI.

## 1. Criar o ambiente no Microsoft Fabric

No workspace do Microsoft Fabric, crie:

- Um **Lakehouse** chamado `LH_Vendas`.
- Um **Warehouse** chamado `DW_Vendas`.

No Lakehouse, crie as pastas `Files/novo` e `Files/processados`.

A pasta `novo` será utilizada para receber os arquivos de origem. Após o processamento, os arquivos serão movidos para `processados`.

## 2. Criar as tabelas e procedures

Abra o SQL Editor do Warehouse `DW_Vendas` e execute os scripts disponíveis na pasta `sql_scripts` deste repositório, na seguinte ordem:

1. `Create_Tables.sql` — cria as tabelas de staging e as tabelas `gold.dim_estrutura_vendas` e `gold.fato_vendas`.
2. `usp_LoadStagingVendas.sql` — cria a procedure responsável pela carga dos arquivos de origem para as tabelas de staging.
3. `usp_LoadDimEstruturaVendas.sql` — cria a procedure responsável pela carga da dimensão de estrutura de vendas utilizando SCD Tipo 2.
4. `usp_LoadFatoVendas.sql` — cria a procedure responsável pela carga da tabela fato.
5. `Exec_procs.sql` — contém exemplos de execução das procedures.

A dimensão `gold.dim_estrutura_vendas` mantém o histórico das alterações do vendedor por meio das colunas `StartDate` e `EndDate`.

Neste exemplo, `Vendedor` é tratado como atributo **Tipo 2**, enquanto `Cidade`, `Regiao`, `Cod_Estrutura_Venda` e `Nome_Estrutura_Venda` são tratados como atributos **Tipo 1**.

## 3. Adicionar o notebook

Adicione ao workspace o notebook `NB_Move_Vendas_Processadas.ipynb`, disponível na pasta `notebooks` deste repositório.

Configure `LH_Vendas` como o Lakehouse padrão do notebook.

O notebook será responsável por mover os arquivos processados de `Files/novo` para `Files/processados/<data>/<hora>`.

## 4. Criar o pipeline

Crie um Data Pipeline chamado `DF_Carga_Vendas`.

O pipeline deve executar as seguintes etapas, nesta ordem:

1. Executar `usp_LoadStagingVendas`, carregando os arquivos existentes em `Files/novo`.
2. Executar `usp_LoadDimEstruturaVendas`, informando a data de referência da carga.
3. Executar `usp_LoadFatoVendas`, informando a mesma data de referência.
4. Executar o notebook `NB_Move_Vendas_Processadas.ipynb`.

A ordem é importante: primeiro a dimensão deve ser atualizada, depois a fato deve ser carregada e, somente após o processamento bem-sucedido, os arquivos devem ser movidos para a pasta de processados.

## 5. Criar o modelo semântico

Opcionalmente, crie um modelo semântico chamado `Vendas` utilizando **Direct Lake on OneLake**.

Adicione as tabelas `gold.dim_estrutura_vendas` e `gold.fato_vendas` do Warehouse `DW_Vendas`.

Crie o relacionamento:

`dim_estrutura_vendas[SK_Estrutura_Vendas]` 1:N `fato_vendas[SK_Estrutura_Vendas]`

Também pode ser adicionada uma dimensão calendário relacionada à coluna de data da fato.

## 6. Carregar os dados de julho de 2026

Faça o upload dos arquivos de julho de 2026 da pasta `data` deste repositório para `LH_Vendas > Files > novo`.

Execute o pipeline `DF_Carga_Vendas`, informando `2026-07-01` como data de referência.

Após a execução, valide:

- Os dados carregados nas tabelas de staging.
- A dimensão `gold.dim_estrutura_vendas`.
- A tabela `gold.fato_vendas`.
- A movimentação dos arquivos para `Files/processados`.

Neste momento, o vendedor responsável pela estrutura deve ser `Paulo P`.

## 7. Carregar os dados de agosto de 2026

Faça o upload dos arquivos de agosto de 2026 da pasta `data` deste repositório para `LH_Vendas > Files > novo`.

Execute novamente o pipeline `DF_Carga_Vendas`, agora informando `2026-08-01` como data de referência.

O processo deverá identificar a alteração do vendedor e criar uma nova versão da estrutura na dimensão.

Neste exemplo, o vendedor muda de `Paulo P` para `Carlos C`.

Após a execução, valide novamente a dimensão, a fato e a movimentação dos arquivos.

## 8. Validar o histórico

A dimensão deverá manter as duas versões do vendedor, com períodos de validade diferentes:

- `Paulo P` — válido até o fim de julho de 2026.
- `Carlos C` — válido a partir de agosto de 2026.

A fato utiliza a combinação de `ID_Localizacao` e período de validade da dimensão para encontrar a chave substituta (`SK_Estrutura_Vendas`) correspondente à data da venda.

Dessa forma, uma venda realizada em julho continua associada a `Paulo P`, enquanto uma venda realizada em agosto fica associada a `Carlos C`.

## 9. Reprocessamento histórico

Uma das características deste exemplo é permitir o reprocessamento de meses anteriores.

Caso os arquivos de um determinado mês sejam processados novamente, a dimensão é recalculada considerando a data de referência da carga e as versões existentes.

Em seguida, a fato daquele mês é recarregada. Os registros da carga anterior são marcados com `fl_inativo = 1` e uma nova carga é inserida com `fl_inativo = 0`.

A coluna `Data_Carga` permite identificar quando cada versão da carga foi realizada.

No Power BI, podem ser utilizados apenas os registros com `fl_inativo = 0` para representar a versão atual dos dados.
