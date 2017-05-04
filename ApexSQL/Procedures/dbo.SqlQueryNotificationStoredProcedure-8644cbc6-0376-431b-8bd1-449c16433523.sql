SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[SqlQueryNotificationStoredProcedure-8644cbc6-0376-431b-8bd1-449c16433523] AS BEGIN BEGIN TRANSACTION; RECEIVE TOP(0) conversation_handle FROM [SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523]; IF (SELECT COUNT(*) FROM [SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523] WHERE message_type_name = 'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer') > 0 BEGIN if ((SELECT COUNT(*) FROM sys.services WHERE name = 'SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523') > 0)   DROP SERVICE [SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523]; if (OBJECT_ID('SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523', 'SQ') IS NOT NULL)   DROP QUEUE [SqlQueryNotificationService-8644cbc6-0376-431b-8bd1-449c16433523]; DROP PROCEDURE [SqlQueryNotificationStoredProcedure-8644cbc6-0376-431b-8bd1-449c16433523]; END COMMIT TRANSACTION; END
GO
