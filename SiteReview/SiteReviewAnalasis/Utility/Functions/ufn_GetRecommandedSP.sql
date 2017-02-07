
--- =============================================
-- Author:		Sharon
-- Create date: 09/06/2016
-- Update date: 
-- Description:	Recomanded Versions
-- =============================================
CREATE FUNCTION [Utility].[ufn_GetRecommandedSP] (@ProductVersion NVARCHAR(128))
RETURNS @RecommandedSP TABLE (
	[Build] [NVARCHAR] (128),
	[Description] [NVARCHAR] (MAX),
	[ReleaseDate] [VARCHAR] (50),
	[ShortName] VARCHAR(10))
AS
BEGIN
    DECLARE @Major VARCHAR(32);
	DECLARE @Minor VARCHAR(32);
	DECLARE @VersionBuild VARCHAR(32);
	DECLARE @Revision VARCHAR(32);
	
	SELECT	@Major = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 4),
			@Minor = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 3),
			@VersionBuild = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 2),
			@Revision = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 1)
	INSERT @RecommandedSP
	SELECT	SSB.Build,SSB.Description,SSB.ReleaseDate,
			CASE WHEN ssb.Description LIKE '%Cumulative update%' THEN 'CU'
			WHEN ssb.Description LIKE '%security update%' THEN 'SU'			
			WHEN ssb.Description LIKE '%FIX%' THEN 'FIX'
			WHEN ssb.Description LIKE '%Service Pack%' OR ssb.Description LIKE '%GDR%'  THEN 'SP'			
			WHEN ssb.Description LIKE '%TLS%' THEN 'TLS'
			WHEN ssb.Description LIKE '%RTM%' THEN 'RTM'
			WHEN ssb.Description LIKE '%CTP%' THEN 'CTP'
			ELSE NULL END [ShortName]
	 FROM	Configuration.SQLServerBuild SSB
			INNER JOIN (
						SELECT	TOP 1 *
						FROM	Configuration.SQLServerBuild SSB
						WHERE	@Major = SSB.Major
								AND CONVERT(INT,@Minor) = CONVERT(INT,SSB.Minor)
								AND @VersionBuild = SSB.VersionBuild
								AND @Revision = ISNULL(SSB.Revision,@Revision)
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
								FROM	Configuration.SQLServerBuild SSB
								WHERE	@Major = SSB.Major
										AND CONVERT(INT,@Minor) = CONVERT(INT,SSB.Minor)
										AND SSB.Build > @ProductVersion)T
			WHERE T.RN = 1 AND T.ShortName = 'SP')SP
	 WHERE	T.Build < SSB.Build
			AND ISNULL(SP.Build,T.Build) <= SSB.Build
			AND SSB.Build NOT IN ('11.00.9120','11.00.9000')
	ORDER BY SSB.Build DESC;

	RETURN;
END



