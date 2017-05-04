CREATE SERVICE [SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523]
	AUTHORIZATION [dbo]
	ON QUEUE [dbo].[SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523]
	([http://schemas.microsoft.com/SQL/Notifications/PostQueryNotification])
GO
