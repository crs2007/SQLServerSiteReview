

-- =============================================
-- Author:		Sharon
-- Create date: 13/10/2016
-- Update date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [Utility].[usp_UpdateClientScriptCloud] @Ver NVARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    
	INSERT [SiteReviewUser].[SiteReviewUser].[dbo].[ClientScript](Ver,Date,Script)
	SELECT	@Ver,GETDATE(),SM.definition
	FROM	master.sys.sql_modules SM
			INNER JOIN master.sys.objects O ON O.object_id = SM.object_id
	WHERE	 o.name = 'sp_SiteReview'

END
