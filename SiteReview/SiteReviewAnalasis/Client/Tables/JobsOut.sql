CREATE TABLE [Client].[JobsOut] (
    [Guid]            UNIQUEIDENTIFIER NOT NULL,
    [JobName]         [sysname]        NOT NULL,
    [StepID]          INT              NULL,
    [StepName]        [sysname]        NOT NULL,
    [Outcome]         NVARCHAR (255)   NULL,
    [LastRunDatetime] DATETIME         NULL,
    [SubSystem]       NVARCHAR (512)   NULL,
    [Message]         NVARCHAR (MAX)   NULL,
    [Caller]          NVARCHAR (255)   NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[JobsOut]([Guid] ASC)
    ON [Client];

