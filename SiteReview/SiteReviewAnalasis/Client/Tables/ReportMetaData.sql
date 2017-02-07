CREATE TABLE [Client].[ReportMetaData] (
    [ReportGUID]       UNIQUEIDENTIFIER NOT NULL,
    [ClientID]         INT              NULL,
    [ClientName]       VARCHAR (255)    NULL,
    [RunDate]          DATETIME         NULL,
    [ServerName]       [sysname]        NULL,
    [IsExported]       BIT              CONSTRAINT [DF_ReportMetaData_IsExported] DEFAULT ((0)) NOT NULL,
    [ClientVersion]    VARCHAR (10)     CONSTRAINT [DF_ReportMetaData_ClientVersion] DEFAULT ('1.0') NOT NULL,
    [HaveExportError]  BIT              CONSTRAINT [DF_ReportMetaData_HaveExportError] DEFAULT ((0)) NOT NULL,
    [ExportError]      NVARCHAR (MAX)   NULL,
    [HaveSent]         BIT              CONSTRAINT [DF_ReportMetaData_HaveSent] DEFAULT ((0)) NOT NULL,
    [SentError]        NVARCHAR (MAX)   NULL,
    [ExportReportName] NVARCHAR (512)   NULL,
    CONSTRAINT [PK_ReportMetaData] PRIMARY KEY CLUSTERED ([ReportGUID] ASC) ON [Client]
) TEXTIMAGE_ON [Client];

