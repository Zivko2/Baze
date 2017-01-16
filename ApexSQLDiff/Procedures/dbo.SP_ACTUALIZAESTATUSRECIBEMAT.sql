SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSRECIBEMAT] (@rc_codigo int)   as

SET NOCOUNT ON 
	if (select rc_cancelado from RecibeMat where RC_CODIGO = @rc_codigo)='N'
	begin
 		IF NOT  EXISTS (SELECT * FROM ENTSALALM where rc_codigo = @rc_codigo) 
		begin
			if (select rc_revisada from RecibeMat where rc_codigo = @rc_codigo)= 'S'
			   	UPDATE RecibeMat 
			     	SET rc_estatus = 'C'  -- REVISADA (CONTROL CALIDAD)
	 		     	 WHERE rc_codigo = @rc_codigo
			else
			   	UPDATE RecibeMat 
			     	SET rc_estatus = 'N'  -- NUEVA RECEPCION
	 		     	 WHERE rc_codigo = @rc_codigo
		end
		else
		   	UPDATE RecibeMat 
		     	SET rc_estatus = 'R'  -- RECIBIDA EN ALMACEN
 		     	 WHERE rc_codigo = @rc_codigo

	end
	else
	         UPDATE RecibeMat 
	         SET rc_estatus = 'K'  -- CANCELADA
	          WHERE rc_codigo = @rc_codigo




























GO
