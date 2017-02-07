CREATE TABLE [Client].[MaintenancePlanFiles] (
    [guid]                UNIQUEIDENTIFIER NOT NULL,
    [MaintenancePlanName] [sysname]        NULL,
    [SizeInMB]            FLOAT (53)       NULL,
    [NumberOfFiles]       INT              NULL,
    [OldFile]             DATE             NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[MaintenancePlanFiles]([guid] ASC)
    ON [Client];

