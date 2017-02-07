-- =============================================
-- Author:		Sharon
-- Create date: 31/12/2016
-- Description:	Get sp_Blitz
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetBlitz] @Guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT	CONCAT(B.FindingsGroup,'-',B.Finding,'-',IIF(B.DatabaseName='','',CONCAT('(',B.DatabaseName,')')),B.Details) [Message]
	FROM	Client.Blitz B
	WHERE	B.guid = @Guid
			AND B.Finding NOT IN ('High VLF Count')
			AND B.FindingsGroup NOT IN ('Wait Stats','Rundate','Server Info','Informational','Licensing','Non-Default Server Config')


END
