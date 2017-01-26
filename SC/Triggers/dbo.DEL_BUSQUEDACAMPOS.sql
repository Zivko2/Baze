SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE TRIGGER [DEL_BUSQUEDACAMPOS] ON dbo.BUSQUEDACAMPOS 
FOR DELETE 
AS

	if exists(select * from busquedaformula where buf_codigo in (select buf_codigo from deleted))
	delete from busquedaformula where buf_codigo in (select buf_codigo from deleted)











GO
