CREATE TABLE [Client].[Blitz] (
    [guid]              UNIQUEIDENTIFIER NOT NULL,
    [ID]                INT              NOT NULL,
    [ServerName]        NVARCHAR (128)   NULL,
    [CheckDate]         DATETIME         NULL,
    [BlitzVersion]      VARCHAR (10)     NULL,
    [Priority]          TINYINT          NULL,
    [FindingsGroup]     VARCHAR (50)     NULL,
    [Finding]           VARCHAR (200)    NULL,
    [DatabaseName]      NVARCHAR (128)   NULL,
    [URL]               VARCHAR (200)    NULL,
    [Details]           NVARCHAR (4000)  NULL,
    [QueryPlan]         XML              NULL,
    [QueryPlanFiltered] NVARCHAR (MAX)   NULL,
    [CheckID]           INT              NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Blitz]([guid] ASC)
    ON [Client];

