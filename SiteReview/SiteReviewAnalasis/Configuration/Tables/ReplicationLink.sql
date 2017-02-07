CREATE TABLE [Configuration].[ReplicationLink] (
    [ID]   INT            NOT NULL,
    [Link] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_ReplicationLink] PRIMARY KEY CLUSTERED ([ID] ASC) ON [Configuration]
) TEXTIMAGE_ON [Configuration];

