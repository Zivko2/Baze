SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSORDTRABAJOSURT] (@OT_CODIGO INT)   as

SET NOCOUNT ON 
DECLARE @saldo decimal(38,6), @cant decimal(38,6)

	SELECT   @saldo = round(SUM(dbo.ORDTRABAJODET.OTD_SALDOSURT),2), @cant = round(SUM(dbo.ORDTRABAJODET.OTD_SIZELOTE),2)
	FROM         dbo.ORDTRABAJO INNER JOIN
                dbo.ORDTRABAJODET ON dbo.ORDTRABAJO.OT_CODIGO = dbo.ORDTRABAJODET.OT_CODIGO
	GROUP BY dbo.ORDTRABAJO.OT_CODIGO
	HAVING dbo.ORDTRABAJO.OT_CODIGO = @OT_CODIGO  



/* actualizamos Estatus de la Orden de Trabajo */
	if @cant >0
	begin
		if @saldo >0 
		begin
			if @cant = @saldo
			begin
				update ORDTRABAJO
					set ot_estatussurt = 'N'		-- Nueva Orden
					where OT_CODIGO = @OT_CODIGO
			end
			else
			begin
					update ORDTRABAJO
					set ot_estatussurt = 'P'			-- Parcialmente cumplida
					where OT_CODIGO = @OT_CODIGO

			end
		end
		else 
		begin
					update ORDTRABAJO
					set ot_estatussurt = 'C'				-- Cumplida
					where OT_CODIGO = @OT_CODIGO
	
		end

	end
	else
		update ORDTRABAJO
		set ot_estatussurt = 'N'		-- Nueva Orden
		where OT_CODIGO = @OT_CODIGO
















































GO
