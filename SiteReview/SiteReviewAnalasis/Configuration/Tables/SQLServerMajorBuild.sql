CREATE TABLE [Configuration].[SQLServerMajorBuild] (
    [Major] INT NOT NULL,
    [Year]  INT NOT NULL,
    CONSTRAINT [PK_SQLServerMajorBuild] PRIMARY KEY CLUSTERED ([Major] ASC) ON [Configuration]
);

