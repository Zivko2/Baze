SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE TRIGGER [DELETE_TFACTURA] ON dbo.TFACTURA 
FOR DELETE 
AS


	if exists(select * from configuratfact where tf_codigo in (select tf_codigo from deleted))
	delete from configuratfact where tf_codigo in (select tf_codigo from deleted)


	if exists(select * from RELTFACTCLAPED where tf_codigo in (select tf_codigo from deleted))
	delete from RELTFACTCLAPED where tf_codigo in (select tf_codigo from deleted)

	if exists(select * from RELTFACTTEMBAR where tf_codigo in (select tf_codigo from deleted))
	delete from RELTFACTTEMBAR where tf_codigo in (select tf_codigo from deleted)





























GO
