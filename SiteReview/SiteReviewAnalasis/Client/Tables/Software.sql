CREATE TABLE [Client].[Software] (
    [guid]     UNIQUEIDENTIFIER NOT NULL,
    [Software] NVARCHAR (255)   NULL,
    [Status]   BIT              CONSTRAINT [DF_Status] DEFAULT ((0)) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Software]([guid] ASC) WITH (FILLFACTOR = 90)
    ON [Client];

