CREATE PROCEDURE [Utility].[usp_clr_ExportPDFReport]
@ServicePathUrl NVARCHAR (MAX), @reportPath NVARCHAR (MAX), @ExportPath NVARCHAR (MAX), @ExportReportName NVARCHAR (MAX), @InputParameter NVARCHAR (MAX)
AS EXTERNAL NAME [CLR_ReportUtil].[StoredProcedures].[usp_clr_ExportPDFReport]







