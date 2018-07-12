-- =============================================
-- Author:		Sharon
-- Create date: 15/02/2018
-- Update date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [Utility].[usp_Activate_StartDatabase]
AS
BEGIN
    SET NOCOUNT ON;
 
	IF EXISTS ( SELECT TOP 1 1 FROM sys.configurations C WHERE   C.name = 'clr enabled' AND C.value = 0 )
	BEGIN
		RAISERROR ('Turn on "clr enabled"',10,1) WITH NOWAIT;
	    EXEC sp_configure 'clr enabled',1;
	    RECONFIGURE WITH OVERRIDE;
		
	END;
	
	IF EXISTS(SELECT TOP 1 1 FROM sys.databases WHERE database_id = DB_ID() AND owner_sid != '0x01')
	BEGIN
		RAISERROR ('Change owner on SiteReviewAnalysis to sa',10,1) WITH NOWAIT;
		EXEC sp_changedbowner 'sa'; -- fix ownerships problems after transfer
	END
	
	IF EXISTS(SELECT TOP 1 1 FROM sys.databases WHERE database_id = DB_ID() AND is_trustworthy_on = 0)
	BEGIN
		RAISERROR ('Turn on "TRUSTWORTHY" on SiteReviewAnalysis',10,1) WITH NOWAIT;
		ALTER DATABASE CURRENT SET TRUSTWORTHY ON WITH NO_WAIT;
	END
END