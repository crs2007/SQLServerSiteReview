

CREATE PROCEDURE [Utility].[usp_UpdateDataPlatform]
AS
BEGIN
    SET NOCOUNT ON;
    
	DECLARE @msg NVARCHAR(MAX) = '';
	DECLARE @CountP INT;
	DECLARE @CountS INT;

	SELECT	*
	INTO	#SQLServerBuild
	FROM	[CloudAzure].[DataPlatform].[Configuration].[SQLServerBuild];

	SELECT	@CountP = COUNT(1)
	FROM	#SQLServerBuild;
	SELECT	@CountS = COUNT(1)
	FROM	[Configuration].[SQLServerBuild];

	IF @CountP > @CountS
	BEGIN
		DELETE FROM [Configuration].[SQLServerBuild];
		INSERT	[Configuration].[SQLServerBuild](Build,FileVersion,Description,ReleaseDate)
		SELECT	Build,FileVersion,Description,ReleaseDate
		FROM	#SQLServerBuild;

		SET @msg += CONCAT('SQLServerBuild - ',@CountP - @CountS,' rows added.
');
	END
	-----------------------------------------------------------
	SELECT	*
	INTO	#LifeCycleSupport
	FROM	[CloudAzure].[DataPlatform].[Configuration].[LifeCycleSupport];

	SELECT	@CountP = COUNT(1)
	FROM	#LifeCycleSupport;
	SELECT	@CountS = COUNT(1)
	FROM	[Configuration].[LifeCycleSupport];

	IF @CountP > @CountS
	BEGIN
		DELETE FROM [Configuration].[LifeCycleSupport];
		INSERT	[Configuration].[LifeCycleSupport]
		        ( [CompatibilityLevel] ,
		          [ProductsReleased] ,
		          [StartDate] ,
		          [MainstreamSupportEndDate] ,
		          [ExtendedSupportEndDate] ,
		          [ServicePackSupportEndDate]
		        )
		SELECT	[CompatibilityLevel] ,
		          [ProductsReleased] ,
		          [StartDate] ,
		          [MainstreamSupportEndDate] ,
		          [ExtendedSupportEndDate] ,
		          [ServicePackSupportEndDate]
		FROM	#LifeCycleSupport;

		SET @msg += CONCAT('LifeCycleSupport - ',@CountP - @CountS,' rows added.
')
	END

	IF LEN(@msg) > 0
	BEGIN
		DECLARE @SlackToken NVARCHAR(MAX);
		SELECT	@SlackToken = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('SlackToken'));
		SELECT Ok,
			Channel,
			TimeStamp,
			Error
		FROM [Utility].SlackChatPostMessage(
			@SlackToken,
			'#sitereview',
			@msg,
			'UpdateDataPlatform',
			null
		);
	END

END