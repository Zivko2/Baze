SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAORDENIMAGEN]  (@Codigo int,@Orden int, @Tipo varchar(1))   as

SET NOCOUNT ON 
declare @PI_CODIGO int, @IM_ORDEN int, @PI_TIPO varchar(1)

	declare cur_orden cursor for
		select PI_CODIGO, IM_ORDEN, PI_TIPO from pedimpImagen
		where PI_CODIGO=@Codigo and IM_ORDEN>=@Orden and PI_TIPO=@Tipo
	open cur_orden
	FETCH NEXT FROM cur_Orden INTO @PI_CODIGO,@IM_ORDEN,@PI_TIPO
	WHILE (@@FETCH_STATUS = 0) 
	 BEGIN
		   Update pedimpImagen set IM_ORDEN=@IM_ORDEN-1
		   where PI_CODIGO=@PI_CODIGO and IM_ORDEN=@IM_ORDEN and PI_TIPO=@PI_TIPO

	   FETCH NEXT FROM cur_Orden INTO @PI_CODIGO,@IM_ORDEN,@PI_TIPO
	 END
	CLOSE cur_orden
	DEALLOCATE cur_orden
















































GO
