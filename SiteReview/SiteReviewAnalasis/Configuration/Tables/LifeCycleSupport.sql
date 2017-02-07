CREATE TABLE [Configuration].[LifeCycleSupport] (
    [CompatibilityLevel]        INT            NOT NULL,
    [ProductsReleased]          NVARCHAR (255) NOT NULL,
    [StartDate]                 DATE           NOT NULL,
    [MainstreamSupportEndDate]  DATE           NULL,
    [ExtendedSupportEndDate]    DATE           NULL,
    [ServicePackSupportEndDate] DATE           NULL,
    CONSTRAINT [PK_LifeCycleSupport] PRIMARY KEY CLUSTERED ([ProductsReleased] ASC) ON [Configuration]
);

