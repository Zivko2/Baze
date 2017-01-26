SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_ACTUALIZASECUENCIAFACT] (@pi_codigo int)   as

SET NOCOUNT ON 
DECLARE @pi_movimiento char(1), @cp_codigo int, @ccptipo varchar(2)
/* este stored se corre desde el sistema del boton actualiza infoanexa que se encuentra en pedimento de importacion
este boton solo esta habilitado en las siguientes opciones = cuando el pedimento sea corriente, cuando si es de salida no sea cambio de regimen
*/

	select @pi_movimiento=pi_movimiento,@cp_codigo=cp_codigo from pedimp where pi_codigo=@pi_codigo

	SELECT @ccptipo = CCP_TIPO
	FROM CONFIGURACLAVEPED
	where CP_CODIGO = @cp_codigo


	IF @ccptipo<>'CT' 
	begin
		if @pi_movimiento='E'
		begin
			if @ccptipo = 'RE'
			begin
				UPDATE dbo.FACTIMPDET
				SET     dbo.FACTIMPDET.FID_PIDSECUENCIA= isnull(dbo.PEDIMPDET.PID_SECUENCIA,0)
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGAR1
				WHERE     (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)
	
			end
			else
			begin
				UPDATE dbo.FACTIMPDET
				SET     dbo.FACTIMPDET.FID_PIDSECUENCIA= isnull(dbo.PEDIMPDET.PID_SECUENCIA,0)
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGA
				WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)


			end
	
	
		end
		else
		begin
			if @ccptipo = 'RE'
			begin
				UPDATE dbo.FACTEXPDET
				SET     dbo.FACTEXPDET.FED_PIDSECUENCIA= isnull(dbo.PEDIMPDET.PID_SECUENCIA,0)
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGAR1
				WHERE     (dbo.PEDIMPDET.PI_CODIGO =@pi_codigo)
	
			end
			else
			begin
				UPDATE dbo.FACTEXPDET
				SET     dbo.FACTEXPDET.FED_PIDSECUENCIA= isnull(dbo.PEDIMPDET.PID_SECUENCIA,0)
				FROM         dbo.PEDIMPDET LEFT OUTER JOIN
				                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA
				WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
			end
		end
	end

GO
