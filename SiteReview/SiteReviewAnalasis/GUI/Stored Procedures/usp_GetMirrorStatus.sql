-- =============================================
-- Author:		Sharon
-- Create date: 11/06/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetMirrorStatus] @guid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

	SELECT  M.DatabaseName ,
			 CASE M.Role 
			 WHEN 1 THEN 'PRINCIPAL' 
			 WHEN 2 THEN 'MIRROR' 
			 END [Role],
		    CASE M.MirroringState 
			 WHEN 0 THEN 'SUSPENDED' 
			 WHEN 1 THEN 'DISCONNECTED' 
			 WHEN 2 THEN 'SYNCHRONIZING' 
			 WHEN 3 THEN 'PENDING FAILOVER' 
			 WHEN 4 THEN 'SYNCHRONIZED' 
			 END MirroringState,
		    CASE M.WitnessStatus 
			 WHEN 0 THEN 'UNKNOWN' 
			 WHEN 1 THEN 'CONNECTED' 
			 WHEN 2 THEN 'DISCONNECTED' 
			 END WitnessStatus,
		    M.LogGeneratRate ,
		    M.UnsentLog ,
		    M.SentRate ,
		    M.UnrestoredLog ,
		    M.RecoveryRate ,
		    M.TransactionDelay ,
		    M.TransactionPerSec ,
		    M.AverageDelay ,
		    M.TimeRecorded ,
		    M.TimeBehind ,
		    M.LocalTime
	FROM	Client.Mirror M
	WHERE	M.guid = @guid

END