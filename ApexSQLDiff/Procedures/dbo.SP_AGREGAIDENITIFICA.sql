SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_AGREGAIDENITIFICA] (@picodigo int, @ide_codigo int, @ided_codigo int, @piid_desc varchar(40), @piid_desc2 varchar(40))   as

SET NOCOUNT ON 
declare @maximo INT, @Piid_codigo int


		TRUNCATE TABLE  TempPedImpDetIdentifica

	
		SELECT     @maximo= isnull(MAX(PIID_CODIGO),0)+1
		FROM         PEDIMPDETIDENTIFICA
	
		dbcc checkident (TempPedImpDetIdentifica, reseed, @maximo) WITH NO_INFOMSGS
	

	      INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_DESC2, PIID_TIPO)
	      SELECT dbo.PEDIMPDETB.PIB_INDICEB, @ide_codigo, @ided_codigo, @piid_desc, @piid_desc2, 'N'
	      FROM dbo.PEDIMPDETB 
	      WHERE dbo.PEDIMPDETB.PI_CODIGO=@picodigo
	      GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PI_CODIGO




		insert into PedImpDetIdentifica (PIID_CODIGO, PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_DESC2, PIID_TIPO)

		SELECT     TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
	                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_DESC2, 'N'
		FROM         TempPedImpDetIdentifica INNER JOIN
	                      PEDIMPDET ON TempPedImpDetIdentifica.PIB_INDICEB = PEDIMPDET.PIB_INDICEB
		WHERE     (PEDIMPDET.PI_CODIGO = @picodigo) AND TempPedImpDetIdentifica.PIB_INDICEB NOT IN
			(SELECT PIB_INDICEB FROM PedImpDetIdentifica where ide_codigo =@ide_codigo
			and pi_codigo=@picodigo)
		GROUP BY TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
	                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_TIPO, TempPedImpDetIdentifica.PIID_DESC2


select @Piid_codigo= isnull(max(Piid_codigo),0) from pedimpdetidentifica

	update consecutivo
	set cv_codigo =  isnull(@Piid_codigo,0) + 1
	where cv_tipo = 'PIID'































GO
