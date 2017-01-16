SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









































CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSPEDIDO] (@PD_CODIGO INT)    as

SET NOCOUNT ON 
DECLARE @saldo decimal(38,6), @cant decimal(38,6)

	SELECT   @saldo = round(SUM(dbo.pedidodet.PDD_SALDO),2), @cant = round(SUM(dbo.pedidodet.PDD_CANT),2)
	FROM         dbo.PEDIDO INNER JOIN
                dbo.PEDIDODET ON dbo.PEDIDO.PD_CODIGO = dbo.PEDIDODET.PD_CODIGO
	GROUP BY dbo.PEDIDO.PD_CODIGO
	HAVING dbo.PEDIDO.PD_CODIGO = @PD_CODIGO  



/* actualizamos Estatus de la Orden de Trabajo */
	if @cant >0
	begin
		if @saldo >0 
		begin
			if @cant = @saldo
			begin
				update PEDIDO
					set PD_estatus = 'N'		-- Nueva Orden
					where PD_CODIGO = @PD_CODIGO
			end
			else
			begin
					update PEDIDO
					set pd_estatus = 'P'			-- Parcialmente cumplida
					where PD_CODIGO = @PD_CODIGO

			end
		end
		else 
		begin
					update PEDIDO
					set pd_estatus = 'C'				-- Cumplida
					where PD_CODIGO = @PD_CODIGO
	
		end

	end
	else
		update PEDIDO
		set PD_estatus = 'N'		-- Nueva Orden
		where PD_CODIGO = @PD_CODIGO








































GO
