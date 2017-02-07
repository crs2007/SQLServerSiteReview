-- =============================================
-- Author:		Sharon
-- Create date: 11/06/2016
-- Description:	Get Replication
-- =============================================
CREATE PROCEDURE [GUI].[usp_GetReplication] @guid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

	SELECT	R.Messages,ISNULL(R.Link,RL.Link)[Link],IIF(ISNULL(R.Link,RL.Link) IS NULL,'Black','Blue')[Color]
	FROM	[Client].[Replications] R
			LEFT JOIN [Configuration].[ReplicationLink] RL ON RL.ID = R.ID
				AND R.Link IS NULL
	WHERE	R.guid = @guid
	ORDER BY R.ID ASC

END