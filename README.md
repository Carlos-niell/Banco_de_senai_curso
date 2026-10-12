# Banco de Dados — RPG Online

Estrutura relacional sugerida para um jogo de RPG online, desenvolvida em T-SQL para Microsoft SQL Server. O projeto organiza contas, personagens, classes, raças, itens, habilidades, missões, monstros e histórico de combates, usando chaves primárias, chaves estrangeiras e restrições para manter a integridade dos dados.

> **Importante:** esta estrutura foi proposta com base no tema “RPG online” e na rubrica compartilhada. Como não foi fornecido um modelo entidade-relacionamento (MER) nem uma especificação oficial das tabelas, campos e regras, ela é uma sugestão inicial — não uma confirmação de que atende a todos os requisitos do trabalho. Compare-a com o enunciado ou MER da atividade antes da entrega.

## Conteúdo do repositório

| Arquivo | Finalidade |
| --- | --- |
| [`estrutura_rpg_online.sql`](./estrutura_rpg_online.sql) | Cria as tabelas, restrições, relacionamentos e índices do banco. |
| [`consulta_usuarios.sql`](./consulta_usuarios.sql) | Exemplo de consulta que lista dados não sensíveis das contas. |
| `README.md` | Explica o modelo, os arquivos e como executar o script. |

## Tecnologias

- **Banco de dados:** Microsoft SQL Server.
- **Linguagem:** T-SQL.
- **Ferramenta recomendada:** SQL Server Management Studio (SSMS) ou Azure Data Studio.
- **Codificação de texto:** campos de nomes e descrições usam `NVARCHAR` para aceitar caracteres acentuados.

## Pré-requisitos

1. Uma instância do Microsoft SQL Server acessível.
2. Permissão para criar tabelas, restrições e índices no banco escolhido.
3. SSMS ou Azure Data Studio para abrir e executar os arquivos `.sql`.

## Como executar

1. Abra o SSMS ou Azure Data Studio e conecte-se à instância do SQL Server.
2. Crie um banco de dados para o projeto, se ainda não existir. Por exemplo, no SSMS, clique com o botão direito em **Databases** → **New Database...** e informe `RPGOnline`.
3. Abra uma nova consulta e selecione esse banco no seletor de banco de dados da ferramenta.
4. Abra [`estrutura_rpg_online.sql`](./estrutura_rpg_online.sql), confira que a consulta está apontando para o banco correto e execute o script inteiro.
5. Para conferir as tabelas criadas, execute:

   ```sql
   SELECT TABLE_SCHEMA, TABLE_NAME
   FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_TYPE = 'BASE TABLE'
     AND TABLE_SCHEMA = 'dbo'
   ORDER BY TABLE_NAME;
   ```

6. Para consultar as contas sem retornar o hash de senha, abra e execute [`consulta_usuarios.sql`](./consulta_usuarios.sql).

O script cria a estrutura, mas **não insere dados iniciais**. Para cadastrar um personagem, por exemplo, primeiro devem existir os registros de usuário, raça e classe que serão referenciados.

### Executar novamente

O arquivo de criação não é idempotente: ao executá-lo uma segunda vez no mesmo banco, o SQL Server informará que os objetos já existem. Use um banco vazio ou prepare uma migração controlada para alterações futuras. Não apague tabelas em um banco com dados importantes sem fazer backup e avaliar as dependências.

## Modelo e relacionamentos

```text
Usuarios       1 ─── N Personagens
Racas          1 ─── N Personagens
Classes        1 ─── N Personagens
Localizacoes   1 ─── N Personagens
Localizacoes   1 ─── N Monstros
Localizacoes   1 ─── N Missoes

Personagens    N ─── N Itens       (por Inventario)
Personagens    N ─── N Habilidades (por PersonagemHabilidades)
Personagens    N ─── N Missoes     (por PersonagemMissoes)
Monstros       N ─── N Itens       (por MonstroItens: tabela de drops)
Personagens    1 ─── N Combates
Monstros       1 ─── N Combates
Classes        1 ─── N Habilidades (opcional; habilidade comum usa ClasseId nulo)
```

## Tabelas

### Contas e personagens

| Tabela | Responsabilidade | Campos e regras principais |
| --- | --- | --- |
| `Usuarios` | Contas que acessam o jogo. | `UsuarioId` é a PK; `Email` é único; `HashSenha` armazena o hash, nunca uma senha em texto puro; `Ativo` e `DataCadastro` possuem valores padrão. |
| `Racas` | Catálogo de raças disponíveis. | `RacaId` é a PK e `Nome` é único. |
| `Classes` | Catálogo de classes disponíveis. | `ClasseId` é a PK e `Nome` é único. |
| `Localizacoes` | Regiões ou mapas do jogo. | `LocalizacaoId` é a PK e `Nome` é único. |
| `Personagens` | Personagens criados pelas contas. | FKs para usuário, raça e classe; localização atual opcional; atributos, nível, vida, mana, experiência e ouro; nome único dentro da conta. |

Um usuário pode ter vários personagens. Cada personagem referencia uma raça e uma classe. A localização do personagem pode ficar nula até que seja definida.

### Conteúdo e progresso

| Tabela | Responsabilidade | Campos e regras principais |
| --- | --- | --- |
| `Itens` | Catálogo de itens. | Tipo e raridade limitados por `CHECK`; valor, peso e nível requerido não podem ser negativos/inválidos. |
| `Inventario` | Itens e quantidades carregados por personagem. | PK composta (`PersonagemId`, `ItemId`); quantidade precisa ser positiva. |
| `Habilidades` | Catálogo de habilidades. | Pode ser vinculada a uma classe; `ClasseId` nulo representa uma habilidade disponível para qualquer classe. |
| `PersonagemHabilidades` | Habilidades aprendidas pelos personagens. | PK composta (`PersonagemId`, `HabilidadeId`); registra nível da habilidade e data de aprendizado. |
| `Missoes` | Catálogo de missões e recompensas. | Localização opcional, nível requerido, experiência e ouro oferecidos. |
| `PersonagemMissoes` | Progresso de cada personagem em cada missão. | PK composta (`PersonagemId`, `MissaoId`); status limitado a “Em andamento”, “Concluida” ou “Abandonada”. |
| `Monstros` | Criaturas encontradas no jogo. | Localização opcional, nível, vida máxima e recompensas. |
| `MonstroItens` | Itens que podem ser obtidos de cada monstro. | PK composta (`MonstroId`, `ItemId`); chance entre 0 e 100% e quantidade mínima/máxima válidas. |
| `Combates` | Histórico de combates entre personagem e monstro. | Guarda início, fim, resultado e experiência ganha; combate em andamento tem `Fim` e `Resultado` nulos. |

## Tipos, chaves e integridade

- IDs usam `INT IDENTITY` (e `BIGINT IDENTITY` para o histórico de combates) como chaves primárias.
- Chaves estrangeiras ligam personagens às contas, raças, classes e localizações, e conectam os registros de inventário, habilidades, missões, drops e combates.
- Tabelas de associação usam chaves primárias compostas para impedir duplicatas da mesma relação.
- `NVARCHAR` é usado em textos para preservar acentos; `NVARCHAR(MAX)` não é necessário para os campos definidos.
- `BIT` representa valores binários, como a situação da conta e se um item pode ser empilhado.
- `TINYINT` representa níveis; `SMALLINT` representa atributos; `INT` e `BIGINT` representam contagens e valores que podem crescer.
- `DECIMAL(8,2)` representa peso e `DECIMAL(5,2)` representa chance percentual de drop.
- `DATETIME2(0)` armazena datas e horários. Os valores padrão de criação usam `SYSUTCDATETIME()`.
- Restrições `CHECK` validam limites e valores permitidos; restrições `UNIQUE` evitam e-mails, nomes de catálogo e nomes repetidos de personagem por conta.
- A exclusão de um personagem remove suas linhas dependentes de inventário, habilidades aprendidas e missões associadas. As demais FKs restringem exclusões que deixariam referências ou histórico inválidos.
- Índices adicionais apoiam buscas pelas FKs e consultas recentes de combates por personagem. SQL Server não cria automaticamente índices para todas as FKs.

## Consulta de exemplo

O arquivo [`consulta_usuarios.sql`](./consulta_usuarios.sql) contém:

```sql
SELECT UsuarioId, Nome, Email, DataCadastro, Ativo
FROM dbo.Usuarios;
```

A consulta escolhe as colunas explicitamente e não retorna `HashSenha`.

## Segurança e dados

- `HashSenha` deve receber somente um hash gerado por uma biblioteca de autenticação apropriada, com algoritmo moderno e salt. Não armazene senhas em texto puro nem gere hashes manualmente em SQL.
- Restrinja o acesso ao banco por usuário e permissões. Não use uma conta administrativa da instância pela aplicação.
- Antes de inserir dados pessoais reais, defina regras de acesso, retenção, backup e exclusão adequadas ao projeto.
- O script contém apenas DDL (definição da estrutura); não contém credenciais nem dados pessoais.

## Escopo e melhorias futuras

Este modelo cobre entidades comuns de um RPG online, mas ainda não especifica sistemas detalhados de equipamentos equipados, grupos/guildas, comércio, pagamentos, PvP, chat, objetivos de missões, mapas com coordenadas, autenticação/sessões nem regras de balanceamento. Esses recursos devem ser adicionados somente se constarem nos requisitos do jogo.

Para alinhar o banco à atividade, confira principalmente:

1. se todas as entidades exigidas pelo enunciado estão representadas;
2. se cada campo, tipo, nulabilidade, valor padrão e limite corresponde à especificação;
3. se as cardinalidades do MER correspondem às FKs e tabelas associativas;
4. se o professor exige nomes de tabelas/campos ou convenções diferentes.

## Licença

Material acadêmico. Nenhuma licença específica foi definida neste repositório.
