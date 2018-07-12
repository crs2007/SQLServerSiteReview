-- =============================================
-- Author:		Shimon Gibraltar
-- Create date: 2012
-- Description:	<Description,,>
-- Email:		shimongb@gmail.com
-- =============================================
CREATE   PROCEDURE [Run].[usp_Analysis_FindPasswords] (@Guid UNIQUEIDENTIFIER,@Debug BIT = 0)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Print NVARCHAR(2048);

	CREATE TABLE #PassLogin(
							[Name] [sys].[sysname] NOT NULL,
							[Header] [varbinary] (max) NOT NULL,
							[Salt] [varbinary] (max) NOT NULL,
							[password_hash] [varbinary] (max) NOT NULL,
							Algoritm NVARCHAR(10) NOT NULL
						);
	DECLARE @alg TABLE(Algoritm NVARCHAR(10) NOT NULL,IsActive BIT);
	DECLARE @RC INT = 0;
	DECLARE @LoginToCheck INT = 0;
	DECLARE @Start INT = 0;
	DECLARE @Stop INT = 0;
	DECLARE @i INT = 1000000;
	DECLARE @StartTime DATETIME = GETDATE();
	DECLARE @LoopStartTime DATETIME;
	 
	--Assume that you have table as Password Bank
	SELECT	@Stop = SUM(P.rows)
	FROM	sys.partitions P
	WHERE	P.object_id = OBJECT_ID('Configuration.PasswordBank1')
			AND P.index_id IN (0,1);
	IF @Debug = 1
	BEGIN
		SET @Print = CONCAT(REPLACE(CONVERT(VARCHAR(50), (CAST(@Stop AS money)), 1), '.00', ''),' Passwords found at the bank')
		RAISERROR (@Print, 10, 1) WITH NOWAIT;   
	END
	
    --Define the crypto algoritms to check
	INSERT  @alg
	VALUES  --( 'MD2' ),( 'MD4' ),( 'MD5' ), -- Only for 2005 todo
	( 'SHA',1 ),( 'SHA1',1 ),( 'SHA2_256',1 ),( 'SHA2_512',1 );

	SELECT	@LoginToCheck = COUNT(1)
	FROM	Client.Logins SL
	WHERE	SL.Name NOT IN('##MS_PolicyEventProcessingLogin##','##MS_PolicyTsqlExecutionLogin##','##MS_SSISServerCleanupJobLogin##')
			AND SL.guid = @Guid;


	--Find straight forward passwords(User name as password)
	INSERT	[Client].[LoginsCheck] ([guid],[Name],[Algoritm],[ClearPassword],password_hash)
	SELECT  SL.guid, SL.Name, A.Algoritm, LC.ClearPassword, SL.password_hash
	FROM	Client.Logins SL
			CROSS JOIN @alg A
			INNER JOIN [Client].[LoginsCheck] LC ON LC.Name = SL.Name
	WHERE	SL.Name NOT IN('##MS_PolicyEventProcessingLogin##','##MS_PolicyTsqlExecutionLogin##','##MS_SSISServerCleanupJobLogin##')
			AND SL.guid = @Guid
			AND LC.Algoritm = A.Algoritm
			AND LC.password_hash = SL.password_hash
	UNION
	SELECT  SL.guid,SL.Name,A.Algoritm ,SL.Name,SL.password_hash
	FROM	Client.Logins SL
			CROSS JOIN @alg A
			CROSS APPLY (SELECT SL.Header + SL.Salt + HASHBYTES(A.Algoritm,SL.Name + CONVERT(NVARCHAR(MAX), SL.Salt)) MyHashedPassword)Pass
	WHERE	SL.Name NOT IN('##MS_PolicyEventProcessingLogin##','##MS_PolicyTsqlExecutionLogin##','##MS_SSISServerCleanupJobLogin##')
			AND SL.guid = @Guid
			AND Pass.MyHashedPassword = SL.password_hash;
	SET @RC = @@ROWCOUNT;

	IF @RC > 0 AND @RC < @LoginToCheck
	BEGIN
	    UPDATE	@alg
		SET		IsActive = 0
		WHERE	Algoritm NOT IN (SELECT DISTINCT Algoritm FROM [Client].[LoginsCheck] WHERE guid = @Guid);

		IF @Debug = 1
		BEGIN
			SET @Print = '';
		
			SELECT	@Print += CONCAT(Algoritm,', ')
			FROM	@alg
			WHERE	IsActive = 1;
			SET @Print += ' Algoritm found in existing logins';
			RAISERROR (@Print, 10, 1) WITH NOWAIT;
		END
	END

	INSERT	#PassLogin
	SELECT	SL.Name ,
            SL.Header ,
            SL.Salt ,
            SL.password_hash,
			A.Algoritm
	FROM	Client.Logins SL
			CROSS JOIN @alg A
	WHERE	SL.guid = @Guid
			AND	SL.Name NOT IN (SELECT Name FROM [Client].[LoginsCheck] WHERE guid = @Guid)
			AND A.IsActive = 1;


	WHILE @RC < @LoginToCheck AND @Start < @Stop --254000000
	BEGIN
		SET @LoopStartTime = GETDATE();
		--Start: This is the problematic query
		INSERT	[Client].[LoginsCheck] ([guid],[Name], [Algoritm], [ClearPassword],[password_hash])
		SELECT  @Guid, SL.Name, SL.Algoritm, P.[Password] ClearTextPassword ,SL.password_hash
		FROM    #PassLogin SL
				CROSS JOIN (SELECT	[Password]
							FROM	[Configuration].[PasswordBank1] [PB] 
							WHERE	PB.ID BETWEEN @Start AND (@Start + @i)
							)P
		WHERE	sl.Header + sl.Salt + HASHBYTES(SL.Algoritm, P.[Password] + CONVERT(NVARCHAR(MAX), sl.Salt)) = SL.password_hash
				
		SET @RC += @@ROWCOUNT;

		IF @Debug = 1
		BEGIN
			SET @Print = CONCAT('Ending loop between ',REPLACE(CONVERT(VARCHAR(50), (CAST(@Start AS money)), 1), '.00', ''),' AND ',REPLACE(CONVERT(VARCHAR(50), (CAST((@Start + @i) AS money)), 1), '.00', ''),'. ',DATEDIFF_BIG(SECOND,@LoopStartTime,GETDATE()),' sec.');
			RAISERROR (@Print, 10, 1) WITH NOWAIT;
		END

		DELETE FROM #PassLogin WHERE Name IN (SELECT Name FROM [Client].[LoginsCheck] WHERE guid = @Guid);
		
		IF @@ROWCOUNT > 0 AND @Debug = 1
		BEGIN
			SET @Print = 'Found Match!';
			RAISERROR (@Print, 10, 1) WITH NOWAIT;
		END
		SET @Start += @i;
	END

END