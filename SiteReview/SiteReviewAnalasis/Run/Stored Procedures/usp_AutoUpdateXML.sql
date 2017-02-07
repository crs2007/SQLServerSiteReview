-- =============================================
-- Author:		Sharon
-- Create date: 19/06/2016
-- Update date: 
-- Description:	Auto Update XML
-- =============================================
CREATE PROCEDURE [Run].[usp_AutoUpdateXML]
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		EXECUTE [Run].[usp_LoadXMLs];
		EXECUTE [Utility].[usp_GetXMLFromCloud];
	END TRY
	BEGIN CATCH
		--TODO
	END CATCH
	

	DECLARE @XML XML,
			@ID INT,
			@FileName NVARCHAR(260),
			@Error NVARCHAR(2048),
			@ClientID INT;

	DECLARE cuXML CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT	XR.XMLData,XR.ID,FileName,XR.ClientID
	FROM	Client.XMLReports XR
	WHERE	IsPopulated = 0
			AND CONVERT(VARCHAR(MAX),XMLData) != ''
			AND HaveError = 0;

	OPEN cuXML

	FETCH NEXT FROM cuXML INTO @XML,@ID,@FileName,@ClientID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			EXECUTE [Run].[usp_SetXMLIntoDataSet] @XML,@ClientID;
			UPDATE	Client.XMLReports 
			SET		IsPopulated =1
			WHERE	ID = @ID;
		END TRY
		BEGIN CATCH
			SET @Error = CONCAT('Error on ' + @FileName + '.xml',ERROR_MESSAGE());
			UPDATE	Client.XMLReports 
			SET		Error = @Error,HaveError = 1
			WHERE	ID = @ID;
			RAISERROR(@Error,16,1);
		END CATCH	
		FETCH NEXT FROM cuXML INTO @XML,@ID,@FileName,@ClientID;
	END

	CLOSE cuXML;
	DEALLOCATE cuXML;
END

