CREATE TABLE [Client].[DatabaseFiles] (
    [Database_Name] NVARCHAR (255)   NULL,
    [File_Name]     NVARCHAR (255)   NULL,
    [Physical_Name] NVARCHAR (MAX)   NULL,
    [File_Type]     NVARCHAR (255)   NULL,
    [database_id]   INT              NULL,
    [file_id]       INT              NULL,
    [Total_Size]    INT              NULL,
    [Free_Space]    INT              NULL,
    [Growth_Units]  NVARCHAR (255)   NULL,
    [Max_Size]      NVARCHAR (255)   NULL,
    [guid]          UNIQUEIDENTIFIER NOT NULL,
    [FG_ID]         INT              NULL,
    [FG_Name]       NVARCHAR (255)   NULL,
    [FG_type]       NVARCHAR (255)   NULL,
    [FG_Default]    INT              NULL
) TEXTIMAGE_ON [Client];


GO
CREATE CLUSTERED INDEX [CI_guid]
    ON [Client].[DatabaseFiles]([guid] ASC)
    ON [Client];

