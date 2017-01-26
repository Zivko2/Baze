SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























/* este procedimiento asigna el nuevo nombre del reporte (reporteador intrade) para la importacion de la plantilla*/
CREATE PROCEDURE [dbo].[SP_NOMBREREPORTE] (@nombre varchar(100), @NvoNombre varchar(100) output)   as

		if exists (select * from busquedasel where bus_nombre=@nombre)
	begin
		if exists (select * from busquedasel where bus_nombre like @nombre+'_%' and bus_nombre not like @nombre+' _%')
		begin
	               SET @NvoNombre= @nombre+'_'+convert(varchar(50),(SELECT max(REPLACE(RIGHT(bus_nombre, 2), '_', ''))+1  FROM busquedasel where bus_nombre like @nombre+'_%' and bus_nombre not like @nombre+' _%'))
		end
		else
		       SET @NvoNombre= @nombre+'_1'
	end
	else
	begin
		SET @NvoNombre= @nombre
	
	end

























GO
