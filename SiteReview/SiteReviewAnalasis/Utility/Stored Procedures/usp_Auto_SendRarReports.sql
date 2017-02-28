
-- =============================================
-- Author:		Sharon
-- Create date: 17/10/2016
-- Update date: 
-- Description:	Send Mail
-- =============================================
CREATE PROCEDURE [Utility].[usp_Auto_SendRarReports]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cmd VARCHAR(MAX);
    DECLARE @ClientName VARCHAR(255);
    DECLARE @ClientID INT;
	DECLARE @ReportGUID UNIQUEIDENTIFIER;
	DECLARE @emailBCC VARCHAR(MAX) = '';
    DECLARE @file_attachment VARCHAR(1000);	

	DECLARE @msg NVARCHAR(MAX);
	DECLARE @error NVARCHAR(MAX);
    DECLARE @MainSubject VARCHAR(1000) = 'Site Review - SQL Server Health Check';
    DECLARE @errormsg VARCHAR(MAX);
    DECLARE @bodymsg VARCHAR(MAX);
    DECLARE @getClientName CURSOR;
    DECLARE @fileexistsresult INT;	

	DECLARE @ExportPath NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('ExportPath'));
	DECLARE @MailProfile sysname = (SELECT TOP 1 name FROM msdb.dbo.sysmail_profile);
	DECLARE @eMail NVARCHAR(MAX);

	DECLARE @SlackToken NVARCHAR(MAX);
	SELECT	@SlackToken = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('SlackToken')),
			@emailBCC = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('emailBCC'));

    SET @getClientName = CURSOR LOCAL FORWARD_ONLY FOR
	SELECT	[Utility].[ufn_CapitalizeFirstLetter](ISNULL(L.FullName,N'General Client')),ISNULL(RMD.ClientID,1),RMD.ReportGUID ,LC.eMail
	FROM	Client.ReportMetaData RMD 
			INNER JOIN [SiteReviewUser].[dbo].[Login] L ON ISNULL(RMD.ClientId,1) = L.ID
			INNER JOIN [SiteReviewUser].[dbo].LoginCheck LC  ON LC.LoginID = L.ID
	WHERE	RMD.HaveSent = 0 
			AND RMD.HaveExportError = 0;

    OPEN @getClientName;
    FETCH NEXT FROM @getClientName INTO @ClientName,@ClientID,@ReportGUID,@eMail;
	
    WHILE @@FETCH_STATUS = 0
        BEGIN


			IF @eMail IS NULL OR @eMail = ''
			BEGIN
				SET @eMail =@emailBCC
			END
			
			SELECT @ClientName = [Utility].[ufn_CapitalizeFirstLetter](@ClientName);
			SELECT @bodymsg = CONCAT('Dear ',@ClientName,',

Thank you for using SQL Server ');
			

            SET @file_attachment = CONCAT(@ExportPath,'\',@eMail,'\Mail\Reports.rar');
            EXEC master.dbo.xp_fileexist @file_attachment,
                @fileexistsresult OUTPUT;
            IF @fileexistsresult = 1 AND @eMail IS NOT NULL
            BEGIN
				BEGIN TRY
					EXEC msdb.dbo.sp_send_dbmail 
						@profile_name = @MailProfile,
						@recipients = @eMail, 
						@blind_copy_recipients = @emailBCC,
						@subject = @MainSubject,
						@body = @bodymsg, 
						@file_attachments = @file_attachment,
						@body_format = 'HTML',
						@exclude_query_output = 1;

					UPDATE  [Client].[ReportMetaData]
					SET     HaveSent = 1
					WHERE   ReportGUID = @ReportGUID;

					SELECT @msg = CONCAT(@@SERVERNAME,':: ',@MainSubject,' :: ',@ClientName,' - ',' PDF has been sent.')
				END TRY
				BEGIN CATCH
					SET @error = ERROR_MESSAGE();
					UPDATE	[Client].[ReportMetaData] 
					SET		HaveExportError = 1,ExportError = @error
					WHERE	IsExported = 0 
							AND ReportGUID = @ReportGUID
							AND HaveExportError = 0;

					SELECT @msg = CONCAT(@@SERVERNAME,':: ',@MainSubject,' :: ',@ClientName,' - Error:: ',@error)
				END CATCH
				 

            END;
            ELSE
            BEGIN
                SET @errormsg = 'Client Name: ' + @ClientName;
                SET @errormsg = CASE WHEN @fileexistsresult = 0
                                        THEN @errormsg
                                            + '; Error: Missing file attachment'
                                        WHEN @eMail IS NULL
                                        THEN @errormsg
                                            + '; Error: Missing Email Recipients'
                                END;
				UPDATE	[Client].[ReportMetaData] 
				SET		HaveExportError = 1,ExportError = @errormsg
				WHERE	HaveSent = 0 
						AND ReportGUID = @ReportGUID
						AND HaveExportError = 0;

				SELECT @msg = CONCAT(@@SERVERNAME,':: ',@MainSubject,' :: ',@errormsg)
                --RAISERROR(@errormsg,16,1);
            END;
			SELECT Ok,
				Channel,
				TimeStamp,
				Error
			FROM [Utility].SlackChatPostMessage(
				@SlackToken,
				'#sitereview',
				@msg,
				@ClientName,
				NULL
			)
            FETCH NEXT FROM @getClientName INTO @ClientName,@ClientID,@ReportGUID,@eMail;
        END;

    CLOSE @getClientName;
    DEALLOCATE @getClientName;

END