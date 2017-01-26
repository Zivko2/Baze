SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_GUARDAREL] (@pi_codigo int)   as

SET NOCOUNT ON 
DECLARE @pi_movimiento char(1), @cp_codigo int, @ccptipo varchar(2)

	select @pi_movimiento=pi_movimiento,@cp_codigo=cp_codigo from pedimp where pi_codigo=@pi_codigo

	SELECT @ccptipo = CCP_TIPO
	FROM CONFIGURACLAVEPED
	where CP_CODIGO = @cp_codigo


	delete from PEDIMPGUARDA where PI_CODIGO=@pi_codigo

	IF @ccptipo<>'CT' 
	begin

		if @pi_movimiento='E'
		begin
			if @ccptipo = 'RE'
			begin

				INSERT INTO PEDIMPGUARDA(PI_CODIGO, FACT_CODIGO)
				SELECT PI_RECTIFICA, FI_CODIGO FROM FACTIMP WHERE PI_RECTIFICA=@pi_codigo
	
			end
			else
			begin
				INSERT INTO PEDIMPGUARDA(PI_CODIGO, FACT_CODIGO)
				SELECT PI_CODIGO, FI_CODIGO FROM FACTIMP WHERE PI_CODIGO=@pi_codigo
			end
	
	
		end
		else
		begin
			if @ccptipo = 'RE'
			begin
				INSERT INTO PEDIMPGUARDA(PI_CODIGO, FACT_CODIGO)
				SELECT PI_RECTIFICA, FE_CODIGO FROM FACTEXP WHERE PI_RECTIFICA=@pi_codigo
	
			end
			else
			begin
				INSERT INTO PEDIMPGUARDA(PI_CODIGO, FACT_CODIGO)
				SELECT PI_CODIGO, FE_CODIGO FROM FACTEXP WHERE PI_CODIGO=@pi_codigo
			end
		end
	end



























GO
