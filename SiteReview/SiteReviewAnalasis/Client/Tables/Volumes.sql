CREATE TABLE [Client].[Volumes] (
    [guid]            UNIQUEIDENTIFIER NOT NULL,
    [VolumeName]      VARCHAR (5)      NOT NULL,
    [available_bytes] BIGINT           NOT NULL,
    [total_bytes]     BIGINT           NOT NULL,
    [DriveLeter]      VARCHAR (5)      NOT NULL,
    [BlockSize]       INT              NOT NULL,
    [VolumeLeble]     NVARCHAR (255)   NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Volumes]([guid] ASC)
    ON [Client];

