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
			@Ver VARCHAR(128);
	SELECT	@InstantInitializationDisabled = MS.InstantInitializationDisabled,
			@LockPagesInMemoryDisabled = MS.LockPagesInMemoryDisabled,
			@SQLAccount = SQLAccount,
			@ProcessorCount = MS.ProcessorCount,
			@Ver = ISNULL(MS.ProductVersion,Utility.ufn_Util_clr_RegexReplace(MS.Version,'Microsoft SQL Server [\d]+ \- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$1',0))
	FROM	Client.MachineSettings MS
	WHERE	MS.guid = @guid;

	SELECT	@CPUInUse = COUNT(1) 
	FROM	Client.os_schedulers OS 
	WHERE	OS.[status]='VISIBLE ONLINE'
			AND OS.guid = @guid;

	SELECT	R.Service [Subject],'The Power Paln on this server is -' + R.Value + '.' [Status],'Change Power Plan setting to "High performance"'[Reco],I.img
	FROM	Client.Registery R
			OUTER APPLY (SELECT TOP 1 img FROM Configuration.Images WHERE ID = 5)I
	WHERE	R.guid = @guid
			AND R.CurrentInstance = 1
			AND R.Service = 'Windows Power Plan'
			AND R.Value != 'High performance'
	UNION ALL 
	SELECT	R.Service [Subject],'The Windows Page File on this server location is -' + Utility.ufn_Util_clr_RegexReplace(R.Value,'(^[a-zA-Z]:\\)([\W\w]*)','$1',0) + ' this drive contein Data/Log files.' [Status],'Change drive location of your page file to empty drive or without SQL file on it.'[Reco],I.img
	FROM	Client.Registery R
			OUTER APPLY (SELECT TOP 1 img FROM Configuration.Images WHERE ID = 9)I
	WHERE	R.guid = @guid
			AND R.CurrentInstance = 1
			AND R.Service = 'Windows Page File'
			AND Utility.ufn_Util_clr_RegexReplace(R.Value,'(^[a-zA-Z]:\\)([\W\w]*)','$1',0) IN (SELECT	V.DriveLeter
			                                                                                    FROM	Client.Volumes V
																								WHERE	V.guid = @guid)
	UNION ALL 
	SELECT 'Instant Initialization','The user privilage without Instant Initialization.','Add user "' + @SQLAccount + '" account or group to "Instant Initialization".' ,
			(SELECT TOP 1 img FROM Configuration.Images WHERE ID = 7)[img]
	WHERE @InstantInitializationDisabled = 1 AND PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) < '13' 
	UNION ALL 
	SELECT 'Lock Pages In Memory','The user privilage without Lock Pages In Memory.','Add user "' + @SQLAccount + '" account or group to "Lock Pages In Memory".' ,
			(SELECT TOP 1 img FROM Configuration.Images WHERE ID = 8) [img]
	WHERE @LockPagesInMemoryDisabled = 1
	UNION ALL
	SELECT 'CPU in use by SQL Server','There unused CPU on the server.','Check license on your SQL Server. The number of CPU in use are ' + CONVERT(NVARCHAR(25),@CPUInUse) + '. The number of CPU that your server have is - ' + CONVERT(NVARCHAR(25),@ProcessorCount) + '.' 
			,(SELECT TOP 1 img FROM Configuration.Images WHERE ID = 6)[img]
	WHERE @ProcessorCount > @CPUInUse

END