CREATE TABLE [Configuration].[PasswordBank1] (
    [ID]       INT            IDENTITY (1, 1) NOT NULL,
    [Password] NVARCHAR (512) NULL
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CSIX_PasswordBank]
    ON [Configuration].[PasswordBank1];

