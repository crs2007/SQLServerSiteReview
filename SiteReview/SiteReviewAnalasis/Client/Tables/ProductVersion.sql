CREATE TABLE [Client].[ProductVersion] (
    [Guid]               UNIQUEIDENTIFIER NOT NULL,
    [Version]            NVARCHAR (128)   NOT NULL,
    [Common_version]     AS               (substring([version],(1),charindex('.',[version])+(1))),
    [Major]              AS               (parsename(CONVERT([varchar](32),[version]),(4))),
    [Minor]              AS               (parsename(CONVERT([varchar](32),[version]),(3))),
    [Build]              AS               (parsename(CONVERT([varchar](32),[version]),(2))),
    [Revision]           AS               (parsename(CONVERT([varchar](32),[version]),(1))),
    [CompatibilityLevel] AS               (parsename(CONVERT([varchar](32),[version]),(4))+'0')
) ON [Client];

