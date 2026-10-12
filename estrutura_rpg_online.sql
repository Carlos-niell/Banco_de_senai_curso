CREATE TABLE dbo.Usuarios (
    UsuarioId int IDENTITY(1,1) NOT NULL,
    Nome nvarchar(100) NOT NULL,
    Email nvarchar(254) NOT NULL,
    HashSenha nvarchar(255) NOT NULL,
    DataCadastro datetime2(0) NOT NULL
        CONSTRAINT DF_Usuarios_DataCadastro DEFAULT (SYSUTCDATETIME()),
    Ativo bit NOT NULL
        CONSTRAINT DF_Usuarios_Ativo DEFAULT (1),
    CONSTRAINT PK_Usuarios PRIMARY KEY (UsuarioId),
    CONSTRAINT UQ_Usuarios_Email UNIQUE (Email)
);

CREATE TABLE dbo.Racas (
    RacaId int IDENTITY(1,1) NOT NULL,
    Nome nvarchar(80) NOT NULL,
    Descricao nvarchar(500) NULL,
    CONSTRAINT PK_Racas PRIMARY KEY (RacaId),
    CONSTRAINT UQ_Racas_Nome UNIQUE (Nome)
);

CREATE TABLE dbo.Classes (
    ClasseId int IDENTITY(1,1) NOT NULL,
    Nome nvarchar(80) NOT NULL,
    Descricao nvarchar(500) NULL,
    CONSTRAINT PK_Classes PRIMARY KEY (ClasseId),
    CONSTRAINT UQ_Classes_Nome UNIQUE (Nome)
);

CREATE TABLE dbo.Localizacoes (
    LocalizacaoId int IDENTITY(1,1) NOT NULL,
    Nome nvarchar(100) NOT NULL,
    Descricao nvarchar(500) NULL,
    CONSTRAINT PK_Localizacoes PRIMARY KEY (LocalizacaoId),
    CONSTRAINT UQ_Localizacoes_Nome UNIQUE (Nome)
);

CREATE TABLE dbo.Personagens (
    PersonagemId int IDENTITY(1,1) NOT NULL,
    UsuarioId int NOT NULL,
    RacaId int NOT NULL,
    ClasseId int NOT NULL,
    LocalizacaoId int NULL,
    Nome nvarchar(50) NOT NULL,
    Nivel tinyint NOT NULL
        CONSTRAINT DF_Personagens_Nivel DEFAULT (1),
    Experiencia bigint NOT NULL
        CONSTRAINT DF_Personagens_Experiencia DEFAULT (0),
    Ouro bigint NOT NULL
        CONSTRAINT DF_Personagens_Ouro DEFAULT (0),
    VidaAtual int NOT NULL
        CONSTRAINT DF_Personagens_VidaAtual DEFAULT (100),
    VidaMaxima int NOT NULL
        CONSTRAINT DF_Personagens_VidaMaxima DEFAULT (100),
    ManaAtual int NOT NULL
        CONSTRAINT DF_Personagens_ManaAtual DEFAULT (50),
    ManaMaxima int NOT NULL
        CONSTRAINT DF_Personagens_ManaMaxima DEFAULT (50),
    Forca smallint NOT NULL
        CONSTRAINT DF_Personagens_Forca DEFAULT (10),
    Destreza smallint NOT NULL
        CONSTRAINT DF_Personagens_Destreza DEFAULT (10),
    Inteligencia smallint NOT NULL
        CONSTRAINT DF_Personagens_Inteligencia DEFAULT (10),
    Constituicao smallint NOT NULL
        CONSTRAINT DF_Personagens_Constituicao DEFAULT (10),
    DataCriacao datetime2(0) NOT NULL
        CONSTRAINT DF_Personagens_DataCriacao DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Personagens PRIMARY KEY (PersonagemId),
    CONSTRAINT UQ_Personagens_Usuario_Nome UNIQUE (UsuarioId, Nome),
    CONSTRAINT FK_Personagens_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES dbo.Usuarios (UsuarioId),
    CONSTRAINT FK_Personagens_Racas FOREIGN KEY (RacaId)
        REFERENCES dbo.Racas (RacaId),
    CONSTRAINT FK_Personagens_Classes FOREIGN KEY (ClasseId)
        REFERENCES dbo.Classes (ClasseId),
    CONSTRAINT FK_Personagens_Localizacoes FOREIGN KEY (LocalizacaoId)
        REFERENCES dbo.Localizacoes (LocalizacaoId),
    CONSTRAINT CK_Personagens_Nivel CHECK (Nivel >= 1),
    CONSTRAINT CK_Personagens_Experiencia CHECK (Experiencia >= 0),
    CONSTRAINT CK_Personagens_Ouro CHECK (Ouro >= 0),
    CONSTRAINT CK_Personagens_Vida CHECK (VidaMaxima > 0 AND VidaAtual BETWEEN 0 AND VidaMaxima),
    CONSTRAINT CK_Personagens_Mana CHECK (ManaMaxima >= 0 AND ManaAtual BETWEEN 0 AND ManaMaxima),
    CONSTRAINT CK_Personagens_Atributos CHECK (
        Forca > 0 AND Destreza > 0 AND Inteligencia > 0 AND Constituicao > 0
    )
);

CREATE TABLE dbo.Itens (
    ItemId int IDENTITY(1,1) NOT NULL,
    Nome nvarchar(100) NOT NULL,
    Descricao nvarchar(500) NULL,
    Tipo nvarchar(20) NOT NULL,
    Raridade nvarchar(20) NOT NULL
        CONSTRAINT DF_Itens_Raridade DEFAULT (N'Comum'),
    ValorOuro int NOT NULL
        CONSTRAINT DF_Itens_ValorOuro DEFAULT (0),
    Peso decimal(8,2) NOT NULL
        CONSTRAINT DF_Itens_Peso DEFAULT (0),
    NivelRequerido tinyint NOT NULL
        CONSTRAINT DF_Itens_NivelRequerido DEFAULT (1),
    Empilhavel bit NOT NULL
        CONSTRAINT DF_Itens_Empilhavel DEFAULT (1),
    CONSTRAINT PK_Itens PRIMARY KEY (ItemId),
    CONSTRAINT UQ_Itens_Nome UNIQUE (Nome),
    CONSTRAINT CK_Itens_Tipo CHECK (Tipo IN (N'Arma', N'Armadura', N'Pocao', N'Missao', N'Outro')),
    CONSTRAINT CK_Itens_Raridade CHECK (
        Raridade IN (N'Comum', N'Incomum', N'Raro', N'Epico', N'Lendario')
    ),
    CONSTRAINT CK_Itens_ValorOuro CHECK (ValorOuro >= 0),
    CONSTRAINT CK_Itens_Peso CHECK (Peso >= 0),
    CONSTRAINT CK_Itens_NivelRequerido CHECK (NivelRequerido >= 1)
);

CREATE TABLE dbo.Inventario (
    PersonagemId int NOT NULL,
    ItemId int NOT NULL,
    Quantidade int NOT NULL
        CONSTRAINT DF_Inventario_Quantidade DEFAULT (1),
    CONSTRAINT PK_Inventario PRIMARY KEY (PersonagemId, ItemId),
    CONSTRAINT FK_Inventario_Personagens FOREIGN KEY (PersonagemId)
        REFERENCES dbo.Personagens (PersonagemId) ON DELETE CASCADE,
    CONSTRAINT FK_Inventario_Itens FOREIGN KEY (ItemId)
        REFERENCES dbo.Itens (ItemId),
    CONSTRAINT CK_Inventario_Quantidade CHECK (Quantidade > 0)
);

CREATE TABLE dbo.Habilidades (
    HabilidadeId int IDENTITY(1,1) NOT NULL,
    ClasseId int NULL,
    Nome nvarchar(100) NOT NULL,
    Descricao nvarchar(500) NULL,
    CustoMana int NOT NULL
        CONSTRAINT DF_Habilidades_CustoMana DEFAULT (0),
    NivelRequerido tinyint NOT NULL
        CONSTRAINT DF_Habilidades_NivelRequerido DEFAULT (1),
    CONSTRAINT PK_Habilidades PRIMARY KEY (HabilidadeId),
    CONSTRAINT UQ_Habilidades_Classe_Nome UNIQUE (ClasseId, Nome),
    CONSTRAINT FK_Habilidades_Classes FOREIGN KEY (ClasseId)
        REFERENCES dbo.Classes (ClasseId),
    CONSTRAINT CK_Habilidades_CustoMana CHECK (CustoMana >= 0),
    CONSTRAINT CK_Habilidades_NivelRequerido CHECK (NivelRequerido >= 1)
);

CREATE TABLE dbo.PersonagemHabilidades (
    PersonagemId int NOT NULL,
    HabilidadeId int NOT NULL,
    NivelHabilidade tinyint NOT NULL
        CONSTRAINT DF_PersonagemHabilidades_Nivel DEFAULT (1),
    DataAprendizado datetime2(0) NOT NULL
        CONSTRAINT DF_PersonagemHabilidades_Data DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_PersonagemHabilidades PRIMARY KEY (PersonagemId, HabilidadeId),
    CONSTRAINT FK_PersonagemHabilidades_Personagens FOREIGN KEY (PersonagemId)
        REFERENCES dbo.Personagens (PersonagemId) ON DELETE CASCADE,
    CONSTRAINT FK_PersonagemHabilidades_Habilidades FOREIGN KEY (HabilidadeId)
        REFERENCES dbo.Habilidades (HabilidadeId),
    CONSTRAINT CK_PersonagemHabilidades_Nivel CHECK (NivelHabilidade >= 1)
);

CREATE TABLE dbo.Missoes (
    MissaoId int IDENTITY(1,1) NOT NULL,
    LocalizacaoId int NULL,
    Nome nvarchar(120) NOT NULL,
    Descricao nvarchar(1000) NULL,
    NivelRequerido tinyint NOT NULL
        CONSTRAINT DF_Missoes_NivelRequerido DEFAULT (1),
    ExperienciaRecompensa int NOT NULL
        CONSTRAINT DF_Missoes_Experiencia DEFAULT (0),
    OuroRecompensa int NOT NULL
        CONSTRAINT DF_Missoes_Ouro DEFAULT (0),
    CONSTRAINT PK_Missoes PRIMARY KEY (MissaoId),
    CONSTRAINT UQ_Missoes_Nome UNIQUE (Nome),
    CONSTRAINT FK_Missoes_Localizacoes FOREIGN KEY (LocalizacaoId)
        REFERENCES dbo.Localizacoes (LocalizacaoId),
    CONSTRAINT CK_Missoes_NivelRequerido CHECK (NivelRequerido >= 1),
    CONSTRAINT CK_Missoes_Recompensas CHECK (
        ExperienciaRecompensa >= 0 AND OuroRecompensa >= 0
    )
);

CREATE TABLE dbo.PersonagemMissoes (
    PersonagemId int NOT NULL,
    MissaoId int NOT NULL,
    Status nvarchar(20) NOT NULL
        CONSTRAINT DF_PersonagemMissoes_Status DEFAULT (N'Em andamento'),
    DataAceite datetime2(0) NOT NULL
        CONSTRAINT DF_PersonagemMissoes_DataAceite DEFAULT (SYSUTCDATETIME()),
    DataConclusao datetime2(0) NULL,
    CONSTRAINT PK_PersonagemMissoes PRIMARY KEY (PersonagemId, MissaoId),
    CONSTRAINT FK_PersonagemMissoes_Personagens FOREIGN KEY (PersonagemId)
        REFERENCES dbo.Personagens (PersonagemId) ON DELETE CASCADE,
    CONSTRAINT FK_PersonagemMissoes_Missoes FOREIGN KEY (MissaoId)
        REFERENCES dbo.Missoes (MissaoId),
    CONSTRAINT CK_PersonagemMissoes_Status CHECK (
        Status IN (N'Em andamento', N'Concluida', N'Abandonada')
    ),
    CONSTRAINT CK_PersonagemMissoes_DataConclusao CHECK (
        (Status = N'Concluida' AND DataConclusao IS NOT NULL)
        OR (Status <> N'Concluida' AND DataConclusao IS NULL)
    )
);

CREATE TABLE dbo.Monstros (
    MonstroId int IDENTITY(1,1) NOT NULL,
    LocalizacaoId int NULL,
    Nome nvarchar(100) NOT NULL,
    Descricao nvarchar(500) NULL,
    Nivel tinyint NOT NULL,
    VidaMaxima int NOT NULL,
    ExperienciaRecompensa int NOT NULL
        CONSTRAINT DF_Monstros_Experiencia DEFAULT (0),
    OuroRecompensa int NOT NULL
        CONSTRAINT DF_Monstros_Ouro DEFAULT (0),
    CONSTRAINT PK_Monstros PRIMARY KEY (MonstroId),
    CONSTRAINT FK_Monstros_Localizacoes FOREIGN KEY (LocalizacaoId)
        REFERENCES dbo.Localizacoes (LocalizacaoId),
    CONSTRAINT CK_Monstros_Nivel CHECK (Nivel >= 1),
    CONSTRAINT CK_Monstros_Vida CHECK (VidaMaxima > 0),
    CONSTRAINT CK_Monstros_Recompensas CHECK (
        ExperienciaRecompensa >= 0 AND OuroRecompensa >= 0
    )
);

CREATE TABLE dbo.MonstroItens (
    MonstroId int NOT NULL,
    ItemId int NOT NULL,
    ChanceDrop decimal(5,2) NOT NULL,
    QuantidadeMinima int NOT NULL
        CONSTRAINT DF_MonstroItens_QuantidadeMinima DEFAULT (1),
    QuantidadeMaxima int NOT NULL
        CONSTRAINT DF_MonstroItens_QuantidadeMaxima DEFAULT (1),
    CONSTRAINT PK_MonstroItens PRIMARY KEY (MonstroId, ItemId),
    CONSTRAINT FK_MonstroItens_Monstros FOREIGN KEY (MonstroId)
        REFERENCES dbo.Monstros (MonstroId) ON DELETE CASCADE,
    CONSTRAINT FK_MonstroItens_Itens FOREIGN KEY (ItemId)
        REFERENCES dbo.Itens (ItemId),
    CONSTRAINT CK_MonstroItens_Chance CHECK (ChanceDrop BETWEEN 0 AND 100),
    CONSTRAINT CK_MonstroItens_Quantidade CHECK (
        QuantidadeMinima > 0 AND QuantidadeMaxima >= QuantidadeMinima
    )
);

CREATE TABLE dbo.Combates (
    CombateId bigint IDENTITY(1,1) NOT NULL,
    PersonagemId int NOT NULL,
    MonstroId int NOT NULL,
    Inicio datetime2(0) NOT NULL
        CONSTRAINT DF_Combates_Inicio DEFAULT (SYSUTCDATETIME()),
    Fim datetime2(0) NULL,
    Resultado nvarchar(10) NULL,
    ExperienciaGanha int NOT NULL
        CONSTRAINT DF_Combates_Experiencia DEFAULT (0),
    CONSTRAINT PK_Combates PRIMARY KEY (CombateId),
    CONSTRAINT FK_Combates_Personagens FOREIGN KEY (PersonagemId)
        REFERENCES dbo.Personagens (PersonagemId),
    CONSTRAINT FK_Combates_Monstros FOREIGN KEY (MonstroId)
        REFERENCES dbo.Monstros (MonstroId),
    CONSTRAINT CK_Combates_Resultado CHECK (
        Resultado IS NULL OR Resultado IN (N'Vitoria', N'Derrota', N'Fuga')
    ),
    CONSTRAINT CK_Combates_Fim CHECK (
        (Resultado IS NULL AND Fim IS NULL)
        OR (Resultado IS NOT NULL AND Fim IS NOT NULL AND Fim >= Inicio)
    ),
    CONSTRAINT CK_Combates_Experiencia CHECK (ExperienciaGanha >= 0)
);

CREATE INDEX IX_Personagens_RacaId_ClasseId
    ON dbo.Personagens (RacaId, ClasseId);
CREATE INDEX IX_Personagens_LocalizacaoId
    ON dbo.Personagens (LocalizacaoId);
CREATE INDEX IX_Inventario_ItemId
    ON dbo.Inventario (ItemId);
CREATE INDEX IX_PersonagemHabilidades_HabilidadeId
    ON dbo.PersonagemHabilidades (HabilidadeId);
CREATE INDEX IX_PersonagemMissoes_MissaoId
    ON dbo.PersonagemMissoes (MissaoId);
CREATE INDEX IX_Monstros_LocalizacaoId
    ON dbo.Monstros (LocalizacaoId);
CREATE INDEX IX_MonstroItens_ItemId
    ON dbo.MonstroItens (ItemId);
CREATE INDEX IX_Combates_PersonagemId_Inicio
    ON dbo.Combates (PersonagemId, Inicio);
