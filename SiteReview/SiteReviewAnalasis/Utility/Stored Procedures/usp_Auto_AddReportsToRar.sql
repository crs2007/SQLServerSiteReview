-- =============================================
-- Author:		Sharon
-- Create date: 2012
-- Update date: 27/06/2016 @Pathe Parameter
-- Description:	
-- =============================================
CREATE PROCEDURE Utility.[usp_Auto_AddReportsToRar]
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @cmd VARCHAR(MAX);
    DECLARE @ClientName NVARCHAR(1000);
	DECLARE @ClientID INT;
    DECLARE @getClientName CURSOR ;
	DECLARE @DirectoryCreate NVARCHAR(1000);	
	DECLARE @DirectoryCreate2 NVARCHAR(1000);
	DECLARE @ReportGuid UNIQUEIDENTIFIER;
	DECLARE @ExportPath NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('ExportPath'));
	DECLARE @sFileNamePath nvarchar(max);
	DECLARE @ExportReportName NVARCHAR(512);

    EXECUTE [Utility].[DirectoryCreate] @ExportPath;
    
	SET @getClientName = CURSOR LOCAL FAST_FORWARD FOR
	SELECT	RMD.ClientName,CONCAT(@ExportPath,'\',ISNULL(RMD.ClientID,1),'\Mail'),ISNULL(RMD.ClientID,1),RMD.ReportGUID,RMD.ExportReportName
	FROM	Client.ReportMetaData RMD 
	WHERE	RMD.IsExported = 1 
			AND RMD.HaveExportError = 0
			AND HaveSent = 0
			AND SentError IS NULL;
    OPEN @getClientName;
    FETCH NEXT FROM @getClientName INTO @ClientName,@DirectoryCreate,@ClientID,@ReportGuid,@ExportReportName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
			--PRINT @DirectoryCreate
			EXECUTE [Utility].[DirectoryCreate] @DirectoryCreate;
			--Delete files from @DirectoryCreate
            SET @cmd = 'xp_cmdshell ''del "' + @DirectoryCreate + '\" /q'',no_output';--
			--PRINT @cmd;
            EXEC (@cmd);
			SET @sFileNamePath = REPLACE(@DirectoryCreate,'\Mail','') + '\*.PDF'
            SET @cmd = 'xp_cmdshell ''cd.. && "C:\Program Files\WinRAR\Rar.exe" a -ep "' + @DirectoryCreate
                + '\Reports.rar" "' + @sFileNamePath + '"'',no_output';--
			--PRINT @cmd;
            EXEC (@cmd);

			UPDATE  Client.ReportMetaData
            SET     HaveSent = 1
            WHERE   IsExported = 1
					AND HaveSent = 0
					AND HaveExportError = 0
                    AND ClientID = @ClientID;

			SET @sFileNamePath = REPLACE(@sFileNamePath,'*.PDF','') + @ExportReportName;
					
			EXECUTE [Utility].[FileDelete] @sFileNamePath;

        END TRY
        BEGIN CATCH
            DECLARE @ErMessage NVARCHAR(2048) ,
                @ErSeverity INT ,
                @ErState INT;
            SELECT  @ErMessage = ERROR_MESSAGE() ,
                    @ErSeverity = ERROR_SEVERITY() ,
                    @ErState = ERROR_STATE();
  
            RAISERROR (@ErMessage,
				@ErSeverity,
				@ErState );
            UPDATE  Client.ReportMetaData
            SET     SentError = CONCAT('Create RAR file - ',@ErMessage)
            WHERE   IsExported = 1
					AND HaveSent = 0
					AND HaveExportError = 0
                    AND ReportGUID = @ReportGuid;
        END CATCH;
        FETCH NEXT FROM @getClientName INTO @ClientName,@DirectoryCreate,@ClientID,@ReportGuid,@ExportReportName;
    END;

    CLOSE @getClientName;
    DEALLOCATE @getClientName;

END




