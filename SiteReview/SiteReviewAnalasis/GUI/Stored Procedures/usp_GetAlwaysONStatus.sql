-- =============================================
-- Author:		Sharon
-- Create date: 11/06/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetAlwaysONStatus] @guid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

	SELECT	H.database_name,H.replica_server_name,H.ag_name,
			CONCAT('Database - ',H.database_name,' on the ',case H.is_local when 1 then 'local server' when 0 then 'remote(' + H.replica_server_name + ')' else '' end, ' that in group - ',H.ag_name,' are ',H.synchronization_state_desc,' and its ',H.synchronization_health_desc) [Message]
	FROM	Client.HADR H
	WHERE	H.Guid = @guid
			AND (H.synchronization_state_desc != 'SYNCHRONIZED' OR H.synchronization_health_desc != 'HEALTHY')
	UNION ALL 
	SELECT	AOL.database_name,AOL.PrimaryServer,AOL.AlwaysOnGroup,
			CONCAT('Database - ',AOL.database_name,' on the server ' ,AOL.PrimaryServer, ' that in group - ',AOL.AlwaysOnGroup,' have high Latency - ',AOL.lag_in_milliseconds/1000,' secondes.') [Message]
	FROM	Client.AlwaysOnLatency AOL
	WHERE	AOL.Guid = @guid
			AND AOL.lag_in_milliseconds > 600000
	UNION ALL 
	SELECT	NULL,IIF(LEN(M.[Replica])> 15,NULL,M.[Replica]) [Replica],IIF(LEN(M.Msg)> 15,NULL,M.Msg) [AlwaysOnGroup],H.[Msg]
	FROM	[Client].[HADRStatus] H
			CROSS APPLY (SELECT Utility.ufn_Util_clr_RegexReplace(H.[Msg],'(Availability Group\- \[([\w\W]*)\][\w\W]*)','$2',0) [Msg],
			Utility.ufn_Util_clr_RegexReplace(H.[Msg],'(Replica name \- \[([\w\W]*)\][\w\W]*)','$2',0) [Replica])M
	WHERE	[guid] = @guid
	UNION ALL 
	SELECT	'master',hr.ReplicaServerName,ag_name,CONCAT('Node ',hr.ReplicaServerName,' have diffrent CPU from this server.')[Message]
	FROM	Client.MachineSettings ms
			CROSS APPLY (SELECT TOP (1) r.CPU,r.NumberOfLogicalProcessors,r.Cores,h.ag_name FROM [Client].RemoteServerNode r INNER JOIN [Client].[HADR] h ON h.guid = r.Guid AND h.replica_server_name = ms.ServerName WHERE r.[Guid] = @guid AND r.Server = ms.MachineName)CurrentServer
			INNER JOIN Client.HADRReplicas hr ON hr.Guid = ms.guid
			INNER JOIN [Client].RemoteServerNode rsn ON rsn.Guid = ms.guid 
				AND rsn.Server = hr.ComputerNamePhysicalNetBIOS
	WHERE	ms.[Guid] = @guid
			AND CurrentServer.CPU != rsn.CPU
	UNION ALL 
	SELECT	'master',hr.ReplicaServerName,ag_name,CONCAT('Node ',hr.ReplicaServerName,' have diffrent NumberOfLogicalProcessors from this server.')[Message]
	FROM	Client.MachineSettings ms
			CROSS APPLY (SELECT TOP (1) r.CPU,r.NumberOfLogicalProcessors,r.Cores,h.ag_name FROM [Client].RemoteServerNode r INNER JOIN [Client].[HADR] h ON h.guid = r.Guid AND h.replica_server_name = ms.ServerName WHERE r.[Guid] = @guid AND r.Server = ms.MachineName)CurrentServer
			INNER JOIN Client.HADRReplicas hr ON hr.Guid = ms.guid
			INNER JOIN [Client].RemoteServerNode rsn ON rsn.Guid = ms.guid 
				AND rsn.Server = hr.ComputerNamePhysicalNetBIOS
	WHERE	ms.[Guid] = @guid
			AND CurrentServer.NumberOfLogicalProcessors != rsn.NumberOfLogicalProcessors
	UNION ALL
	SELECT	'master',hr.ReplicaServerName,ag_name,CONCAT('Node ',hr.ReplicaServerName,' have diffrent number of Cores from this server.')[Message]
	FROM	Client.MachineSettings ms
			CROSS APPLY (SELECT TOP (1) r.CPU,r.NumberOfLogicalProcessors,r.Cores,h.ag_name FROM [Client].RemoteServerNode r INNER JOIN [Client].[HADR] h ON h.guid = r.Guid AND h.replica_server_name = ms.ServerName WHERE r.[Guid] = @guid AND r.Server = ms.MachineName)CurrentServer
			INNER JOIN Client.HADRReplicas hr ON hr.Guid = ms.guid
			INNER JOIN [Client].RemoteServerNode rsn ON rsn.Guid = ms.guid 
				AND rsn.Server = hr.ComputerNamePhysicalNetBIOS
	WHERE	ms.[Guid] = @guid
			AND CurrentServer.Cores != rsn.Cores

END
