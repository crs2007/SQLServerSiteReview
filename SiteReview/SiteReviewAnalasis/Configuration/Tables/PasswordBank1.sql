CREATE TABLE [Configuration].[PasswordBank1] (
    [ID]       INT            IDENTITY (1, 1) NOT NULL,
    [Password] NVARCHAR (512) NULL,
    CONSTRAINT [PK_PasswordBank1] PRIMARY KEY CLUSTERED ([ID] ASC)
);

