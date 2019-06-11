CREATE TABLE [Client].[RemoteServerNode] (
    [Guid]                      UNIQUEIDENTIFIER NOT NULL,
    [Server]                    [sysname]        NULL,
    [CPU]                       NVARCHAR (2000)  NULL,
    [NumberOfLogicalProcessors] SMALLINT         NULL,
    [Cores]                     SMALLINT         NULL
);
