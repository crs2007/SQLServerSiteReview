CREATE TABLE [Client].[VersionBug] (
    [guid]      UNIQUEIDENTIFIER NOT NULL,
    [Version]   NVARCHAR (30)    NOT NULL,
    [Detail]    NVARCHAR (MAX)   NULL,
    [IntDetail] INT              NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[VersionBug]([guid] ASC)
    ON [Client];

