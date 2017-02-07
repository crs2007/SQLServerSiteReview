CREATE FUNCTION [Utility].[SlackChatPostMessage]
(@Token NVARCHAR (MAX), @Channel NVARCHAR (MAX), @Text NVARCHAR (MAX), @UserName NVARCHAR (MAX), @IconUrl NVARCHAR (MAX))
RETURNS 
     TABLE (
        [Ok]        BIT            NULL,
        [Channel]   NVARCHAR (MAX) NULL,
        [TimeStamp] NVARCHAR (MAX) NULL,
        [Error]     NVARCHAR (MAX) NULL)
AS
 EXTERNAL NAME [SqlServerSlackAPI].[UserDefinedFunctions].[SlackChatPostMessage]

