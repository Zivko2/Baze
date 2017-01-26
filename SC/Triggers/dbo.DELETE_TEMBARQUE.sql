SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE TRIGGER [DELETE_TEMBARQUE] ON dbo.TEMBARQUE 
FOR DELETE 
AS

	if exists(select * from configuratembarque where tq_codigo in (select tq_codigo from deleted))
	delete from configuratembarque where tq_codigo in (select tq_codigo from deleted)


	if exists(select * from RELTEMBTIPO where tq_codigo in (select tq_codigo from deleted))
	delete from RELTEMBTIPO where tq_codigo in (select tq_codigo from deleted)

	if exists(select * from RELTFACTTEMBAR where tq_codigo in (select tq_codigo from deleted))
	delete from RELTFACTTEMBAR where tq_codigo in (select tq_codigo from deleted)































GO
