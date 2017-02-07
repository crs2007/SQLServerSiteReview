-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetFreeSpaceChart
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetAllReportOnTheServer]
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT  TOP 100 
			CONVERT(NVARCHAR(36),RM.ReportGUID) ID ,
			RM.ClientName + ' - ' + RM.ServerName + ' - '
			+ CONVERT(VARCHAR(MAX), RM.RunDate, 103) AS ReportName ,
			CONVERT(VARCHAR(MAX), RM.RunDate, 103) AS [Date] ,
			+RM.ServerName
	FROM    [Client].[ReportMetaData] RM
	ORDER BY RM.RunDate DESC;	
END
