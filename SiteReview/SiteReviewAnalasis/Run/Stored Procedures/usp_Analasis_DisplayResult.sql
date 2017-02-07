
-- =============================================
-- Author:		Sharon
-- Create date: 20/03/2014
-- Description:	Server smell
-- =============================================
CREATE PROCEDURE [Run].[usp_Analasis_DisplayResult](@Guid UNIQUEIDENTIFIER)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	*
	FROM	Run.Exeption 
	WHERE Guid = @Guid;

END