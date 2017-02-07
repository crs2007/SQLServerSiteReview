CREATE TABLE [Configuration].[Images] (
    [ID]   INT             IDENTITY (1, 1) NOT NULL,
    [Name] [sysname]       NOT NULL,
    [img]  VARBINARY (MAX) NOT NULL,
    CONSTRAINT [PK_Images] PRIMARY KEY CLUSTERED ([ID] ASC) ON [Configuration]
) TEXTIMAGE_ON [Configuration];

