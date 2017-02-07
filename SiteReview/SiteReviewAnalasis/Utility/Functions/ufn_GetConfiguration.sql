-- =============================================
-- Author:      Sharon
-- Create date: 29/04/2013
-- Update date: 
-- Description: Get Value By Name
-- =============================================
CREATE FUNCTION [Utility].[ufn_GetConfiguration]
(
       @Name sysname
)
RETURNS SQL_VARIANT
AS
BEGIN  
       DECLARE @Value SQL_VARIANT

        SELECT @Value = Value
        FROM   Configuration.Product_Configuration
        WHERE  Name = @Name;
              
       RETURN @Value;
END
