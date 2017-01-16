SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE PROCEDURE [dbo].[SP_AGREGAIDENITIFICAEN] (@picodigo int, @fraccion varchar(50))   as

SET NOCOUNT ON 
declare @maximo INT, @Piid_codigo int, @IDED_CODIGO int


	TRUNCATE TABLE  TempPedImpDetIdentifica





 	if (SELECT PICF_APLICANOMS FROM PEDIMPSAAICONFIG where PI_CODIGO=@picodigo)='N'
	begin

		if exists (select * from PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'EN' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N'))
		begin
			delete from  PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'EN' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N')
		end

		--Se agrego el IDED_CODIGO, ya que no lo almacenaba sobre todo cuando el identificador es de tipo lista. Manuel G. 28-Mar-11
		if @fraccion='0'
		SELECT @fraccion=IDEG_DESC, @IDED_CODIGO = IDED_CODIGO FROM IDENTIFICAGRAL WHERE IDEG_TIPO = 'C' AND IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'EN' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N')
	
	

		SELECT     @maximo= isnull(MAX(PIID_CODIGO),0)+1
		FROM         PEDIMPDETIDENTIFICA
	
		dbcc checkident (TempPedImpDetIdentifica, reseed, @maximo) WITH NO_INFOMSGS
	
	
		      INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, PIID_DESC, PIID_DESC2, IDED_CODIGO)
		      SELECT dbo.PEDIMPDETB.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'EN' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N'), @fraccion, 
		      dbo.Noms(dbo.ARANCELPERMISO.ARP_PERMISO), @IDED_CODIGO
		      FROM dbo.PEDIMPDETB INNER JOIN dbo.ARANCELPERMISO ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCELPERMISO.AR_CODIGO 
		      WHERE dbo.ARANCELPERMISO.ARP_PERMISO LIKE '%NOM-%' and dbo.PEDIMPDETB.PI_CODIGO=@picodigo
		       GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PI_CODIGO, dbo.ARANCELPERMISO.ARP_PERMISO


	end
	else
	begin
		if exists (select * from PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'NM' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N'))
		begin
			delete from  PedImpDetIdentifica where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'NM' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N')
		end


		if @fraccion='0'
		SELECT @fraccion=IDEG_DESC, @IDED_CODIGO = IDED_CODIGO FROM IDENTIFICAGRAL WHERE IDEG_TIPO = 'C' AND IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'NM' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N')
	
	
		SELECT     @maximo= isnull(MAX(PIID_CODIGO),0)+1
		FROM         PEDIMPDETIDENTIFICA
	
		dbcc checkident (TempPedImpDetIdentifica, reseed, @maximo) WITH NO_INFOMSGS
		--Se agrego condicion para verificar que exista el identificador NM no obsoleto, ya que de lo contrario no deberia insertarlo. Manuel G. 28-Mar-11
		if exists(SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'NM' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N')
			begin
				if @fraccion ='' 
					  INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, PIID_DESC, IDED_CODIGO)
					  SELECT dbo.PEDIMPDETB.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'NM' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N'), 
					  dbo.Noms(dbo.ARANCELPERMISO.ARP_PERMISO), @IDED_CODIGO
					  FROM dbo.PEDIMPDETB INNER JOIN dbo.ARANCELPERMISO ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCELPERMISO.AR_CODIGO 
					  WHERE dbo.ARANCELPERMISO.ARP_PERMISO LIKE '%NOM-%' and dbo.PEDIMPDETB.PI_CODIGO=@picodigo
					   GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PI_CODIGO, dbo.ARANCELPERMISO.ARP_PERMISO
				else
					  INSERT INTO TempPedimpDetIdentifica (PIB_INDICEB, IDE_CODIGO, PIID_DESC, PIID_DESC2, IDED_CODIGO)
					  SELECT dbo.PEDIMPDETB.PIB_INDICEB, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'NM' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N'), @fraccion, 
					  dbo.Noms(dbo.ARANCELPERMISO.ARP_PERMISO), @IDED_CODIGO
					  FROM dbo.PEDIMPDETB INNER JOIN dbo.ARANCELPERMISO ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCELPERMISO.AR_CODIGO 
					  WHERE dbo.ARANCELPERMISO.ARP_PERMISO LIKE '%NOM-%' and dbo.PEDIMPDETB.PI_CODIGO=@picodigo
					   GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PI_CODIGO, dbo.ARANCELPERMISO.ARP_PERMISO
			end
	end

alter table [PedImpDetIdentifica] disable trigger [UPDATE_PEDIMPDETIDENTIFICA]
		insert into PedImpDetIdentifica (PIID_CODIGO, PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_DESC2, PIID_TIPO)

		SELECT     TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
	                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_DESC2, 'N'
		FROM         TempPedImpDetIdentifica INNER JOIN
	                      PEDIMPDET ON TempPedImpDetIdentifica.PIB_INDICEB = PEDIMPDET.PIB_INDICEB
		WHERE     (PEDIMPDET.PI_CODIGO = @picodigo) AND TempPedImpDetIdentifica.PIB_INDICEB NOT IN
			(SELECT PIB_INDICEB FROM PedImpDetIdentifica where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'EN' and IDE_IDENTPERM='I' and IDE_OBSOLETO = 'N')
			and pi_codigo=@picodigo)
		GROUP BY TempPedImpDetIdentifica.PIID_CODIGO, TempPedImpDetIdentifica.PIB_INDICEB, TempPedImpDetIdentifica.IDE_CODIGO, 
	                      TempPedImpDetIdentifica.IDED_CODIGO, TempPedImpDetIdentifica.PIID_DESC, TempPedImpDetIdentifica.PIID_TIPO, TempPedImpDetIdentifica.PIID_DESC2

alter table [PedImpDetIdentifica] enable trigger [UPDATE_PEDIMPDETIDENTIFICA]

	select @Piid_codigo= isnull(max(Piid_codigo),0) from pedimpdetidentifica

	update consecutivo
	set cv_codigo =  isnull(@Piid_codigo,0) + 1
	where cv_tipo = 'PIID'


























GO
