CREATE TABLE [Client].[Mirror] (
    [guid]              UNIQUEIDENTIFIER NOT NULL,
    [DatabaseName]      VARCHAR (255)    NULL,
    [Role]              INT              NULL,
    [MirroringState]    TINYINT          NULL,
    [WitnessStatus]     TINYINT          NULL,
    [LogGeneratRate]    INT              NULL,
    [UnsentLog]         INT              NULL,
    [SentRate]          INT              NULL,
    [UnrestoredLog]     INT              NULL,
    [RecoveryRate]      INT              NULL,
    [TransactionDelay]  INT              NULL,
    [TransactionPerSec] INT              NULL,
    [AverageDelay]      INT              NULL,
    [TimeRecorded]      DATETIME         NULL,
    [TimeBehind]        DATETIME         NULL,
    [LocalTime]         DATETIME         NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Mirror]([guid] ASC)
    ON [Client];

