SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























































CREATE PROCEDURE [dbo].[SP_fillpedimpdetidentificaDT] (@picodigo int)   as

SET NOCOUNT ON 
declare @maximo INT, @Piid_codigo int



	if exists (select * from TempPedImpDetIdentifica)
	begin
		delete from  TempPedImpDetIdentifica
	end


	if (select cf_pagocontribucion from configuracion)='J'
	begin


		if exists (select * from PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
		begin
			delete from  PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
		end
	
		SELECT     @maximo= isnull(MAX(PIID_CODIGO),0)+1
		FROM         PEDIMPDETIDENTIFICA
	
	
		dbcc checkident (TempPedImpDetIdentifica, reseed, @maximo) WITH NO_INFOMSGS
	
		exec sp_droptable 'identificapermite'
	
		SELECT     IDE_CODIGO
		into dbo.identificapermite
		FROM         CLAVEPEDIDENTIFICA
		WHERE      (IDE_NIVEL='A' OR IDE_NIVEL='P')  AND (CP_MOVIMIENTO = 'S') AND (CP_CODIGO in (select cp_codigo from pedimp where pi_codigo=@picodigo))
	
	
			/* ======================= DT complemento 9a, el pago se realiza en el J1 y es mayor que cero  ============================= */
			if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
			and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
			begin
				INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
			
				SELECT     dbo.PEDIMPDETB.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
					(SELECT IDED_CODIGO FROM IDENTIFICADET
					WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
					AND IDED_VALOR='9a'), ''
				FROM         dbo.PEDIMPDETB 
				WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) AND dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL
				AND PIB_VALORMCIANOORIG >0 AND PIB_VALORMCIANOORIG IS NOT NULL
			end


		
	
			/* ======================= DT complemento 10, el pago se realiza en el J1 pero es igual que cero  ============================= */
			if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
			and not exists (select * from TempPedimpDetIdentifica where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'))
			begin
				INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC)
			
				SELECT     dbo.PEDIMPDETB.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I'),
					(SELECT IDED_CODIGO FROM IDENTIFICADET
					WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'DT' and IDE_IDENTPERM='I')
					AND IDED_VALOR='10'), ''
				FROM         dbo.PEDIMPDETB 
				WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) AND dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL
				AND PIB_VALORMCIANOORIG =0
			end
			
			alter table [PedImpDetIdentifica] disable trigger [UPDATE_PEDIMPDETIDENTIFICA]

			insert into PedImpDetIdentifica (PIID_CODIGO, PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_DESC2, PIID_TIPO)
		
			SELECT     TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
			                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_DESC2, 'N'
			FROM         TempPedImpDetIdentifica INNER JOIN
			                      PEDIMPDET ON TempPedImpDetIdentifica.PIB_INDICEB = PEDIMPDET.PIB_INDICEB
			WHERE     (PEDIMPDET.PI_CODIGO = @picodigo)
			GROUP BY TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
			                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_TIPO,
					TempPedImpDetIdentifica.PIID_DESC2
	
			alter table [PedImpDetIdentifica] enable trigger [UPDATE_PEDIMPDETIDENTIFICA]	
	
	end


select @Piid_codigo= isnull(max(Piid_codigo),0) from pedimpdetidentifica

	update consecutivo
	set cv_codigo =  isnull(@Piid_codigo,0) + 1
	where cv_tipo = 'PIID'

	exec sp_droptable 'identificapermite'

GO
