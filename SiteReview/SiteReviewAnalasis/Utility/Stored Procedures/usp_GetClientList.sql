
-- =============================================
-- Author:		Sharon
-- Create date: 13/10/2016
-- Update date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [Utility].[usp_GetClientList] 
	@LoginID INT ,
	@FullName NVARCHAR(200) OUTPUT,
	@eMail NVARCHAR(512) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	EXEC SiteReviewUser.SiteReviewUser.[GUI].[usp_GetLoginInfo]	@LoginID  ,	@FullName OUTPUT,@eMail OUTPUT;
END

