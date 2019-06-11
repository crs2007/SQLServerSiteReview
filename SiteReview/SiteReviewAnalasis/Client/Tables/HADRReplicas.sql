CREATE TABLE [Client].[HADRReplicas] (
    [Guid]                        UNIQUEIDENTIFIER NOT NULL,
    [ReplicaServerName]           [sysname]        NOT NULL,
    [ComputerNamePhysicalNetBIOS] [sysname]        NOT NULL
);
