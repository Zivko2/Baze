SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSCOTIZACION] (@COT_CODIGO INT)   as

SET NOCOUNT ON 
DECLARE @saldo decimal(38,6), @cant decimal(38,6), @cuentaseg int, @cot_aprobada char(1)
	SELECT   @saldo = round(SUM(dbo.cotizaciondet.COTD_SALDO),2), @cant = round(SUM(dbo.cotizaciondet.COTD_CANT),2)
	FROM         dbo.COTIZACION INNER JOIN
                dbo.COTIZACIONDET ON dbo.COTIZACION.COT_CODIGO = dbo.COTIZACIONDET.COT_CODIGO
	GROUP BY dbo.COTIZACION.COT_CODIGO
	HAVING dbo.COTIZACION.COT_CODIGO = @COT_CODIGO  
	select @cot_aprobada=cot_aprobada from cotizacion where cot_codigo=@cot_codigo
	
	SELECT     @cuentaseg=COUNT(COTA_CONTACTO)
	FROM         dbo.COTIZACIONAVISO
	WHERE     (COT_CODIGO = @COT_CODIGO) AND (COTA_CONTACTO IS NOT NULL AND COTA_CONTACTO <> '')

/* actualizamos Estatus de la Orden de Trabajo */
	if @cant >0
	begin
		if @saldo >0 
		begin
			if @cant = @saldo
			begin
				if @cot_aprobada='S'
					update COTIZACION
					set COT_estatus = 'A'		-- Aprobada
					where COT_CODIGO = @COT_CODIGO			
				else
				begin
					if @cuentaseg=0
						update COTIZACION
						set COT_estatus = 'N'		-- Nueva Orden
						where COT_CODIGO = @COT_CODIGO
					else
						update COTIZACION
						set COT_estatus = 'R'		-- Con seguimiento
						where COT_CODIGO = @COT_CODIGO
				end
			end
			else
			begin
					update COTIZACION
					set cot_estatus = 'P'			-- Parcialmente pedida
					where COT_CODIGO = @COT_CODIGO
			end
		end
		else 
		begin
					update COTIZACION
					set cot_estatus = 'C'				-- Totalmente pedida
					where COT_CODIGO = @COT_CODIGO
	
		end
	end
	else
		update COTIZACION
		set COT_estatus = 'N'		-- Nueva Orden
		where COT_CODIGO = @COT_CODIGO

GO
