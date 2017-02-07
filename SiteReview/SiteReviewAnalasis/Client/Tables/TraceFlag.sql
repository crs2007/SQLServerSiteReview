CREATE TABLE [Client].[TraceFlag] (
    [guid]      UNIQUEIDENTIFIER NOT NULL,
    [TraceFlag] INT              NOT NULL,
    [status]    INT              NOT NULL,
    [Global]    INT              NOT NULL,
    [Session]   INT              NOT NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[TraceFlag]([guid] ASC)
    ON [Client];

