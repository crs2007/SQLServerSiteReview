-- =============================================
-- Author:		Sharon
-- Create date: 09/06/2016
-- Update date: 
-- Description:	Recomanded Versions
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetRecommandedSP]
	@guid UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Ver NVARCHAR(128)

	SELECT @Ver = CAST(ISNULL(ProductVersion,Utility.ufn_Util_clr_RegexReplace(Version,'Microsoft SQL Server [\d]+ \- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$1',0))AS NVARCHAR(128))
	FROM	Client.MachineSettings MS
	WHERE	@guid = MS.guid;

	IF EXISTS(SELECT TOP 1 1 FROM
	Configuration.SQLServerBuild SSB
			INNER JOIN (
						SELECT	TOP 1 *
						FROM	Configuration.SQLServerBuild SSB
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
								FROM	Configuration.SQLServerBuild SSB
								WHERE	PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) = SSB.Major
										AND CONVERT(INT,PARSENAME(CONVERT(VARCHAR(32), @Ver), 3)) = CONVERT(INT,SSB.Minor)
										AND SSB.Build > @Ver)T
			WHERE T.RN = 1 AND T.ShortName = 'SP')SP
	 WHERE	T.Build < SSB.Build
			AND ISNULL(SP.Build,T.Build) <= SSB.Build
			AND SSB.Build NOT IN ('11.00.9120','11.00.9000'))
	BEGIN
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
									FROM	Configuration.SQLServerBuild SSB
									WHERE	PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) = SSB.Major
											AND CONVERT(INT,PARSENAME(CONVERT(VARCHAR(32), @Ver), 3)) = CONVERT(INT,SSB.Minor)
											AND SSB.Build > @Ver)T
				WHERE T.RN = 1 AND T.ShortName = 'SP')SP
		 WHERE	T.Build < SSB.Build
				AND ISNULL(SP.Build,T.Build) <= SSB.Build
				AND SSB.Build NOT IN ('11.00.9120','11.00.9000')
		ORDER BY SSB.Build DESC;
	END
	ELSE
	BEGIN
	    SELECT	TOP 1 SSB.Build,'The server have the last update version installed',SSB.ReleaseDate,
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
							WHERE	PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) = SSB.Major
									AND CONVERT(INT,PARSENAME(CONVERT(VARCHAR(32), @Ver), 3)) = CONVERT(INT,SSB.Minor)
									AND PARSENAME(CONVERT(varchar(32), @Ver), 2) = SSB.VersionBuild
									AND PARSENAME(CONVERT(VARCHAR(32), @Ver), 1) = ISNULL(SSB.Revision,PARSENAME(CONVERT(VARCHAR(32), @Ver), 1))
							)T ON T.Major = SSB.Major
							AND t.Minor = SSB.Minor
		WHERE	SSB.Build NOT IN ('11.00.9120','11.00.9000')
		ORDER BY SSB.Build DESC;
	END
END

