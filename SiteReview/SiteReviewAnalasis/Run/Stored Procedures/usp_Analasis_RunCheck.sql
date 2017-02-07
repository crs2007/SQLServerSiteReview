-- =============================================
-- Author:		Sharon
-- Create date: 20/03/2014
-- Description:	Server smell
-- =============================================
CREATE PROCEDURE [Run].[usp_Analasis_RunCheck](@Guid UNIQUEIDENTIFIER)
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM Run.Exeption WHERE Guid = @Guid;
	-- Collecte all errors from checks.
	DECLARE @OS_Mem FLOAT,
			@ThreadStack INT,
			@vCPU INT,
			@PhysicalMemory INT,
			@VMOverhead INT,
			@PLE INT
	DECLARE @CPU_Core INT;
	DECLARE @logicalCPU INT;
	DECLARE @maxWorkerThreads INT;
	DECLARE @OS_bit INT;
	DECLARE @VM INT;


	DECLARE @PlatformType INT;
	SELECT	@PlatformType = SP.PlatformType,
			@OS_Mem = OS_Mem,
			@vCPU = logicalCPU,
			@PhysicalMemory = PhysicalMemory,
			@ThreadStack = SP.ThreadStack,
			@PLE = SP.PLE,
			@logicalCPU = SP.logicalCPU,
			@OS_bit = SP.OS_bit ,
			@CPU_Core = SP.CPU_Core,
			@VM = SP.VirtualMemory
	FROM	Client.ServerProporties SP
	WHERE	SP.guid = @Guid;

	DECLARE @maxServerMemory INT;

	SELECT	@maxServerMemory = SC.value
	FROM	Client.SPConfigure SC
	WHERE	SC.guid = @Guid
			AND SC.name = 'max server memory (MB)';
		
	DECLARE @CLREnabled INT;

	SELECT	@CLREnabled = SC.value
	FROM	Client.SPConfigure SC
	WHERE	SC.guid = @Guid
			AND SC.name = 'clr enabled';
		
		
	SELECT	@maxWorkerThreads = SP.value FROM Client.SPConfigure SP WHERE SP.guid = @Guid AND SP.name = 'max worker threads';

	-- Get VLF Counts for all databases on the instance (Query 25) (VLF Counts)
	INSERT	Run.Exeption
	SELECT  @Guid,1,
			'Database' Type,
			'High VLF counts can affect write performance and they can make database restores and recovery take much longer. (' + [Utility].[ufn_Util_clr_Conc]('[' + D.name + ']::' + CONVERT(VARCHAR(10),VLFCount )) + ')' Message,
			NULL URL,
			'Minor' Severity,
			'Try to keep your VLF counts under 200 in most cases' Action  
	FROM	Client.Databases D
	WHERE	VLFCount > 200
			AND D.guid = @Guid
	--ORDER BY VLFCount DESC
	OPTION(RECOMPILE);
	-- High VLF counts can affect write performance 
	-- and they can make database restores and recovery take much longer
	-- Try to keep your VLF counts under 200 in most cases	 

	--http://blogs.msdn.com/b/sqlsakthi/archive/2011/03/14/max-worker-threads-and-when-you-should-change-it.aspx
	

	IF @OS_bit = 64
	BEGIN
		IF @logicalCPU <= 4
		BEGIN
			IF @maxWorkerThreads NOT IN (0,512)
				INSERT	Run.Exeption
				SELECT  @Guid,3,
						'CPU' Type,
						'Max worker threads:' + CONVERT(VARCHAR(10), @maxWorkerThreads) Message ,
						'http://blogs.msdn.com/b/sqlsakthi/archive/2011/03/14/max-worker-threads-and-when-you-should-change-it.aspx' URL,
						'Major' Severity,
						'Max worker threads shuold be 0 or Total available logical CPU’s <= 4 : 512 On 64bit system' Action 
		END
		ELSE
		BEGIN
			IF @maxWorkerThreads NOT IN (0,256 + ((@logicalCPU - 4) * 16))
				INSERT	Run.Exeption
				SELECT  @Guid,3,
						'CPU' Type,
						'Max worker threads:' + CONVERT(VARCHAR(10), @maxWorkerThreads) Message ,
						'http://blogs.msdn.com/b/sqlsakthi/archive/2011/03/14/max-worker-threads-and-when-you-should-change-it.aspx' URL,
						'Major' Severity,
						'Max worker threads shuold be 0 or Total available logical CPU’s > 4 : 512 + ((logicalCPU - 4) * 16)) On 64bit system' Action 
		END   
	END
	ELSE--32bit
	BEGIN
		IF @logicalCPU <= 4
		BEGIN
			IF @maxWorkerThreads NOT IN (0,256)
				INSERT	Run.Exeption
				SELECT  @Guid,3,
						'CPU' Type,
						'Max worker threads:' + CONVERT(VARCHAR(10), @maxWorkerThreads) Message ,
						'http://blogs.msdn.com/b/sqlsakthi/archive/2011/03/14/max-worker-threads-and-when-you-should-change-it.aspx' URL,
						'Major' Severity,
						'Max worker threads shuold be 0 or Total available logical CPU’s <= 4 : 256 On 32bit system' Action 
		END
		ELSE
		BEGIN
			IF @maxWorkerThreads NOT IN (0,256 + ((@logicalCPU - 4) * 8))
				INSERT	Run.Exeption
				SELECT  @Guid,3,
						'CPU' Type,
						'Max worker threads:' + CONVERT(VARCHAR(10), @maxWorkerThreads) Message ,
						'http://blogs.msdn.com/b/sqlsakthi/archive/2011/03/14/max-worker-threads-and-when-you-should-change-it.aspx' URL,
						'Major' Severity,
						'Max worker threads shuold be 0 or Total available logical CPU’s > 4 : 256 + ((logicalCPU - 4) * 8))On 32bit system' Action 
		END    
	END

	----– SQL Server Error log. This query might take a few seconds
	----– if you have not recycled your error log recently
	--CREATE TABLE #Manufacturer (LogDate DATETIME,ProcessInfo sysname,Text VARCHAR(4000))
	--INSERT #Manufacturer
	--EXEC xp_readerrorlog 0, 1, "Manufacturer";

	--SELECT TOP 1 1 FROM #Manufacturer WHERE Text LIKE '%VMware%'
	IF @VM = 1 /*HYPERVISOR*/
	BEGIN
		
		INSERT	Run.Exeption
		SELECT  @Guid,2,
				'CPU' Type,
				'CPU resources ratio of the physical cores is 1:' + CONVERT(VARCHAR(10), SP.CPU_Core) Message ,
				'http://www.vmware.com/files/pdf/solutions/SQL_Server_on_VMware-Best_Practices_Guide.pdf' URL,
				'Major' Severity,
				'Provide CPU resources by maintaining a 1:1 ratio of the physical cores' Action 
		FROM	Client.ServerProporties SP
		WHERE	sp.hyperthread_ratio != 1
				AND SP.CPU_Core  > 1
				AND SP.guid = @Guid;

		--INSERT	Run.Exeption
		--SELECT  @Guid,
		--		'Memory' Type,
		--		'CPU resources ratio of the physical cores is ' + CONVERT(VARCHAR(10),cpu_count/hyperthread_ratio ) + ':' + CONVERT(VARCHAR(10),hyperthread_ratio ) Message,
		--		'http://www.vmware.com/files/pdf/solutions/SQL_Server_on_VMware-Best_Practices_Guide.pdf' URL,
		--		'Major' Severity,
		--		'Provide CPU resources by maintaining a 1:1 ratio of the physical cores' Action 
		--FROM	sys.dm_os_sys_info WITH (NOLOCK) 
		--WHERE	hyperthread_ratio != 1	
		
	
		/*---------------------------------------------------------------------------------------------------
		4.3.4.2. Tier 1 SQL Server workloads 
		Achieving adequate performance is the primary goal. Consider setting the memory reservation equal to 
		the provisioned memory, to avoid ballooning or swapping. When calculating the amount of memory to 
		provision for the virtual machine, use the following formulas: 
		VM Memory = SQL Max Server Memory + ThreadStack + OS Mem + VM Overhead 
		ThreadStack = SQL Max Worker Threads * ThreadStackSize 
		ThreadStackSize	 = 1MB on x86 
						 = 2MB on x64 
						 = 4MB on IA64 
		OS Mem: 1GB for every 4 CPU Cores 

		*/
		

			SELECT	@VMOverhead = mo.Memory_MB
			FROM	Configuration.[VM_MemoryOverhead] mo
			WHERE	mo.vCPU = CASE WHEN @vCPU > 8 THEN 8 ELSE @vCPU END
					AND @PhysicalMemory BETWEEN VM_Memory_MB_From AND VM_Memory_MB_Till
			OPTION(RECOMPILE);

			INSERT	Run.Exeption
			SELECT  @Guid,4,
					'Memory' Type,
					'Minimum Memory For This VM is ' + CONVERT(VARCHAR(50),@PhysicalMemory ) + 'MB and does not meet VM requirements: ' + CONVERT(VARCHAR(50),(CONVERT(BIGINT,@maxServerMemory)) + @ThreadStack + @OS_Mem + @VMOverhead ) Message,
					'http://www.vmware.com/files/pdf/solutions/SQL_Server_on_VMware-Best_Practices_Guide.pdf' URL,
					'Major' Severity,
					'VM Memory = SQL Max Server Memory + ThreadStack + OS Mem + VM Overhead ' Action 
			WHERE	(CONVERT(BIGINT,@maxServerMemory)) + @ThreadStack + @OS_Mem + @VMOverhead > @PhysicalMemory
					and @maxServerMemory != '2147483647'
			OPTION(RECOMPILE);
			---------------------------------------------------------------------------------------------------
	END
	-- Memory
	INSERT	Run.Exeption
	SELECT  @Guid,5,
			'Memory' Type,
			'Max server memory configure worng ' + CONVERT(varchar(25),@maxServerMemory) + 'MB. Physical memory: ' + CONVERT(varchar(25),@PhysicalMemory) + 'MB. You should leave about 10-12% for OS.' Message,
			NULL URL,
			'Minor' Severity,
			'Configure max server memory' Action 
	FROM	(SELECT TOP 1 CASE WHEN @CLREnabled = 1 THEN 0.12 ELSE 0.1 END Factor, @PhysicalMemory * 1024 [PhysicalMemoryKB]) uf
	WHERE	@maxServerMemory > CONVERT(INT,(([PhysicalMemoryKB] - (CASE WHEN ([PhysicalMemoryKB] * uf.Factor) < 4194304 THEN 4194304.0 ELSE [PhysicalMemoryKB] * uf.Factor END))/1024))
	OPTION(RECOMPILE);
	
	--Average Page Life Expectancy
/*
For those of you not familiar with Page Life Expectancy (PLE), this is the length
of time that a database page will stay in the buffer cache without references. 
Microsoft recommends a minimum target of 300 seconds for PLE, which is roughly (5) minutes.
I have to admit that even in my own environment, we rarely see PLE more than (3) to (4) minutes.
I wondered what would the average DBA do in a situation where they do not have the luxury of using
a 3rd party monitoring tool to capture (PLE)? In this post I decided to share a useful script that
I wrote that will sample the DMV sys.dm_os_performance_counters table to provide an average PLE 
captured in (1) minute intervals. I hope this query will prove useful for those DBA's that do not
have a 3rd party monitoring tool, or find themselves in a situation where they can only rely on 
a query to give them the results.
*/

/****************************************************************************** 
NOTES: 
 This script provides a sampling of PLE based on (1) minute intervals from 
 sys.dm_os_performance_counters. Originally written on December 29, 2012 
 by Akhamie Patrick
*******************************************************************************/ 


	INSERT	Run.Exeption
	SELECT  @Guid,6,
			'Memory' Type ,
			'Page life expectancy(PLE) is to low - '
			+ CONVERT(VARCHAR(25), [AveragePageLifeExpectancy]) + 'sec. Physical memory: '
			+ CONVERT(VARCHAR(25), @PhysicalMemory) + 'MB' Message ,
			NULL URL ,
			'Minor' Severity ,
			'PLE is a good measurement of memory pressure. Higher PLE is better. Watch the trend, not the absolute value.' Action 
	FROM    (SELECT @PLE [AveragePageLifeExpectancy]) PLE
			CROSS APPLY (	SELECT	CONVERT(INT,CASE WHEN @maxServerMemory/1024.0 < (@PhysicalMemory/1024.0) THEN ((CONVERT(INT,@maxServerMemory/1024.0)/4) * 300) ELSE ((@PhysicalMemory/1024.0)/4) * 300 END )PLEvalue)T
	WHERE   [AveragePageLifeExpectancy] < t.PLEvalue -- Seconds
	OPTION (RECOMPILE);

	--INSERT	Run.Exeption
	--SELECT  
	--		'Memory' Type,
	--		'"MAX_EVENTS_LIMIT" on XE is set to high(' + CONVERT(VARCHAR(15),ring_buffer_event_count)+ ')' Message,
	--		'http://www.sqlskills.com/blogs/jonathan/why-i-hate-the-ring_buffer-target-in-extended-events/?utm_source=rss&utm_medium=rss&utm_campaign=why-i-hate-the-ring_buffer-target-in-extended-events' URL,
	--		'Major' Severity,
	--		'Set "MAX_EVENTS_LIMIT" to less than ' + CONVERT(VARCHAR(15),ring_buffer_event_count) Action 
	--FROM    ( SELECT    target_data.value('(RingBufferTarget/@eventCount)[1]',
	--									  'int') AS ring_buffer_event_count ,
	--					target_data.value('count(RingBufferTarget/event)', 'int') AS event_node_count
	--		  FROM      ( SELECT    CAST(target_data AS XML) AS target_data
	--					  FROM      sys.dm_xe_sessions AS s
	--								INNER JOIN sys.dm_xe_session_targets AS st ON s.address = st.event_session_address
	--					  WHERE     s.name = N'system_health'
	--								AND st.target_name = N'ring_buffer'
	--					) AS n
	--		) AS t
	--WHERE	ring_buffer_event_count > 10000 -- MAX_EVENTS_LIMIT
	--OPTION (RECOMPILE);

	DECLARE @DisplayPhysicalMemory INT
	SELECT @DisplayPhysicalMemory = CASE 
	WHEN @PhysicalMemory <= 8000 THEN 6000
	ELSE @PhysicalMemory * 0.9 END
	

	INSERT	Run.Exeption
	SELECT  @Guid,69999,
			'Server' Type ,
			'Server configuration - ' + cSP.[name] + ' is configure not by best Practice' Message ,
			NULL URL ,
			'Minor' Severity ,
			CASE WHEN cSP.[name] = 'max server memory (MB)' THEN CONVERT(VARCHAR(15),@DisplayPhysicalMemory)
			WHEN cSP.[name] = 'min server memory (MB)' THEN CONVERT(VARCHAR(15),CONVERT(INT,@PhysicalMemory * 0.8))
			ELSE CONVERT(VARCHAR(15),c.BestPractice) END Action --c.BedPractice
   FROM    [Client].[SPConfigure] cSP
            INNER JOIN ActiveReportServer.[Configuration].[sp_configurations] c ON cSP.name LIKE c.Name + '%' 
                                                            AND ( ISNULL(c.BestPractice,c.[Default]) != c.[Default]
                                                            --OR c.BedPractice IS NOT NULL
                                                            )
                                                            AND ( cSP.value != ISNULL(c.BestPractice,cSP.value)
                                                            OR cSP.value = ISNULL(c.BedPractice,-1)
                                                            )
    WHERE   cSP.guid = @guid
            AND cSP.name NOT IN ( 'show advanced options')
	UNION ALL 
	SELECT  @Guid,69999,
			'Server' Type ,
			'Server configuration - min\max server memory (MB) is configure not by best Practice' Message ,
			NULL URL ,
			'Minor' Severity ,
			'Change min\max server memory (MB) to ' + CONVERT(VARCHAR(15),CONVERT(INT,@PhysicalMemory * 0.8)) + '\' + CONVERT(VARCHAR(15),@DisplayPhysicalMemory) Action --c.BedPractice
    FROM    [Client].[SPConfigure] cSP
			CROSS APPLY (SELECT value FROM [Client].[SPConfigure] IC WHERE IC.guid = @guid AND IC.name = 'max server memory (MB)')MI
	WHERE   cSP.guid = @guid
			AND cSP.name = 'min server memory (MB)'
			AND MI.value = cSP.value;
----------------------------- Server ---------------------------------

	--Service
	INSERT	Run.Exeption
	SELECT  @Guid,7,
			'Server' Type,
			SS.ServiceName + ' startup state: ' + SS.StartupTypeDesc Message,
			NULL URL,
			'Major' Severity,
			'Change service startup methud to Automatic' ACTION
	FROM    Client.ServerServices SS--sys.dm_server_services WITH ( NOLOCK )
	WHERE   ss.ServiceName LIKE 'SQL Server%'
			AND ss.StartupType != 2 --Automatic
			AND SS.Guid = @Guid
	UNION ALL 
	SELECT  @Guid,8,
			'Server' Type,
			SS2.ServiceName + ' is in state: ' + SS2.StatusDesc Message,
			NULL URL,
			'Major' Severity,
			'Start Service' Action 
	FROM    Client.ServerServices SS2 
	WHERE   SS2.ServiceName LIKE 'SQL Server%'
			AND SS2.Status != 4 --Running
			AND SS2.Guid = @Guid
	UNION ALL 
	SELECT  @Guid,9,
			'Server' Type,
			s.ServiceName + ' service account is differnt from agent service' Message,
			NULL URL,
			'Major' Severity,
			'Change Service account of agent service to ' + s.ServiceAccount Action 
	FROM    Client.ServerServices s 
			CROSS JOIN (SELECT	ss.ServiceAccount
			            FROM	Client.ServerServices ss
						WHERE   ss.ServiceName LIKE 'SQL Server Agent%'
								AND SS.Guid = @Guid) t
	WHERE   s.ServiceName LIKE 'SQL Server (%'
			AND t.ServiceAccount != s.ServiceAccount
			AND S.Guid = @Guid
	OPTION  ( RECOMPILE );
	
	--configurations
	INSERT	Run.Exeption
	SELECT  @Guid,10,
			'Server' Type,
			CONVERT(varchar(40),C.Name) + ' configure worng ' Message,
			NULL URL,
			'Worning' Severity,
			'Turn on - ' + CONVERT(varchar(25),C.Name) Action 
	FROM	Client.SPConfigure  C WITH (NOLOCK)
	WHERE	C.name IN ('optimize for ad hoc workloads','backup compression default')
			AND C.value = 0
	OPTION  ( RECOMPILE );

-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------

	
	--TempDB Configuration
	INSERT	Run.Exeption
	SELECT  TOP 1 @Guid,11,
			'Server' Type,
			'TempDB files has different sizes' Message,
			'http://www.confio.com/logicalread/sql-server-tempdb-best-practices-initial-sizing-w01/#.UzEbJfl_tCw' URL,
			'Worning' Severity,
			'Change initial size of tempdb' ACTION
	FROM	Client.MasterFiles MF
			CROSS APPLY (SELECT TOP 1 MF2.size,MF2.file_id FROM Client.MasterFiles MF2 WHERE MF2.database_id = 2 AND MF2.type = 0)iMF
	WHERE	database_id = 2
			AND type = 0
			AND iMF.file_id != MF.file_id
			AND iMF.size != MF.SIZE
            AND MF.guid = @Guid
	UNION ALL 
	SELECT  TOP 1 @Guid,12,
			'Server' Type,
			'TempDB files are lower then logical CPU count (tempdb files - ' + CONVERT(VARCHAR(5),Tmp.TempDBcnt) + ', CPU count - ' + CONVERT(VARCHAR(5),SP.logicalCPU) + ')' Message,
			'http://www.confio.com/logicalread/sql-server-tempdb-best-practices-multiple-files-w01/#.UzEbCfl_tCw' URL,
			'Worning' Severity,
			'Use of multiple data files of tempdb:: Add to tempdb ' + CONVERT(VARCHAR(5),8 - Tmp.TempDBcnt) + ' ndf files more at the same size'  ACTION
	FROM	Client.ServerProporties SP
			CROSS APPLY (SELECT	COUNT_BIG(1) TempDBcnt FROM	Client.MasterFiles WHERE database_id = 2 AND type = 0 AND guid = @Guid) Tmp
	WHERE	SP.logicalCPU > Tmp.TempDBcnt
			AND SP.guid = @Guid;

	INSERT	Run.Exeption
	SELECT  @Guid,13,'Server' Type,
			'Instant Initialization disabled' Message,
			N'http://www.sqlskills.com/blogs/kimberly/instant-initialization-what-why-and-how/' URL,
			'Worning' Severity,
			'Activate Instant Initialization'  Action 
	FROM	Client.MachineSettings MS
	WHERE	MS.InstantInitializationDisabled = 1
			AND MS.guid = @Guid
	UNION ALL 
	SELECT  @Guid,14,'Server' Type,
			'Lock Pages In Memory disabled' Message,
			null URL,
			'Worning' Severity,
			'Activate Lock Pages In Memory'  Action 
	FROM	Client.MachineSettings MS
	WHERE	MS.LockPagesInMemoryDisabled = 1
			AND MS.guid = @Guid
	-- Sustained values above 10 suggest further investigation in that area
	-- High Avg Task Counts are often caused by blocking or other resource contention
	INSERT	Run.Exeption
	SELECT  @Guid,15,'Server' Type,
			'Avg Task Count ' + CONVERT(varchar(25),AVG(current_tasks_count)) Message,
			NULL URL,
			'Worning' Severity,
			'High Avg Task Counts are often caused by blocking or other resource contention'  Action 
	FROM    Client.os_schedulers OS
	WHERE   scheduler_id < 255
			AND OS.guid = @Guid
	HAVING AVG(current_tasks_count) > 10
	UNION ALL 
	-- High Avg Runnable Task Counts are a good sign of CPU pressure
	SELECT  @Guid,16,'CPU' Type,
			'Avg Runnable Task Count ' + CONVERT(varchar(25),AVG(runnable_tasks_count)) Message,
			NULL URL,
			'Worning' Severity,
			'High Avg Runnable Task Counts are a good sign of CPU pressure'  Action 
	FROM    Client.os_schedulers OS
	WHERE   scheduler_id < 255
			AND OS.guid = @Guid
	HAVING AVG(runnable_tasks_count) > 10
	UNION ALL 
	-- High Avg Pending DiskIO Counts are a sign of disk pressure
	SELECT  @Guid,17,'CPU' Type,
			'Avg Pending DiskIO Count ' + CONVERT(varchar(25),AVG(pending_disk_io_count)) Message,
			NULL URL,
			'Worning' Severity,
			'High Avg Pending DiskIO Counts are a sign of disk pressure'  Action 
	FROM    Client.os_schedulers OS
	WHERE   scheduler_id < 255
			AND OS.guid = @Guid
	HAVING AVG(pending_disk_io_count) > 10
	-- High Avg Pending DiskIO Counts are a sign of disk pressure
	UNION ALL 
	SELECT  @Guid,18,
			'LinkedServer' Type,
			'The LinkedServer "' + S.name + '" is configured to work with IP address. On DR based IP This will not work automaticly.' Message,
			NULL URL,
			'Worning' Severity,
			'Change data_source on "' + S.name + '" from IP(' + S.data_source + ') to Name DNS based'  Action 
	FROM    Client.Servers S
	WHERE	[Utility].[ufn_Util_clr_RegexIsMatch] (data_source,'^\d*\.\d*\.\d*\.\d*') = 1
			AND S.guid = @Guid
			AND S.is_linked = 1;
 
	----------------------------------------  TraceFlags  ----------------------------------------
	INSERT	Run.Exeption
	SELECT  @Guid,19,'Server' Type,
			TS.Name Message,
			NULL URL,
			'Minor' Severity,
			'Turn Trace flag on - DBCC TRACEON(' + TS.value + ',-1); -- Turn on in statup tab on configuration as well'  Action 
	FROM	(SELECT 'Turn on TF 1118(Full Extents Only)' Name,'1118' value --http://www.sqlskills.com/blogs/paul/misconceptions-around-tf-1118/
			UNION ALL 
			SELECT 'Turn on TF 1117(Grow all files in a filegroup equally)' Name,'1117' value --http://www.sqlskills.com/blogs/paul/misconceptions-around-tf-1118/
			UNION ALL 
			SELECT 'Turn on TF 1222(More info about deadlock)' Name,'1222' value
			UNION ALL 
			SELECT 'Turn on TF 3226(Suppress the success messages from backups)' Name,'3226' value
			UNION ALL 
			SELECT 'Turn on TF 3023(BACKUP WITH CHECKSUM)' Name,'3023' value --http://www.sqlservercentral.com/blogs/nebraska-sql-from-dba_andy/2014/03/25/backup-checksums-and-trace-flag-3023/
			UNION ALL 
			SELECT 'Turn on TF 4199 (Turn on all optimizations)' Name,'4199' value
			UNION ALL 
			--SELECT 'Is TF 2453 (Fix optimizer on table variable row est) On' Name,'2453' value WHERE SERVERPROPERTY('ProductVersion') >= '11.0.5058' -- Applay only for 2012 SP2 & above
			--SELECT 'Is TF 1448(Replication and AlwaysOn) On' Name,'1448' value WHERE @IsReplication = 1 AND  @IsHADR = 1 /*•  Trace flag 1448 Trace flag 1448 enables the replication log reader to move forward even if the asynchronous secondary replicas have not acknowledged the reception of a change. Even with this trace flag enabled,, the log reader always waits for the synchronous secondary replicas. The log reader will not go beyond the min ack of the synchronous secondary replicas. This trace flag applies to the instance of SQL Server, not just to an availability group, an availability database, or a log reader instance. This trace flag takes effect immediately without a restart. It can be activated ahead of time or when an asynchronous secondary replica fails.*/
            --UNION ALL 
            --SELECT 'Is TF 9481 (Change Cardinality Estimator to 70) On' Name,'9481' value WHERE SERVERPROPERTY('ProductVersion') >= '12.0.0' -- Applay only for 2014 & above
            --UNION ALL 
            SELECT 'Turn on TF 2371 (Change index threshold for filter indexes)' Name,'2371' value 
            --UNION ALL 
            --SELECT 'Is TF 3042 (Cancellation the pre-allocation Disk space for backup) On' Name,'3042' value 
            UNION ALL 
            SELECT 'Turn on TF 6498 (Alleviate RESOURCE_SEMAPHORE_QUERY_COMPILE waits during concurrent compilation of large queries)' Name,'6498' value

			) TS
			LEFT JOIN Client.TraceFlag GTS ON GTS.TraceFlag = TS.value				
				AND GTS.guid = @Guid
	WHERE	GTS.TraceFlag IS NULL
	----------------------------------------  TraceFlags  ----------------------------------------
	
	--Error Log file
	INSERT	Run.Exeption
	SELECT  @Guid,20,
			'Server' Type,
			'Number of Error Logs is -' + CONVERT(VARCHAR(10),ISNULL(R.Value, -1))+ '. Change to 30 or more.' Message,
			NULL URL,
			'Minor' Severity,
			'/*Configure SQL Server Error Logs*/USE [master]
GO
EXEC xp_instance_regwrite N''HKEY_LOCAL_MACHINE'',
    N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''NumErrorLogs'', REG_DWORD,
    30
GO' Action 
	FROM	Client.Registery R
	WHERE	r.guid = @Guid
			AND R.CurrentInstance = 1
			AND R.keyName = 'Number Error Logs '
			AND R.Value < 30;

	INSERT	Run.Exeption
	SELECT  @Guid,21,'JOB' Type,
			'JobName: ' + JobName + ' That run on ' + CONVERT(VARCHAR(25),RunDateTime) + ' took - ' + CONVERT(VARCHAR(25),RunDurationMinutes) + ' minutes' Message,
			NULL URL,
			'Minor' Severity,
			NULL Action 
	FROM	Client.Jobs J
	WHERE	j.guid = @Guid;

	-- Storage
	INSERT	Run.Exeption
	SELECT	@Guid,22,'Storage' Type,
			'Reads are averaging longer than ' + CASE Type WHEN 1 THEN '10' WHEN 99 THEN '10' ELSE '20' END + 'ms on drive - ' + [Drive] + CASE Type WHEN 1 THEN '(LOG files)' WHEN 99 THEN '(TempDB)' ELSE '(DATA files)' END + ' - ' + CONVERT(VARCHAR(20),L.ReadLatency) Message,
			'http://technet.microsoft.com/en-us/library/aa995945(v=exchg.80).aspx' URL,
			'Major' Severity,
						CASE Type WHEN 1 THEN 
			'Transaction log drives
The drive that hosts the transaction log should have average write latencies below 10 ms. Spikes in write latencies should be under 50ms. Writes to the transaction log are synchronous. This means that, before a thread in the Store.exe process can perform another task, the thread must wait for the write to complete. Having low write latencies for the transaction logs is important to server performance. The average Read latency to the transaction log drives should be below 20 ms. Spikes in read latency should be under 50ms. Database Log Record Stalls per second should be less than 10. Database Log Threads Waiting should be less than 10.
Ordinarily, Exchange servers do not read from the transaction logs. Therefore, the read latencies to that drive do not matter. However, because the transaction log write latencies are so important to Exchange performance, it is recommended that, on large servers, you do not use the drives that host transaction logs for any other purpose. In this case, the rate of reads (as measured by LogicalDisk\Disk Reads/sec) should be minimal compared to the rate of writes (LogicalDisk\Disk Writes/sec). The Exchange Server Analyzer will detect if the ratio of reads to writes on the transaction log drive is greater than 0.10 (more than one read for every ten writes).
If there are more than 0.10 reads for every write, you should identify which application is reading from the transaction log drive, and then prevent this action from occurring.' 
			WHEN 99 THEN 
'TEMP and TMP drives   The latency for the drives that contain the TEMP and TMP directories should have read and write latencies below 10 ms. The maximum value for the read or write latency should be below 50 ms.' 
			ELSE 
			'Database drives
The acceptable latency for the drives that contain Exchange database files ( *edb, and *stm files) are as below (higher values indicate a disk bottleneck):
The maximum value for Logical Disk\Avg. Disk sec/Read on a database drive should be less than 50 ms. (0.050 seconds)
The average value for Logical Disk\Avg. Disk sec/Read on a database drive should be less than 20 ms. (0.020 seconds)' 
			END + '
---------------------------------------------------------------------------------------------------------------------------------------
If you are running a RAID-5 disk array, you may want to change to a RAID-10 disk array to improve the available supported IOPS of the disk subsystem.
To improve the available supported IOPS, consider adding additional disks to your disk system.
' Action
	FROM    Client.Latency L
	WHERE	L.guid = @Guid
			AND ((L.type IN (1,99) AND L.ReadLatency > 10)
			OR
			(L.type != 1 AND L.ReadLatency > 20))
	UNION ALL 
	SELECT	@Guid,23,
			'Storage' Type,
			'Writes are averaging longer than ' + CASE Type WHEN 1 THEN '10' WHEN 99 THEN '10' ELSE '20' END + 'ms on drive - ' + [Drive] + CASE Type WHEN 1 THEN '(LOG files)' WHEN 99 THEN '(TempDB)' ELSE '(DATA files)' END + ' - ' + CONVERT(VARCHAR(20),L.WriteLatency) Message,
			'http://technet.microsoft.com/en-us/library/aa995945(v=exchg.80).aspx' URL,
			'Major' Severity,
			CASE Type WHEN 1 THEN 
			'Transaction log drives
The drive that hosts the transaction log should have average write latencies below 10 ms. Spikes in write latencies should be under 50ms. Writes to the transaction log are synchronous. This means that, before a thread in the Store.exe process can perform another task, the thread must wait for the write to complete. Having low write latencies for the transaction logs is important to server performance. The average Read latency to the transaction log drives should be below 20 ms. Spikes in read latency should be under 50ms. Database Log Record Stalls per second should be less than 10. Database Log Threads Waiting should be less than 10.
Ordinarily, Exchange servers do not read from the transaction logs. Therefore, the read latencies to that drive do not matter. However, because the transaction log write latencies are so important to Exchange performance, it is recommended that, on large servers, you do not use the drives that host transaction logs for any other purpose. In this case, the rate of reads (as measured by LogicalDisk\Disk Reads/sec) should be minimal compared to the rate of writes (LogicalDisk\Disk Writes/sec). The Exchange Server Analyzer will detect if the ratio of reads to writes on the transaction log drive is greater than 0.10 (more than one read for every ten writes).
If there are more than 0.10 reads for every write, you should identify which application is reading from the transaction log drive, and then prevent this action from occurring.' 
			WHEN 99 THEN 
'TEMP and TMP drives   The latency for the drives that contain the TEMP and TMP directories should have read and write latencies below 10 ms. The maximum value for the read or write latency should be below 50 ms.' 
			ELSE 
			'Database drives
The acceptable latency for the drives that contain Exchange database files ( *edb, and *stm files) are as below (higher values indicate a disk bottleneck):
The maximum value for Logical Disk\Avg. Disk sec/Read on a database drive should be less than 50 ms. (0.050 seconds)
The average value for Logical Disk\Avg. Disk sec/Read on a database drive should be less than 20 ms. (0.020 seconds)' 
			END + '
---------------------------------------------------------------------------------------------------------------------------------------
If you are running a RAID-5 disk array, you may want to change to a RAID-10 disk array to improve the available supported IOPS of the disk subsystem.
To improve the available supported IOPS, consider adding additional disks to your disk system.
' Action
	FROM    Client.Latency L
	WHERE	L.guid = @Guid
			AND ((L.type IN (1,99) AND L.WriteLatency > 10)
			OR
			(L.type != 1 AND L.WriteLatency > 20))
	OPTION  ( RECOMPILE );

	INSERT	Run.Exeption
	SELECT  @Guid,24,'Storage' Type,
			V.VolumeName + ' has ' + CAST(CAST(V.available_bytes AS FLOAT) / CAST(V.total_bytes AS FLOAT)  * 100 AS VARCHAR(50)) + '% free space.' Message,
			NULL URL,
			'Minor' Severity,
			'Check what files located in ' + V.VolumeName Action 
	FROM    Client.Volumes V
	WHERE	CAST(CAST(V.available_bytes AS FLOAT) / CAST(V.total_bytes AS FLOAT) AS DECIMAL(18,2)) < 0.1
			AND V.guid = @Guid
	OPTION  ( RECOMPILE );

	INSERT	Run.Exeption
	SELECT	@Guid,25,
			'Storage' Type,
			'On volume ' + V.VolumeName + ' change "Block Size" from ' + CONVERT(VARCHAR(25),V.BlockSize/1024) + 'KB to 64KB' Message,
			'http://technet.microsoft.com/en-us/library/cc966412.aspx
http://www.midnightdba.com/Jen/2014/04/decree-set-your-partition-offset-and-block-size-make-sql-server-faster/' URL,
			'Minor' Severity,
			'Ask your SAN guy to change the "Block Size" on the drive to 64KB' Action
	FROM    Client.Volumes V
	WHERE	V.BlockSize != 65536
			AND V.guid = @Guid
	OPTION  ( RECOMPILE );
	
	INSERT	Run.Exeption
	SELECT	@Guid,9999,
			'Storage' Type,
			'On volume ' + V.VolumeName + ' there is ' + CONVERT(VARCHAR(25),CONVERT(INT,(CONVERT(NUMERIC(38,2),V.available_bytes) / CONVERT(NUMERIC(38,2),V.total_bytes) * 100))) + '% free' Message,
			NULL URL,
			'Minor' Severity,
			'Check why you have low space (' + CONVERT(VARCHAR(5),V.available_bytes) + 'GB/' + CONVERT(VARCHAR(5),V.total_bytes) + 'GB)' Action
	FROM    Client.Volumes V
	WHERE	(CONVERT(NUMERIC(38,2),V.available_bytes) / CONVERT(NUMERIC(38,2),V.total_bytes) * 100) <= 30
			AND V.guid = @Guid
	OPTION  ( RECOMPILE );
	--------------------------------------------------------

	INSERT	Run.Exeption
	SELECT	@Guid,26,'Server' Type,
			'Serious bug in SQL Server 2012 SP1, due to msiexec process keep running. registry file grow to 2GB' Message,
			'http://connect.microsoft.com/SQLServer/feedback/details/770630/msiexec-exe-processes-keep-running-after-installation-of-sql-server-2012-sp1' URL,
			'Minor' Severity,
			'http://rusanu.com/2013/02/15/registry-bloat-after-sql-server-2012-sp1-installation/' Action
	FROM    Client.VersionBug VB
	WHERE   VB.IntDetail = 2 -- 2GB
			AND VB.guid = @Guid

	DECLARE @Ver NVARCHAR(128)

	SELECT @Ver = CAST(ISNULL(ProductVersion,Utility.ufn_Util_clr_RegexReplace(Version,'Microsoft SQL Server [\d]+ \- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$1',0))AS NVARCHAR(128))
	FROM	Client.MachineSettings MS
	WHERE	@guid = MS.guid;

	INSERT	Run.Exeption
	SELECT	@Guid,9998,'Server' Type,
			'There is new (' + [Utility].[ufn_Util_clr_Conc]( DISTINCT CASE WHEN ssb.Description LIKE '%Cumulative update%' THEN 'CU'
			WHEN ssb.Description LIKE '%security update%' THEN 'SU'			
			WHEN ssb.Description LIKE '%FIX%' THEN 'FIX'
			WHEN ssb.Description LIKE '%Service Pack%' OR ssb.Description LIKE '%GDR%'  THEN 'SP'			
			WHEN ssb.Description LIKE '%TLS%' THEN 'TLS'
			WHEN ssb.Description LIKE '%RTM%' THEN 'RTM'
			WHEN ssb.Description LIKE '%CTP%' THEN 'CTP'
			ELSE NULL END) + ') that waiting to upgrade.' Message,
			'http://sqlserverbuilds.blogspot.co.il/' URL,
			'Minor' Severity,
			[Utility].[ufn_Util_clr_Conc](SSB.Description) Action
	FROM	ActiveReportServer.Configuration.SQLServerBuild SSB
			INNER JOIN (
						SELECT	TOP 1 *
						FROM	ActiveReportServer.Configuration.SQLServerBuild SSB
						WHERE	PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) = SSB.Major
								AND CONVERT(INT,PARSENAME(CONVERT(VARCHAR(32), @Ver), 3)) = CONVERT(INT,SSB.Minor)
								AND PARSENAME(CONVERT(varchar(32), @Ver), 2) = SSB.VersionBuild
								AND PARSENAME(CONVERT(VARCHAR(32), @Ver), 1) = ISNULL(SSB.Revision,PARSENAME(CONVERT(VARCHAR(32), @Ver), 1))
						)T ON T.Major = SSB.Major
						AND t.Minor = SSB.Minor
			OUTER APPLY (SELECT TOP 1 T.Build ,
										T.Description ,
										T.ReleaseDate ,
										T.ShortName ,
										T.Major,T.Minor,T.VersionBuild,T.Revision
						FROM (
								SELECT	SSB.Build,SSB.Description,SSB.ReleaseDate,
										CASE WHEN ssb.Description LIKE '%Cumulative update%' THEN 'CU'
										WHEN ssb.Description LIKE '%security update%' THEN 'SU'			
										WHEN ssb.Description LIKE '%FIX%' THEN 'FIX'
										WHEN ssb.Description LIKE '%Service Pack%' OR ssb.Description LIKE '%GDR%'  THEN 'SP'			
										WHEN ssb.Description LIKE '%TLS%' THEN 'TLS'
										WHEN ssb.Description LIKE '%RTM%' THEN 'RTM'
										WHEN ssb.Description LIKE '%CTP%' THEN 'CTP'
										ELSE NULL END [ShortName],
										ROW_NUMBER() OVER (PARTITION BY CASE WHEN ssb.Description LIKE '%Cumulative update%' THEN 'CU'
										WHEN ssb.Description LIKE '%security update%' THEN 'SU'			
										WHEN ssb.Description LIKE '%FIX%' THEN 'FIX'
										WHEN ssb.Description LIKE '%Service Pack%' OR ssb.Description LIKE '%GDR%' THEN 'SP'			
										WHEN ssb.Description LIKE '%TLS%' THEN 'TLS'
										WHEN ssb.Description LIKE '%RTM%' THEN 'RTM'
										WHEN ssb.Description LIKE '%CTP%' THEN 'CTP'
										ELSE NULL END ORDER BY SSB.Build DESC) RN,SSB.Major,SSB.Minor,SSB.VersionBuild,SSB.Revision
								FROM	ActiveReportServer.Configuration.SQLServerBuild SSB
								WHERE	PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) = SSB.Major
										AND CONVERT(INT,PARSENAME(CONVERT(VARCHAR(32), @Ver), 3)) = CONVERT(INT,SSB.Minor)
										AND SSB.Build > @Ver)T
			WHERE T.RN = 1 AND T.ShortName = 'SP')SP
		WHERE	T.Build < SSB.Build
			AND ISNULL(SP.Build,T.Build) <= SSB.Build
			AND SSB.Build NOT IN ('11.00.9120','11.00.9000');
	--ORDER BY SSB.Build DESC;

-------------------------------------------------------------------
	EXEC [Run].[usp_Analasis_DisplayResult] @Guid;

/* TODO -- צריך להכניס את הבדיקה הזאת כאשר מצאנו בלוג עדות לכך שיה את מספרי האררורים 
/*
--18272 --3634
The operating system returned the error '3(The system cannot find the path specified.)' while attempting 'DeleteFile' on 'D:\SQL\BACKUP\RestoreCheckpointDB23.CKP'.
During restore restart, an I/O error occurred on checkpoint file 'D:\SQL\BACKUP\RestoreCheckpointDB24.CKP' (operating system error 3(The system cannot find the path specified.)). The statement is proceeding but cannot be restarted. Ensure that a valid storage location exists for the checkpoint file.
*/

DECLARE @instance_name NVARCHAR(200) ,
		@system_instance_name NVARCHAR(200) ,
		@registry_key NVARCHAR(512)

SET @instance_name = COALESCE(CONVERT(NVARCHAR(20), SERVERPROPERTY('InstanceName')),'MSSQLSERVER');
EXEC master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',N'Software\Microsoft\Microsoft SQL Server\Instance Names\SQL',@instance_name, @system_instance_name OUTPUT;
SET @registry_key = N'Software\Microsoft\Microsoft SQL Server\' + @system_instance_name + '\MSSQLServer';
DECLARE @BackupDirectory VARCHAR(100) 
--Default Backup Directory Path Check
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', 
  @key=@registry_key, 
  @value_name='BackupDirectory', 
  @BackupDirectory=@BackupDirectory OUTPUT 
SELECT @BackupDirectory -- CHECK IF THE PATH EXISTS!!
/* --How to Fix
EXEC master..xp_regwrite 
     @rootkey='HKEY_LOCAL_MACHINE', 
     @key=@registry_key, 
     @value_name='BackupDirectory', 
     @type='REG_SZ', 
     @value= -- HERE YOU NEED TO WRITE THE NEW PATH
*/
--Default Log Path Check
DECLARE @DefaultLog VARCHAR(100) 
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', 
  @key=@registry_key, 
  @value_name='DefaultLog', 
  @DefaultLog=@DefaultLog OUTPUT 
SELECT @DefaultLog-- CHECK IF THE PATH EXISTS!!
/* --How to Fix
EXEC master..xp_regwrite 
     @rootkey='HKEY_LOCAL_MACHINE', 
     @key=@registry_key, 
     @value_name='DefaultLog', 
     @type='REG_SZ', 
     @value='L:\SQL\Log'
*/



*/
END

