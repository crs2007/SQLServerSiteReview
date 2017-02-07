CREATE TABLE [Configuration].[Product_Configuration] (
    [ID]    INT         IDENTITY (1, 1) NOT NULL,
    [Name]  [sysname]   NOT NULL,
    [Value] SQL_VARIANT NOT NULL,
    CONSTRAINT [PK_Product_Configuration] PRIMARY KEY CLUSTERED ([ID] ASC) ON [Configuration]
);

