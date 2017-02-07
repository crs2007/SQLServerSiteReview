-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetFreeSpaceChart
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetCPUBenchmarkLink] @Guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @ProcessorName NVARCHAR(MAX)

	SELECT	@ProcessorName = REPLACE(REPLACE([Utility].[PatternReplace](REPLACE(MS.ProcessorName,'(R)',''),'  ',' '),'@','%40'),' ','+')
	FROM	Client.MachineSettings MS
	WHERE	MS.guid = @Guid;

	SELECT CONCAT('http://www.cpubenchmark.net/cpu.php?cpu=',@ProcessorName) [Link]--http://www.cpubenchmark.net/cpu.php?cpu=Intel+Xeon+X5660+%40+2.80GHz
END
