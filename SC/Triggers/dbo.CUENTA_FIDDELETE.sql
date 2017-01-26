SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE TRIGGER [CUENTA_FIDDELETE] ON dbo.FACTIMPDET 
FOR DELETE 
AS

/*
	update factimp
	set fi_cuentadet=isnull(fi_cuentadet,0)-1
	where fi_codigo in (select fi_codigo from deleted)
*/
	update factimp
	set fi_cuentadet=(select count(*) from factimpdet where fi_codigo in (select fi_codigo from deleted))
	where fi_codigo in (select fi_codigo from deleted)


        update factimp
	set fi_totalb = (select isnull(sum(fid_cantemp),0) from factimpdet where fi_codigo in (select fi_codigo from deleted))
	where fi_codigo in (select fi_codigo from deleted)



GO
