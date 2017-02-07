CREATE TABLE [Run].[Exeption] (
    [Guid]     UNIQUEIDENTIFIER NOT NULL,
    [CheckID]  INT              CONSTRAINT [DF_Exeption_CheckID] DEFAULT ((0)) NULL,
    [Type]     NVARCHAR (255)   NULL,
    [Message]  NVARCHAR (4000)  NULL,
    [URL]      VARCHAR (512)    NULL,
    [Severity] [sysname]        NULL,
    [Action]   NVARCHAR (4000)  NULL
);

