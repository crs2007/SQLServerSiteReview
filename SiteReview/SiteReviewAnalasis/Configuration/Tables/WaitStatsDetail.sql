CREATE TABLE [Configuration].[WaitStatsDetail] (
    [Wait_type] NVARCHAR (60) COLLATE Hebrew_CI_AI NOT NULL,
    [Area]      VARCHAR (60)  COLLATE Hebrew_CI_AI NULL,
    [BOL]       VARCHAR (MAX) COLLATE Hebrew_CI_AI NULL,
    [Detail]    VARCHAR (MAX) COLLATE Hebrew_CI_AI NULL,
    [Action]    VARCHAR (MAX) COLLATE Hebrew_CI_AI NULL,
    [Ignore]    BIT           CONSTRAINT [DF_LiveMonitor_WaitStatsDetail_Ignore] DEFAULT ((0)) NOT NULL
) ON [Configuration] TEXTIMAGE_ON [Configuration];

