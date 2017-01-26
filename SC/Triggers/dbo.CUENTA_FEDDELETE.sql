SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE TRIGGER [CUENTA_FEDDELETE] ON dbo.FACTEXPDET 
FOR DELETE 
AS


	
	update factexp
	set fe_cuentadet=(select count(*) from factexpdet where fe_codigo in (select fe_codigo from deleted))
	where fe_codigo in (select fe_codigo from deleted)


             update factexp
	set fe_totalb = (select isnull(sum(fed_cantemp),0) from factexpdet where fe_codigo in (select fe_codigo from deleted))
	where fe_codigo in (select fe_codigo from deleted)


GO
