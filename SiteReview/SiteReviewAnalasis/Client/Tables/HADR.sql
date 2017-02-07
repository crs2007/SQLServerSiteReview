CREATE TABLE [Client].[HADR] (
    [guid]                        UNIQUEIDENTIFIER NOT NULL,
    [replica_server_name]         NVARCHAR (256)   NULL,
    [database_name]               [sysname]        NULL,
    [ag_name]                     [sysname]        NULL,
    [is_local]                    BIT              NULL,
    [synchronization_state_desc]  NVARCHAR (60)    NULL,
    [is_commit_participant]       BIT              NULL,
    [synchronization_health_desc] NVARCHAR (60)    NULL,
    [recovery_lsn]                NUMERIC (25)     NULL,
    [truncation_lsn]              NUMERIC (25)     NULL,
    [last_sent_lsn]               NUMERIC (25)     NULL,
    [last_sent_time]              DATETIME         NULL,
    [last_received_lsn]           NUMERIC (25)     NULL,
    [last_received_time]          DATETIME         NULL,
    [last_hardened_lsn]           NUMERIC (25)     NULL,
    [last_hardened_time]          DATETIME         NULL,
    [last_redone_lsn]             NUMERIC (25)     NULL,
    [last_redone_time]            DATETIME         NULL,
    [log_send_queue_size]         BIGINT           NULL,
    [log_send_rate]               BIGINT           NULL,
    [redo_queue_size]             BIGINT           NULL,
    [redo_rate]                   BIGINT           NULL,
    [filestream_send_rate]        BIGINT           NULL,
    [end_of_log_lsn]              NUMERIC (25)     NULL,
    [last_commit_lsn]             NUMERIC (25)     NULL,
    [last_commit_time]            DATETIME         NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[HADR]([guid] ASC)
    ON [Client];

