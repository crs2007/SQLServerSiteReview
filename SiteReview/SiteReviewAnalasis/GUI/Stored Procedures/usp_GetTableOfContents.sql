-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetFreeSpaceChart
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetTableOfContents] @guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT CONVERT(FLOAT,CONVERT(VARCHAR(5),DENSE_RANK() OVER (ORDER BY T.Major)) + IIF(T.Minor IS NULL,'','.' + CONVERT(VARCHAR(5),ROW_NUMBER() OVER (PARTITION BY T.Major ORDER BY T.Minor)-1))) ID,T.Title
	FROM	(
		SELECT 1 [Major],CONVERT(INT,NULL)[Minor],'General Information' [Title]
		UNION ALL SELECT 2,NULL,'Machine Configuration'
		UNION ALL SELECT 2,1,'Operating System Information'
		UNION ALL SELECT 2,2,'Processor'
		UNION ALL SELECT 3,NULL,'Volume Information'
		UNION ALL SELECT 3,1,'Free Space'
		UNION ALL SELECT 3,2,'Block Size'
		UNION ALL SELECT 4,NULL,'SQL Server Configuration'
		UNION ALL SELECT 4,1,'Product Version to Install'
		UNION ALL SELECT 4,2,'TempDB Configurations'
		UNION ALL SELECT 4,3,'System Server Configuration'
		UNION ALL SELECT 4,4,'Job Configurations' WHERE EXISTS (SELECT TOP 1 1 [Ex] FROM Client.JobsOut WHERE [guid] = @guid 
				UNION ALL SELECT TOP 1 1 [Ex] FROM Client.Jobs WHERE [guid] = @guid)
		UNION ALL SELECT 4,5,'Database Configuration'
		UNION ALL SELECT 4,6,'Availability Configuration' WHERE EXISTS (
				SELECT TOP 1 1 [Ex] FROM [Client].[Replications] WHERE [guid] = @guid 
				UNION ALL SELECT TOP 1 1 [Ex] FROM Client.HADRStatus  WHERE [guid] = @guid
				UNION ALL SELECT TOP 1 1 [Ex] FROM Client.AlwaysOnLatency WHERE [guid] = @guid
				UNION ALL SELECT TOP 1 1 [Ex] FROM Client.HADRServices WHERE [guid] = @guid AND (
					[Replication] = 1 OR AlwaysOn = 1 OR Mirror = 1 OR LogShipping = 1)
				)
		)T;
END