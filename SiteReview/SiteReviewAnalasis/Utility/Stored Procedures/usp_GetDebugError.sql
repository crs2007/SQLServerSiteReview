-- =============================================
-- Author:		Sharon
-- Create date: 13/10/2016
-- Update date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [Utility].[usp_GetDebugError] 
AS
BEGIN
    SET NOCOUNT ON;

	SELECT	RMD.ReportGUID,
			RMD.ClientName,
			RMD.RunDate,
			RMD.ServerName,
			RMD.ClientVersion,
			DE.Subject,
			DE.Error,
			DE.Duration
	FROM	Client.DebugError DE
			INNER JOIN Client.ReportMetaData RMD ON DE.guid = RMD.ReportGUID
	WHERE	DE.Error != ''
			AND DE.Error NOT LIKE '%Could not obtain information about Windows NT group/user%'
	ORDER BY RMD.RunDate DESC;
END
