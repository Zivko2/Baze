SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













CREATE PROCEDURE [dbo].[SP_importCertOrig]   as


declare  @CL_MATRIZ int, @CL_TRAFICO int,  @DIRPRINC int, @DIRMATRIZ int, @BlanketPeriod varchar(5), @CONSECUTIVO int, @CMP_CODIGO int

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=-124

if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS


	DELETE FROM TempCertOrigen WHERE(DateComplete IS NULL) AND (CountryOrigin = '')

	UPDATE TempCertOrigen
	SET ProducerInTrade = '4'
	WHERE ltrim(Producer) ='NO3'
	
	UPDATE TempCertOrigen
	SET ProducerInTrade = '3'
	WHERE ltrim(Producer) ='NO2'
	
	UPDATE TempCertOrigen
	SET ProducerInTrade = '2'
	WHERE ltrim(Producer) ='NO1'
	
	UPDATE TempCertOrigen
	SET ProducerInTrade = '1'
	WHERE ltrim(Producer) ='NO'
	
	UPDATE TempCertOrigen
	SET ProducerInTrade = '0'
	WHERE ltrim(Producer) ='YES'
	
	/*----*/
	
	UPDATE TempCertOrigen
	SET PrefCriterionInTrade = '0'
	WHERE ltrim(PrefCriterion) ='A'
	
	UPDATE TempCertOrigen
	SET PrefCriterionInTrade = '1'
	WHERE ltrim(PrefCriterion) ='B'
	
	UPDATE TempCertOrigen
	SET PrefCriterionInTrade = '2'
	WHERE ltrim(PrefCriterion) ='C'
	
	UPDATE TempCertOrigen
	SET PrefCriterionInTrade = '3'
	WHERE ltrim(PrefCriterion) ='D'
	
	UPDATE TempCertOrigen
	SET PrefCriterionInTrade = '4'
	WHERE ltrim(PrefCriterion) ='E'
	
	UPDATE TempCertOrigen
	SET PrefCriterionInTrade = '5'
	WHERE ltrim(PrefCriterion) ='F'
	
	/*---*/
	
	
	UPDATE TempCertOrigen
	SET NETCostInTrade = '1'
	WHERE ltrim(NETCost) ='NO'
	
	UPDATE TempCertOrigen
	SET NETCostInTrade = '0'
	WHERE ltrim(NETCost) ='NC'

	UPDATE TempCertOrigen
	SET MexicoTariff = replace(MexicoTariff,'.','')
	WHERE MexicoTariff<>''

	UPDATE TempCertOrigen
	SET USTariff = replace(USTariff,'.','')
	WHERE USTariff<>''

	UPDATE TempCertOrigen
	SET CanadaTariff = replace(CanadaTariff,'.','')
	WHERE CanadaTariff<>''
	

	
	UPDATE TempCertOrigen
	SET MexicoTariff = NULL
	WHERE MexicoTariff=''
	
	UPDATE TempCertOrigen
	SET USTariff = NULL
	WHERE USTariff=''
	
	UPDATE TempCertOrigen
	SET CanadaTariff = NULL
	WHERE CanadaTariff=''
	

	UPDATE TempCertOrigen
	SET     TempCertOrigen.SuppliernameInTrade= CONFIGURAPROVEETempCertOrigen.CL_CODIGO
	FROM         TempCertOrigen INNER JOIN
	                      CONFIGURAPROVEETempCertOrigen ON TempCertOrigen.Suppliername = CONFIGURAPROVEETempCertOrigen.CFP_PROVEEDORARCHIVO	


	 SELECT @CL_MATRIZ=CL_MATRIZ, @CL_TRAFICO=CL_TRAFICO, 
	             @DIRPRINC=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_CODIGO),
	             @DIRMATRIZ=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_MATRIZ)
	 FROM CLIENTE    WHERE CL_EMPRESA='S'


	UPDATE TempCertOrigen
	set SuppliernameInTrade	= @CL_MATRIZ
	where SuppliernameInTrade=''

	Declare Cur_CertOrig cursor for
		SELECT     BlanketPeriod
		FROM         TempCertOrigen
		WHERE     (DateComplete IS NOT NULL) AND (CountryOrigin = 'US' OR CountryOrigin = 'MX' OR CountryOrigin = 'CA')
		GROUP BY BlanketPeriod
	Open Cur_CertOrig
	Fetch Next from Cur_CertOrig into @BlanketPeriod
	While (@@fetch_status =0 )
	begin

		if not exists (select CMP_FOLIO from CERTORIGMP where CMP_FOLIO=@BlanketPeriod)
		begin
			 EXEC SP_GETCONSECUTIVO @TIPO='CMP', @VALUE=@CONSECUTIVO OUTPUT
	
			INSERT INTO CERTORIGMP(CMP_CODIGO, CMP_IFECHA, CMP_VFECHA, PR_CODIGO, DI_PROD, CL_IMP, DI_IMP, SPI_CODIGO, CMP_TIPO, CMP_FOLIO, CMP_FECHA, CL_EXP, 
			                      DI_EXP, CMP_FECHATRANS)
			
			SELECT      @CONSECUTIVO, '01/01/'+BlanketPeriod, '12/31/'+BlanketPeriod, @CL_MATRIZ, @DIRMATRIZ, @CL_TRAFICO, @DIRPRINC, (SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='NAFTA'),
			'M', BlanketPeriod, convert(varchar(10), getdate(),101), @CL_MATRIZ, @DIRMATRIZ, '12/31/'+BlanketPeriod
			FROM         TempCertOrigen
			WHERE     (DateComplete IS NOT NULL) AND (CountryOrigin = 'US' OR CountryOrigin = 'MX' OR CountryOrigin = 'CA')
				AND BlanketPeriod not in (select CMP_FOLIO from CERTORIGMP) AND BlanketPeriod=@BlanketPeriod
			GROUP BY BlanketPeriod

		end

		select @CMP_CODIGO=CMP_CODIGO from CERTORIGMP where CMP_FOLIO=@BlanketPeriod


		INSERT INTO CERTORIGMPDET(CMP_CODIGO, MA_CODIGO, CMP_CLASE, CMP_FABRICA, CMP_CRITERIO, CMP_NETCOST, 
		                      CMP_OTRASINST, CMP_FRACCION, CMP_FRACCIONALT, PR_CODIGO, CMP_DESCRIP, CMP_NOPARTE, CMP_NOPARTEAUX)
		SELECT     @CMP_CODIGO, dbo.MAESTRO.MA_CODIGO, (SELECT PA_CODIGO FROM PAIS WHERE PA_ISO= dbo.TempCertOrigen.CountryOrigin),
			isnull(convert(smallint,dbo.TempCertOrigen.ProducerInTrade),0), isnull(convert(smallint,dbo.TempCertOrigen.PrefCriterionInTrade),0), 
			isnull(convert(smallint,dbo.TempCertOrigen.NETCostInTrade),0), 5, isnull(ISNULL(ISNULL(MexicoTariff, USTariff), CanadaTariff),''), '', 
			isnull(dbo.TempCertOrigen.SuppliernameInTrade, 0), dbo.TempCertOrigen.Descripcion, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX
		FROM         dbo.TempCertOrigen INNER JOIN
		                      dbo.MAESTRO ON  rtrim(replace(replace(replace(dbo.TempCertOrigen.NoCatalogo,'-',''),'\',''),'/','')) = replace(replace(replace(dbo.MAESTRO.MA_NOPARTE,'-',''),'\',''),'/','')
		WHERE     (dbo.TempCertOrigen.DateComplete IS NOT NULL) AND (dbo.TempCertOrigen.CountryOrigin = 'US' OR
		                      dbo.TempCertOrigen.CountryOrigin = 'MX' OR
		                      dbo.TempCertOrigen.CountryOrigin = 'CA') AND (dbo.TempCertOrigen.BlanketPeriod = @BlanketPeriod)
			AND dbo.MAESTRO.MA_CODIGO not in (select MA_CODIGO from CERTORIGMPDET where CMP_CODIGO=@CMP_CODIGO)
		GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.TempCertOrigen.CountryOrigin, dbo.TempCertOrigen.ProducerInTrade, dbo.TempCertOrigen.PrefCriterionInTrade, dbo.TempCertOrigen.NETCostInTrade,
		ISNULL(ISNULL(ISNULL(MexicoTariff, USTariff), CanadaTariff),''), dbo.TempCertOrigen.SuppliernameInTrade, dbo.TempCertOrigen.Descripcion, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX


		
	Fetch Next from Cur_CertOrig into @BlanketPeriod
	end

        Close Cur_CertOrig
        Deallocate Cur_CertOrig


	DELETE FROM CERTORIGMP  where CMP_FOLIO in (SELECT     BlanketPeriod
		FROM         TempCertOrigen
		WHERE     (DateComplete IS NOT NULL) AND (CountryOrigin = 'US' OR CountryOrigin = 'MX' OR CountryOrigin = 'CA')
		GROUP BY BlanketPeriod)
	and CMP_CODIGO not in (select CMP_CODIGO from CERTORIGMPDET group by CMP_CODIGO)



	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
	SELECT      'EL NO. DE PARTE : '+ rtrim(replace(replace(replace(dbo.TempCertOrigen.NoCatalogo,'-',''),'\',''),'/',''))+' NO ESTA DADO DE ALTA EN EL CATALOGO MAESTRO', -124
	FROM         dbo.TempCertOrigen LEFT OUTER JOIN
	                      dbo.MAESTRO ON  rtrim(replace(replace(replace(dbo.TempCertOrigen.NoCatalogo,'-',''),'\',''),'/','')) = replace(replace(replace(dbo.MAESTRO.MA_NOPARTE,'-',''),'\',''),'/','')
	WHERE     (dbo.TempCertOrigen.DateComplete IS NOT NULL) AND (dbo.TempCertOrigen.CountryOrigin = 'US' OR
	                      dbo.TempCertOrigen.CountryOrigin = 'MX' OR
	                      dbo.TempCertOrigen.CountryOrigin = 'CA') 
	GROUP BY dbo.TempCertOrigen.NoCatalogo
	
	


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
	SELECT      'EL NO. DE PARTE : '+MAESTRO.MA_NOPARTE+' TIENE ASIGNADO OTRO PAIS DE ORIGEN, INTRADE: '+PAIS.PA_ISO+
	' ARCHIVO: '+TempCertOrigen.CountryOrigin, -124
	FROM         TempCertOrigen INNER JOIN
	                      MAESTRO ON REPLACE(REPLACE(REPLACE(TempCertOrigen.NoCatalogo, '-', ''), '\', ''), '/', '') = REPLACE(REPLACE(REPLACE(MAESTRO.MA_NOPARTE, 
	                      '-', ''), '\', ''), '/', '') INNER JOIN
	                      PAIS ON MAESTRO.PA_ORIGEN = PAIS.PA_CODIGO AND TempCertOrigen.CountryOrigin <> PAIS.PA_ISO


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
	SELECT      'EL NO. DE PARTE : '+MAESTRO.MA_NOPARTE+' EL UN REGISTRO NO ORIGINARIO, PAIS ORIGEN: '+TempCertOrigen.CountryOrigin, -124
	FROM         TempCertOrigen INNER JOIN
	                      MAESTRO ON REPLACE(REPLACE(REPLACE(TempCertOrigen.NoCatalogo, '-', ''), '\', ''), '/', '') = REPLACE(REPLACE(REPLACE(MAESTRO.MA_NOPARTE, 
	                      '-', ''), '\', ''), '/', '') 
	WHERE TempCertOrigen.CountryOrigin NOT IN ('US', 'MX', 'CA')


	UPDATE MAESTRO
	SET     MAESTRO.PA_ORIGEN= PAIS.PA_CODIGO
	FROM         TempCertOrigen INNER JOIN
	                      PAIS ON TempCertOrigen.CountryOrigin = PAIS.PA_ISO INNER JOIN
	                      MAESTRO ON TempCertOrigen.NoCatalogo = MAESTRO.MA_NOPARTE
	WHERE TempCertOrigen.CountryOrigin NOT IN ('US', 'MX', 'CA')



	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
	SELECT      'EL NO. DE PARTE : '+MAESTRO.MA_NOPARTE+' TIENE ASIGNADA OTRA F. ARANCELARIA ', -124
	FROM         TempCertOrigen INNER JOIN
	                      MAESTRO ON REPLACE(REPLACE(REPLACE(TempCertOrigen.NoCatalogo, '-', ''), '\', ''), '/', '') = REPLACE(REPLACE(REPLACE(MAESTRO.MA_NOPARTE, 
	                      '-', ''), '\', ''), '/', '') INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO AND LEFT(ISNULL(ISNULL(TempCertOrigen.MexicoTariff, TempCertOrigen.USTariff), 
	                      TempCertOrigen.CanadaTariff), 6) <> LEFT(REPLACE(ARANCEL.AR_FRACCION, '.', ''), 6)


GO
