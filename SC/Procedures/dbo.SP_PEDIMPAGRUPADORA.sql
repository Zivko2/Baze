SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_PEDIMPAGRUPADORA] (@picodigo INT, @FIA_CODIGO INT)   as

SET NOCOUNT ON 
declare @pi_movimiento char(1)


	select @pi_movimiento=pi_movimiento from pedimp where pi_codigo=@picodigo


	if @pi_movimiento='E'
	begin
		update factimp
		set pi_codigo=-1
		where fi_factagru=@picodigo

		update factimp
		set pi_codigo=@picodigo 
		where fi_factagru=@FIA_CODIGO
	end
	else
	begin
		update factexp
		set pi_codigo=-1
		where fe_factagru=@picodigo

		update factexp
		set pi_codigo=@picodigo 
		where fe_factagru=@FIA_CODIGO

	end


		exec sp_fillpedimento @picodigo, 1, @pi_movimiento



GO
