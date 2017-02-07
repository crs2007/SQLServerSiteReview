CREATE TABLE [Client].[Replications] (
    [guid]     UNIQUEIDENTIFIER NOT NULL,
    [ID]       INT              NOT NULL,
    [Messages] NVARCHAR (MAX)   NOT NULL,
    [Type]     [sysname]        NOT NULL,
    [Link]     NVARCHAR (MAX)   NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Replications]([guid] ASC)
    ON [Client];

