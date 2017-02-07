CREATE TABLE [Client].[LoginIssue] (
    [guid]    UNIQUEIDENTIFIER NOT NULL,
    [Message] NVARCHAR (MAX)   NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[LoginIssue]([guid] ASC)
    ON [Client];

