SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE TRIGGER [CUENTA_FIDINSERT] ON dbo.FACTIMPDET 
FOR INSERT
AS


	update factimp
	set fi_cuentadet=(select count(*) from factimpdet where fi_codigo in (select fi_codigo from inserted))
	where fi_codigo in (select fi_codigo from inserted)

             update factimp
	set fi_totalb = (select sum(fid_cantemp) from factimpdet where fi_codigo in (select fi_codigo from inserted))
	where fi_codigo in (select fi_codigo from inserted)


SET QUOTED_IDENTIFIER OFF 
GO
