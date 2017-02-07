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

END