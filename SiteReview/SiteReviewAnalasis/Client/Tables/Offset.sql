CREATE TABLE [Client].[Offset] (
    [guid]       UNIQUEIDENTIFIER NOT NULL,
    [VolumeName] [sysname]        NOT NULL,
    [MB]         BIGINT           NOT NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Offset]([guid] ASC)
    ON [Client];

