-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetFreeSpaceChart
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetCPU] @Guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @ProcessorName NVARCHAR(MAX);
	DECLARE @MaxClockSpeed NVARCHAR(MAX);
	DECLARE @CurrentClockSpeed NVARCHAR(MAX);
	DECLARE @ProcessorCount NVARCHAR(MAX);
	DECLARE @ProcessorActiveCount NVARCHAR(MAX);
	DECLARE @hyperthreadingRatio BIT;
	DECLARE @logicalCPUs INT;
	DECLARE @HTEnabled INT;
	DECLARE @physicalCPU INT;
	DECLARE @SOCKET INT;
	DECLARE @logicalCPUPerNuma INT;
	DECLARE @NoOfNUMA INT;
	DECLARE @MaxDOP INT;
	DECLARE @CurentMaxDOP INT;

	SELECT	@ProcessorName = [Utility].[PatternReplace](MS.ProcessorName,'  ',' '),
			@MaxClockSpeed = LEFT(CONVERT(NVARCHAR(40),ROUND(MS.MaxClockSpeed/1000.0,2)),4) + ' GHz' ,
			@CurrentClockSpeed = LEFT(CONVERT(NVARCHAR(40),ROUND(MS.CurrentClockSpeed/1000.0,2)),4) + ' GHz',
			@ProcessorCount = CONVERT(NVARCHAR(MAX),MS.ProcessorCount)
	FROM	Client.MachineSettings MS
	WHERE	MS.guid = @Guid;
	-- find NO OF NUMA Nodes 
	SELECT  @NoOfNUMA = COUNT(DISTINCT OS.parent_node_id)
	FROM    Client.os_schedulers OS
	WHERE	OS.guid = @Guid
			AND OS.status = 'VISIBLE ONLINE'
			AND OS.parent_node_id < 64;

	SELECT  @logicalCPUs = SP.logicalCPU -- [Logical CPU Count]
			,@hyperthreadingRatio = hyperthread_ratio --  [Hyperthread Ratio]
			,@physicalCPU = SP.CPU_Core -- [Physical CPU Count]
			,@HTEnabled = CASE WHEN SP.logicalCPU > hyperthread_ratio THEN 1
							  ELSE 0
						END -- HTEnabled
	FROM    [Client].[ServerProporties] SP
	WHERE	SP.guid = @Guid;

	SELECT  @logicalCPUPerNuma = COUNT(OS.parent_node_id) -- [NumberOfLogicalProcessorsPerNuma]
	FROM    Client.os_schedulers OS
	WHERE	OS.guid = @Guid
			AND OS.[status] = 'VISIBLE ONLINE'
			AND OS.parent_node_id < 64
	GROUP BY OS.parent_node_id;


	SELECT	@ProcessorActiveCount = CONVERT(NVARCHAR(MAX),COUNT(1))
	FROM	Client.os_schedulers OS
	WHERE	OS.guid = @Guid
			AND OS.status = 'VISIBLE ONLINE';
	IF @NoOfNUMA = 1
	BEGIN
		   IF @logicalCPUPerNuma > 8 
		   BEGIN
			   IF EXISTS(SELECT TOP 1 1 FROM sys.dm_os_sys_info OS WHERE OS.virtual_machine_type = 1) --Virtual
				  BEGIN
						 SET @NoOfNUMA = 2;
						 --PRINT 'On this VM "Hot Plug" is enabled';
						 SET @MaxDOP = 8;
				  END
		   END
		   ELSE 
		   BEGIN
			   SET @MaxDOP = @logicalCPUPerNuma;
		   END
	END
	ELSE
	BEGIN
		   IF @logicalCPUPerNuma > 8 
		   BEGIN
			   SET @MaxDOP = 8;
		   END
		   ELSE 
		   BEGIN
			   SET @MaxDOP = @logicalCPUPerNuma; 
		   END
	END


--https://support.microsoft.com/en-us/kb/2806535
--https://www.brentozar.com/archive/2014/11/many-cpus-parallel-query-using-sql-server/
--https://www.littlekendra.com/2016/07/14/max-degree-of-parallelism-cost-threshold-for-parallelism/
--https://blogs.msdn.microsoft.com/sqlsakthi/p/maxdop-calculator-sqlserver/

	SELECT	@CurentMaxDOP = SPC.value
	FROM	[Client].[SPConfigure] SPC
	WHERE	SPC.guid = @Guid
			AND SPC.name = 'max degree of parallelism';

	SELECT	CONVERT(NVARCHAR(MAX),'Processor Name') Name,@ProcessorName [Value],'Black'[Color],CONVERT(NVARCHAR(MAX),NULL) [Link]
	UNION ALL SELECT 'Processor Max Clock Rate',@MaxClockSpeed,'Black'[Color],CONVERT(NVARCHAR(MAX),NULL) [Link]
	UNION ALL SELECT 'Processor Curent Clock Rate',@CurrentClockSpeed,IIF (@CurrentClockSpeed != @MaxClockSpeed,'Red','Green')[Color],CONVERT(NVARCHAR(MAX),NULL) [Link]
	UNION ALL SELECT 'Processor Count',@ProcessorCount,'Black'[Color],CONVERT(NVARCHAR(MAX),NULL) [Link]
	UNION ALL SELECT 'Processor Visible by SQL Count',@ProcessorActiveCount,IIF (@ProcessorActiveCount != @ProcessorCount,'Red','Green')[Color],CONVERT(NVARCHAR(MAX),NULL) [Link]
	UNION ALL SELECT 'Processor Curent max degree of parallelism',IIF(@CurentMaxDOP = 0,CONCAT(@ProcessorActiveCount , '(0)'),CONVERT(NVARCHAR(5),@CurentMaxDOP)),'Red'[Color],N'https://www.littlekendra.com/2016/07/14/max-degree-of-parallelism-cost-threshold-for-parallelism/' [Link] WHERE @MaxDOP != @CurentMaxDOP
	UNION ALL SELECT 'Processor suggested max degree of parallelism',CONVERT(NVARCHAR(5),@MaxDOP),'Green'[Color] ,N'https://support.microsoft.com/en-us/kb/2806535' [Link]WHERE @MaxDOP != @CurentMaxDOP
	UNION ALL SELECT 'Number Of NUMA node',CONVERT(NVARCHAR(5),@NoOfNUMA),'Black'[Color] ,NULL [Link]
	

END
