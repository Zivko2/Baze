SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[SP_TempCertOrigen]   as

SET NOCOUNT ON 

	-- borra los numeros de parte que no se encuentran en intrade
         /*     DELETE TempCertOrigen FROM TempCertOrigen LEFT OUTER JOIN 
              MAESTRO ON REPLACE(REPLACE(REPLACE(TempCertOrigen.NoCatalogo, '-', ''), '/', ''), '\', '') = REPLACE(REPLACE(REPLACE(MAESTRO.MA_NOPARTE,'-', ''), '/', ''), '\', '') 
              WHERE MAESTRO.MA_NOPARTE IS NULL */


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'EL NO. PARTE : '+NoCatalogo+' NO ES NAFTA', -124
	FROM         TempCertOrigen
	WHERE     (CountryOrigin <> 'US' AND CountryOrigin <> 'MX' AND CountryOrigin <> 'CA')


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'EL NO. PARTE : '+TempCertOrigen.NoCatalogo+' tiene asignada fraccion arancelaria diferente, Cat. Maestro: '+ LEFT(REPLACE(ARANCEL.AR_FRACCION, '.', ''), 6) +', Cert. Origen: '+ REPLACE(TempCertOrigen.MexicoTariff, '.', ''), -124 
	FROM         TempCertOrigen INNER JOIN
	                      MAESTRO ON REPLACE(REPLACE(REPLACE(TempCertOrigen.NoCatalogo, '-', ''), '\', ''), '/', '') = REPLACE(REPLACE(REPLACE(MAESTRO.MA_NOPARTE, 
	                      '-', ''), '\', ''), '/', '') INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
	WHERE     (TempCertOrigen.CountryOrigin = 'US' OR TempCertOrigen.CountryOrigin = 'MX' OR TempCertOrigen.CountryOrigin = 'CA') and
	LEFT(REPLACE(ARANCEL.AR_FRACCION, '.', ''), 6) <> REPLACE(TempCertOrigen.MexicoTariff, '.', '') 



	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'EL NO. PARTE : '+TempCertOrigen.NoCatalogo+' tiene asignado pais de origen diferente, Cat. Maestro: '+ PAIS.PA_ISO +', Cert. Origen: '+ TempCertOrigen.CountryOrigin, -124 
	FROM         TempCertOrigen INNER JOIN
	                      MAESTRO ON REPLACE(REPLACE(REPLACE(TempCertOrigen.NoCatalogo, '-', ''), '\', ''), '/', '') = REPLACE(REPLACE(REPLACE(MAESTRO.MA_NOPARTE, 
	                      '-', ''), '\', ''), '/', '') INNER JOIN
	                      PAIS ON MAESTRO.PA_ORIGEN = PAIS.PA_CODIGO
	WHERE     (TempCertOrigen.CountryOrigin = 'US' OR TempCertOrigen.CountryOrigin = 'MX' OR TempCertOrigen.CountryOrigin = 'CA') AND
	PAIS.PA_ISO <> TempCertOrigen.CountryOrigin











GO
