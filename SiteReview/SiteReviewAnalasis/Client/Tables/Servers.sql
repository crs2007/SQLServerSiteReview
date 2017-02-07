CREATE TABLE [Client].[Servers] (
    [guid]        UNIQUEIDENTIFIER NOT NULL,
    [server_id]   INT              NOT NULL,
    [name]        [sysname]        NOT NULL,
    [data_source] NVARCHAR (MAX)   NULL,
    [is_linked]   BIT              NOT NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Servers]([guid] ASC)
    ON [Client];

