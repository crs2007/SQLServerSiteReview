-- =============================================
-- Author:		Sharon
-- Create date: 08/09/2016
-- Update date: 31/01/2017 Fix BUG
-- Description:	
-- =============================================
CREATE FUNCTION [Utility].[ufn_GetSupportEndDate] (@Ver NVARCHAR(MAX), @ProductVersion NVARCHAR(128))
RETURNS @SupportEndDate TABLE ( [SupportEndDate] NVARCHAR(35) )
AS
BEGIN
    DECLARE @Edition NVARCHAR(MAX) ;
	DECLARE @ServicePack NVARCHAR(MAX) ;
	DECLARE @Description NVARCHAR(MAX) ;
	DECLARE @Major VARCHAR(32);
	DECLARE @Minor VARCHAR(32);
	DECLARE @VersionBuild VARCHAR(32);
	
	SELECT	@Major = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 4),
			@Minor = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 3),
			@VersionBuild = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 2)

	SELECT	@Description = SSB.Description 
	FROM	Configuration.SQLServerBuild SSB
	WHERE	@Major = SSB.Major
			AND CONVERT(INT,@Minor) = CONVERT(INT,SSB.Minor)
			AND CONVERT(INT,@VersionBuild) = CONVERT(INT,SSB.VersionBuild)

	IF @Ver LIKE '%Enterprise%' OR @Ver LIKE '%Core-based%' SET @Edition = 'Enterprise Core'
	ELSE IF @Ver LIKE '%Enterprise%' SET @Edition = 'Enterprise'
	ELSE IF @Ver LIKE '%Web%' SET @Edition = 'Web'
	ELSE IF @Ver LIKE '%Express%' SET @Edition = 'Express'
	ELSE IF @Ver LIKE '%Developer%' SET @Edition = 'Developer'
	ELSE IF @Ver LIKE '%Business Intelligence%' SET @Edition = 'Business Intelligence'
	ELSE IF @Ver LIKE '%Standard%' SET @Edition = 'Standard'
	
	SELECT @Edition = 'Microsoft SQL Server ' + CASE WHEN b.Major = 10 THEN CASE WHEN @Minor = '50' THEN '2008 R2' ELSE '2008' END
			ELSE CONVERT(VARCHAR(8),b.Year) END +' ' + @Edition
	FROM	[Configuration].[SQLServerMajorBuild] b 
	WHERE	@Major = CONVERT(NCHAR(4),b.Major);	

	IF @Description LIKE '%Service Pack 1%' OR @Description LIKE '% SP1 %' SET @ServicePack = 'Service Pack 1'
	ELSE IF @Description LIKE '%Service Pack 2%' OR @Description LIKE '% SP2 %' SET @ServicePack = 'Service Pack 2'
	ELSE IF @Description LIKE '%Service Pack 3%' OR @Description LIKE '% SP3 %' SET @ServicePack = 'Service Pack 3'
	ELSE IF @Description LIKE '%Service Pack 4%' OR @Description LIKE '% SP4 %' SET @ServicePack = 'Service Pack 4'
	ELSE IF @Description LIKE '%Service Pack 5%' OR @Description LIKE '% SP5 %' SET @ServicePack = 'Service Pack 5'
	ELSE IF @Description LIKE '%Service Pack 6%' OR @Description LIKE '% SP6 %' SET @ServicePack = 'Service Pack 6'
	ELSE IF @Description LIKE '%Service Pack 7%' OR @Description LIKE '% SP7 %' SET @ServicePack = 'Service Pack 7'
	ELSE IF @Description LIKE '%Service Pack 8%' OR @Description LIKE '% SP8 %' SET @ServicePack = 'Service Pack 8'
	ELSE IF @Description LIKE '%Service Pack 9%' OR @Description LIKE '% SP9 %' SET @ServicePack = 'Service Pack 9';

	SELECT	@ServicePack = 'Microsoft SQL Server ' + CASE WHEN b.Major = 10 THEN CASE WHEN @Minor = '50' THEN '2008 R2' ELSE '2008' END
			ELSE CONVERT(VARCHAR(8),b.Year) END +' ' + @ServicePack
	FROM	[Configuration].[SQLServerMajorBuild] b 
	WHERE	@Major = CONVERT(NCHAR(4),b.Major); 

	INSERT @SupportEndDate
	SELECT TOP 1 TRY_CONVERT(NVARCHAR(35),MAX(T.SupportEndDate))[SupportEndDate]
	FROM ( 
	
	SELECT TOP 1 [CompatibilityLevel]
					  ,[ProductsReleased]
					  ,[StartDate]
					  ,CASE WHEN [MainstreamSupportEndDate] > [ExtendedSupportEndDate] THEN [MainstreamSupportEndDate] ELSE [ExtendedSupportEndDate] END [SupportEndDate]
				  FROM [Configuration].[LifeCycleSupport]
				  WHERE	@Major + IIF(@Minor = '50','5','0') = [CompatibilityLevel]
						AND @Edition like ProductsReleased + '%'
					UNION ALL 
				  SELECT TOP 1 [CompatibilityLevel]
					  ,[ProductsReleased]
					  ,[StartDate]
					  ,iif(ExtendedSupportEndDate > [ServicePackSupportEndDate],ExtendedSupportEndDate,[ServicePackSupportEndDate]) [SupportEndDate]
				  FROM [Configuration].[LifeCycleSupport]
				  WHERE	@Major + IIF(@Minor = '50','5','0') = [CompatibilityLevel]
						AND @ServicePack = ProductsReleased
						)T
	HAVING	MAX(T.SupportEndDate) IS NOT NULL;

	RETURN;
END
