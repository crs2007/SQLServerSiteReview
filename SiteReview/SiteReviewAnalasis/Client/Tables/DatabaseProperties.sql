CREATE TABLE [Client].[DatabaseProperties] (
    [guid]         UNIQUEIDENTIFIER NOT NULL,
    [Type]         [sysname]        NOT NULL,
    [DatabaseName] [sysname]        NOT NULL,
    [Note]         NVARCHAR (MAX)   NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[DatabaseProperties]([guid] ASC)
    ON [Client];

