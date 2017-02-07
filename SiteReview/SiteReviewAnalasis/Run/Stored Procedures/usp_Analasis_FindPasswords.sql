-- =============================================
-- Author:		Shimon Gibraltar
-- Create date: 2012
-- Description:	<Description,,>
-- Email:		shimongb@gmail.com
-- =============================================
CREATE PROCEDURE [Run].[usp_Analasis_FindPasswords] (@Guid UNIQUEIDENTIFIER)
AS
BEGIN
	SET NOCOUNT ON;

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
	SELECT	@Stop = SUM(P.rows)
	FROM	sys.partitions P
	WHERE	P.object_id = OBJECT_ID('Configuration.PasswordBank1')
			AND P.index_id IN (0,1)
    --define the crypto algoritms to check
	INSERT  @alg
	VALUES  --( 'MD2' ),( 'MD4' ),( 'MD5' ), -- Only for 2005 todo
	( 'SHA',1 ),( 'SHA1',1 ),( 'SHA2_256',1 ),( 'SHA2_512',1 );

	SELECT	@LoginToCheck = COUNT(1)
	FROM	Client.Logins SL
	WHERE	SL.Name NOT IN('##MS_PolicyEventProcessingLogin##','##MS_PolicyTsqlExecutionLogin##','##MS_SSISServerCleanupJobLogin##')
			AND SL.guid = @Guid;

	INSERT	[Client].[LoginsCheck]
	SELECT  SL.guid,SL.Name ,
			A.Algoritm ,SL.Name
	FROM	Client.Logins SL
			CROSS JOIN @alg A
			CROSS APPLY (SELECT SL.Header + SL.Salt + HASHBYTES(A.Algoritm,SL.Name + CONVERT(NVARCHAR(MAX), SL.Salt)) MyHashedPassword)Pass
	WHERE	SL.Name NOT IN('##MS_PolicyEventProcessingLogin##','##MS_PolicyTsqlExecutionLogin##','##MS_SSISServerCleanupJobLogin##')
			AND SL.guid = @Guid
			AND Pass.MyHashedPassword = SL.password_hash
	SET @RC = @@ROWCOUNT;

	IF @RC > 0 AND @RC < @LoginToCheck
	BEGIN
	    UPDATE	@alg
		SET		IsActive = 0
		WHERE	Algoritm NOT IN (SELECT DISTINCT Algoritm FROM [Client].[LoginsCheck] WHERE guid = @Guid)

		
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


	WHILE @RC < @LoginToCheck AND @Start < 20000000--@Stop --254000000
	BEGIN
		INSERT	[Client].[LoginsCheck]
		SELECT  @Guid,SL.NAME ,
				SL.Algoritm ,
				P.[Password] ClearTextPassword 
		FROM    #PassLogin SL
				CROSS JOIN (SELECT	[Password]
							FROM	[Configuration].[PasswordBank1] [PB] 
							WHERE	PB.ID BETWEEN @Start AND (@Start + @i)
							)P
		WHERE	sl.Header + sl.Salt + HASHBYTES(SL.Algoritm, P.[Password] + CONVERT(NVARCHAR(MAX), sl.Salt)) = sl.password_hash
				
		SET @RC += @@ROWCOUNT;
		DELETE FROM #PassLogin WHERE Name IN (SELECT Name FROM [Client].[LoginsCheck] WHERE guid = @Guid)
		SET @Start += @i;
	END

END