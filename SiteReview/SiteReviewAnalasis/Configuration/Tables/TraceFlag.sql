CREATE TABLE [Configuration].[TraceFlag] (
    [TraceFlag]          INT             NOT NULL,
    [Description]        NVARCHAR (MAX)  NULL,
    [FromProductVersion] NVARCHAR (128)  NULL,
    [ToProductVersion]   NVARCHAR (128)  NULL,
    [Link]               NVARCHAR (1000) NULL
) ON [Configuration] TEXTIMAGE_ON [Configuration];

