CREATE TABLE [Configuration].[Database] (
    [ID]           INT       IDENTITY (1, 1) NOT NULL,
    [DatabaseName] [sysname] NOT NULL,
    [TypeID]       INT       NOT NULL,
    CONSTRAINT [PK_Database] PRIMARY KEY CLUSTERED ([ID] ASC) ON [Configuration],
    CONSTRAINT [FK_Database_DatabaseType] FOREIGN KEY ([TypeID]) REFERENCES [Configuration].[DatabaseType] ([ID])
);

