SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSORDCOMPRA] (@or_codigo int)   as

SET NOCOUNT ON 
DECLARE @cant decimal(38,6), @saldo decimal(38,6)

		SELECT     @CANT=SUM(ORD_CANT_ST), @SALDO=SUM(ORD_SALDO) 
		FROM         dbo.ORDCOMPRADET
		WHERE     (OR_CODIGO = @or_codigo)


	if (select or_cancelado from ordCompra where OR_CODIGO = @or_codigo)='N'
	begin
		   IF EXISTS (SELECT * FROM OrdCompraDet
		   WHERE or_codigo = @or_codigo and ord_enuso='S') 
		begin
		      if @cant = @saldo
		         UPDATE OrdCompra 
		         SET OrdCompra.or_estatus = 'E'  -- nueva orden
		          WHERE OrdCompra.or_codigo = @or_codigo
		        else	
			if @saldo>0
			begin
			         UPDATE OrdCompra 
			         SET OrdCompra.or_estatus = 'P'  -- en proceso
			          WHERE OrdCompra.or_codigo = @or_codigo
			end
			else
			begin
			         UPDATE OrdCompra 
			         SET OrdCompra.or_estatus = 'C'  -- totalmente cumplida
			          WHERE OrdCompra.or_codigo = @or_codigo
			end
		end
		else
		         UPDATE OrdCompra 
		         SET OrdCompra.or_estatus = 'E'  -- nueva orden
		          WHERE OrdCompra.or_codigo = @or_codigo
	end
	else
	         UPDATE OrdCompra 
	         SET OrdCompra.or_estatus = 'K'  -- cancelada
	          WHERE OrdCompra.or_codigo = @or_codigo
















































GO
