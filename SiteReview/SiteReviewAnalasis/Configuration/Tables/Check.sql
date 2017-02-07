CREATE TABLE [Configuration].[Check] (
    [ID]          INT             NOT NULL,
    [Name]        NVARCHAR (255)  NOT NULL,
    [Description] NVARCHAR (1500) NULL,
    CONSTRAINT [PK_Check] PRIMARY KEY CLUSTERED ([ID] ASC) ON [Configuration]
);

