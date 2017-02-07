CREATE TABLE [Client].[Registery] (
    [guid]            UNIQUEIDENTIFIER NOT NULL,
    [Service]         [sysname]        NOT NULL,
    [InstanceNames]   [sysname]        NOT NULL,
    [keyName]         NVARCHAR (255)   NOT NULL,
    [Value]           [sysname]        NOT NULL,
    [CurrentInstance] BIT              CONSTRAINT [DF_Registery_CurrentInstance] DEFAULT ((0)) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Registery]([guid] ASC)
    ON [Client];

