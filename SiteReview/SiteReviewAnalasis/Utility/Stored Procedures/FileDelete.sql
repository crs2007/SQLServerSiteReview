CREATE PROCEDURE [Utility].[FileDelete]
@sFileNamePath NVARCHAR (MAX)
AS EXTERNAL NAME [FileSystemHelper].[StoredProcedures].[FileDelete]







