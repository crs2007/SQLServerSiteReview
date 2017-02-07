CREATE TABLE [Client].[Jobs] (
    [guid]               UNIQUEIDENTIFIER NOT NULL,
    [JobName]            [sysname]        NOT NULL,
    [RunDateTime]        DATETIME         NOT NULL,
    [RunDurationMinutes] INT              NOT NULL,
    [Type]               NVARCHAR (255)   NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Jobs]([guid] ASC)
    ON [Client];

