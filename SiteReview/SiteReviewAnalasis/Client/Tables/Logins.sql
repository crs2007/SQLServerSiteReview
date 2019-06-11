CREATE TABLE [Client].[Logins] (
    [guid]          UNIQUEIDENTIFIER NOT NULL,
    [Name]          [sysname]        NOT NULL,
    [Header]        VARBINARY (MAX)  NOT NULL,
    [Salt]          VARBINARY (MAX)  NOT NULL,
    [password_hash] VARBINARY (MAX)  NOT NULL,
    [sid]           NVARCHAR (85)    NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Logins]([guid] ASC) WITH (FILLFACTOR = 90)
    ON [Client];

