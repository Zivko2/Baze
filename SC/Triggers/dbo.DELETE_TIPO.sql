SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE TRIGGER [DELETE_TIPO] ON dbo.TIPO 
FOR DELETE
AS



	if exists(select * from configuratipo where ti_codigo in (select ti_codigo from deleted))
	delete from configuratipo where ti_codigo in (select ti_codigo from deleted)

	if exists(select * from RELTEMBTIPO where ti_codigo in (select ti_codigo from deleted))
	delete from RELTEMBTIPO where ti_codigo in (select ti_codigo from deleted)





























GO
