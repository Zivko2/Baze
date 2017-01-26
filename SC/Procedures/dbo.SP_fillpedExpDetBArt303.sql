SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedExpDetBArt303] (@picodigo int, @CrearTablas char(1)='N')   as

SET NOCOUNT ON 
declare @cf_pagocontribdet char(1), @ccptipo varchar(5)


	select @cf_pagocontribdet=cf_pagocontribdet from configuracion


	SELECT @ccptipo = CCP_TIPO
	FROM CONFIGURACLAVEPED
	where CP_CODIGO in (select cp_codigo from pedimp where pi_codigo=@picodigo)


	EXEC SP_CREAVISTASPAGOCONTRIB @picodigo, @CrearTablas


	DELETE FROM KARDATOSPEDEXPDESC WHERE PI_CODIGOPEDEXP NOT IN (SELECT PI_CODIGO FROM PEDIMP)
	DELETE FROM KARDATOSPEDEXPPAGOUSA WHERE PI_CODIGO NOT IN (SELECT PI_CODIGO FROM PEDIMP)




	IF @ccptipo='CT' 
	begin
		exec sp_fillpedExpComplArt303 @picodigo
	end
	else
	begin
		if @cf_pagocontribdet='S'
		exec fillpedExpDetBArt303Fed @picodigo
		else
		exec fillpedExpDetBArt303Comp @picodigo
	end

	exec fillpedExpArt303 @picodigo


	if (select cf_pagocontribucion from configuracion)='J'
	begin
		exec sp_fillpedimpdetidentificaDT @picodigo

		-- contribucion 303
		if exists (select * from pedimpdetbcontribucion where pi_codigo =@picodigo and con_codigo in (select con_codigo from contribucion where con_abrevia='303'))
		delete from pedimpdetbcontribucion where pi_codigo=@picodigo and con_codigo in (select con_codigo from contribucion where con_abrevia='303')
	
		insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)				
		SELECT     @picodigo, (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0'), (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_abrevia='303'),
			     ROUND((PIB_IMPORTECONTR/PIB_VAL_ADU)*100,6), PIB_IMPORTECONTR, PEDIMPDETB.PIB_INDICEB		FROM         PEDIMPDETB 
		WHERE     (PEDIMPDETB.PI_CODIGO = @picodigo) and PEDIMPDETB.PIB_INDICEB IS NOT NULL
		                  and PIB_IMPORTECONTR>0
	end
GO
