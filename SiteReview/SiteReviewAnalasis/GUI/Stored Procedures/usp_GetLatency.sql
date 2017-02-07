
-- =============================================
-- Author:		Sharon
-- Create date: 09/01/2016
-- Description:	Get Latency
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetLatency] @Guid UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT	L.Drive ,
			LI.[Type],
			L.ReadLatency ,
			L.WriteLatency ,
			L.OverallLatency ,
			H.Info,
			IIF(LEN(H.Info) > 0,'http://technet.microsoft.com/en-us/library/aa995945(v=exchg.80).aspx',NULL) [Link],
			H.[HTMLInfo] [HTML]
	FROM	Client.Latency L
			CROSS APPLY (SELECT TOP 1 CASE L.type 
			WHEN 99 THEN 'TempDB Files'
			WHEN 0 THEN 'Data Files' 
			WHEN 1 THEN 'Log Files'
			ELSE 'Error' END [Type])LI
			CROSS APPLY (SELECT CASE 
			WHEN L.type IN (1,99) AND L.ReadLatency > 10 THEN CONCAT('I/O Reads on ',LI.[Type],' are averaging longer than 10ms - Current is - ',L.ReadLatency,'ms')
			WHEN L.type = 0 AND L.ReadLatency > 20 THEN  CONCAT('I/O Reads on ',LI.[Type],' are averaging longer than 20ms - Current is - ',L.ReadLatency,'ms')
			ELSE ''
			END [ReadInfo],
			CASE 
			WHEN L.type IN (1,99) AND L.WriteLatency > 10 THEN CONCAT('I/O Write on ',LI.[Type],' are averaging longer than 10ms - Current is - ',L.WriteLatency,'ms')
			WHEN L.type = 0 AND L.WriteLatency > 20 THEN  CONCAT('I/O Write on ',LI.[Type],' are averaging longer than 20ms - Current is - ',L.WriteLatency,'ms')
			ELSE ''
			END [WriteInfo],
			CASE 
			WHEN L.type IN (1,99) AND L.ReadLatency > 10 THEN CONCAT('<font color =Blue><U><HRef="http://www.sqlshack.com/sql-server-disk-performance-metrics-part-1-important-disk-performance-metrics/">I/O Reads</A></U></font><font color =Black> on ',LI.[Type],' are averaging longer than <B>10ms</B> - Current is - </font><font color =Orange><B>',L.ReadLatency,'ms</B></font>')
			WHEN L.type = 0 AND L.ReadLatency > 20 THEN  CONCAT('<font color =Blue><U><HRef="http://www.sqlshack.com/sql-server-disk-performance-metrics-part-1-important-disk-performance-metrics/">I/O Reads</A></U></font><font color =Black> on ',LI.[Type],' are averaging longer than <B>20ms</B> - Current is - </font><font color =',IIF(L.ReadLatency > 100,'Red','Orange'),'><B>',L.ReadLatency,'ms</B></font>')
			ELSE ''
			END [HTMLReadInfo],
			CASE 
			WHEN L.type IN (1,99) AND L.WriteLatency > 10 THEN CONCAT('<font color =Blue><U><HRef="http://www.sqlshack.com/sql-server-disk-performance-metrics-part-1-important-disk-performance-metrics/">I/O Write</A></U></font><font color =Black> on ',LI.[Type],' are averaging longer than <B>10ms</B> - Current is - </font><font color =Orange><B>',L.WriteLatency,'ms</B></font>')
			WHEN L.type = 0 AND L.WriteLatency > 20 THEN  CONCAT('<font color =Blue><U><HRef="http://www.sqlshack.com/sql-server-disk-performance-metrics-part-1-important-disk-performance-metrics/">I/O Write</A></U></font><font color =Black> on ',LI.[Type],' are averaging longer than <B>20ms</B> - Current is - </font><font color =',IIF(L.WriteLatency > 100,'Red','Orange'),'><B>',L.WriteLatency,'ms</B></font>')
			ELSE ''
			END [HTMLWriteInfo])M
			CROSS APPLY (SELECT CASE WHEN LEN(M.ReadInfo)> 0 AND LEN(M.WriteInfo) > 0 THEN CONCAT(M.ReadInfo,'
',M.WriteInfo) 
			WHEN LEN(M.ReadInfo)> 0 AND LEN(M.WriteInfo) = 0 THEN M.ReadInfo
			WHEN LEN(M.ReadInfo)= 0 AND LEN(M.WriteInfo) > 0 THEN M.WriteInfo
			ELSE NULL END [Info],
			CASE WHEN LEN(M.ReadInfo)> 0 AND LEN(M.WriteInfo) > 0 THEN CONCAT(M.HTMLReadInfo,'<br>',M.HTMLWriteInfo) 
			WHEN LEN(M.ReadInfo)> 0 AND LEN(M.WriteInfo) = 0 THEN M.HTMLReadInfo
			WHEN LEN(M.ReadInfo)= 0 AND LEN(M.WriteInfo) > 0 THEN M.HTMLWriteInfo
			ELSE NULL END [HTMLInfo])H
	WHERE	L.guid = @Guid
			AND L.type IN (0,1,99)
	ORDER BY 1,2;

END