
-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetIsPropertyOn
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetIsPropertyOn] @Guid UNIQUEIDENTIFIER = NULL,@Property sysname = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @Property = 'AlwaysON'
	BEGIN
	    SELECT TOP 1 HS.AlwaysOn [IsPropertyOn] FROM Client.HADRServices HS WHERE HS.Guid = @Guid;
		RETURN;
	END
	IF @Property = 'Mirror'
	BEGIN
	    SELECT TOP 1 HS.Mirror [IsPropertyOn] FROM Client.HADRServices HS WHERE HS.Guid = @Guid;
		RETURN;
	END
	IF @Property = 'LogShipping'
	BEGIN
	    SELECT TOP 1 HS.LogShipping [IsPropertyOn] FROM Client.HADRServices HS WHERE HS.Guid = @Guid;
		RETURN;
	END
	IF @Property = 'Replication'
	BEGIN
	    SELECT TOP 1 HS.[Replication] [IsPropertyOn] FROM Client.HADRServices HS WHERE HS.Guid = @Guid;
		RETURN;
	END
END
