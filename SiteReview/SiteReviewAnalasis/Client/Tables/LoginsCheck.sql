CREATE TABLE [Client].[LoginsCheck] (
    [guid]          UNIQUEIDENTIFIER NOT NULL,
    [Name]          [sysname]        NOT NULL,
    [Algoritm]      [sysname]        NOT NULL,
    [ClearPassword] NVARCHAR (128)   NOT NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[LoginsCheck]([guid] ASC) WITH (FILLFACTOR = 90)
    ON [Client];

