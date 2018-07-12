CREATE TABLE [Configuration].[sp_configurations] (
    [Name]         NVARCHAR (255) NOT NULL,
    [Minimum]      SQL_VARIANT    NOT NULL,
    [Maximum]      SQL_VARIANT    NOT NULL,
    [Default]      SQL_VARIANT    NOT NULL,
    [BestPractice] SQL_VARIANT    NULL,
    [BedPractice]  SQL_VARIANT    NULL,
    [Link]         NVARCHAR (MAX) NULL,
    [Note]         NVARCHAR (MAX) NULL
) ON [Configuration] TEXTIMAGE_ON [Configuration];



