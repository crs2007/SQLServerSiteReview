CREATE TABLE [Client].[AlwaysOnLatency] (
    [Guid]                UNIQUEIDENTIFIER NOT NULL,
    [AlwaysOnGroup]       [sysname]        NULL,
    [PrimaryServer]       NVARCHAR (256)   NULL,
    [SecondaryServer]     NVARCHAR (256)   NULL,
    [database_name]       NVARCHAR (128)   NULL,
    [last_commit_time]    DATETIME         NULL,
    [DR_commit_time]      DATETIME         NULL,
    [lag_in_milliseconds] INT              NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[AlwaysOnLatency]([Guid] ASC) WITH (FILLFACTOR = 90)
    ON [Client];

