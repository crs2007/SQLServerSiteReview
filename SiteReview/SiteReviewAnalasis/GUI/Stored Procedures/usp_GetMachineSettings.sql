-- =============================================
-- Author:		Sharon
-- Create date: 2016
-- Update date: 2016/06/08 Sharon
--				2016/07/21 Sharon Utility.ufn_Util_clr_RegexReplace(Version,'Microsoft SQL Server [\d]+ \- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$1',0)
-- Description:	
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetMachineSettings] @guid UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    SELECT  name , value,'Black' Color, NULL [Link]
    FROM    ( SELECT    CONVERT(NVARCHAR(MAX),ISNULL(ServerName, '')) AS ServerName ,
                        ISNULL(MachineName, '') MachineName ,
                        ISNULL(SystemModel, '') SystemModel
              FROM      Client.[MachineSettings]
              WHERE     guid = @guid
            ) p UNPIVOT
	( value FOR name IN ( ServerName, MachineName, SystemModel ) ) AS unpvt
    WHERE   value <> ''
	UNION ALL 
	SELECT	TOP 1 'Operating System',[OSName], 'Black',NULL [Link]
	FROM	Client.ServerProporties SP
	WHERE	SP.guid = @guid
	UNION ALL 
	SELECT	TOP 1 'Bit',CONVERT(NVARCHAR(MAX),OS_bit), 'Black',NULL [Link]
	FROM	Client.ServerProporties SP
	WHERE	SP.guid = @guid
	UNION ALL 
	--SELECT	TOP 1 'Platform Type',[PlatformType], 'Black',NULL [Link]
	--FROM	Client.ServerProporties SP
	--WHERE	SP.guid = @guid
	--UNION ALL 
	SELECT	TOP 1 'Machine Type',IIF(SP.virtual_machine_type = 1,'Virtual Machine','Physical Machine'), IIF(SP.virtual_machine_type = 1,'Blue','Black'),IIF(SP.virtual_machine_type = 1,'http://www.vmware.com/content/dam/digitalmarketing/vmware/en/pdf/solutions/sql-server-on-vmware-best-practices-guide.pdf',NULL) [Link]
	FROM	Client.ServerProporties SP
	WHERE	SP.guid = @guid

END