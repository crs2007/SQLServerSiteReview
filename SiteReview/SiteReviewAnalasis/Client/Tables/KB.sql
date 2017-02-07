CREATE TABLE [Client].[KB] (
    [guid] UNIQUEIDENTIFIER NOT NULL,
    [KBID] VARCHAR (255)    NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[KB]([guid] ASC)
    ON [Client];

