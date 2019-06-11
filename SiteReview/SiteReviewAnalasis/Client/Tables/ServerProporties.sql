CREATE TABLE [Client].[ServerProporties] (
    [guid]                           UNIQUEIDENTIFIER NOT NULL,
    [logicalCPU]                     INT              NOT NULL,
    [CPU_Core]                       INT              NOT NULL,
    [hyperthread_ratio]              INT              NULL,
    [VirtualMemory]                  BIGINT           NULL,
    [Committed]                      INT              NULL,
    [CommittedTarget]                INT              NULL,
    [VisibleTarget]                  INT              NULL,
    [os_quantum]                     INT              NULL,
    [os_error_mode]                  INT              NULL,
    [os_priority_class]              INT              NULL,
    [max_workers_count]              INT              NULL,
    [scheduler_count]                INT              NULL,
    [scheduler_total_count]          INT              NULL,
    [deadlock_monitor_serial_number] BIGINT           NULL,
    [sqlserver_start_time]           DATETIME         NOT NULL,
    [affinity_type]                  INT              NULL,
    [virtual_machine_type]           INT              NULL,
    [OS_bit]                         INT              NULL,
    [PlatformType]                   INT              NULL,
    [ThreadStack]                    INT              NULL,
    [OS_Mem]                         FLOAT (53)       NULL,
    [PLE]                            INT              NULL,
    [PhysicalMemory]                 BIGINT           NULL,
    [OSName]                         NVARCHAR (1000)  NULL,
    [softnuma_configuration]         INT              NULL,
    [softnuma_configuration_desc]    NVARCHAR (60)    NULL,
    [sql_memory_model]               INT              NULL,
    [sql_memory_model_desc]          NVARCHAR (120)   NULL,
    [socket_count]                   INT              NULL,
    [cores_per_socket]               INT              NULL,
    [numa_node_count]                INT              NULL,
    [IsLinux]                        BIT              NULL
);


GO
CREATE CLUSTERED INDEX [CIX_guid]
    ON [Client].[ServerProporties]([guid] ASC)
    ON [Client];

