-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	GetFreeSpaceChart
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetCPUChart] @Guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT	MS.ProcessorName,
			--TRY_CONVERT(FLOAT,Utility.ufn_Util_clr_RegexReplace('Intel(R) Xeon(R) CPU E5-2643 v2 @ 3.50GHz','[\W\w]*@\s+([\d]*\.[\d]*)GHz','$1',0))[CoreRate],
			--TRY_CONVERT(FLOAT,Utility.ufn_Util_clr_RegexReplace('Intel(R) Xeon(R) CPU E5-2643 v2 @ 3.50GHz','[\W\w]*@\s+([\d]*\.[\d]*)GHz','$1',0))[CurrentCoreRate],
			ROUND(MS.MaxClockSpeed/1000.0,2) [CoreRate],
			ROUND(MS.CurrentClockSpeed/1000.0,2) [CurrentCoreRate],
			TRY_CONVERT(FLOAT,4.0) OfficalMaxCoreRate,
			TRY_CONVERT(FLOAT,1.5) OfficalMinCoreRate
	FROM	Client.MachineSettings MS
	WHERE	MS.guid = @Guid;

END
