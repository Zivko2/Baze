SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE TRIGGER [DEL_BUSQUEDASEL] ON dbo.BUSQUEDASEL 
FOR DELETE 
AS

	if exists(select * from busquedaseldet where bus_codigo in (select bus_codigo from deleted))
	delete from busquedaseldet where bus_codigo in (select bus_codigo from deleted)

	if exists(select * from busquedacampos where bus_codigo in (select bus_codigo from deleted))
	delete from busquedacampos where bus_codigo in (select bus_codigo from deleted)

	if exists(select * from busquedaformula where bus_codigo in (select bus_codigo from deleted))
	delete from busquedaformula where bus_codigo in (select bus_codigo from deleted)

	if exists(select * from busquedaparametro where bus_codigo in (select bus_codigo from deleted))
	delete from busquedaparametro where bus_codigo in (select bus_codigo from deleted)

	if exists(select * from busquedaorden where bus_codigo in (select bus_codigo from deleted))
	delete from busquedaorden where bus_codigo in (select bus_codigo from deleted)

	if exists(select * from busquedafiltro where bus_codigo in (select bus_codigo from deleted))
	delete from busquedafiltro where bus_codigo in (select bus_codigo from deleted)











GO
