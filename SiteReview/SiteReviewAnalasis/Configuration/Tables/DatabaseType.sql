CREATE TABLE [Configuration].[DatabaseType] (
    [ID]   INT       IDENTITY (1, 1) NOT NULL,
    [Name] [sysname] NOT NULL,
    CONSTRAINT [PK_DatabaseType] PRIMARY KEY CLUSTERED ([ID] ASC) ON [Configuration]
);

