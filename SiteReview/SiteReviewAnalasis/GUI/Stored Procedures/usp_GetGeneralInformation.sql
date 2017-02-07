-- =============================================
-- Author:		Dror
-- Create date: 2012
-- Update date: 2016/06/08 Sharon
--				2016/07/21 Sharon Utility.ufn_Util_clr_RegexReplace(Version,'Microsoft SQL Server [\d]+ \- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$1',0)
-- Description:	
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetGeneralInformation] @guid UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 'Report Number'[Name],CONVERT(NVARCHAR(MAX),@guid)[Value],NULL [Note]
	UNION ALL SELECT 'Client name',RMD.ClientName , NULL
	FROM	Client.ReportMetaData RMD
	WHERE	RMD.ReportGUID = @guid
	UNION ALL SELECT 'Date of collection',CONVERT(NVARCHAR(MAX),RMD.RunDate,103) , NULL
	FROM	Client.ReportMetaData RMD
	WHERE	RMD.ReportGUID = @guid
	UNION ALL SELECT 'Client Analysis Version',RMD.ClientVersion , IIF(RMD.ClientVersion < '1.00','Alfa Version',NULL)
	FROM	Client.ReportMetaData RMD
	WHERE	RMD.ReportGUID = @guid
	UNION ALL 
	SELECT	TOP 1 'Server Analysis Version' [App],V.FullVersion, IIF(V.FullVersion < '1.00','Alfa Version',NULL)
	FROM	[Configuration].Version V
	WHERE	V.Platform = 'Server'
	UNION ALL
	SELECT	TOP 1 'Report Version' [App],V.FullVersion, IIF(V.FullVersion < '1.00','Alfa Version',NULL)
	FROM	[Configuration].Version V
	WHERE	V.Platform = 'Report'
	ORDER BY 2 DESC;

END