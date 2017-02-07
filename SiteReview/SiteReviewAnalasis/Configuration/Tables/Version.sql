CREATE TABLE [Configuration].[Version] (
    [ID]          INT       IDENTITY (1, 1) NOT NULL,
    [ReleaceDate] DATE      NOT NULL,
    [Major]       INT       NOT NULL,
    [Minor]       INT       NOT NULL,
    [FullVersion] AS        ((CONVERT([varchar](5),[Major])+'.')+CONVERT([varchar](5),[Minor])),
    [Platform]    [sysname] NOT NULL,
    CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED ([ID] ASC) ON [Configuration]
);

