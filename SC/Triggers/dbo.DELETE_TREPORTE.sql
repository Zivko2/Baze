SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


































CREATE TRIGGER [DELETE_TREPORTE] ON dbo.TREPORTE 
FOR DELETE 
AS

	if exists(select * from treportedesc where trd_nombre_rtm in (select tre_nombre_rtm from deleted))
	delete from treportedesc where trd_nombre_rtm in (select tre_nombre_rtm from deleted)





GO
