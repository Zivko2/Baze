SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE TRIGGER [CUENTA_FEDINSERT] ON dbo.FACTEXPDET 
FOR INSERT
AS


	update factexp
	set fe_cuentadet=(select count(*) from factexpdet where fe_codigo in (select fe_codigo from inserted))
	where fe_codigo in (select fe_codigo from inserted)

             update factexp
	set fe_totalb = (select sum(fed_cantemp) from factexpdet where fe_codigo in (select fe_codigo from inserted))
	where fe_codigo in (select fe_codigo from inserted)





GO
