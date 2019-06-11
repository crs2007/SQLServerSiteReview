-- =============================================
-- Author:		Dror
-- Create date: 2012
-- Update date: 2016/06/08 Sharon
--				2016/07/21 Sharon Utility.ufn_Util_clr_RegexReplace(Version,'Microsoft SQL Server [\d]+ \- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$1',0)
-- Description:	
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetOSSettings] @guid UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @InstantInitializationDisabled [BIT] = 0,
			@LockPagesInMemoryDisabled BIT = 0,
			@SQLAccount NVARCHAR(max),
			@ProcessorCount INT = 0,
			@CPUInUse INT = 0,
			@Ver VARCHAR(128),
			@NodeCPU INT = 0,
			@UnevenCPU BIT = 0;
	SELECT	@InstantInitializationDisabled = MS.InstantInitializationDisabled,
			@LockPagesInMemoryDisabled = ISNULL((SELECT TOP (1) 1 FROM Client.ServerProporties WHERE sql_memory_model = 1 AND guid = @guid),MS.LockPagesInMemoryDisabled),
			@SQLAccount = SQLAccount,
			@ProcessorCount = MS.ProcessorCount,
			@Ver = ISNULL(MS.ProductVersion,Utility.ufn_Util_clr_RegexReplace(MS.Version,'Microsoft SQL Server [\d]+ \- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$1',0))
	FROM	Client.MachineSettings MS
	WHERE	MS.guid = @guid;
	;WITH NodeActiveCPU AS (
		SELECT	parent_node_id,
				count (1) [Count]
		FROM	[Client].[os_schedulers]
		WHERE	is_online = 1
				AND status = 'VISIBLE ONLINE'
				AND guid = @guid
		GROUP BY parent_node_id
	)
	SELECT	TOP (1) @NodeCPU = [Count]
	FROM	NodeActiveCPU
	SELECT	@CPUInUse = COUNT(1) 
	FROM	Client.os_schedulers OS 
	WHERE	OS.[status]='VISIBLE ONLINE'
			AND OS.guid = @guid;
	IF EXISTS(
		SELECT	parent_node_id,
				count (1) [Count]
		FROM	[Client].[os_schedulers]
		WHERE	is_online = 1
				AND status = 'VISIBLE ONLINE'
				AND guid = @guid
		GROUP BY parent_node_id
		HAVING @NodeCPU != count (1))
	BEGIN
	    SET @UnevenCPU = 1;
	END


	SELECT	R.Service [Subject],'The Power Paln on this server is -' + R.Value + '.' [Status],'Change Power Plan setting to "<B>High performance</B>"'[Reco],I.img
	FROM	Client.Registery R
			OUTER APPLY (SELECT TOP 1 img FROM Configuration.Images WHERE ID = 5)I
	WHERE	R.guid = @guid
			AND R.CurrentInstance = 1
			AND R.Service = 'Windows Power Plan'
			AND R.Value != 'High performance'
	UNION ALL 
	SELECT	'vCPUs',
			'Uneven divide of vCPU per node',
			'When you need to configure more vCPUs than there are physical cores in the NUMA node, OR if you assign more memory than a NUMA node contains, evenly divide the vCPU count across the minimum number of NUMA nodes. <a href="https://blogs.vmware.com/performance/2017/03/virtual-machine-vcpu-and-vnuma-rightsizing-rules-of-thumb.html">Link</a>' ,
			(SELECT TOP 1 img FROM Configuration.Images WHERE ID = 6)[img]
	WHERE	@UnevenCPU = 1
	UNION ALL 
	SELECT	R.Service [Subject],'The Windows Page File on this server located at -' + Utility.ufn_Util_clr_RegexReplace(R.Value,'(^[a-zA-Z]:\\)([\W\w]*)','$1',0) + ', this drive contein Data/Log files.' [Status],'Change drive location of your page file to empty drive or without SQL file on it.'[Reco],I.img
	FROM	Client.Registery R
			OUTER APPLY (SELECT TOP 1 img FROM Configuration.Images WHERE ID = 9)I
	WHERE	R.guid = @guid
			AND R.CurrentInstance = 1
			AND R.Service = 'Windows Page File'
			AND Utility.ufn_Util_clr_RegexReplace(R.Value,'(^[a-zA-Z]:\\)([\W\w]*)','$1',0) IN (SELECT	V.DriveLeter
			                                                                                    FROM	Client.Volumes V
																								WHERE	V.guid = @guid)
	UNION ALL 
	SELECT  'Instant Initialization',
			'The user privilage without Instant Initialization.',
			'Add user "' + @SQLAccount + '" account or group to "<a href="https://blogs.msdn.microsoft.com/sql_server_team/developers-choice-programmatically-identify-lpim-and-ifi-privileges-in-sql-server">Instant Initialization</a>".' ,
			(SELECT TOP 1 img FROM Configuration.Images WHERE ID = 7)[img]
	WHERE	@InstantInitializationDisabled = 1 AND PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) < '13' 
	UNION ALL 
	SELECT 'Lock Pages In Memory',
			'The user privilage without Lock Pages In Memory.',
			'Add user "' + @SQLAccount + '" account or group to "<a href="https://blogs.msdn.microsoft.com/sql_server_team/developers-choice-programmatically-identify-lpim-and-ifi-privileges-in-sql-server">Lock Pages In Memory</a>".' ,
			(SELECT TOP 1 img FROM Configuration.Images WHERE ID = 8) [img]
	WHERE	@LockPagesInMemoryDisabled = 1
	UNION ALL
	SELECT 'CPU in use by SQL Server','There unused CPU on the server.','Check license on your SQL Server. The number of CPU in use are ' + CONVERT(NVARCHAR(25),@CPUInUse) + '. The number of CPU that your server have is - ' + CONVERT(NVARCHAR(25),@ProcessorCount) + '.' 
			,(SELECT TOP 1 img FROM Configuration.Images WHERE ID = 6)[img]
	WHERE	@ProcessorCount > @CPUInUse
	UNION ALL 
	SELECT	'OS hotfixes','Recommended hotfixes and updates for Windows Server ' + k.[Platform] + ' Failover Clusters','Missing hotfixs (' + Utility.ufn_Util_clr_Conc(CONCAT('<B>KB',k.KB,'</B>')) + ') 
<a href="' + CASE k.[Platform] WHEN '2008 R2' THEN 'https://support.microsoft.com/en-us/help/2545685/recommended-hotfixes-and-updates-for-windows-server-2008-r2-sp1-failover-clusters'
WHEN '2008' THEN 'https://blogs.technet.microsoft.com/yongrhee/2011/06/12/list-of-failover-cluster-related-hotfixes-post-service-pack-2-for-windows-server-2008-sp2/'
WHEN '2012' THEN 'https://support.microsoft.com/en-us/help/2784261/recommended-hotfixes-and-updates-for-windows-server-2012-based-failover-clusters' 
ELSE'' END + '">Ms-Link</a>.',NULL
	FROM	Client.ServerProporties SP
			CROSS APPLY (SELECT TOP 1 [Platform] FROM [Configuration].KB WHERE SP.OSName LIKE '%' + [Platform]+ '%')ca
			INNER JOIN [Configuration].KB k ON [ca].[Platform] = k.Platform
			LEFT JOIN Client.KB cK ON cK.guid = SP.guid
				AND k.KB = TRY_CONVERT(INT,REPLACE(cK.KBID,'KB',''))
	WHERE	SP.guid = @guid
			AND EXISTS (
				SELECT	TOP  1 1
				FROM	Client.HADRServices HS
				WHERE	hs.Guid = @guid
						AND (AlwaysOn = 1 OR HS.Cluster = 1)
						)
			AND cK.guid IS NULL
	GROUP BY k.[Platform];
	


END
GO

