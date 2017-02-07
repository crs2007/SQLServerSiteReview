CREATE TABLE [Client].[os_schedulers] (
    [guid]                  UNIQUEIDENTIFIER NOT NULL,
    [scheduler_id]          INT              NOT NULL,
    [current_tasks_count]   INT              NOT NULL,
    [runnable_tasks_count]  INT              NOT NULL,
    [pending_disk_io_count] INT              NOT NULL,
    [status]                NVARCHAR (60)    NULL,
    [parent_node_id]        INT              NULL,
    [is_online]             BIT              NULL,
    [is_idle]               BIT              NULL,
    [active_workers_count]  INT              NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[os_schedulers]([guid] ASC)
    ON [Client];

