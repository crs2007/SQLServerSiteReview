
-- =============================================
-- Author:		Dror
-- Create date: 2012
-- Update date: 07/08/2016 Sharon Add Diraction
--				17/08/2016 Sharon Fix More then 10 DBs
--				25/08/2016 Sharon Add LifeCycle Support + Client DB Ver
-- Description:	Format Mail
-- =============================================
CREATE FUNCTION [Utility].[ufn_Auto_GenerateMailText]
(
    @ClientName NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @msg VARCHAR(MAX);
    DECLARE @AutoCloseStr VARCHAR(MAX);
    DECLARE @MachineName VARCHAR(MAX);
    DECLARE @guid VARCHAR(MAX);
    DECLARE @CheckdbStr VARCHAR(MAX);
    DECLARE @backupStr VARCHAR(MAX);
    DECLARE @AutoShrinkStr VARCHAR(MAX);
    DECLARE @FreeSpace VARCHAR(MAX);
    DECLARE @Persetage VARCHAR(MAX);
    DECLARE @AutoCreateStat VARCHAR(MAX);
    DECLARE @AutoUpdateStat VARCHAR(MAX);   
    DECLARE @Life VARCHAR(MAX);
    DECLARE @Issues INT;
    DECLARE @ClientVer CHAR(1);
    DECLARE @Ver NVARCHAR(128) ;
    DECLARE @Edition NVARCHAR(MAX) ;
    DECLARE @ServicePack NVARCHAR(MAX) ;
    DECLARE @CRLF NVARCHAR(10) = N'
';
    SET @msg = '<!DOCTYPE html>
<html lang="HE">
<body>
<style type="text/css">
table.sample {
	font-family:Calibri;
	font-size:small;
	border-width: 1px;
	border-spacing: 0px;
	border-style: solid;
	border-color: gray;
	border-collapse: collapse;
	background-color: white;}
table.sample th {
	border-width: 1px;
	padding: 3px;
	border-style: solid;
	border-color: gray;
	background-color: white;
	}
table.sample td {
	font-family:Calibri;
	font-size:12px;
	border-width: 1px;
	padding: 3px;
	border-style: solid;
	border-color: gray;
	background-color: white;
	}
</style>
<font face="Calibri (Body)">
<H1><p style=''font-size:18.0pt;font-family:"Bradley Hand ITC";text-align: center;''> New Active Report</p></H1>
<p style="text-align: right;direction: rtl;" ><span style="font-family: Arial;"><br>';
--    SET @msg += 'שלום ';
--    SET @Issues = 0;

--	SELECT	@msg += REPLACE(Utility.ufn_Util_clr_Conc(ML.Name),', ',' ו')
--	FROM	[Client].[MailList] ML
--			INNER JOIN Client.Clients C ON C.ID = ML.ClientID
--	WHERE	C.Name LIKE '%' + @ClientName + '%';
--	SET @msg += '<br>';

--    DECLARE @getReportguid CURSOR ;

--    SET @getReportguid = CURSOR LOCAL FAST_FORWARD FOR
--	SELECT	rtm.Reportguid,LEFT(ClientVersion,1)
--	FROM	Run.ReportMetaData XR
--			INNER JOIN ReportToMail RTM ON RTM.Reportguid = XR.ReportGUID
--	WHERE	RTM.wassent = 0
--			AND RTM.ClientName LIKE '%' + @ClientName + '%';

--    OPEN @getReportguid;
--    FETCH NEXT FROM @getReportguid INTO @guid,@ClientVer;
	
--    WHILE @@FETCH_STATUS = 0
--        BEGIN
--            SET @AutoCloseStr = NULL; 
--            SET @AutoShrinkStr = NULL;
--            SET @backupStr = NULL;
--            SET @CheckdbStr = NULL;
--			SET @Persetage = NULL;
--			SET @AutoCreateStat = NULL;
--			SET @AutoUpdateStat = NULL;

--			--Get Machine Name
--            SELECT  @Edition = Edition ,
--                    @ServicePack = ProductLevel  ,
--                    @MachineName = MS.ServerName,
--                    @Ver = ISNULL(ProductVersion,Utility.ufn_Util_clr_RegexReplace(Version,'([\W\w]*)\- ([\d]+\.[\d]+\.[\d]+\.[\d]+)[\W\w]*','$2',0))
--            FROM    MachineSettings MS
--            WHERE   @guid = guid;
 
--            IF @Edition LIKE '%Enterprise%' AND @Edition LIKE '%Core-based%' SET @Edition = 'Enterprise Core'
--            ELSE IF @Edition LIKE '%Enterprise%' SET @Edition = 'Enterprise'
--            ELSE IF @Edition LIKE '%Web%' SET @Edition = 'Web'
--            ELSE IF @Edition LIKE '%Express%' SET @Edition = 'Express'
--            ELSE IF @Edition LIKE '%Developer%' SET @Edition = 'Developer'
--            ELSE IF @Edition LIKE '%Business Intelligence%' SET @Edition = 'Business Intelligence'
--            ELSE IF @Edition LIKE '%Standard%' SET @Edition = 'Standard'
 
--            SELECT @Edition = 'Microsoft SQL Server ' + CASE PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) 
--                    WHEN 9 THEN '2005' 
--                    WHEN 10 THEN CASE WHEN PARSENAME(CONVERT(VARCHAR(32), @Ver), 3) = '50' THEN '2008 R2' ELSE '2008' END
--                    WHEN 11 THEN '2012'
--                    WHEN 12 THEN '2014' 
--                    WHEN 13 THEN '2016' 
--                    ELSE '' END +' ' + @Edition
--            IF @ServicePack = 'SP1' SET @ServicePack = 'Service Pack 1'
--            ELSE IF @ServicePack = 'SP2' SET @ServicePack = 'Service Pack 2'
--            ELSE IF @ServicePack = 'SP3' SET @ServicePack = 'Service Pack 3'
--            ELSE IF @ServicePack = 'SP4' SET @ServicePack = 'Service Pack 4'
--            ELSE IF @ServicePack = 'SP5' SET @ServicePack = 'Service Pack 5'
--            ELSE IF @ServicePack = 'SP6' SET @ServicePack = 'Service Pack 6'
--            ELSE IF @ServicePack = 'SP7' SET @ServicePack = 'Service Pack 7'
--            ELSE IF @ServicePack = 'SP8' SET @ServicePack = 'Service Pack 8'
--            ELSE IF @ServicePack = 'SP9' SET @ServicePack = 'Service Pack 9'
--            SELECT @ServicePack = 'Microsoft SQL Server ' + CASE PARSENAME(CONVERT(VARCHAR(32), @Ver), 4)
--                    WHEN 9 THEN '2005'  
--                    WHEN 10 THEN CASE WHEN PARSENAME(CONVERT(VARCHAR(32), @Ver), 3) = '50' THEN '2008 R2' ELSE '2008' END
--                    WHEN 11 THEN '2012'
--                    WHEN 12 THEN '2014' 
--                    WHEN 13 THEN '2016' 
--                    ELSE '' END + ' ' + @ServicePack
 
--			--Get List of Databases with AutoClose		
--            SELECT  @AutoCloseStr = COALESCE(@AutoCloseStr + ', ', '')
--                    + name
--            FROM    DatabaseInfo
--            WHERE   is_auto_close_on = 1
--                    AND @guid = guid
--                    AND name NOT IN ( SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB );

--			--Get list of Database with AutoShrink
--            SELECT  @AutoShrinkStr = COALESCE(@AutoShrinkStr + ', ', '') + name
--            FROM    DatabaseInfo
--            WHERE   is_auto_shrink_on = 1
--                    AND @guid = guid
--                    AND name NOT IN ( SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB );

--			--Get list of Database with Persetage Groth
--            SELECT  DISTINCT @Persetage = COALESCE(@Persetage + '<br>', '') +  Database_Name
--            FROM    DatabaseFiles
--            WHERE   @guid = guid
--                    AND Growth_Units LIKE '%[%]%'
--                    AND Database_Name NOT IN (SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB);

--			--Get list of Database with AutoCreateStatistics
--			IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Software] WHERE @guid = guid)
--            SELECT  @AutoCreateStat = COALESCE(@AutoCreateStat + '<br>', '') + name
--            FROM    DatabaseInfo
--            WHERE   is_auto_create_stats_on = 0
--                    AND @guid = guid
--                    AND name NOT IN (SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB );

--			--Get list of Database with AutoUpdateStatistics
--			IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[Software] WHERE @guid = guid)
--            SELECT  @AutoUpdateStat = COALESCE(@AutoUpdateStat + '<br>', '') + name
--            FROM    DatabaseInfo
--            WHERE   is_auto_update_stats_on = 0
--                    AND @guid = guid
--                    AND name NOT IN (SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB );

--			--Get list of database with no backup
--			SELECT  TOP 10 @backupStr = COALESCE(@backupStr + '<br>', '') + DatabaseName
--			FROM    [LastbackupDate]
--			WHERE   CONVERT(DATETIME, LastBackUpTime) < DATEADD(ww, -1, GETDATE())
--					AND guid = @guid
--					AND DatabaseName NOT IN ( SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB );

--			IF (SELECT COUNT(1) FROM [LastbackupDate] WHERE   CONVERT(DATETIME, LastBackUpTime) < DATEADD(ww, -1, GETDATE())
--                    AND guid = @guid
--                    AND DatabaseName NOT IN ( SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB ))> 10
--			BEGIN
--				SET @backupStr += '<br>More DBs in Attachment file...';
--			END
--			--Get list of database with no checkDB
--            SELECT  TOP 10 @CheckdbStr = COALESCE(@CheckdbStr + '<br>', '') + DBName
--            FROM    [dbo].[LastCheckDB]
--            WHERE   guid = @guid
--                    AND dbccLastKnownGood < DATEADD(ww, -1, GETDATE())
--                    AND DBName NOT IN ( SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB );

--			IF (SELECT COUNT(1) FROM [dbo].[LastCheckDB] WHERE dbccLastKnownGood < DATEADD(ww, -1, GETDATE())
--                    AND guid = @guid
--                    AND DBName NOT IN ( SELECT EDB.DatabaseName FROM Client.ExcludedDBs EDB ))> 10
--			BEGIN
--				SET @CheckdbStr += '<br>More DBs in Attachment file...';
--			END
--			--Get List of Free Space
--			SELECT	@FreeSpace = COALESCE(@FreeSpace + '<br>', '') + 'בכונן ' + CDrive + ' ' + 
--					CASE 
--					WHEN [FreePersent] BETWEEN 20 AND 30 THEN 'קיים <span style="color: orange;">' + CONVERT(VARCHAR(20),[FreePersent]) + '%</span> פנוי.'
--					WHEN [FreePersent] < 20 THEN 'קיים <span style="color: red;">' + CONVERT(VARCHAR(20),[FreePersent]) + '%</span> פנוי.'
--					ELSE ''
--					END + 
--					CASE 
--					WHEN [Change] >= 20 THEN 'קיים שינוי ב' + CONVERT(VARCHAR(20),[Change]) + '% מהבדיקה הקודמת.'
--					ELSE ''
--					END
--			FROM	(
--			SELECT T.CDrive ,
--					   --CONVERT(INT,T.CFree_Space * 1024)[Free],
--					   --CONVERT(INT,T.CTotal_Size * 1024)[Total],
--					   --T.date ,
--					   --T.Free_Space ,
--					   CONVERT(INT,(T.CFree_Space / T.CTotal_Size) * 100)[FreePersent], -- LESS THEN 30 ORANGE | LESS THEN 20 RED
--					   CONVERT(INT,(ABS(T.DiffFromLastWeek)/(T.CTotal_Size * 1024))*100)[Change]-- OVER 20 % CHANGE FROM LAST SAMPLE
--				FROM (
--						SELECT  T1.Drive AS CDrive ,
--								CONVERT(NUMERIC(10, 2), T1.Free_Space) / 1024 AS CFree_Space ,
--								CONVERT(NUMERIC(10, 2), ISNULL(T1.Total_Size, '')) / 1024 AS CTotal_Size ,
--								T1.RunDate [date] ,
--								CONVERT(NUMERIC(10, 2), DI1.Free_Space) / 1024 AS Free_Space ,
--								ISNULL(T1.Free_Space - DI2.Free_Space, '') AS DiffFromLastWeek,
--								ROW_NUMBER() OVER (PARTITION BY DI1.Drive ORDER BY RM.RunDate DESC) RN
--						FROM    [dbo].[DiskInfo] DI1
--								INNER JOIN [getlastreportguids](@guid) gd ON DI1.guid = gd.guid
--								INNER JOIN ( SELECT   d.*,RM.RunDate--Curent Run
--											FROM     DiskInfo d
--													INNER JOIN Run.ReportMetaData RM ON RM.ReportGUID = d.guid
--											WHERE    d.guid = @guid
--											) T1 ON T1.Drive = DI1.Drive
--								INNER JOIN Run.ReportMetaData RM ON RM.ReportGUID = gd.guid
--								LEFT JOIN [dbo].[DiskInfo] DI2 ON [dbo].[getlastreportguid](T1.guid) = DI2.guid
--																  AND DI1.Drive = DI2.Drive
--						WHERE	CONVERT(NUMERIC(10, 2), T1.Free_Space) / 1024  > 0
--						)T
--				WHERE	T.RN = 1
--						AND T.DiffFromLastWeek != 0)t
--			WHERE	t.[FreePersent] <= 30 or [Change] >= 20;
---------------------------------------------------------------------------------------
--            SET @Life = '';
--            SELECT  TOP 1 @Life = '<li style="direction: rtl;">End of Life cycle Microsoft support for - ' + @ServicePack + ' is - ' + T.[SupportEndDate] + ' <a href="https://support.microsoft.com/he-il/lifecycle?p1=14917">Check Link</a></li>'+@CRLF
--            FROM ( SELECT TRY_CONVERT(NVARCHAR(35),MAX(T.SupportEndDate))[SupportEndDate]
--                    FROM    (SELECT TOP 1 [CompatibilityLevel]
--                              ,[ProductsReleased]
--                              ,[StartDate]
--                              ,CASE WHEN [MainstreamSupportEndDate] > [ExtendedSupportEndDate] THEN [MainstreamSupportEndDate] ELSE [ExtendedSupportEndDate] END [SupportEndDate]
--                          FROM [Configuration].[LifeCycleSupport]
--                          WHERE PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) + CASE WHEN PARSENAME(CONVERT(VARCHAR(32), @Ver), 3) = '50' THEN '5' ELSE '0' END = [CompatibilityLevel]
--                                AND @Edition = ProductsReleased
--                          UNION ALL 
--                          SELECT TOP 1 [CompatibilityLevel]
--                              ,[ProductsReleased]
--                              ,[StartDate]
--                              ,[ServicePackSupportEndDate] [SupportEndDate]
--                          FROM [Configuration].[LifeCycleSupport]
--                          WHERE PARSENAME(CONVERT(VARCHAR(32), @Ver), 4) + CASE WHEN PARSENAME(CONVERT(VARCHAR(32), @Ver), 3) = '50' THEN '5' ELSE '0' END = [CompatibilityLevel]
--                                AND @ServicePack = ProductsReleased)T
--                            HAVING  MAX(T.SupportEndDate) IS NOT NULL
--                                )T
--            WHERE T.SupportEndDate <= DATEADD(DAY,-365,GETDATE());
--------------------------------------------------------- Sun ------------------------------------------------------
--            IF NOT (@AutoCloseStr IS NULL AND @AutoShrinkStr IS NULL AND @backupStr IS NULL AND @CheckdbStr IS NULL AND  @AutoUpdateStat IS NULL AND @AutoCreateStat IS NULL AND @Persetage IS NULL)
--            BEGIN
--                SET @msg += '<p style="direction: rtl;">בשרת: <strong>' + @MachineName + '</strong>'+@CRLF + '<ul style="direction: rtl;">';
--                IF PARSENAME(CONVERT(VARCHAR(32), @Ver), 4)  > 10 AND @ClientVer = '1'
--                    SELECT @msg += '<li style="direction: rtl;"><strong>Please Upgrade the Client DB collector for more accurate results - Contact SQL Server Group Manager for more details.</strong></li>'+@CRLF;
--                IF @Life IS NOT NULL
--                    SET @msg += @Life;
--				IF @backupStr IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">בשבוע האחרון לא היה גיבוי מוצלח לבסיסי הנתונים: ' + @backupStr + '</li>'+@CRLF;
--                IF @CheckdbStr IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">לא רץ CheckDB מוצלח בשבוע האחרון לבסיסי הנתונים הבאים: ' + @CheckdbStr + '</li>'+@CRLF;
--                IF @AutoCloseStr IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">בסיסי הנתונים הבאים מוגדרים עם Auto Close (הגדרה זו יכולה לפגוע בביצועים): ' + @AutoCloseStr + '</li>'+@CRLF;
--                IF @AutoShrinkStr IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">בסיסי הנתונים הבאים מוגדרים עם Auto Shrink (הגדרה זו יכולה לפגוע בביצועים): ' + @AutoShrinkStr + '</li>'+@CRLF;
--				IF @FreeSpace IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">בכוננים הבאים התגלתה בעיית מקום : ' + @FreeSpace + '</li>'+@CRLF;
--				IF @AutoUpdateStat IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">בסיסי הנתונים הבאים לא מוגדרים עם Auto Update Statistc(יש לבדוק מול הגדרות מוצר כגון ביזטוק,שר-פוינט ודינמיק CRM): ' + @AutoUpdateStat + '</li>'+@CRLF;	
--				IF @AutoCreateStat IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">בסיסי הנתונים הבאים לא מוגדרים עם Auto Create Statistc(יש לבדוק מול הגדרות מוצר כגון ביזטוק,שר-פוינט ודינמיק CRM): ' + @AutoCreateStat + '</li>'+@CRLF;	
--				IF @Persetage IS NOT NULL
--                    SET @msg += '<li style="direction: rtl;">בסיסי הנתונים הבאים מוגדרים עם גדילת קבצים ע"פ אחוזים : ' + @Persetage + '</li>'+@CRLF;	
--                SET @Issues += 1;
--                SET @msg += '</p></ul><br>';
--            END;
--            FETCH NEXT FROM @getReportguid INTO @guid,@ClientVer;
--        END;

--    CLOSE @getReportguid;
--    DEALLOCATE @getReportguid;

	 SET @msg +='<p style="direction: rtl;">'
    IF @Issues = 0
        SET @msg += 'הכל נראה תקין<br> אשמח לענות לכל שאלה<br>'+@CRLF;
    ELSE
        IF @Issues = 1
            SET @msg += '<br>פרטים נוספים בדוח המצורף עם מייל זה<br>'+@CRLF;
        ELSE
            SET @msg += '<br>פרטים נוספים בדוחות המצורפים עם מייל זה<br>'+@CRLF;
    SET @msg += @CRLF + '</span></p></font>
<p style="direction: rtl;">
<a href="https://github.com/crs2007/SQLServerQuickFix">SQL Server Configuration Base Fix</a><br>
<a href="http://www.naya-tech.co.il/#!blog/yc0lo">Visit our Experts Blog</a><br>
<span style="color: #7f7f7f; font-family: Arial; font-size: xx-small;">דואר אלקטרוני זה, כולל המסמכים המצורפים, מיועד אך&nbsp;ורק לאדם אליו הוא נשלח, ועשוי להכיל מידע סודי ו / או חסוי. אם אינך הנמען המיועד או שקיבלת דואר אלקטרוני זה בטעות, הינך מתבקש להודיע לשולח מייד ולמחוק כל העתק שלו.</span><br>
<br><span style="color: #339966;font-family: Arial;text-align: center;"> אנא התחשב בסביבה לפני הדפסת מייל זה</span></p>
</body>
</html>'
    RETURN @msg;
END