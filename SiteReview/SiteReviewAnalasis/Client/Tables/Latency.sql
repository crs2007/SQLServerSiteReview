CREATE TABLE [Client].[Latency] (
    [guid]                 UNIQUEIDENTIFIER NOT NULL,
    [Drive]                [sysname]        NOT NULL,
    [type]                 INT              NOT NULL,
    [num_of_reads]         BIGINT           NOT NULL,
    [io_stall_read_ms]     BIGINT           NOT NULL,
    [num_of_writes]        BIGINT           NOT NULL,
    [io_stall_write_ms]    BIGINT           NOT NULL,
    [num_of_bytes_read]    BIGINT           NOT NULL,
    [num_of_bytes_written] BIGINT           NOT NULL,
    [io_stall]             BIGINT           NULL,
    [ReadLatency]          BIGINT           NULL,
    [WriteLatency]         BIGINT           NULL,
    [OverallLatency]       BIGINT           NULL,
    [AvgBytesRead]         BIGINT           NULL,
    [AvgBytesWrite]        BIGINT           NULL,
    [AvgBytesTransfer]     BIGINT           NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[Latency]([guid] ASC) WITH (FILLFACTOR = 90)
    ON [Client];

