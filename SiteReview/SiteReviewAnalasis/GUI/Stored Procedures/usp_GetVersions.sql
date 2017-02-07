
-- =============================================
-- Author:		Sharon
-- Create date: 01/07/2016
-- Update date: 
-- Description:	Gui - Get Versions
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetVersions] @Guid VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	TOP 1 V.Platform [App],V.FullVersion
	INTO	#Version
	FROM	[Configuration].Version V
	WHERE	V.Platform = 'Report'
	ORDER BY 2 DESC;

	INSERT #Version
	SELECT	TOP 1 V.Platform [App],V.FullVersion
	FROM	[Configuration].Version V
	WHERE	V.Platform = 'Server'
	ORDER BY 2 DESC;

	SELECT	'Client' [App],RMD.ClientVersion [Version]
	FROM	Client.ReportMetaData RMD
	WHERE	RMD.ReportGUID = @Guid
	UNION ALL 
	SELECT	[App],V.FullVersion
	FROM	#Version V;
	
END




