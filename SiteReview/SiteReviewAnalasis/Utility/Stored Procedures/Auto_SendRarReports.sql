-- =============================================
-- Author:		Sharon
-- Create date: 17/10/2016
-- Update date: 
-- Description:	Send Mail
-- =============================================
CREATE PROCEDURE Utility.[Auto_SendRarReports]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cmd VARCHAR(MAX);
    DECLARE @ClientName VARCHAR(255);
    DECLARE @ClientID INT;
	DECLARE @ReportGUID UNIQUEIDENTIFIER;
    DECLARE @emailadr VARCHAR(MAX) = '';
	DECLARE @emaILCC VARCHAR(MAX) = '';
    DECLARE @file_attachment VARCHAR(1000);	

	DECLARE @msg NVARCHAR(MAX);
	DECLARE @error NVARCHAR(MAX);
    DECLARE @MainSubject VARCHAR(1000) = 'Site Review - SQL Server Health Check';
    DECLARE @errormsg VARCHAR(MAX);
    DECLARE @bodymsg VARCHAR(MAX);
    DECLARE @getClientName CURSOR;
    DECLARE @fileexistsresult INT;	
	DECLARE @FullName NVARCHAR(200);
	DECLARE @ExportPath NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),[Utility].[ufn_GetConfiguration] ('ExportPath'));
	DECLARE @MailProfile sysname = (SELECT TOP 1 name FROM msdb.dbo.sysmail_profile);
	SELECT	@emaILCC = 'sharonr@naya-tech.co.il';

    SET @getClientName = CURSOR LOCAL FORWARD_ONLY FOR
	SELECT [Utility].[ufn_CapitalizeFirstLetter](ISNULL(ClientName,N'General Client')),ISNULL(ClientID,1),ReportGUID FROM [Client].[ReportMetaData] WHERE HaveSent = 0 AND HaveExportError = 0;

    OPEN @getClientName;
    FETCH NEXT FROM @getClientName INTO @ClientName,@ClientID,@ReportGUID;
	
    WHILE @@FETCH_STATUS = 0
        BEGIN

			EXECUTE [Utility].[usp_GetClientList] @ClientID,@FullName OUTPUT,@emailadr OUTPUT;

			IF @emailadr IS NULL OR @emailadr = ''
			BEGIN
				SET @emailadr =@emaILCC
			END
			
			SELECT @bodymsg = Utility.ufn_Auto_GenerateMailText(@FullName);
			SELECT @ClientName = [Utility].[ufn_CapitalizeFirstLetter](CONCAT(@ClientName,' - ',@FullName));

            SET @file_attachment = CONCAT(@ExportPath,'\',@ClientID,'\Mail\Reports.rar');
            EXEC master.dbo.xp_fileexist @file_attachment,
                @fileexistsresult OUTPUT;
            IF @fileexistsresult = 1 AND @emailadr IS NOT NULL
            BEGIN
				BEGIN TRY
					EXEC msdb.dbo.sp_send_dbmail 
						@profile_name = @MailProfile,
						@recipients = @emailadr, 
						@blind_copy_recipients = @emaILCC,
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
                                        WHEN @emailadr IS NULL
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
				'xoxp-71992844615-71990538485-73144034609-9b77806502',
				'#sitereview',
				@msg,
				@ClientName,
				null
			)
            FETCH NEXT FROM @getClientName INTO @ClientName,@ClientID,@ReportGUID;
        END;

    CLOSE @getClientName;
    DEALLOCATE @getClientName;

END


