CREATE PROCEDURE [dbo].[sp_SiteReview] ( @Client NVARCHAR(255) = N'General Client',@Allow_Week_Password_Check BIT = 0,@debug BIT = 0,@Display BIT = 0)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF OBJECT_ID('dbo.SiteReview') IS NOT NULL DROP TABLE dbo.SiteReview;
	CREATE TABLE dbo.SiteReview ( Col XML) ;
    DECLARE @showadvanced INT ,
			@cmdshell INT;
    SELECT  @showadvanced = 0 ,
            @cmdshell = 0;
    IF EXISTS ( SELECT TOP 1 1
                FROM    sys.configurations C
                WHERE   C.name = 'show advanced options' AND C.value = 0 )
    BEGIN
        EXEC sp_configure 'show advanced options', 1;
        RECONFIGURE WITH OVERRIDE;
    END;
    ELSE
    BEGIN
        SET @showadvanced = 1;
    END;

    IF EXISTS ( SELECT TOP 1 1
                FROM    sys.configurations C
                WHERE   C.name = 'xp_cmdshell'
                        AND C.value = 0 )
    BEGIN
        EXEC sp_configure 'xp_cmdshell', 1;
        RECONFIGURE WITH OVERRIDE;
	
    END;
    ELSE
    BEGIN
        SET @cmdshell = 1;
    END;
    BEGIN TRY
        DECLARE @MajorVersion INT;
        IF OBJECT_ID('tempdb..#checkversion') IS NOT NULL
            DROP TABLE #checkversion;
        CREATE TABLE #checkversion
            (
                version NVARCHAR(128) ,
                common_version AS SUBSTRING(version, 1,
                                            CHARINDEX('.', version) + 1) ,
                major AS PARSENAME(CONVERT(VARCHAR(32), version), 4) ,
                minor AS PARSENAME(CONVERT(VARCHAR(32), version), 3) ,
                build AS PARSENAME(CONVERT(VARCHAR(32), version), 2) ,
                revision AS PARSENAME(CONVERT(VARCHAR(32), version), 1)
            );
        INSERT  INTO #checkversion
                ( version
                )
                SELECT  CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128));
        SELECT  @MajorVersion = major + CASE WHEN minor = 0 THEN '00' ELSE minor end
        FROM    #checkversion;
-- Get VLF Counts for all databases on the instance (VLF Counts)
        IF OBJECT_ID('tempdb..#VLFInfo2008') IS NOT NULL
            DROP TABLE #VLFInfo2008;
        CREATE TABLE #VLFInfo2008
            (
                FileID INT ,
                FileSize BIGINT ,
                StartOffset BIGINT ,
                FSeqNo BIGINT ,
                Status BIGINT ,
                Parity BIGINT ,
                CreateLSN NUMERIC(38)
            );
	
        IF OBJECT_ID('tempdb..#VLFInfo') IS NOT NULL
            DROP TABLE #VLFInfo;
        CREATE TABLE #VLFInfo
            (
                RecoveryUnitID INT ,
                FileID INT ,
                FileSize BIGINT ,
                StartOffset BIGINT ,
                FSeqNo BIGINT ,
                Status BIGINT ,
                Parity BIGINT ,
                CreateLSN NUMERIC(38)
            );
	
	
	
	

        IF OBJECT_ID('tempdb..#VLFCountResults') IS NOT NULL
            DROP TABLE #VLFCountResults;
        CREATE TABLE #VLFCountResults
            (
                DatabaseName sysname COLLATE SQL_Latin1_General_CP1_CI_AS ,
                VLFCount INT
            );

        IF @MajorVersion > 1050
            BEGIN
                EXEC sp_MSforeachdb N'Use [?]; 

INSERT INTO #VLFInfo 
EXEC sp_executesql N''DBCC LOGINFO([?]) WITH NO_INFOMSGS''; 
	 
INSERT INTO #VLFCountResults 
SELECT DB_NAME(), COUNT(*) 
FROM #VLFInfo
OPTION(RECOMPILE); 

TRUNCATE TABLE #VLFInfo;';
            END;
        ELSE
            BEGIN
	    
                EXEC sp_MSforeachdb N'Use [?]; 

INSERT INTO #VLFInfo2008
EXEC sp_executesql N''DBCC LOGINFO([?]) WITH NO_INFOMSGS''; 
	 
INSERT INTO #VLFCountResults 
SELECT DB_NAME(), COUNT(*) 
FROM #VLFInfo2008
OPTION(RECOMPILE); 

TRUNCATE TABLE #VLFInfo;';
            END;

        SELECT  D.name ,
                D.database_id ,
                D.source_database_id ,
                CONVERT(NVARCHAR(MAX), D.owner_sid,1) owner_sid ,
                D.create_date ,
                D.compatibility_level ,
                D.collation_name ,
                D.user_access ,
                D.user_access_desc ,
                D.is_read_only ,
                D.is_auto_close_on ,
                D.is_auto_shrink_on ,
                D.state ,
                D.state_desc ,
                D.is_in_standby ,
                D.is_cleanly_shutdown ,
                D.is_supplemental_logging_enabled ,
                D.snapshot_isolation_state ,
                D.snapshot_isolation_state_desc ,
                D.is_read_committed_snapshot_on ,
                D.recovery_model ,
                D.recovery_model_desc ,
                D.page_verify_option ,
                D.page_verify_option_desc ,
                D.is_auto_create_stats_on ,
                --D.is_auto_create_stats_incremental_on ,
                D.is_auto_update_stats_on ,
                D.is_auto_update_stats_async_on ,
                D.is_ansi_null_default_on ,
                D.is_ansi_nulls_on ,
                D.is_ansi_padding_on ,
                D.is_ansi_warnings_on ,
                D.is_arithabort_on ,
                D.is_concat_null_yields_null_on ,
                D.is_numeric_roundabort_on ,
                D.is_quoted_identifier_on ,
                D.is_recursive_triggers_on ,
                D.is_cursor_close_on_commit_on ,
                D.is_local_cursor_default ,
                D.is_fulltext_enabled ,
                D.is_trustworthy_on ,
                D.is_db_chaining_on ,
                D.is_parameterization_forced ,
                D.is_published ,
                D.is_subscribed ,
                D.is_merge_published ,
                D.is_distributor ,
                D.is_broker_enabled ,
                D.log_reuse_wait ,
                D.log_reuse_wait_desc ,
                D.is_cdc_enabled ,
                VL.VLFCount ,
                DF.NumberOfDataFiles ,
                LF.NumberOfLogFiles
        INTO    #SR_Databases
        FROM    sys.databases D
                INNER JOIN #VLFCountResults VL ON VL.DatabaseName COLLATE DATABASE_DEFAULT = D.name
                OUTER APPLY ( SELECT    COUNT(1) NumberOfDataFiles
                                FROM      sys.master_files MF
                                WHERE     MF.database_id = D.database_id
                                        AND MF.type = 0
                            ) DF
                OUTER APPLY ( SELECT    COUNT(1) NumberOfLogFiles
                                FROM      sys.master_files MF
                                WHERE     MF.database_id = D.database_id
                                        AND MF.type = 1
                            ) LF
        WHERE   D.state = 0;

        DROP TABLE #VLFInfo;
        DROP TABLE #VLFCountResults;

--------------------------------------------------------------------------------------------------
        DECLARE @PhysicalMemory INT ,
            @VirtualMemory INT ,
            @Committed INT ,
            @CommittedTarget INT ,
            @VisibleTarget INT;
        IF @MajorVersion > 1050
            EXEC sp_executesql N'
SELECT	@PhysicalMemory = physical_memory_kb/1024 ,--MB
		@VirtualMemory = virtual_memory_kb/1024 ,
		@Committed = committed_kb/1024 ,
		@CommittedTarget = committed_target_kb/1024 ,
		@VisibleTarget = visible_target_kb/1024
FROM	sys.dm_os_sys_info WITH (NOLOCK)
OPTION(RECOMPILE);', N'@PhysicalMemory INT OUTPUT,
		@VirtualMemory INT OUTPUT,
		@Committed INT OUTPUT,
		@CommittedTarget INT OUTPUT,
		@VisibleTarget INT OUTPUT',
                @PhysicalMemory = @PhysicalMemory OUTPUT,
                @VirtualMemory = @VirtualMemory OUTPUT,
                @Committed = @Committed OUTPUT,
                @CommittedTarget = @CommittedTarget OUTPUT,
                @VisibleTarget = @VisibleTarget OUTPUT;
        ELSE
            EXEC sp_executesql N'
SELECT	@PhysicalMemory = physical_memory_in_bytes/1024/1024 ,--MB
		@VirtualMemory = virtual_memory_in_bytes/1024/1024
FROM	sys.dm_os_sys_info WITH (NOLOCK)
OPTION(RECOMPILE);', N'@PhysicalMemory INT OUTPUT,
		@VirtualMemory INT OUTPUT',
                @PhysicalMemory = @PhysicalMemory OUTPUT,
                @VirtualMemory = @VirtualMemory OUTPUT;

        DECLARE @OS_Mem FLOAT ,
            @ThreadStack INT ,
            @vCPU INT ,
			--@PhysicalMemory INT,
            @VMOverhead INT;

        IF OBJECT_ID('tempdb..#_XPMSVER') IS NOT NULL
            DROP TABLE #_XPMSVER;
        CREATE TABLE #_XPMSVER
            (
                IDX INT NULL ,
                NAME VARCHAR(100) COLLATE DATABASE_DEFAULT
                                    NULL ,
                INT_VALUE FLOAT NULL ,
                C_VALUE VARCHAR(128) COLLATE DATABASE_DEFAULT
                                        NULL
            )
        ON  [PRIMARY];
        INSERT  INTO #_XPMSVER
                EXEC ( 'master.dbo.xp_msver'
                    );

        DECLARE @PlatformType INT;
        SELECT  @PlatformType = CASE WHEN C_VALUE LIKE '%x86%' THEN 1
                                        WHEN C_VALUE LIKE '%x64%' THEN 2
                                        WHEN C_VALUE LIKE '%IA64%' THEN 4
                                END
        FROM    #_XPMSVER
        WHERE   NAME = 'Platform'
        OPTION  ( RECOMPILE );

        IF OBJECT_ID('tempdb..#SR_ServerProporties') IS NOT NULL
            DROP TABLE #SR_ServerProporties;
        SELECT  cpu_count logicalCPU ,--@logicalCPU
                cpu_count / hyperthread_ratio CPU_Core ,
                hyperthread_ratio ,
                @PhysicalMemory PhysicalMemory ,
                @VirtualMemory VirtualMemory ,
                @Committed Committed ,
                @CommittedTarget CommittedTarget ,
                -@VisibleTarget VisibleTarget ,
                os_quantum ,
                os_error_mode ,
                os_priority_class ,
                max_workers_count ,
                scheduler_count ,
                scheduler_total_count ,
                deadlock_monitor_serial_number ,
                sqlserver_start_time ,
                affinity_type ,
                virtual_machine_type ,
                CASE WHEN @@Version LIKE '%64-bit%' THEN 64
                        ELSE 32
                END OS_bit ,
                @PlatformType PlatformType ,
                max_workers_count * @PlatformType ThreadStack ,
                ( cpu_count / hyperthread_ratio ) / 4.0 OS_Mem
        INTO    #SR_ServerProporties
        FROM    sys.dm_os_sys_info WITH ( NOLOCK )
        OPTION  ( RECOMPILE );
-----------------------------------------------------------------------------------------------------------
        IF OBJECT_ID('tempdb..#SR_Configuration') IS NOT NULL
            DROP TABLE #SR_Configuration;

        SELECT  name ,
                value
        INTO    #SR_Configuration
        FROM    sys.configurations;
-----------------------------------------------------------------------------------------------------------

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


        DECLARE @counter INT; --This will be used to iterate the sampling loop for the PLE measure. 
        SET @counter = 0; 
        CREATE TABLE #pleSample
            (
                CaptureTime DATETIME ,
                PageLifeExpectancy BIGINT
            ); 
        WHILE @counter < 30 --Sampling will run approximately 1 minute. 
        BEGIN 
--Captures Page Life Expectancy from sys.dm_os_performance_counters 
            INSERT  INTO #pleSample
                    ( CaptureTime ,
                        PageLifeExpectancy 
 				    )
                    SELECT  CURRENT_TIMESTAMP ,
                            cntr_value
                    FROM    sys.dm_os_performance_counters
                    WHERE   object_name = N'SQLServer:Buffer Manager'
                            AND counter_name = N'Page life expectancy'
            OPTION  ( RECOMPILE );
            SET @counter = @counter + 1; 
            WAITFOR DELAY '000:00:02';
        END; 
        IF OBJECT_ID('tempdb..#SR_PLE') IS NOT NULL
            DROP TABLE #SR_PLE;
--This query will return the average PLE based on a 1 minute sample. 
        SELECT  AVG(PageLifeExpectancy) AS AveragePageLifeExpectancy
        INTO    #SR_PLE
        FROM    #pleSample; 
        IF OBJECT_ID('tempdb..#pleSample') IS NOT NULL
            DROP TABLE #pleSample;

-----------------------------------------------------------------------------------------------------------
	
        IF OBJECT_ID('tempdb..#SR_server_services') IS NOT NULL
            DROP TABLE #SR_server_services;
        SELECT  servicename ,
                startup_type_desc ,
                startup_type ,
                status ,
                status_desc ,
                service_account
        INTO    #SR_server_services
        FROM    sys.dm_server_services WITH ( NOLOCK );
-----------------------------------------------------------------------------------------------------------
        IF OBJECT_ID('tempdb..#SR_login') IS NOT NULL
            DROP TABLE #SR_login;
		CREATE TABLE #SR_login([Name] sysname,Header VARCHAR(6),[Salt] NVARCHAR(MAX),[password_hash] NVARCHAR(MAX));
--Collect sql logins data(Alert week Password)
		IF @Allow_Week_Password_Check = 1
		INSERT	#SR_login
        SELECT  name  COLLATE DATABASE_DEFAULT [Name] ,
                CONVERT(NVARCHAR(6),SUBSTRING([password_hash], 0, 3),1) Header ,
                CONVERT(NVARCHAR(MAX), CONVERT(VARBINARY(4), SUBSTRING([password_hash_str], 2, 2)),1) Salt ,
                [password_hash_full_str] password_hash
        FROM    sys.sql_logins WITH ( NOLOCK )
				CROSS APPLY (SELECT TOP 1 CONVERT(NVARCHAR(MAX), password_hash,1) [password_hash_full_str],CONVERT(NVARCHAR(MAX), password_hash) [password_hash_str])P
        OPTION  ( RECOMPILE );
-----------------------------------------------------------------------------------------------------------
--TempDB
        IF OBJECT_ID('tempdb..#SR_MasterFiles') IS NOT NULL
            DROP TABLE #SR_MasterFiles;
        SELECT  size ,
                file_id ,
                database_id ,
                type
        INTO    #SR_MasterFiles
        FROM    sys.master_files;
-----------------------------------------------------------------------------------------------------------
-- Sustained values above 10 suggest further investigation in that area
-- High Avg Task Counts are often caused by blocking or other resource contention
	
        IF OBJECT_ID('tempdb..#SR_os_schedulers') IS NOT NULL
            DROP TABLE #SR_os_schedulers;
        SELECT  scheduler_id ,
                current_tasks_count ,
                runnable_tasks_count ,
                pending_disk_io_count,
				status,
				parent_node_id,
				is_online,
				is_idle,
				active_workers_count
        INTO    #SR_os_schedulers
        FROM    sys.dm_os_schedulers WITH ( NOLOCK )
        OPTION  ( RECOMPILE );
-----------------------------------------------------------------------------------------------------------
	
	
        IF OBJECT_ID('tempdb..#SR_servers') IS NOT NULL
            DROP TABLE #SR_servers;
        SELECT  server_id ,
                name ,
                data_source ,
                is_linked
        INTO    #SR_servers
        FROM    sys.servers
        OPTION  ( RECOMPILE );
----------------------------------------  TraceFlags  ----------------------------------------
        IF OBJECT_ID('tempdb..#SR_TraceStatus') IS NOT NULL
            DROP TABLE #SR_TraceStatus;
        CREATE TABLE #SR_TraceStatus
            (
                TraceFlag VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS ,
                status BIT ,
                Global BIT ,
                Session BIT
            );
        INSERT  INTO #SR_TraceStatus
                EXEC ( ' DBCC TRACESTATUS(-1) WITH NO_INFOMSGS'
                    );
----------------------------------------  TraceFlags  ----------------------------------------
        IF OBJECT_ID('tempdb..#SR_MachineSettings') IS NULL
            CREATE TABLE #SR_MachineSettings
                (
                    ServerName NVARCHAR(200) ,
                    MachineName NVARCHAR(200) ,
                    Instance sysname ,
                    ProcessorCount VARCHAR(150) ,
                    ProcessorName VARCHAR(150) ,
                    PhysicalMemory VARCHAR(150) ,
                    SQLAccount VARCHAR(1000) ,
                    SQLAgentAccount VARCHAR(1000) ,
                    AuthenticationnMode VARCHAR(1000) ,
                    Version NVARCHAR(4000) ,
                    ProductVersion NVARCHAR(128) ,
                    Edition NVARCHAR(4000) ,
                    Collation NVARCHAR(500) ,
                    ProductLevel NVARCHAR(500) ,
                    SystemModel VARCHAR(40) ,
                    ServerStartTime DATETIME ,
                    InstantInitializationDisabled BIT ,
                    LockPagesInMemoryDisabled BIT,
					MaxClockSpeed INT,
					CurrentClockSpeed INT
                );

        DECLARE @SQLSVRACC VARCHAR(50); 
        DECLARE @SQLAGTACC VARCHAR(50);
        DECLARE @LOGINMODE VARCHAR(50);
        DECLARE @SystemManufacturer VARCHAR(20);
        EXEC master..xp_regread @rootkey = 'HKEY_LOCAL_MACHINE',
            @key = 'HARDWARE\DESCRIPTION\System\BIOS',
            @value_name = 'SystemManufacturer',
            @value = @SystemManufacturer OUTPUT;
  
        DECLARE @SystemModal VARCHAR(20);
        EXEC master..xp_regread @rootkey = 'HKEY_LOCAL_MACHINE',
            @key = 'HARDWARE\DESCRIPTION\System\BIOS',
            @value_name = 'SystemProductName',
            @value = @SystemModal OUTPUT;
  
        DECLARE @ProcessorNameString NVARCHAR(1024);
        EXEC master..xp_regread N'HKEY_LOCAL_MACHINE',
            N'HARDWARE\DESCRIPTION\System\CentralProcessor\0\',
            N'ProcessorNameString', @ProcessorNameString OUTPUT;

        IF OBJECT_ID('tempdb..#reg') IS NOT NULL
            EXEC ('Drop table #reg');

        CREATE TABLE #reg
            (
                keyname CHAR(200) ,
                value VARCHAR(1000)
            );

        DECLARE @key VARCHAR(8000); -- Holds Registry Key Value

--Build Sql Server's full service name
        DECLARE @SQLServiceName VARCHAR(8000);
        SELECT  @SQLServiceName = @@ServiceName;
        SET @SQLServiceName = CASE WHEN @@ServiceName = 'MSSQLSERVER'
                                    THEN 'MSSQLSERVER'
                                    ELSE 'MSSQL$' + @@ServiceName
                                END; 

        SET @key = 'SYSTEM\CurrentControlSet\Services\' + @SQLServiceName;


--MSSQLSERVER Service Account
        INSERT  INTO #reg
                EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @key,
                    'ObjectName';
        UPDATE  #reg
        SET     keyname = @SQLServiceName; 

--SQLSERVERAGENT Service Account
        DECLARE @AgentServiceName VARCHAR(8000);
        SELECT  @AgentServiceName = @@ServiceName;
        SET @AgentServiceName = CASE WHEN @@ServiceName = 'MSSQLSERVER'
                                        THEN 'SQLSERVERAGENT'
                                        ELSE 'SQLAgent$' + @@ServiceName
                                END; 

        SET @key = 'SYSTEM\CurrentControlSet\Services\'
            + @AgentServiceName; 

        INSERT  INTO #reg
                EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @key,
                    'ObjectName';
	
        UPDATE  #reg
        SET     keyname = @AgentServiceName
        WHERE   keyname = 'ObjectName';


--Authentication Mode
        INSERT  INTO #reg
                EXEC master..xp_loginconfig 'login mode';
--EXEC master..xp_regread N'HKEY_LOCAL_MACHINE',N'Software\Microsoft\MSSQLServer\MSSQLServer',N'LoginMode'


        SELECT  @SQLSVRACC = value
        FROM    #reg
        WHERE   keyname = @SQLServiceName;
        SELECT  @SQLAGTACC = value
        FROM    #reg
        WHERE   keyname = @AgentServiceName; 
        SELECT  @LOGINMODE = CASE value
                                WHEN 'Windows NT Authentication'
                                THEN 'Windows Authentication Mode'
                                WHEN 'Mixed' THEN 'Mixed Mode'
                                END
        FROM    #reg
        WHERE   keyname = 'login mode';


        DROP TABLE #reg;


        DECLARE @WindowsVersion VARCHAR(150);
        DECLARE @Processorcount VARCHAR(150);
        DECLARE @ProcessorType VARCHAR(150);
        DECLARE @PhysicalMemorySTR VARCHAR(150);

        IF OBJECT_ID('tempdb..#Internal') IS NOT NULL
            EXEC ('Drop table #Internal');

        CREATE TABLE #Internal
            (
                [Index] INT ,
                Name VARCHAR(20) ,
                Internal_Value VARCHAR(150) ,
                Character_Value VARCHAR(150)
            );

        INSERT  INTO #Internal
                EXEC master..xp_msver;

        SET @WindowsVersion = ( SELECT  Character_Value
                                FROM    #Internal
                                WHERE   Name = 'WindowsVersion'
                                );
        SET @Processorcount = ( SELECT  Character_Value
                                FROM    #Internal
                                WHERE   Name = 'ProcessorCount'
                                );
        SET @ProcessorType = ( SELECT   Character_Value
                                FROM     #Internal
                                WHERE    Name = 'ProcessorType'
                                );
        SET @PhysicalMemorySTR = ( SELECT   Character_Value
                                    FROM     #Internal
                                    WHERE    Name = 'PhysicalMemory'
                                    );
    

        DROP TABLE #Internal;


        CREATE TABLE #xp_cmdshell_output ( Output VARCHAR(8000) );
        INSERT  INTO #xp_cmdshell_output EXEC ( 'xp_cmdshell "whoami /priv"');

        DECLARE @InstantInitializationDisabled BIT ,
				@LockPagesInMemoryDisabled BIT,
				@CurrentClockSpeed INT,
				@MaxClockSpeed INT;

        SELECT  @InstantInitializationDisabled = 0 ,
                @LockPagesInMemoryDisabled = 0;
	
        SELECT  @InstantInitializationDisabled = 1
        WHERE   NOT EXISTS ( SELECT TOP 1 1
                                FROM   #xp_cmdshell_output
                                WHERE  Output LIKE '%SeManageVolumePrivilege%'
                                    AND Output LIKE '%Enabled%' );

        SELECT  @LockPagesInMemoryDisabled = 1
        WHERE   NOT EXISTS ( SELECT TOP 1 1
                                FROM   #xp_cmdshell_output
                                WHERE  Output LIKE '%SeLockMemoryPrivilege%'
                                    AND Output LIKE '%Enabled%' );
		
		DELETE FROM #xp_cmdshell_output;
        INSERT  INTO #xp_cmdshell_output EXEC ( 'xp_cmdshell "wmic cpu get CurrentClockSpeed"');
		SELECT	TOP 1 @CurrentClockSpeed = LEFT(Output,4)
		FROM	#xp_cmdshell_output
		WHERE	ISNUMERIC(REPLACE(LEFT(Output,4),' ',''))= 1
				AND REPLACE(LEFT(Output,4),' ','') != '
';
		DELETE FROM #xp_cmdshell_output;
        INSERT  INTO #xp_cmdshell_output EXEC ( 'xp_cmdshell "wmic cpu get MaxClockSpeed"');
		SELECT	TOP 1 @MaxClockSpeed = LEFT(Output,4)
		FROM	#xp_cmdshell_output
		WHERE	ISNUMERIC(REPLACE(LEFT(Output,4),' ',''))= 1
				AND REPLACE(LEFT(Output,4),' ','') != '
';
		DELETE FROM #xp_cmdshell_output;
        INSERT  #SR_MachineSettings
        SELECT  ISNULL(CONVERT(NVARCHAR(200), @@ServerName),
                        CONVERT(NVARCHAR(200), SERVERPROPERTY('MachineName'))) AS ServerName ,
                CONVERT(NVARCHAR(200), SERVERPROPERTY('MachineName')) AS MachineName ,
                @@ServiceName AS Instance ,
                @Processorcount AS ProcessorCount ,
                @ProcessorNameString AS ProcessorName ,
                @PhysicalMemorySTR AS PhysicalMemory ,
                @SQLSVRACC AS SQLAccount ,
                @SQLAGTACC AS SQLAgentAccount ,
                @LOGINMODE AS AuthenticationnMode ,
                @@Version AS Version ,
                CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)) ProductVersion ,
                CONVERT(NVARCHAR(200), SERVERPROPERTY('Edition')) AS Edition ,
                CONVERT(NVARCHAR(200), SERVERPROPERTY('Collation')) AS Collation ,
                CONVERT(NVARCHAR(200), SERVERPROPERTY('ProductLevel')) AS ProductLevel ,
                @SystemManufacturer + ' ' + @SystemModal AS SystemModel ,
                ( SELECT TOP 1
                            login_time AS ServiceStartTime
                    FROM      sys.sysprocesses
                    WHERE     spid = 1
                ) AS ServerStartTime ,
                @LockPagesInMemoryDisabled ,
                @InstantInitializationDisabled,
				@MaxClockSpeed,
				@CurrentClockSpeed;
					


-----------------------------------------------------------------------------------------------------------

DECLARE @GetInstances TABLE
( Value nvarchar(100),
InstanceNames nvarchar(100),
Data nvarchar(100))

Insert into @GetInstances
EXECUTE xp_regread
  @rootkey = 'HKEY_LOCAL_MACHINE',
  @key = 'SOFTWARE\Microsoft\Microsoft SQL Server',
  @value_name = 'InstalledInstances'

  
	DECLARE @ver nvarchar(128)
	
	DECLARE @ComptabilityLevel nvarchar(128)



  /* declare variables */
	DECLARE @InstanceNames nvarchar(1000)
	DECLARE @reg TABLE
		(
			keyname CHAR(200) ,
			value NVARCHAR(1000)
		);
	DECLARE @Tempreg TABLE
		(
			keyname CHAR(200) ,
			value NVARCHAR(1000)
		);
		IF OBJECT_ID('tempdb..#SR_reg') IS NOT NULL DROP TABLE #SR_reg
	CREATE TABLE #SR_reg
		(
			Service VARCHAR(1000),
			InstanceNames VARCHAR(1000),
			keyname CHAR(200) ,
			value NVARCHAR(1000),
			CurrentInstance AS CASE WHEN InstanceNames = @@SERVICENAME THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END
		);
	DECLARE @keyi VARCHAR(8000); -- Holds Registry Key Value
		
	DECLARE @SQLServiceNamei VARCHAR(8000);
	DECLARE @AgentServiceNamei VARCHAR(8000);
  DECLARE crInctances CURSOR FAST_FORWARD READ_ONLY FOR SELECT	InstanceNames
  FROM	@GetInstances
  ORDER BY Value
  
  OPEN crInctances
  
  FETCH NEXT FROM crInctances INTO @InstanceNames
  
  WHILE @@FETCH_STATUS = 0
  BEGIN
--Build Sql Server's full service name
        SET @SQLServiceNamei = CASE WHEN @InstanceNames = 'MSSQLSERVER'
                                    THEN 'MSSQLSERVER'
                                    ELSE 'MSSQL$' + @InstanceNames
                                END; 

        SET @keyi = 'SYSTEM\CurrentControlSet\Services\' + @SQLServiceNamei;

             DELETE FROM @reg  
--MSSQLSERVER Service Account
        INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'ObjectName';
        UPDATE  @reg
        SET     keyname = @SQLServiceNamei; 
             INSERT #SR_reg
                     ( Service, InstanceNames,keyname, value )
             SELECT 'SQL Server Engine',@InstanceNames,'Account Name'  ,value FROM @reg;

             -------------------------------------------------------------------------------	
        SET @keyi = 'SYSTEM\CurrentControlSet\Services\' + @SQLServiceNamei;

        DELETE FROM @reg  
--MSSQLSERVER Service Account
        INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'Start';
        UPDATE  @reg
        SET     keyname = @SQLServiceNamei; 
             INSERT #SR_reg
                     ( Service, InstanceNames,keyname, value )
             SELECT 'SQL Server Engine State',@InstanceNames,'Service state'  ,CASE value WHEN '2' THEN 'Running' 
			 WHEN '3' THEN 'Stoped'
			 ELSE 'Unknown' END
			 FROM @reg;
             -------------------------------------------------------------------------------
             IF @InstanceNames = @@SERVICENAME
             BEGIN
                 SET @ver = CAST(serverproperty('ProductVersion') AS nvarchar)
                    IF ( SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1) = '10' )
                    BEGIN
                           IF SUBSTRING(SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)),1,CHARINDEX('.', SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)))-1) = '50'
                                 SELECT @ver = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1) + '_' + SUBSTRING(SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)),1,CHARINDEX('.', SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)))-1);
                           ELSE SELECT @ver = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1)
                    END
   
                    ELSE SELECT @ver = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1)
             END
                    

             SET @keyi = CASE WHEN @InstanceNames = 'MSSQLSERVER'
                                    THEN 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL' + @Ver + '.' + @InstanceNames + '\MSSQLServer\CurrentVersion'
                                    ELSE 'SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server\' + @InstanceNames + '\MSSQLServer\CurrentVersion'
                                END; 
             DELETE FROM @reg;
             DELETE FROM @Tempreg; 

        INSERT  INTO @Tempreg
             EXECUTE xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'CurrentVersion';
			 
             SELECT @ver = value
             FROM   @Tempreg;

             SET @ComptabilityLevel = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1) + SUBSTRING(SUBSTRING(@ver, CHARINDEX('.', @ver)+1,LEN(@ver) ), 1, 1);
             IF ( SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1) = '10' )
             BEGIN
                    IF SUBSTRING(SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)),1,CHARINDEX('.', SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)))-1) = '50'
                           SELECT @ver = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1) + '_' + SUBSTRING(SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)),1,CHARINDEX('.', SUBSTRING(@ver, CHARINDEX('.', @ver)+1 , LEN(@ver)))-1);
                    ELSE SELECT @ver = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1)
             END
   
             ELSE SELECT @ver = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1)

----------------------------------------------------------------------------------------------------------------------------------
             SET @key = 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL' + @Ver + '.' + @InstanceNames + '\Setup'

			 INSERT   @reg
             EXECUTE xp_regread 'HKEY_LOCAL_MACHINE', @key, 'PatchLevel';
			 
             INSERT #SR_reg ( Service,InstanceNames, keyname, value )
             SELECT 'SQL Server Engine Version',@InstanceNames,'Last Version Installed' ,value FROM @reg;
			 
		
----------------------------------------------------------------------------------------------------------------------------------
             DELETE FROM @reg;
             SET @keyi = 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL' + @Ver + '.' + @InstanceNames + '\Setup'
             INSERT  INTO @reg
             EXECUTE xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'Edition';

             INSERT #SR_reg ( Service,InstanceNames, keyname, value )
             SELECT 'SQL Server Engine Edition',@InstanceNames,'Edition Installed' ,value FROM @reg;
			 
		
----------------------------------------------------------------------------------------------------------------------------------
             --Error Log file
             DELETE FROM @reg;
        SET @keyi = N'Software\Microsoft\Microsoft SQL Server\MSSQL' + @Ver + '.' + @InstanceNames + '\MSSQLServer'

             INSERT  INTO @reg
        EXECUTE xp_regread N'HKEY_LOCAL_MACHINE',@keyi, N'NumErrorLogs';

             INSERT #SR_reg ( Service,InstanceNames, keyname, value )
             SELECT 'SQL Server Number of Error Log files',@InstanceNames,'Number Error Logs' ,value FROM @reg;     
			 
		         
----------------------------------------------------------------------------------------------------------------------------------
             DELETE FROM @reg;


             SET @key = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + @ComptabilityLevel;

        INSERT  INTO @reg
             EXECUTE xp_regread 'HKEY_LOCAL_MACHINE', @key, 'CustomerFeedback';

             INSERT #SR_reg ( Service,InstanceNames, keyname, value )
             SELECT 'SQL Server Customer Feedback',@InstanceNames,'Customer Feedback Enabled' ,value FROM @reg;
             DELETE FROM @reg;

        INSERT  INTO @reg
             EXECUTE xp_regread 'HKEY_LOCAL_MACHINE', @key, 'EnableErrorReporting';

             INSERT #SR_reg ( Service,InstanceNames, keyname, value )
             SELECT 'SQL Server Error Reporting',@InstanceNames,'Error Reporting Enabled' ,value FROM @reg;

			 
		
----------------------------------------------------------------------------------------------------------------------------------
        --SQLSERVERAGENT Service Account
        SET @AgentServiceNamei = CASE WHEN @InstanceNames = 'MSSQLSERVER'
                                        THEN 'SQLSERVERAGENT'
                                        ELSE 'SQLAgent$' + @InstanceNames
                                END; 

        SET @keyi = 'SYSTEM\CurrentControlSet\Services\' + @AgentServiceNamei; 
             
        DELETE FROM @reg  
        INSERT  INTO @reg
                EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'ObjectName';
       
        UPDATE  @reg
        SET     keyname = @AgentServiceNamei
        WHERE   keyname = 'ObjectName';
        INSERT #SR_reg
                ( Service, InstanceNames,keyname, value )
        SELECT 'SQL Server Agent',@InstanceNames,'Account Name' ,value FROM @reg;
----------------------------------------------------------------------------------------------------
        --Windows Power Plan
		IF @InstanceNames = @@SERVICENAME
        BEGIN
			SET @keyi = 'SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}'; 
             
			DELETE FROM @reg  
			INSERT  INTO @reg
					EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'PreferredPlan';
       
			INSERT #SR_reg
					( Service, InstanceNames,keyname, value )
			SELECT 'Windows Power Plan',@InstanceNames,'Power Plan' ,CASE CONVERT(VARCHAR(50),value) 
					WHEN '381b4222-f694-41f0-9685-ff5bb260df2e' THEN 'Balanced'
					WHEN 'a1841308-3541-4fab-bc81-f71556f20b4a' THEN 'Power saver'
					WHEN '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' THEN 'High performance'
					ELSE NULL END 
			FROM	@reg;
		END
----------------------------------------------------------------------------------------------------
        --Windows Power Plan
		IF @InstanceNames = @@SERVICENAME--HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\
        BEGIN
			SET @keyi = 'SOFTWARE\CurrentControlSet\Control\Session Manager\Memory Management'; 
             
			DELETE FROM @reg  
			INSERT  INTO @reg
					EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'PagingFiles';
       
			INSERT #SR_reg
					( Service, InstanceNames,keyname, value )
			SELECT 'Windows Page File',@InstanceNames,'PagingFiles' ,value
			FROM	@reg;
		END		
----------------------------------------------------------------------------------------------------
--SQLArgs
        DELETE FROM @reg  
        
        SET @keyi = CASE WHEN @InstanceNames = 'MSSQLSERVER'
                            THEN 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL' + @Ver + '.' + @InstanceNames + '\MSSQLServer\Parameters'
                            ELSE 'SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server\' + @InstanceNames + '\MSSQLServer\Parameters'
                        END; 
        DELETE FROM @reg  
        INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs3';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs4';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs5';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs6';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs7';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs8';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs9';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs10';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs11';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs12';
		INSERT  INTO @reg EXEC master..xp_regread 'HKEY_LOCAL_MACHINE', @keyi, 'SQLArgs13';
       
        UPDATE  @reg
        SET     keyname = @InstanceNames
        WHERE   keyname like 'SQLArgs%';
		
        INSERT #SR_reg
                ( Service, InstanceNames,keyname, value )
        SELECT 'SQL Server Trace Flage',@InstanceNames,'Trace Flage' ,value FROM @reg;
----------------------------------------------------------------------------------------------------
      FETCH NEXT FROM crInctances INTO @InstanceNames      
  END
  
  CLOSE crInctances
  DEALLOCATE crInctances
-----------------------------------------------------------------------------------------------------------
        IF OBJECT_ID('tempdb..#SR_Jobs') IS NOT NULL
            DROP TABLE #SR_Jobs;
        SELECT  T.JobName ,
                T.RunDateTime ,
                T.RunDurationMinutes,
				CONVERT(NVARCHAR(MAX),'Over 55 Minuts')[Type]
        INTO    #SR_Jobs
        FROM    ( SELECT    j.name AS JobName ,
                            rdm.RunDateTime ,
                            rdm.RunDurationMinutes ,
                            ROW_NUMBER() OVER ( PARTITION BY j.name ORDER BY rdm.RunDateTime DESC ) RN
                    FROM      msdb.dbo.sysjobs j
                            INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
                            CROSS APPLY ( SELECT    msdb.dbo.agent_datetime(run_date, run_time) AS RunDateTime ,
                                                    ( ( h.run_duration / 10000 * 3600 + ( h.run_duration / 100 ) % 100 * 60 + run_duration % 100 + 31 ) / 60 ) RunDurationMinutes
                                        ) rdm
                    WHERE     j.enabled = 1  --Only Enabled Jobs
                            AND rdm.RunDateTime > DATEADD(DAY, -3,
                                                            GETDATE())
							AND rdm.RunDurationMinutes > 55
                ) T
        WHERE   T.RN = 1;

		
	INSERT	#SR_Jobs
	SELECT  --h.job_id ,
            j.name JobName,
            joa.JobStart ,
            --joa.JobEnd ,
            --joa.outcome ,
            --CONVERT(VARCHAR(50),DATEDIFF(MI, joa.JobStart, joa.JobEND)) + ' Min' Duration
			rdm.RunDurationMinutes,
			'Longer then the next run'
    FROM    msdb..sysjobhistory AS h
			CROSS APPLY ( SELECT    msdb.dbo.agent_datetime(run_date, run_time) AS RunDateTime ,
                                                    ( ( h.run_duration / 10000 * 3600 + ( h.run_duration / 100 ) % 100 * 60 + run_duration % 100 + 31 ) / 60 ) RunDurationMinutes
                                        ) rdm
            INNER JOIN msdb..sysjobs AS j ON j.job_id = h.job_id
            OUTER APPLY ( SELECT    CAST(SUBSTRING(CONVERT(VARCHAR(10), h.run_date),
                                                   5, 2) + '-'
                                    + SUBSTRING(CONVERT(VARCHAR(10), h.run_date),
                                                7, 2) + '-'
                                    + SUBSTRING(CONVERT(VARCHAR(10), h.run_date),
                                                1, 4) + ' '
                                    + +SUBSTRING(CONVERT(VARCHAR(10), REPLICATE('0',
                                                              6
                                                              - LEN(h.run_time))
                                                 + CAST(h.run_time AS VARCHAR)),
                                                 1, 2) + ':'
                                    + SUBSTRING(CONVERT(VARCHAR(10), REPLICATE('0',
                                                              6
                                                              - LEN(h.run_time))
                                                + CAST(h.run_time AS VARCHAR)),
                                                3, 2) + ':'
                                    + SUBSTRING(CONVERT(VARCHAR(10), REPLICATE('0',
                                                              6
                                                              - LEN(h.run_time))
                                                + CAST(h.run_time AS VARCHAR)),
                                                5, 2) AS SMALLDATETIME) AS JobStart ,
                                    DATEADD(SECOND,
                                            CASE WHEN h.run_duration > 0
                                                 THEN ( h.run_duration
                                                        / 1000000 ) * ( 3600
                                                              * 24 )
                                                      + ( h.run_duration
                                                          / 10000 % 100 )
                                                      * 3600
                                                      + ( h.run_duration / 100
                                                          % 100 ) * 60
                                                      + ( h.run_duration % 100 )
                                                 ELSE 0
                                            END,
                                            CAST(SUBSTRING(CONVERT(VARCHAR(10), h.run_date),
                                                           5, 2) + '-'
                                            + SUBSTRING(CONVERT(VARCHAR(10), h.run_date),
                                                        7, 2) + '-'
                                            + SUBSTRING(CONVERT(VARCHAR(10), h.run_date),
                                                        1, 4) + ' '
                                            + +SUBSTRING(CONVERT(VARCHAR(10), REPLICATE('0',
                                                              6
                                                              - LEN(h.run_time))
                                                         + CAST(h.run_time AS VARCHAR)),
                                                         1, 2) + ':'
                                            + SUBSTRING(CONVERT(VARCHAR(10), REPLICATE('0',
                                                              6
                                                              - LEN(h.run_time))
                                                        + CAST(h.run_time AS VARCHAR)),
                                                        3, 2) + ':'
                                            + SUBSTRING(CONVERT(VARCHAR(10), REPLICATE('0',
                                                              6
                                                              - LEN(h.run_time))
                                                        + CAST(h.run_time AS VARCHAR)),
                                                        5, 2) AS SMALLDATETIME)) AS JobEND ,
                                    outcome = CASE WHEN h.run_status = 0
                                                   THEN 'Fail'
                                                   WHEN h.run_status = 1
                                                   THEN 'Success'
                                                   WHEN h.run_status = 2
                                                   THEN 'Retry'
                                                   WHEN h.run_status = 3
                                                   THEN 'Cancel'
                                                   WHEN h.run_status = 4
                                                   THEN 'In progress'
                                              END
                        ) joa
			CROSS APPLY(SELECT	TOP 1 freq_subday_interval,job_id,
								CASE 
								WHEN [sSCH].freq_subday_type = 4 THEN [sSCH].freq_subday_interval * 60		-- Minuts
								WHEN [sSCH].freq_subday_type = 2 THEN [sSCH].freq_subday_interval			-- Seconds
								WHEN [sSCH].freq_subday_type = 8 THEN [sSCH].freq_subday_interval * 60 * 60 -- Hours
								END SecondsToNextRun
						FROM	msdb..[sysjobschedules] AS [sJOBSCH]
								LEFT JOIN msdb..[sysschedules] AS [sSCH] ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
						WHERE	sSCH.enabled = 1
								AND [sSCH].freq_type = 4 --Daily	
								AND [sSCH].freq_interval = 1 -- One Day
								AND [sSCH].freq_subday_type != 1 -- Minuts
								AND [sJOBSCH].job_id = j.job_id
								)SC
    WHERE   h.step_id = 0
            AND j.enabled = 1
            AND CAST(SUBSTRING(CONVERT(VARCHAR(10), h.run_date), 5, 2) + '-'
            + SUBSTRING(CONVERT(VARCHAR(10), h.run_date), 7, 2) + '-'
            + SUBSTRING(CONVERT(VARCHAR(10), h.run_date), 1, 4) AS SMALLDATETIME) = CONVERT(VARCHAR(10), GETDATE(), 121)
			--AND DATEDIFF(MI, joa.JobStart, joa.JobEND) > 10 -- 10 Min
			AND SC.SecondsToNextRun < DATEDIFF(SECOND, joa.JobStart, joa.JobEnd)

	IF OBJECT_ID('tempdb..#JobStatus') IS NOT NULL DROP TABLE #JobStatus;
		CREATE TABLE #JobStatus([JobName] sysname,[StepID] INT, [StepName] sysname,[Outcome] NVARCHAR(255),
		[LastRunDatetime] DATETIME,
		--[Diff] VARCHAR(50),
		[SubSystem] NVARCHAR(512),
		[Message] NVARCHAR(max),
		[Caller] NVARCHAR(255));
	IF OBJECT_ID('tempdb..#SR_JobOut') IS NULL
		CREATE TABLE #SR_JobOut([JobName] sysname,[StepID] INT, [StepName] sysname,[Outcome] NVARCHAR(255),
		[LastRunDatetime] DATETIME,
		--[Diff] VARCHAR(50),
		[SubSystem] NVARCHAR(512),
		[Message] NVARCHAR(max),
		[Caller] NVARCHAR(255));

	IF EXISTS(SELECT TOP 1 1 FROM sys.databases D WHERE D.name = 'SSIS')
	BEGIN
		INSERT #JobStatus
		SELECT	j.name [JobName],
				js.step_id [StepID],
				js.step_name [StepName],
				--js.database_name [ExecutingDBOnJob],
				CASE 
				WHEN JSS.[SubSystem] = 'Maintenance Plans(SSIS)' AND MP.Error COLLATE DATABASE_DEFAULT != '' THEN LR.last_run_outcome + ' + Minor Errors'
				WHEN LR.last_run_datetime >= ISNULL(xSDT.StartDateTime,JxA.run_requested_date) OR ST.StepID IS NULL THEN LR.last_run_outcome 
						ELSE 'Did not run' END	[Outcome],
				CASE WHEN LR.last_run_datetime >= ISNULL(xSDT.StartDateTime,JxA.run_requested_date) THEN case WHEN ST.StepID IS NULL THEN null
									else LR.last_run_datetime END
						ELSE NULL END [LastRunDatetime] ,
				--[Utility].[ufn_DATEDIFF2String1](CASE WHEN LR.last_run_datetime >= ISNULL(xSDT.StartDateTime,JxA.run_requested_date) THEN case WHEN ST.StepID IS NULL THEN null
				--					else LR.last_run_datetime END
				--		ELSE NULL END,GETDATE()) [Diff],
			   JSS.[SubSystem],
			   CASE WHEN LR.last_run_datetime >= xSDT.StartDateTime THEN
					   CASE  
						WHEN JSS.[SubSystem] = 'Maintenance Plans(SSIS)' THEN CASE WHEN MP.Error COLLATE DATABASE_DEFAULT = '' THEN JH.message ELSE ISNULL(MP.Error COLLATE DATABASE_DEFAULT,JH.message) END
						WHEN LR.last_run_outcome = 'Failed' AND js.subsystem = 'SSIS' THEN JH.message
						WHEN LR.last_run_outcome = 'Failed' AND js.subsystem = 'TSQL' THEN JH.message
					   ELSE NULL END 
			   ELSE NULL END [Message],
			   CASE WHEN j.description LIKE '%report server%' THEN 'Report Server, ' ELSE '' END + ISNULL('Alert - ' + Al.name + ', ','') + ISNULL('Schedule - ' + SCH.name,'') [Caller]
		FROM	msdb.dbo.sysjobs j
				INNER JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id
				CROSS APPLY(SELECT TOP 1 CASE WHEN patINDEX('%"Maintenance Plans\%',js.command) > 0 THEN 'Maintenance Plans(SSIS)' ELSE
				CASE js.subsystem
			WHEN 'ActiveScripting' THEN 'ActiveX Script'
			WHEN 'CmdExec' THEN 'Operating system (CmdExec)'
			WHEN 'PowerShell' THEN 'PowerShell'
			WHEN 'Distribution' THEN 'Replication Distributor'
			WHEN 'Merge' THEN 'Replication Merge'
			WHEN 'QueueReader' THEN 'Replication Queue Reader'
			WHEN 'Snapshot' THEN 'Replication Snapshot'
			WHEN 'LogReader' THEN 'Replication Transaction-Log Reader'
			WHEN 'ANALYSISCOMMAND' THEN 'SQL Server Analysis Services Command'
			WHEN 'ANALYSISQUERY' THEN 'SQL Server Analysis Services Query'
			WHEN 'SSIS' THEN 'SQL Server Integration Services Package'
			WHEN 'TSQL' THEN 'Transact-SQL script (T-SQL)'
			ELSE js.subsystem END
		  END AS [SubSystem]) JSS
				LEFT JOIN (SELECT	DISTINCT Ij.name,ISNULL(IIF(LAG(Ijs.on_success_step_id) OVER(ORDER BY Ijs.step_id) = 0,Ijs.step_id,LAG(Ijs.on_success_step_id) OVER(ORDER BY Ijs.step_id)),Ijs.step_id) StepID
							FROM	msdb.dbo.sysjobs Ij
									inner join msdb.dbo.sysjobsteps Ijs on Ij.job_id = Ijs.job_id
									) ST ON ST.StepID = js.step_id and ST.name = j.name
				CROSS APPLY (SELECT TOP 1 msdb.dbo.agent_datetime(
								   case when js.last_run_date = 0 then NULL else js.last_run_date end,
								   case when js.last_run_time = 0 then NULL else js.last_run_time end) last_run_datetime,
								   case WHEN ST.StepID IS NULL THEN 'Disabled'
									when js.last_run_outcome = 0 then 'Failed'
									when js.last_run_outcome = 1 then 'Succeeded'
									when js.last_run_outcome = 2 then 'Retry'
									when js.last_run_outcome = 3 then 'Canceled'
									else 'Unknown'
								   end AS last_run_outcome
								   ) LR
				LEFT JOIN msdb.dbo.sysjobhistory JH ON j.job_id = JH.job_id
					AND JH.step_id = js.step_id
					AND msdb.dbo.agent_datetime(JH.run_date,JH.run_time) = case WHEN ST.StepID IS NULL THEN null else LR.last_run_datetime END
				LEFT JOIN msdb..sysalerts Al ON Al.job_id = j.job_id
				OUTER APPLY (SELECT TOP 1 S2.name FROM msdb..sysjobschedules S INNER JOIN msdb..sysschedules S2 ON S2.schedule_id = S.schedule_id WHERE j.job_id = S.job_id)SCH
				--LEFT JOIN #MPLog MP ON j.name LIKE MP.MP_Name + '%'
				OUTER APPLY (SELECT REPLACE(REPLACE(T.Error,'<X>',''),'</X>','')
							FROM	(SELECT  ld.error_message  X
									FROM    msdb..sysmaintplan_plans mp
											INNER JOIN msdb..sysmaintplan_subplans msp ON mp.id = msp.plan_id
											OUTER APPLY (SELECT TOP 1 * FROM msdb..sysmaintplan_log mpl WHERE msp.subplan_id = mpl.subplan_id ORDER BY mpl.start_time DESC)mpl
											LEFT JOIN msdb..sysmaintplan_logdetail ld ON mpl.task_detail_id = ld.task_detail_id
									WHERE   j.name LIKE mp.name + '%'
									FOR XML PATH(''))T(Error))MP(Error)
				OUTER APPLY (SELECT	TOP 1 [StartDateTime] = msdb.dbo.agent_datetime(
									   CASE WHEN xjs.last_run_date = 0 then NULL else xjs.last_run_date end,
									   CASE WHEN xjs.last_run_time = 0 then NULL else xjs.last_run_time end)
								FROM	msdb.dbo.sysjobsteps xjs
										LEFT JOIN (SELECT	ja.job_id,
															j.name AS job_name,
															ja.start_execution_date,      
															ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
															js.step_name
													FROM	msdb.dbo.sysjobactivity ja 
															LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id
															INNER JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
															INNER JOIN msdb.dbo.sysjobsteps js ON ja.job_id = js.job_id
																AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
													WHERE	ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
															AND start_execution_date is not null
															AND stop_execution_date is null)Ac ON Ac.job_id = xjs.job_id
								WHERE	j.job_id = xjs.job_id
										AND (Ac.start_execution_date != msdb.dbo.agent_datetime(case when xjs.last_run_date = 0 then NULL else xjs.last_run_date end,
									   case when xjs.last_run_time = 0 then NULL else xjs.last_run_time end) or Ac.start_execution_date is null)
								order by xjs.step_id)xSDT
				OUTER APPLY (SELECT	TOP 1 ja.run_requested_date FROM msdb.dbo.sysjobactivity ja WHERE j.job_id = ja.job_id ORDER BY ja.run_requested_date desc)JxA
				OUTER APPLY( SELECT  TOP 1 message--,event_message_id,package_name,event_name,message_source_name,package_path,execution_path,message_type,message_source_type
							   FROM    SSISDB.catalog.event_messages em
							   WHERE   em.package_name COLLATE database_default = RIGHT( SUBSTRING(js.command,0,patINDEX('%.dtsx%',js.command)), CHARINDEX( '\', REVERSE( SUBSTRING(js.command,0,patINDEX('%.dtsx%',js.command))) + '\' ) - 1 ) +N'.dtsx'
										--AND em.operation_id = (SELECT MAX(execution_id) FROM SSISDB.catalog.executions)
										AND event_name = 'OnError'
						ORDER BY event_message_id DESC
				)SS
  
		WHERE	j.enabled = 1
		ORDER BY j.name,js.step_id;
	END
	ELSE
	BEGIN
		INSERT #JobStatus
		SELECT	j.name [JobName],
				js.step_id [StepID],
				js.step_name [StepName],
				--js.database_name [ExecutingDBOnJob],
				CASE 
				WHEN JSS.[SubSystem] = 'Maintenance Plans(SSIS)' AND MP.Error COLLATE DATABASE_DEFAULT != '' THEN LR.last_run_outcome + ' + Minor Errors'
				WHEN LR.last_run_datetime >= ISNULL(xSDT.StartDateTime,JxA.run_requested_date) OR ST.StepID IS NULL THEN LR.last_run_outcome 
						ELSE 'Did not run' END	[Outcome],
				CASE WHEN LR.last_run_datetime >= ISNULL(xSDT.StartDateTime,JxA.run_requested_date) THEN case WHEN ST.StepID IS NULL THEN null
									else LR.last_run_datetime END
						ELSE NULL END [LastRunDatetime] ,
				--[Utility].[ufn_DATEDIFF2String1](CASE WHEN LR.last_run_datetime >= ISNULL(xSDT.StartDateTime,JxA.run_requested_date) THEN case WHEN ST.StepID IS NULL THEN null
				--					else LR.last_run_datetime END
				--		ELSE NULL END,GETDATE()) [Diff],
			   JSS.[SubSystem],
			   CASE WHEN LR.last_run_datetime >= xSDT.StartDateTime THEN
					   CASE 
						WHEN JSS.[SubSystem] = 'Maintenance Plans(SSIS)' THEN CASE WHEN MP.Error COLLATE DATABASE_DEFAULT = '' THEN JH.message ELSE ISNULL(MP.Error COLLATE DATABASE_DEFAULT,JH.message) END
						WHEN LR.last_run_outcome = 'Failed' AND js.subsystem = 'SSIS' THEN JH.message
						WHEN LR.last_run_outcome = 'Failed' AND js.subsystem = 'TSQL' THEN JH.message
					   ELSE NULL END 
			   ELSE NULL END [Message],
			   CASE WHEN j.description LIKE '%report server%' THEN 'Report Server, ' ELSE '' END + ISNULL('Alert - ' + Al.name + ', ','') + ISNULL('Schedule - ' + SCH.name,'') [Caller]
		FROM	msdb.dbo.sysjobs j
				INNER JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id
				CROSS APPLY(SELECT TOP 1 CASE WHEN patINDEX('%"Maintenance Plans\%',js.command) > 0 THEN 'Maintenance Plans(SSIS)' ELSE
				CASE js.subsystem	WHEN 'ActiveScripting' THEN 'ActiveX Script'
									WHEN 'CmdExec' THEN 'Operating system (CmdExec)'
									WHEN 'PowerShell' THEN 'PowerShell'
									WHEN 'Distribution' THEN 'Replication Distributor'
									WHEN 'Merge' THEN 'Replication Merge'
									WHEN 'QueueReader' THEN 'Replication Queue Reader'
									WHEN 'Snapshot' THEN 'Replication Snapshot'
									WHEN 'LogReader' THEN 'Replication Transaction-Log Reader'
									WHEN 'ANALYSISCOMMAND' THEN 'SQL Server Analysis Services Command'
									WHEN 'ANALYSISQUERY' THEN 'SQL Server Analysis Services Query'
									WHEN 'SSIS' THEN 'SQL Server Integration Services Package'
									WHEN 'TSQL' THEN 'Transact-SQL script (T-SQL)'
									ELSE js.subsystem END
								  END AS [SubSystem]) JSS
				LEFT JOIN (SELECT	DISTINCT Ij.name,ISNULL(IIF(LAG(Ijs.on_success_step_id) OVER(ORDER BY Ijs.step_id) = 0,Ijs.step_id,LAG(Ijs.on_success_step_id) OVER(ORDER BY Ijs.step_id)),Ijs.step_id) StepID
							FROM	msdb.dbo.sysjobs Ij
									inner join msdb.dbo.sysjobsteps Ijs on Ij.job_id = Ijs.job_id
									) ST ON ST.StepID = js.step_id and ST.name = j.name
				CROSS APPLY (SELECT TOP 1 msdb.dbo.agent_datetime(
								   case when js.last_run_date = 0 then NULL else js.last_run_date end,
								   case when js.last_run_time = 0 then NULL else js.last_run_time end) last_run_datetime,
								   case WHEN ST.StepID IS NULL THEN 'Disabled'
									when js.last_run_outcome = 0 then 'Failed'
									when js.last_run_outcome = 1 then 'Succeeded'
									when js.last_run_outcome = 2 then 'Retry'
									when js.last_run_outcome = 3 then 'Canceled'
									else 'Unknown'
								   end AS last_run_outcome
								   ) LR
				LEFT JOIN msdb.dbo.sysjobhistory JH ON j.job_id = JH.job_id
					AND JH.step_id = js.step_id
					AND msdb.dbo.agent_datetime(JH.run_date,JH.run_time) = case WHEN ST.StepID IS NULL THEN null else LR.last_run_datetime END
				LEFT JOIN msdb..sysalerts Al ON Al.job_id = j.job_id
				OUTER APPLY (SELECT TOP 1 S2.name FROM msdb..sysjobschedules S INNER JOIN msdb..sysschedules S2 ON S2.schedule_id = S.schedule_id WHERE j.job_id = S.job_id)SCH
				--LEFT JOIN #MPLog MP ON j.name LIKE MP.MP_Name + '%'
				OUTER APPLY (SELECT REPLACE(REPLACE(T.Error,'<X>',''),'</X>','')
							FROM	(SELECT  ld.error_message  X
									FROM    msdb..sysmaintplan_plans mp
											INNER JOIN msdb..sysmaintplan_subplans msp ON mp.id = msp.plan_id
											OUTER APPLY (SELECT TOP 1 * FROM msdb..sysmaintplan_log mpl WHERE msp.subplan_id = mpl.subplan_id ORDER BY mpl.start_time DESC)mpl
											LEFT JOIN msdb..sysmaintplan_logdetail ld ON mpl.task_detail_id = ld.task_detail_id
									WHERE   j.name LIKE mp.name + '%'
									FOR XML PATH(''))T(Error))MP(Error)
				OUTER APPLY (SELECT	TOP 1 [StartDateTime] = msdb.dbo.agent_datetime(
									   CASE WHEN xjs.last_run_date = 0 then NULL else xjs.last_run_date end,
									   CASE WHEN xjs.last_run_time = 0 then NULL else xjs.last_run_time end)
								FROM	msdb.dbo.sysjobsteps xjs
										LEFT JOIN (SELECT	ja.job_id,
															j.name AS job_name,
															ja.start_execution_date,      
															ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
															js.step_name
													FROM	msdb.dbo.sysjobactivity ja 
															LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id
															INNER JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
															INNER JOIN msdb.dbo.sysjobsteps js ON ja.job_id = js.job_id
																AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
													WHERE	ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
															AND start_execution_date is not null
															AND stop_execution_date is null)Ac ON Ac.job_id = xjs.job_id
								WHERE	j.job_id = xjs.job_id
										AND (Ac.start_execution_date != msdb.dbo.agent_datetime(case when xjs.last_run_date = 0 then NULL else xjs.last_run_date end,
									   case when xjs.last_run_time = 0 then NULL else xjs.last_run_time end) or Ac.start_execution_date is null)
								order by xjs.step_id)xSDT
				OUTER APPLY (SELECT	TOP 1 ja.run_requested_date FROM msdb.dbo.sysjobactivity ja WHERE j.job_id = ja.job_id ORDER BY ja.run_requested_date desc)JxA

  
		WHERE	j.enabled = 1
		ORDER BY JSS.[SubSystem],j.name,js.step_id;
	END

	INSERT	#SR_JobOut
	SELECT	*
	FROM	#JobStatus
	WHERE	Outcome LIKE '%Failed%' OR Outcome LIKE '%Error%'

	DROP TABLE #JobStatus;
	
	INSERT	#SR_Jobs
	SELECT	S.name JobName ,
            NULL RunDateTime ,
            NULL RunDurationMinutes,
			CONVERT(NVARCHAR(MAX),'Owner')[Type]
	FROM	msdb..sysjobs S
	WHERE	S.owner_sid != '0x01'
			AND S.enabled = 1;
---------------------------------------------------------------------------------------------------
        IF OBJECT_ID('tempdb..#SR_Latency') IS NOT NULL
            DROP TABLE #SR_Latency;
        SELECT  tab.Drive ,
                tab.type ,
                tab.num_of_reads ,
                tab.io_stall_read_ms ,
                tab.num_of_writes ,
                tab.io_stall_write_ms ,
                tab.num_of_bytes_read ,
                tab.num_of_bytes_written ,
                tab.io_stall ,
                RL.[Read Latency] [ReadLatency],
                RL.[Write Latency] [WriteLatency],
                RL.[Overall Latency] [OverallLatency],
                RL.[Avg Bytes/Read] [AvgBytes_Read],
                RL.[Avg Bytes/Write] [AvgBytes_Write],
                RL.[Avg Bytes/Transfer] [AvgBytes_Transfer]
        INTO    #SR_Latency
        FROM    ( SELECT    LEFT(mf.physical_name, 2) AS Drive ,
                            CASE WHEN mf.database_id = 2 THEN 99
                                    ELSE mf.type
                            END type ,
                            SUM(num_of_reads) AS num_of_reads ,
                            SUM(io_stall_read_ms) AS io_stall_read_ms ,
                            SUM(num_of_writes) AS num_of_writes ,
                            SUM(io_stall_write_ms) AS io_stall_write_ms ,
                            SUM(num_of_bytes_read) AS num_of_bytes_read ,
                            SUM(num_of_bytes_written) AS num_of_bytes_written ,
                            SUM(io_stall) AS io_stall
                    FROM      sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
                            INNER JOIN sys.master_files AS mf WITH ( NOLOCK ) ON vfs.database_id = mf.database_id
                                                            AND vfs.file_id = mf.file_id
                    WHERE     mf.database_id NOT IN ( 1, 3, 4 ) -- Master,MSDB,Model
                    GROUP BY  LEFT(mf.physical_name, 2) ,
                            CASE WHEN mf.database_id = 2 THEN 99
                                    ELSE mf.type
                            END
                ) AS tab
                CROSS APPLY ( SELECT    CASE WHEN num_of_reads = 0 THEN 0
                                                ELSE ( io_stall_read_ms
                                                    / num_of_reads )
                                        END AS [Read Latency] ,
                                        CASE WHEN io_stall_write_ms = 0
                                                THEN 0
                                                ELSE ( io_stall_write_ms
                                                    / num_of_writes )
                                        END AS [Write Latency] ,
                                        CASE WHEN ( num_of_reads = 0
                                                    AND num_of_writes = 0
                                                    ) THEN 0
                                                ELSE ( io_stall
                                                    / ( num_of_reads
                                                        + num_of_writes ) )
                                        END AS [Overall Latency] ,
                                        CASE WHEN num_of_reads = 0 THEN 0
                                                ELSE ( num_of_bytes_read
                                                    / num_of_reads )
                                        END AS [Avg Bytes/Read] ,
                                        CASE WHEN io_stall_write_ms = 0
                                                THEN 0
                                                ELSE ( num_of_bytes_written
                                                    / num_of_writes )
                                        END AS [Avg Bytes/Write] ,
                                        CASE WHEN ( num_of_reads = 0
                                                    AND num_of_writes = 0
                                                    ) THEN 0
                                                ELSE ( ( num_of_bytes_read
                                                        + num_of_bytes_written )
                                                    / ( num_of_reads
                                                        + num_of_writes ) )
                                        END AS [Avg Bytes/Transfer]
                            ) RL;
--------------------------------------------------------------------------------------------------------

        DECLARE @PS VARCHAR(4000) = 'powershell.exe "get-wmiobject win32_diskpartition | select name, startingoffset | foreach{$_.name+''|''+$_.startingoffset/1024+''*''}"';
----------------------------------------------
        DECLARE @output TABLE ( line VARCHAR(255) );
----------------------------------------------
        BEGIN TRY 
            INSERT  @output EXEC xp_cmdshell @PS;
        END TRY
        BEGIN CATCH
	--{TODO: }
        END CATCH;
		IF OBJECT_ID('tempdb..#SR_Offset') IS NOT NULL DROP TABLE #SR_Offset;
        SELECT  RTRIM(LTRIM(SUBSTRING(line, 1, CHARINDEX('|', line) - 1))) Volume,
                SO.StartingOffset/1024  'MB' 
		INTO	#SR_Offset
        FROM    @output
                CROSS APPLY ( SELECT TOP 1
                                        RTRIM(LTRIM(SUBSTRING(line,
                                                            CHARINDEX('|',
                                                            line) + 1,
                                                            ( CHARINDEX('*',
                                                            line) - 1 )
                                                            - CHARINDEX('|',
                                                            line)))) AS StartingOffset
                            ) SO
        WHERE   line IS NOT NULL
                AND line LIKE '%Partition #0%'
                AND SO.StartingOffset != '1024'
        ORDER BY 1;
--------------------------------------------------------------------------------------------
----------------------------------------------
--cleanUP
        DELETE  FROM @output;
----------------------------------------------
--DECLARE @output TABLE ( line VARCHAR(255) );
        DECLARE @sql VARCHAR(4000);
	
	--Block Size
        SET @sql = 'wmic volume GET Caption, BlockSize';--inserting disk name, total space and free space value in to temporary table
	
        INSERT  @output
                EXEC xp_cmdshell @sql;

        DELETE  FROM @output
        WHERE   line IS NULL
                OR line IN ( '
', 'BlockSize  Caption                                            
' );
        IF OBJECT_ID('tempdb..#DriveLeter') IS NOT NULL
            DROP TABLE #DriveLeter;
        CREATE TABLE #DriveLeter
            (
                DriveLeter CHAR(3) NOT NULL
            );

        INSERT  #DriveLeter
                SELECT	DISTINCT
                        LEFT(MF.physical_name, 3)
                FROM    sys.master_files MF;

        IF OBJECT_ID('tempdb..#SR_BlockSize') IS NOT NULL
            DROP TABLE #SR_BlockSize;

        SELECT  DL.DriveLeter ,
                RTRIM(LTRIM(REPLACE(O.line, DL.DriveLeter, ''))) BlockSize
        INTO    #SR_BlockSize
        FROM    #DriveLeter DL
                LEFT JOIN @output O ON O.line LIKE '%' + DL.DriveLeter
                                        + '%';
	--WHERE	RTRIM(LTRIM(REPLACE(O.line,DL.DriveLeter,''))) NOT LIKE '%65536%';
----------------------------------------------
--cleanUP
        DELETE  FROM @output;
----------------------------------------------
        IF OBJECT_ID('tempdb..#SR_Volume') IS NOT NULL
            DROP TABLE #SR_Volume;
        SELECT  DISTINCT
                vs.volume_mount_point ,
                CAST(vs.available_bytes AS FLOAT) available_bytes ,
                CAST(vs.total_bytes AS FLOAT) total_bytes ,
                BS.*
        INTO    #SR_Volume
        FROM    sys.master_files AS f WITH ( NOLOCK )
                CROSS APPLY sys.dm_os_volume_stats(f.database_id,
                                                    f.file_id) AS vs
                LEFT JOIN #SR_BlockSize BS ON BS.DriveLeter = vs.volume_mount_point;
        DROP TABLE #SR_BlockSize;
        DROP TABLE #DriveLeter;

--------------------------------------------------------------------------------------------
--#VersionsBugs
	DELETE FROM @output;
	DECLARE @cmdshellcommand VARCHAR(255)

	SET @cmdshellcommand = 'dir "%SystemRoot%\system32\config\software"'

	INSERT INTO @output
	EXEC master.dbo.xp_cmdshell @cmdshellcommand;

	CREATE TABLE #SR_VersionBug(Version NVARCHAR(30) NOT NULL,
	Detail NVARCHAR(MAX) NULL,
	IntDetail INT NULL);

	INSERT	#SR_VersionBug
	SELECT	CONVERT(NVARCHAR(30),SERVERPROPERTY('productversion')) Version,
			'msiexec' Detail,
			FileSize.GB IntDetail
	FROM    @output
			CROSS APPLY (SELECT LTRIM(
					REPLACE(
						SUBSTRING(line, CHARINDEX(')', line) + 1, LEN(line))
					, ',', '')
				) TrimLine) TL
			CROSS APPLY (SELECT CONVERT (INT,CONVERT (INT,SUBSTRING(TL.TrimLine,0,CHARINDEX(' ', TL.TrimLine)))/1048576.0/128) GB)FileSize
	WHERE   line LIKE '%File(s)%bytes'
			AND SERVERPROPERTY('productversion') BETWEEN '11.0.3000.0' AND '11.00.3513.0';

--------------------------------------------------------------------------------------------------------
			/*
Biztalt:https://blogs.msdn.microsoft.com/blogdoezequiel/2009/01/25/sql-best-practices-for-biztalk/
Auto create statistics must be disabled
Auto update statistics must be disabled
MAXDOP (Max degree of parallelism) must be defined as 1 in both SQL Server 2000 and SQL Server 2005 in the instance in which BizTalkMsgBoxDB database exists
*/
DECLARE @DB_Exclude TABLE
(DatabaseName sysname)
--CRM Dynamics
INSERT @DB_Exclude
SELECT D.name
FROM   sys.databases D
WHERE  D.name IN ('MSCRM_CONFIG','OrganizationName_MSCRM');
DECLARE @IsCRMDynamicsON BIT = 0
DECLARE @IsBizTalkON BIT = 0
DECLARE @IsSharePointON BIT = 0
SELECT TOP 1 @IsCRMDynamicsON = 1 
FROM   sys.server_principals SP
WHERE  SP.name = 'MSCRMSqlLogin'
IF @IsCRMDynamicsON = 0 
   SELECT TOP 1 @IsCRMDynamicsON = 1
   FROM   @DB_Exclude
DELETE FROM @DB_Exclude;
--BizTalk
SELECT @IsBizTalkON = 1 
WHERE EXISTS (
SELECT TOP 1 1
FROM   sys.databases D
WHERE  D.name IN ('BizTalkMsgBoxDB','BizTalkRuleEngineDb','SSODB','BizTalkHWSDb','BizTalkEDIDb','BAMArchive','BAMStarSchema','BAMPrimaryImport','BizTalkMgmtDb','BizTalkAnalysisDb','BizTalkTPMDb')
)
--SharePoint
INSERT @DB_Exclude
EXEC sp_MSforeachdb

'
use [?]
SELECT TOP 1 DB_NAME()[DatabaseName]
FROM   sys.database_principals DP
WHERE  DP.type = ''R''
              AND DP.name IN (''SPDataAccess'',''SPReadOnly'')'
SELECT @IsSharePointON = 1 
WHERE EXISTS (SELECT TOP 1 1 FROM @DB_Exclude);
SELECT 'SharePoint' [Software] ,@IsSharePointON [Status]
INTO #SR_Software
UNION ALL SELECT 'BizTalk' [Software] ,@IsBizTalkON [Status]
UNION ALL SELECT 'CRMDynamics' [Software] ,@IsCRMDynamicsON [Status]
--------------------------------------------------------------------------------------------------------
DECLARE @cmdSQL NVARCHAR(MAX);  

	IF OBJECT_ID('tempdb..##Results') IS NOT NULL
		DROP TABLE ##Results;
	IF OBJECT_ID('tempdb..#SR_DatabaseFiles') IS NULL 
	CREATE TABLE #SR_DatabaseFiles
					(
						[DatabaseName] VARCHAR(200) NULL,
						[FileName] VARCHAR(1000) NULL,
						[PhysicalName] NVARCHAR(260) NULL,
						[FileType] VARCHAR(15) NULL,
						[databaseid] INT NULL,
						[fileid] INT NULL,
						[TotalSize] INT NULL,
						[FreeSpace] INT NULL,
						[GrowthUnits] VARCHAR(15) NULL,
						[MaxSize] INT NULL,
						FGid INT NULL,
						FGName sysname NULL,
						FGType sysname NULL,
						FGDefault INT NULL
					);  
	CREATE TABLE ##Results ([Database Name] varchar(200) NULL, [File Name] varchar(1000) NULL,[Available Space in Mb] INT NULL,FG_Name sysname NULL,FG_Type sysname NULL,FG_Default int NULL)  
   
	SELECT @cmdSQL =    
'USE [?] INSERT INTO ##Results([Database Name], [File Name],[Available Space in Mb],FG_Name, FG_Type, FG_Default )    
SELECT	DB_NAME(),   
		fil.[name] AS [File Name],
		CASE ceiling(fil.[size]/128)   
		WHEN 0 THEN (1 - CAST(FILEPROPERTY(fil.[name], ''SpaceUsed''' + ') as int) /128)   
		ELSE (([size]/128) - CAST(FILEPROPERTY(fil.[name], ''SpaceUsed''' + ') as int) /128)   
		END AS [Available Space in Mb],
		fg.name,fg.type_desc,fg.is_default
FROM	sys.database_files fil
		LEFT JOIN sys.data_spaces fg ON fil.data_space_id = fg.data_space_id'   

	--Run the command against each database (IGNORE OFF-LINE DB)
	EXEC sp_MSforeachdb @cmdSQL   
	INSERT	#SR_DatabaseFiles
	SELECT	D.name [DatabaseName],mf.name [File Name],MF.physical_name [Physical Name],
			CASE MF.type_desc 
			WHEN 'ROWS' THEN 'Data'
			WHEN 'LOG' THEN 'Log'
			WHEN 'FILESTREAM' THEN 'FileStream'
			WHEN 'FULLTEXT' THEN 'FullText'
			ELSE 'Unknowen' END  [File Type],
			D.database_id,
			MF.file_id,
			MF.size * 8 / 1024 [Total Size in Mb],
			R.[Available Space in Mb],
			CONVERT(VARCHAR(25),CASE WHEN MF.is_percent_growth = 1 THEN MF.growth ELSE MF.growth * 8 / 1024 END) + CASE WHEN MF.is_percent_growth = 1 THEN '%' ELSE 'MB' END,
			CASE WHEN MF.max_size = -1 OR MF.max_size = 268435456 THEN NULL ELSE CONVERT(VARCHAR(25),MF.max_size) END [Max File Size in MB],
			MF.data_space_id,
			R.FG_Name,R.FG_Type,R.FG_Default
	FROM	sys.databases D
			INNER JOIN sys.master_files MF ON MF.database_id = D.database_id
			LEFT JOIN ##Results R ON D.name = R.[Database Name] AND R.[File Name] = MF.name;
--------------------------------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#Users') IS NOT NULL DROP TABLE #Users;
    CREATE TABLE #Users
        (
            DatabaseName sysname ,
            Type NVARCHAR(260) ,
            sid NVARCHAR(MAX) ,
            UserName sysname
        );
    EXEC sp_MSforeachdb 'USE [?]; 
INSERT #Users
SELECT DB_NAME(),dp.type_desc, convert(nvarchar(max),dp.SID,1), dp.name AS user_name  
FROM   sys.database_principals AS dp  
            LEFT JOIN sys.server_principals AS sp   ON dp.SID = sp.SID  
WHERE  sp.SID IS NULL  
            AND authentication_type_desc = ''INSTANCE''; ';

IF OBJECT_ID('tempdb..#DBCCRes') IS NULL 
		CREATE TABLE #DBCCRes
        (
            id INT IDENTITY(1, 1)
                    PRIMARY KEY CLUSTERED ,
            DBName VARCHAR(500) ,
            dbccLastKnownGood DATETIME ,
            RowNum INT
        );
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp;
    CREATE TABLE #temp
        (
            id INT IDENTITY(1, 1) ,
            ParentObject VARCHAR(255) ,
            [OBJECT] VARCHAR(255) ,
            Field VARCHAR(255) ,
            [VALUE] VARCHAR(255)
        );
 
    DECLARE @DBName VARCHAR(500) ,
			@SQLcmd VARCHAR(512);
 
    DECLARE dbccpage CURSOR LOCAL Fast_Forward
    FOR
        SELECT  name
        FROM    sys.databases
        WHERE   state = 0
                AND database_id NOT IN (2,DB_ID());
 
    OPEN dbccpage;
    FETCH NEXT FROM dbccpage INTO @DBName;
    WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SQLcmd = 'Use [' + @DBName + '];' + CHAR(10) + CHAR(13);
            SET @SQLcmd = @SQLcmd + 'DBCC Page ( [' + @DBName
                + '],1,9,3) WITH TABLERESULTS,NO_INFOMSGS;' + CHAR(10) + CHAR(13);
 
            INSERT  INTO #temp
                    EXECUTE ( @SQLcmd);
            SET @SQLcmd = '';
 
            INSERT  INTO #DBCCRes ( DBName , dbccLastKnownGood , RowNum)
            SELECT  @DBName ,
                    VALUE ,
                    ROW_NUMBER() OVER ( PARTITION BY Field ORDER BY VALUE ) AS Rownum
            FROM    #temp
            WHERE   Field = 'dbi_dbccLastKnownGood';
 
            TRUNCATE TABLE #temp;
 
            FETCH NEXT FROM dbccpage INTO @DBName;
        END;
    CLOSE dbccpage;
    DEALLOCATE dbccpage;
	
    DROP TABLE #temp;

	IF OBJECT_ID('tempdb..#Backup') IS NULL 
		CREATE TABLE #Backup
                (
                    DatabaseName sysname ,
                    [LastBackUpTime] VARCHAR(50) ,
                    Type CHAR(1) ,
                    physical_device_name NVARCHAR(1000)
                );

	IF OBJECT_ID('tempdb..#WitchDBtoCheck') IS NULL 
	CREATE TABLE #WitchDBtoCheck(DatabaseName sysname NOT NULL,
	LastBackUpTime DATETIME NOT NULL,
	[Type] CHAR(1) NULL);

	DECLARE @cmd NVARCHAR(MAX);
	
	SELECT @cmd = N'
	INSERT	#WitchDBtoCheck
	SELECT  sdb.name AS DatabaseName ,
			MAX(ISNULL(bus.backup_finish_date, 0)) AS LastBackUpTime ,
			bus.type AS Type
	FROM    sys.databases sdb
			LEFT JOIN msdb..backupset bus ON bus.database_name = sdb.name
			LEFT JOIN sys.database_mirroring dm ON sdb.database_id = dm.database_id
	WHERE   sdb.database_id NOT IN (2,DB_ID())
			AND sdb.source_database_id IS NULL ---Exclude Snapshots
			AND (dm.mirroring_role = 1 OR mirroring_guid IS NULL) --Not mirror
			AND sdb.state <> 6 -- not offline
			' + CASE WHEN @@VERSION LIKE 'Microsoft SQL Server 201%' THEN N'AND sys.fn_hadr_backup_is_preferred_replica (sdb.name) != 0' ELSE N'' END+ N'
	GROUP BY  sdb.name , bus.type';

	EXEC sp_executesql @cmd;

	INSERT #Backup
    SELECT  t1.DatabaseName ,
            CONVERT(VARCHAR(50), t1.LastBackUpTime, 101) AS LastBackUpTime ,
            t1.Type ,
            t2.physical_device_name
    FROM    #WitchDBtoCheck t1
            LEFT JOIN ( SELECT   sd.name AS database_name ,
                            ISNULL(bu.backup_finish_date, 0) AS BackupDate ,
                            bmf.physical_device_name
                    FROM    sys.databases AS sd
                            LEFT JOIN msdb..backupset bu ON bu.database_name = sd.name
								AND bu.is_copy_only = 0
                            LEFT JOIN msdb..backupmediafamily bmf ON bu.media_set_id = bmf.media_set_id
                    ) t2 ON t1.DatabaseName = t2.database_name
                            AND t1.LastBackUpTime = t2.BackupDate;




SELECT	CONVERT(sysname,'Backup') [Type],CONVERT(sysname,DatabaseName) [DatabaseName],CONVERT(NVARCHAR(max),'Backup ' + 
		CASE WHEN [type] IS NULL THEN 'has yet run on this DB' ELSE 
		CASE [type] 
			WHEN 'D' THEN 'type - Data' 
			WHEN 'L' THEN 'type - Log' 
			WHEN 'I' THEN 'type - Data-Diff' 
			ELSE 'N' 				
			END  +' was last backedup at - '+ 

		CASE WHEN LastBackUpTime ='01/01/1900'
			then 'never'
			else ISNULL(LastBackUpTime,'')
		END END)as  [Note]
INTO	#SR_DBProp
FROM	#Backup
WHERE	LastBackUpTime < DATEADD(DAY,-2,GETDATE())
UNION ALL 
SELECT	'CheckDB'[Type],DBName [Database Name],CASE WHEN dbccLastKnownGood = '1900-01-01 00:00:00.000' THEN 'CheckDB never run on this db' ELSE 'The DB has it last check on- ' + CONVERT(VARCHAR(25),dbccLastKnownGood,3) END [Note]
FROM	#DBCCRes
WHERE	DATEDIFF(DAY,dbccLastKnownGood,GETDATE()) > 7
UNION ALL 
SELECT  'USER',U.DatabaseName,'Login ' + QUOTENAME(SP.name) + ' Have a different sid for the user'
FROM    sys.server_principals SP
        INNER JOIN #Users U ON U.UserName = SP.name
WHERE   SP.sid != U.sid
UNION ALL 
select 'PAGE VERIFY'[Type],db.name [Database Name],N'Change PAGE_VERIFY to CHECKSUM.' [Note]
from sys.databases db
where db.state = 0
and db.is_read_only = 0
and db.page_verify_option != 2
and db.database_id > 4
UNION ALL
SELECT 'File Growth'[Type],db.name as database_name,N'Change database file growth to Megabyte.'
FROM   sys.master_files mf (NOLOCK)
       INNER JOIN sys.databases db (NOLOCK) on mf.database_id = db.database_id
WHERE  is_percent_growth=1

UNION ALL

SELECT  'AUTO SHRINK'[Type],db.name,N'Turn off AUTO_SHRINK ' AS [Note]
FROM    sys.databases db
where db.state = 0
and db.is_read_only = 0
AND is_auto_shrink_on = 1

UNION ALL

SELECT  'CURSOR_DEFAULT'[Type],db.name,N'Change CURSOR_DEFAULT to LOCAL' AS [Note]
FROM    sys.databases db
where	db.state = 0
		and db.is_read_only = 0
		AND is_local_cursor_default = 0
UNION ALL
SELECT  'Auto Create Statistics'[Type],db.name,N'Turn on AUTO_CREATE_STATISTICS' AS [Note]
FROM    sys.databases db
where	db.state = 0
		and db.is_read_only = 0
		AND is_auto_create_stats_on = 0
		AND db.name NOT IN(SELECT DatabaseName FROM	@DB_Exclude)
UNION ALL
SELECT  'Auto Create Statistics'[Type],db.name,N'Turn off AUTO_CREATE_STATISTICS' AS [Note]
FROM    sys.databases db
where	db.state = 0
		and db.is_read_only = 0
		AND is_auto_create_stats_on = 1
		AND db.name IN(SELECT DatabaseName FROM	@DB_Exclude)
UNION ALL
SELECT  'Auto Updtae Statistics'[Type],db.name,N'Turn on AUTO_UPDATE_STATISTICS' AS [Note]
FROM    sys.databases db
where	db.state = 0
		and db.is_read_only = 0
		AND is_auto_update_stats_on = 0
		AND db.name NOT IN(SELECT DatabaseName FROM	@DB_Exclude)
UNION ALL
SELECT  'Auto Updtae Statistics'[Type],db.name,N'Turn off AUTO_UPDATE_STATISTICS' AS [Note]
FROM    sys.databases db
where	db.state = 0
		and db.is_read_only = 0
		AND is_auto_update_stats_on = 1
		AND db.name IN(SELECT DatabaseName FROM	@DB_Exclude)
ORDER BY 2,1
--------------------------------------------------------------------------------------------------------

	IF OBJECT_ID('tempdb..#SR_HADR') IS NOT NULL
		DROP TABLE #SR_HADR;
CREATE TABLE #SR_HADR(
replica_server_name	nvarchar(256)	null
,database_name	sysname	null
,ag_name	sysname	null
,is_local	bit	null
,synchronization_state_desc	nvarchar(60)	null
,is_commit_participant	bit	null
,synchronization_health_desc	nvarchar(60)	null
,recovery_lsn	numeric	null
,truncation_lsn	numeric	null
,last_sent_lsn	numeric	null
,last_sent_time	datetime	null
,last_received_lsn	numeric	null
,last_received_time	datetime	null
,last_hardened_lsn	numeric	null
,last_hardened_time	datetime	null
,last_redone_lsn	numeric	null
,last_redone_time	datetime	null
,log_send_queue_size	bigint	null
,log_send_rate	bigint	null
,redo_queue_size	bigint	null
,redo_rate	bigint	null
,filestream_send_rate	bigint	null
,end_of_log_lsn	numeric	null
,last_commit_lsn	numeric	null
,last_commit_time	datetime	NULL);

IF @MajorVersion > 1100--2012
BEGIN
	EXEC('INSERT	#SR_HADR
SELECT  ar.replica_server_name ,
        adc.database_name ,
        ag.name AS ag_name ,
        drs.is_local ,  
        drs.synchronization_state_desc ,
        drs.is_commit_participant ,
        drs.synchronization_health_desc ,
        drs.recovery_lsn ,
        drs.truncation_lsn ,
        drs.last_sent_lsn ,
        drs.last_sent_time ,
        drs.last_received_lsn ,
        drs.last_received_time ,
        drs.last_hardened_lsn ,
        drs.last_hardened_time ,
        drs.last_redone_lsn ,
        drs.last_redone_time ,
        drs.log_send_queue_size ,
        drs.log_send_rate ,
        drs.redo_queue_size ,
        drs.redo_rate ,
        drs.filestream_send_rate ,
        drs.end_of_log_lsn ,
        drs.last_commit_lsn ,
        drs.last_commit_time
INTO #a
FROM    sys.dm_hadr_database_replica_states AS drs
        INNER JOIN sys.availability_databases_cluster AS adc ON drs.group_id = adc.group_id AND drs.group_database_id = adc.group_database_id
        INNER JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
        INNER JOIN sys.availability_replicas AS ar ON drs.group_id = ar.group_id AND drs.replica_id = ar.replica_id;');
END
--------------------------------------------------------------------------------------------------------
CREATE TABLE #sp_Blitz (
	[ID] [INT]  NOT NULL,
	[ServerName] [NVARCHAR](128) NULL,
	[CheckDate] [DATETIME] NULL,
	[BlitzVersion] [INT] NULL,
	[Priority] [TINYINT] NULL,
	[FindingsGroup] [VARCHAR](50) NULL,
	[Finding] [VARCHAR](200) NULL,
	[DatabaseName] [NVARCHAR](128) NULL,
	[URL] [VARCHAR](200) NULL,
	[Details] [NVARCHAR](4000) NULL,
	[QueryPlan] [XML] NULL,
	[QueryPlanFiltered] [NVARCHAR](MAX) NULL,
	[CheckID] [INT] NULL);
	IF OBJECT_ID('dbo.sp_Blitz') IS NOT NULL
	BEGIN
	    BEGIN TRY 
			IF OBJECT_ID('dbo.sp_BlitzTableOutput') IS NOT NULL
			BEGIN
				EXEC('DELETE FROM dbo.sp_BlitzTableOutput;')
			END
	    	DECLARE @CheckUserDatabaseObjects TINYINT = 0
			DECLARE @CheckProcedureCache TINYINT = 0
			DECLARE @OutputType VARCHAR(20) = 'NONE'
			DECLARE @OutputProcedureCache TINYINT
			DECLARE @CheckProcedureCacheFilter VARCHAR(10)
			DECLARE @CheckServerInfo TINYINT = 1
			DECLARE @SkipChecksServer NVARCHAR(256)
			DECLARE @SkipChecksDatabase NVARCHAR(256)
			DECLARE @SkipChecksSchema NVARCHAR(256)
			DECLARE @SkipChecksTable NVARCHAR(256)
			DECLARE @IgnorePrioritiesBelow INT
			DECLARE @IgnorePrioritiesAbove INT
			DECLARE @OutputDatabaseName NVARCHAR(128) = 'master'
			DECLARE @OutputSchemaName NVARCHAR(256) = 'dbo'
			DECLARE @OutputTableName NVARCHAR(256) = 'sp_BlitzTableOutput'
			DECLARE @OutputXMLasNVARCHAR TINYINT =1
			DECLARE @EmailRecipients VARCHAR(MAX)
			DECLARE @EmailProfile sysname
			DECLARE @SummaryMode TINYINT
			DECLARE @Help TINYINT = 0
			DECLARE @Version INT
			DECLARE @VersionDate DATETIME

			EXECUTE [dbo].[sp_Blitz] 
			   @CheckUserDatabaseObjects
			  ,@CheckProcedureCache
			  ,@OutputType
			  ,@OutputProcedureCache
			  ,@CheckProcedureCacheFilter
			  ,@CheckServerInfo
			  ,@SkipChecksServer
			  ,@SkipChecksDatabase
			  ,@SkipChecksSchema
			  ,@SkipChecksTable
			  ,@IgnorePrioritiesBelow
			  ,@IgnorePrioritiesAbove
			  ,@OutputDatabaseName
			  ,@OutputSchemaName
			  ,@OutputTableName
			  ,@OutputXMLasNVARCHAR
			  ,@EmailRecipients
			  ,@EmailProfile
			  ,@SummaryMode
			  ,@Help
			  ,@Version OUTPUT
			  ,@VersionDate OUTPUT;

			  IF OBJECT_ID('dbo.sp_BlitzTableOutput') IS NOT NULL
			  BEGIN
				EXEC('
			      INSERT	#sp_Blitz
				  SELECT	* 
				  FROM		dbo.sp_BlitzTableOutput
				  WHERE		CheckID NOT IN (74,49,27,78,32);')
			  END
	    
	    END TRY
	    BEGIN CATCH
	    	PRINT 'Info only: No sp_Blitz has been found.'
	    	
	    	
	    END CATCH
	END
--------------------------------------------------------------------------------------------------------
-----------------------------------
        IF @debug = 1
            PRINT 'Make XML';

        DECLARE @XML XML;


        SET @XML = ( SELECT ( SELECT    NEWID() AS id ,
                                        @Client Client,
										GETDATE() AS date ,
                                        @@ServerName AS ServerName,
										'1.33' [ClientVersion]
                                FROM      ( SELECT    1 AS col1
                                        ) AS Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS ReportMetadata ,
                            ( SELECT    Data.*
                                FROM      #SR_MachineSettings Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS MachineSettings ,
                            ( SELECT    Data.*
                                FROM      #SR_ServerProporties Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS ServerProporties ,
                            ( SELECT    Data.*
                                FROM      #SR_Configuration Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS Configuration ,
                            ( SELECT    Data.*
                                FROM      #SR_Databases Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS Databases ,
                            ( SELECT    Data.* FROM      #SR_Jobs Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS Jobs ,
							( SELECT    Data.* FROM      #SR_JobOut Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS JobsOut ,

                            ( SELECT    Data.*
                                FROM      #SR_Latency Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS Latency ,
                            ( SELECT    Data.*
                                FROM      #SR_login Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS login ,
                            ( SELECT    Data.*
                                FROM      #SR_MasterFiles Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS MasterFiles ,
                            ( SELECT    Data.*
                                FROM      #SR_os_schedulers Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS os_schedulers ,
                            ( SELECT    Data.*
                                FROM      #SR_PLE Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS PLE ,
                            ( SELECT    Data.*
                                FROM      #SR_servers Data
                            FOR
                                XML AUTO ,
                                    TYPE ,
                                    ELEMENTS XSINIL
                            ) AS servers ,
                            ( SELECT    Data.*
                                FROM      #SR_server_services Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS server_services ,
							( SELECT    Data.* FROM      #SR_Software Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS Software ,
                            ( SELECT    Data.* FROM      #SR_TraceStatus Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS TraceStatus ,
                            ( SELECT    Data.* FROM      #SR_Volume Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS Volume,
                            ( SELECT    Data.* FROM      #SR_Offset Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS Offset,
							( SELECT    Data.* FROM      #SR_reg Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS Registery,
							( SELECT    Data.* FROM      #SR_VersionBug Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS VersionBug,
							( SELECT    Data.* FROM      #SR_DatabaseFiles Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS DatabaseFiles,
							( SELECT    Data.* FROM      #SR_DBProp Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS DBPro,
							( SELECT    Data.* FROM      #SR_HADR Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS HADR,
							( SELECT    Data.* FROM      #sp_Blitz Data
                            FOR XML AUTO , TYPE , ELEMENTS XSINIL ) AS Blitz
                        FROM   ( SELECT    1 AS col
                            ) AS SiteReview
                    FOR
                        XML AUTO ,
                            TYPE ,
                            ELEMENTS XSINIL
                    );
		 
		INSERT  INTO master.dbo.SiteReview ( Col ) SELECT  @XML;
		IF @Display = 1 SELECT TOP 1 Col FROM master.dbo.SiteReview;

		DECLARE @Command VARCHAR(4000);
		DECLARE @Filename VARCHAR(1000);
		 
		DECLARE @FilePath VARCHAR(1000);
		SELECT @FilePath = 'C:\Temp';
		SELECT @Command = 'if not exist "' + @FilePath + '" mkdir ' + @FilePath;
		INSERT @output
		EXECUTE master..xp_cmdshell @command;
 
		 SELECT  @Filename = 'C:\Temp\SiteReview_' + CONVERT(VARCHAR(25),YEAR(GETDATE()))+CONVERT(VARCHAR(25),MONTH(GETDATE()))+CONVERT(VARCHAR(25),DAY(GETDATE())) + '_' + CONVERT(VARCHAR(25),DATEPART(MINUTE,GETDATE()))++CONVERT(VARCHAR(25),DATEPART(SECOND,GETDATE())) + '.xml'
		 /* we then insert a row into the table from the XML variable */
		 /* so we can then write it out via BCP! */
		 SELECT  @Command = 'bcp "select xCol from ' + DB_NAME() + '.dbo.SiteReview" queryout ' + @Filename + ' -w -T -S' + @@ServerName;
		 INSERT @output
		 EXECUTE master..xp_cmdshell @command;
		 
		DROP TABLE #SR_Software;
        DROP TABLE #SR_Configuration;
        DROP TABLE #SR_Databases;
        DROP TABLE #SR_Jobs;
        DROP TABLE #SR_Latency;
        DROP TABLE #SR_login;
        DROP TABLE #SR_MasterFiles;
        DROP TABLE #SR_os_schedulers;
        DROP TABLE #SR_PLE;
        DROP TABLE #SR_servers;
        DROP TABLE #SR_server_services;
        DROP TABLE #SR_TraceStatus; 
        DROP TABLE #SR_Volume;
        DROP TABLE #SR_ServerProporties;
        DROP TABLE #SR_MachineSettings;
		DROP TABLE #SR_Offset;
		DROP TABLE #SR_reg;
    END TRY
    BEGIN CATCH 
        DECLARE @ErMessage NVARCHAR(2048) ,
            @ErSeverity INT ,
            @ErState INT;
        SELECT  @ErMessage = ERROR_MESSAGE() ,
                @ErSeverity = ERROR_SEVERITY() ,
                @ErState = ERROR_STATE();
  
        RAISERROR (@ErMessage, @ErSeverity, @ErState );

                
        IF @debug = 1
            PRINT @@ServerName + ' Failed Generating Report';
		--IF @debug = 1 PRINT @Error;
		--RETURN -1;
    END CATCH;
    IF @debug = 1
        PRINT @@ServerName + ' Finished Generating Report';
--------------------------------------------------------------------------------------------------------

    IF @cmdshell = 0
        BEGIN
            EXEC sp_configure 'xp_cmdshell', 0;
            RECONFIGURE WITH OVERRIDE;
        END;

    IF @showadvanced = 0
        BEGIN
            EXEC sp_configure 'show advanced options', 0;
            RECONFIGURE WITH OVERRIDE;
        END;
	DECLARE @Print NVARCHAR(4000);
	SET @Print = 'Go tack your file from here - "' + @Filename + '"';
	PRINT @Print;
END;

