CREATE ROLE [INTRADE_USER] AUTHORIZATION [dbo]
GO

EXEC sp_addrolemember @rolename=N'INTRADE_USER', @membername =N'INSNT01\kespinoza'

GO
