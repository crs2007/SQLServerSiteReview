CREATE TABLE [Client].[SPConfigure] (
    [guid]  UNIQUEIDENTIFIER NOT NULL,
    [name]  NVARCHAR (255)   NULL,
    [value] INT              NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[SPConfigure]([guid] ASC) WITH (FILLFACTOR = 90)
    ON [Client];

