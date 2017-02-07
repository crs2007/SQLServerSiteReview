CREATE TABLE [Client].[LoginIssu] (
    [guid] UNIQUEIDENTIFIER NOT NULL,
    [Weak] NVARCHAR (1000)  NOT NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[LoginIssu]([guid] ASC)
    ON [Secondery];

