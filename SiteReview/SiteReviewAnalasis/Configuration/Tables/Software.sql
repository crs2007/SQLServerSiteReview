CREATE TABLE [Configuration].[Software] (
    [Software] NVARCHAR (255)  NOT NULL,
    [Link]     NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_Software] PRIMARY KEY CLUSTERED ([Software] ASC) ON [Configuration]
);

