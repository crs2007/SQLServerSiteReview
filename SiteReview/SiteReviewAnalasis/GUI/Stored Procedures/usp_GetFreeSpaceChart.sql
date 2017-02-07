-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetFreeSpaceChart
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetFreeSpaceChart] @Guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT	ROW_NUMBER() OVER (ORDER BY V.VolumeName) ID,
			V.VolumeName ,
			V.available_bytes Free,
			V.total_bytes Total,
			V.total_bytes - V.available_bytes [Full],
			CASE WHEN V.available_bytes > 1024 THEN CONCAT(CONVERT(INT,ROUND(V.available_bytes/1024.0,0)) ,'TB')
			ELSE CONCAT(V.available_bytes ,'GB')
			END FreeStr,
			CASE WHEN V.total_bytes > 1024 THEN CONCAT(CONVERT(INT,ROUND(V.total_bytes/1024.0,0)) ,'TB')
			ELSE CONCAT(V.total_bytes ,'GB')
			END TotalStr,
			CASE WHEN V.total_bytes - V.available_bytes > 1024 THEN CONCAT(CONVERT(NUMERIC(36,2),ROUND((V.total_bytes - V.available_bytes)/1024.0,2)) ,'TB')
			ELSE CONCAT(V.total_bytes - V.available_bytes ,'GB')
			END FullStr,
			CASE 
			WHEN (CONVERT(NUMERIC(38,2),V.available_bytes) / CONVERT(NUMERIC(38,2),V.total_bytes) * 100) <= 30 THEN 'Drive have less then 30% free space'
			WHEN (CONVERT(NUMERIC(38,2),V.available_bytes) / CONVERT(NUMERIC(38,2),V.total_bytes) * 100) <= 20 THEN 'Drive have less then 20% free space'
			WHEN (CONVERT(NUMERIC(38,2),V.available_bytes) / CONVERT(NUMERIC(38,2),V.total_bytes) * 100) <= 10 THEN 'Drive have less then 10% free space'
			ELSE NULL END
			[Note]
	INTO	#Volume
	FROM	Client.Volumes V
	WHERE	V.guid = @Guid

	SELECT	V1.ID ID1,
			V1.VolumeName VolumeName1,
            V1.Free Free1,
			V1.Total - V1.Free [Full1],
            V1.Total Total1,
			V1.Note [Note1],
			V1.FreeStr [FreeStr1],
			V1.TotalStr [TotalStr1],
			V1.FullStr [FullStr1],
            V2.ID ID2,
			V2.VolumeName VolumeName2,
            V2.Free Free2,
			V2.Total - V2.Free [Full2],
            V2.Total Total2,
			V2.Note [Note2],
			V2.FreeStr [FreeStr2],
			V2.TotalStr [TotalStr2],
			V2.FullStr [FullStr2],
            V3.ID ID3,
			V3.VolumeName VolumeName3,
            V3.Free Free3,
			V3.Total - V3.Free [Full3],
            V3.Total Total3,
			V3.Note [Note3],
			V3.FreeStr [FreeStr3],
			V3.TotalStr [TotalStr3],
			V3.FullStr [FullStr3]
	FROM	#Volume V1
			LEFT JOIN #Volume V2 ON V1.ID + 1 = V2.ID
				AND V2.ID % 3 = 2
			LEFT JOIN #Volume V3 ON V1.ID + 2 = V3.ID
				AND V3.ID % 3 = 0
	WHERE	V1.ID % 3 = 1

END

