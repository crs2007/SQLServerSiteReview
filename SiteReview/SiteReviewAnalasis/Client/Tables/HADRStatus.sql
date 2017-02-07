CREATE TABLE [Client].[HADRStatus] (
    [guid]   UNIQUEIDENTIFIER NOT NULL,
    [TypeID] INT              NOT NULL,
    [Msg]    NVARCHAR (MAX)   NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[HADRStatus]([guid] ASC)
    ON [Client];

