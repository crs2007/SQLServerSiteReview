-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetFreeSpaceChart
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetBlockSizeChart] @Guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT	ROW_NUMBER() OVER (ORDER BY V.VolumeName) ID,
			V.VolumeName ,
            V.BlockSize/1024 [BlockSize]
	INTO	#Block
	FROM	Client.Volumes V
	WHERE	V.guid = @Guid
			--AND V.BlockSize != 65536;

	SELECT	V1.ID ID1,
			V1.VolumeName VolumeName1,
            V1.[BlockSize] BlockSize1,
			IIF(V1.[BlockSize] = 64,'Disk Block in propre size','Change Block size to 64K')[Note1],
			IIF(V1.[BlockSize] = 64,'Green','Red')[Color1],
            V2.ID ID2,
			V2.VolumeName VolumeName2,
            V2.[BlockSize] BlockSize2,
			IIF(V2.[BlockSize] = 64,'Disk Block in propre size','Change Block size to 64K')[Note2],
			IIF(V2.[BlockSize] = 64,'Green','Red')[Color2],
            V3.ID ID3,
			V3.VolumeName VolumeName3,
            V3.[BlockSize] BlockSize3,
			IIF(V3.[BlockSize] = 64,'Disk Block in propre size','Change Block size to 64K')[Note3],
			IIF(V3.[BlockSize] = 64,'Green','Red')[Color3]
	FROM	#Block V1
			LEFT JOIN #Block V2 ON V1.ID + 1 = V2.ID
				AND V2.ID % 3 = 2
			LEFT JOIN #Block V3 ON V1.ID + 2 = V3.ID
				AND V3.ID % 3 = 0
	WHERE	V1.ID % 3 = 1;

END

