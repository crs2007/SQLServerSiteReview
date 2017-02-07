
-- =============================================
-- Author:		Sharon
-- Create date: 07/06/2016
-- Description:	Get Excluded DB
-- =============================================
CREATE PROCEDURE [Run].[usp_LoadXMLs]
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT TOP 1 1 FROM sys.databases D WHERE D.database_id = DB_ID() AND D.owner_sid != '0x01')
		EXEC sp_changedbowner 'sa' -- fix ownerships problems after transfer
	
	IF EXISTS(SELECT TOP 1 1 FROM sys.databases D WHERE D.database_id = DB_ID() AND d.is_trustworthy_on = 0)
		ALTER DATABASE CURRENT SET TRUSTWORTHY ON WITH NO_WAIT;
	--Cursor
	DECLARE @ExportPath NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('InputPath'));
	DECLARE @Path NVARCHAR(255) = @ExportPath;

	DECLARE @FilePath NVARCHAR(1000);
	DECLARE @FileName NVARCHAR(1000);
	DECLARE @cmd NVARCHAR(MAX);

	DECLARE FilePath CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
	SELECT	@Path + '\' + Name ,REPLACE(Name,'.xml','')
	FROM	[Utility].[DirectoryList](@Path,'*.xml');

	OPEN FilePath

	FETCH NEXT FROM FilePath INTO @FilePath,@FileName;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @cmd = '
INSERT INTO [Client].[XMLReports](XMLData, LoadedDateTime,[FileName])
SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() ,@FileName
FROM OPENROWSET(BULK ''' + @FilePath + ''', SINGLE_BLOB) AS x;'
    
		EXECUTE sp_executesql @cmd,N'@FileName NVARCHAR(1000)', @FileName =@FileName;
		EXECUTE [Utility].[FileDelete] @FilePath;

		FETCH NEXT FROM FilePath INTO @FilePath,@FileName;
	END

	CLOSE FilePath;
	DEALLOCATE FilePath;

END
