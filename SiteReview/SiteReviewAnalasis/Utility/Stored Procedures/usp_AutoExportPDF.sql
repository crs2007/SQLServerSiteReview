-- =============================================
-- Author:		Sharon
-- Create date: 19/06/2016
-- Update date: 
-- Description:	Auto Update XML
-- =============================================
CREATE PROCEDURE [Utility].[usp_AutoExportPDF]
AS
BEGIN
	SET NOCOUNT ON;

	--Constant 4 This Environment
	DECLARE @ServicePathUrl NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('ServicePathUrl'));
	DECLARE @reportPath NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('ReportPath'));
	DECLARE @ExportPath NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('ExportPath'));
	DECLARE @ExportPathReport NVARCHAR(MAX);

	DECLARE @ExportReportName NVARCHAR(MAX) 
	--DECLARE @InputParameter NVARCHAR(MAX) 
	DECLARE @ReportGUID VARCHAR(50);

	
    DECLARE @ClientID INT;
    DECLARE @ClientName VARCHAR(1000);
	SELECT @ClientName =  RMD.ClientName FROM Client.ReportMetaData RMD WHERE RMD.IsExported = 0 AND RMD.HaveExportError = 0;
	

	DECLARE cuExport CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT	FORMAT(XR.RunDate,'yyyyMMdd') + '-' + REPLACE(XR.ServerName,'\','@') ,XR.ReportGUID,ISNULL(XR.ClientID,1)
	FROM	Client.ReportMetaData XR
	WHERE	XR.IsExported = 0;

	OPEN cuExport

	FETCH NEXT FROM cuExport INTO @ExportReportName,@ReportGUID,@ClientID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
		
			SET @ExportPathReport = CONCAT(@ExportPath,'\',@ClientID);
			EXECUTE [Utility].[DirectoryCreate] @ExportPathReport;

			EXECUTE Utility.[usp_clr_ExportPDFReport] 
					   @ServicePathUrl
					  ,@reportPath
					  ,@ExportPathReport
					  ,@ExportReportName
					  ,@ReportGUID;

			UPDATE	Client.ReportMetaData
			SET		IsExported =1,
					ExportReportName = @ExportReportName
			WHERE	ReportGUID = @ReportGUID
					AND IsExported = 0;
		END TRY
		BEGIN CATCH
			THROW;
			UPDATE	Client.ReportMetaData
			SET		IsExported = 0, HaveExportError = 1,ExportError = 'Error While creating PDF'
			WHERE	ReportGUID = @ReportGUID
		END CATCH
		FETCH NEXT FROM cuExport INTO @ExportReportName,@ReportGUID,@ClientID;
	END

	CLOSE cuExport;
	DEALLOCATE cuExport;
	
	EXEC Utility.[usp_Auto_AddReportsToRar];
	
END
