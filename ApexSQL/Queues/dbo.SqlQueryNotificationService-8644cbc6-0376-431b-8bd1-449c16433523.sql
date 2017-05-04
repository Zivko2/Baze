CREATE QUEUE [dbo].[SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523]
	WITH
		STATUS = ON,
		RETENTION = OFF,
		ACTIVATION (
			STATUS = ON,
			PROCEDURE_NAME = [dbo].[SqlQueryNotificationStoredProcedure-8644cbc6-0376-431b-8bd1-449c16433523],
			MAX_QUEUE_READERS = 1,
			EXECUTE AS OWNER
			),
		POISON_MESSAGE_HANDLING (STATUS = ON)
ON [PRIMARY]
GO
