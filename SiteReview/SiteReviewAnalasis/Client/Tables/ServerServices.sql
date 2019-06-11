CREATE TABLE [Client].[ServerServices] (
    [Guid]            UNIQUEIDENTIFIER NOT NULL,
    [ServiceName]     [sysname]        NOT NULL,
    [StartupTypeDesc] NVARCHAR (255)   NOT NULL,
    [StartupType]     INT              NOT NULL,
    [Status]          INT              NOT NULL,
    [StatusDesc]      NVARCHAR (255)   NOT NULL,
    [ServiceAccount]  NVARCHAR (255)   NOT NULL,
    [instant_file_initialization_enabled] BIT              NULL
);


GO
CREATE CLUSTERED INDEX [CIX_Guid]
    ON [Client].[ServerServices]([Guid] ASC)
    ON [Client];

