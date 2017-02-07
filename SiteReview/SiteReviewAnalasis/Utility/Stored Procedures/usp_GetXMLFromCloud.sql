-- =============================================
-- Author:		Sharon
-- Create date: 13/10/2016
-- Update date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [Utility].[usp_GetXMLFromCloud]
AS
BEGIN
    SET NOCOUNT ON;
    
	DECLARE @MaxID INT;

	INSERT	INTO Client.XMLReports
	        ( XMLData ,
	          LoadedDateTime ,
	          IsPopulated ,
	          FileName,ClientID
	        )
	EXEC [SiteReviewUser].[SiteReviewUser].[GUI].[usp_GetXMLReport] @MaxID OUTPUT;

	EXEC [SiteReviewUser].[SiteReviewUser].[GUI].[usp_DeleteXMLReport] @MaxID;
END
