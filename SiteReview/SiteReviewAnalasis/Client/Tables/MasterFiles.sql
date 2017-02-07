CREATE TABLE [Client].[MasterFiles] (
    [guid]        UNIQUEIDENTIFIER NOT NULL,
    [size]        INT              NOT NULL,
    [file_id]     INT              NOT NULL,
    [database_id] INT              NOT NULL,
    [type]        INT              NOT NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[MasterFiles]([guid] ASC)
    ON [Client];

