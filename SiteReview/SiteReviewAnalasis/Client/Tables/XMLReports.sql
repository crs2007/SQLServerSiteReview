CREATE TABLE [Client].[XMLReports] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [XMLData]        XML            NULL,
    [LoadedDateTime] DATETIME       CONSTRAINT [DF_LoadedDateTime] DEFAULT (getdate()) NOT NULL,
    [IsPopulated]    BIT            CONSTRAINT [DF_XMLReports_IsPopulated] DEFAULT ((0)) NOT NULL,
    [FileName]       NVARCHAR (260) NULL,
    [ClientID]       INT            NULL,
    [HaveError]      BIT            CONSTRAINT [DF_XMLReports_HaveError] DEFAULT ((0)) NOT NULL,
    [Error]          NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_XMLReports] PRIMARY KEY CLUSTERED ([ID] ASC)
);

