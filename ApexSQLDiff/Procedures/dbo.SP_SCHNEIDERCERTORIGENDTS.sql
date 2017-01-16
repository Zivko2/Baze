SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_SCHNEIDERCERTORIGENDTS]   as

DECLARE @ANIO VARCHAR(5), @CL_MATRIZ INT, @CL_TRAFICO INT, @DIRPRINC INT, @DIRMATRIZ INT, @CONSECUTIVO INT


SELECT @ANIO=CONVERT(VARCHAR(5),YEAR(GETDATE()))

         SELECT @CL_MATRIZ=CL_MATRIZ, @CL_TRAFICO=CL_TRAFICO, 
 		@DIRPRINC=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_CODIGO),
		@DIRMATRIZ=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_MATRIZ)
	 FROM CLIENTE
	 WHERE CL_EMPRESA='S'


-- materias primas
if exists(select * from temp_certDTS where TIPO = 'MP')
begin
	DELETE FROM CERTORIGMP WHERE CMP_FOLIO='MP'+@ANIO

	 EXEC SP_GETCONSECUTIVO @TIPO='CMP', @VALUE=@CONSECUTIVO OUTPUT

	INSERT INTO CERTORIGMP(CMP_CODIGO, CMP_IFECHA, CMP_VFECHA, PR_CODIGO, DI_PROD, CL_IMP, DI_IMP, SPI_CODIGO, CMP_TIPO, CMP_FOLIO, CMP_FECHA, CL_EXP, 
	                      DI_EXP, CMP_FECHATRANS)
	SELECT @CONSECUTIVO, '01/01/'+@ANIO, '12/31/'+@ANIO, @CL_MATRIZ, @DIRMATRIZ, @CL_TRAFICO, @DIRPRINC, 22, 'M', 'MP'+@ANIO, '01/01/'+@ANIO, @CL_MATRIZ, @DIRMATRIZ,
	'12/31/'+@ANIO
	
	
	INSERT INTO CERTORIGMPDET(CMP_CODIGO, MA_CODIGO, CMP_DESCRIP, CMP_FRACCION, PA_CLASE, CMP_CRITERIO, CMP_FABRICA, CMP_NETCOST, CMP_NOPARTE, CMP_NOPARTEAUX)
	SELECT    @CONSECUTIVO, MAESTRO.MA_CODIGO, UPPER(max(temp_certDTS.Description)), max(REPLACE(temp_certDTS.HTS_Number, '.', '')), PAIS.PA_CODIGO,
	                          (SELECT     CB_KEYFIELD
	                            FROM          COMBOBOXES
	                            WHERE      CB_TABLA = 209 AND CB_FIELD = 'CMP_CRITERIO' AND CB_LOOKUPENG = max(Preference_Criterion)) AS CMP_CRITERIO,
	                          (SELECT     CB_KEYFIELD
	                            FROM          COMBOBOXES
	                            WHERE      CB_TABLA = 209 AND CB_FIELD = 'CMP_FABRICA' AND 
	                                                   CB_LOOKUPENG = max(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Producer, 'NO1', 'NO (1)'), 'NO-1', 'NO (1)'), 'NO2', 
	                                                   'NO (2)'), 'NO-2', 'NO (2)'), 'NO3', 'NO (3)'), 'NO-3', 'NO (3)'))) AS CMP_FABRICA,
	                          (SELECT     CB_KEYFIELD
	                            FROM          COMBOBOXES
	                            WHERE      CB_TABLA = 209 AND CB_FIELD = 'CMP_NETCOST' AND CB_LOOKUPENG = max(REPLACE(REPLACE(Net_Cost, 'NO', 'NON APPLICABLE'), 
	                                                   'NC', 'NET COST'))) AS CMP_NETCOST, MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX
	FROM         temp_certDTS INNER JOIN
	                      MAESTRO ON rtrim(ltrim(temp_certDTS.Catalog_Number)) = rtrim(ltrim(replace(MAESTRO.MA_NOPARTE,'-',''))) LEFT OUTER JOIN
	                      PAIS ON temp_certDTS.Country_Main = PAIS.PA_ISO
	WHERE     (temp_certDTS.TIPO = 'MP')
	GROUP BY MAESTRO.MA_CODIGO, PAIS.PA_CODIGO, MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX
end



-- productos terminados
if exists(select * from temp_certDTS where TIPO = 'PT')
begin
		DELETE FROM CERTORIGMP WHERE CMP_FOLIO='PT'+@ANIO
		
			 EXEC SP_GETCONSECUTIVO @TIPO='CMP', @VALUE=@CONSECUTIVO OUTPUT
		
		INSERT INTO CERTORIGMP(CMP_CODIGO, CMP_IFECHA, CMP_VFECHA, PR_CODIGO, DI_PROD, CL_IMP, DI_IMP, SPI_CODIGO, CMP_TIPO, CMP_FOLIO, CMP_FECHA, CL_EXP, 
		                      DI_EXP, CMP_FECHATRANS)
		SELECT @CONSECUTIVO, '01/01/'+@ANIO, '12/31/'+@ANIO, @CL_TRAFICO, @DIRPRINC, @CL_MATRIZ, @DIRMATRIZ, 22, 'P', 'PT'+@ANIO, '01/01/'+@ANIO, @CL_TRAFICO, @DIRPRINC,
		'12/31/'+@ANIO
		
		
		
		INSERT INTO CERTORIGMPDET(CMP_CODIGO, MA_CODIGO, CMP_DESCRIP, CMP_FRACCION, PA_CLASE, CMP_CRITERIO, CMP_FABRICA, CMP_NETCOST, CMP_NOPARTE, CMP_NOPARTEAUX)
		SELECT    @CONSECUTIVO, MAESTRO.MA_CODIGO, UPPER(max(temp_certDTS.Description)), max(REPLACE(temp_certDTS.HTS_Number, '.', '')), PAIS.PA_CODIGO,
		                          (SELECT     CB_KEYFIELD
		                            FROM          COMBOBOXES
		                            WHERE      CB_TABLA = 209 AND CB_FIELD = 'CMP_CRITERIO' AND CB_LOOKUPENG = max(Preference_Criterion)) AS CMP_CRITERIO,
		                          (SELECT     CB_KEYFIELD
		                            FROM          COMBOBOXES
		                            WHERE      CB_TABLA = 209 AND CB_FIELD = 'CMP_FABRICA' AND 
		                                                   CB_LOOKUPENG = max(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Producer, 'NO1', 'NO (1)'), 'NO-1', 'NO (1)'), 'NO2', 
		                                                   'NO (2)'), 'NO-2', 'NO (2)'), 'NO3', 'NO (3)'), 'NO-3', 'NO (3)'))) AS CMP_FABRICA,
		                          (SELECT     CB_KEYFIELD
		                            FROM          COMBOBOXES
		                            WHERE      CB_TABLA = 209 AND CB_FIELD = 'CMP_NETCOST' AND CB_LOOKUPENG = max(REPLACE(REPLACE(Net_Cost, 'NO', 'NON APPLICABLE'), 
		                                                   'NC', 'NET COST'))) AS CMP_NETCOST, MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX
		FROM         temp_certDTS INNER JOIN
		                      MAESTRO ON rtrim(ltrim(temp_certDTS.Catalog_Number)) = rtrim(ltrim(replace(MAESTRO.MA_NOPARTE,'-',''))) LEFT OUTER JOIN
		                      PAIS ON temp_certDTS.Country_Main = PAIS.PA_ISO
		WHERE     (temp_certDTS.TIPO = 'PT')
		GROUP BY MAESTRO.MA_CODIGO, PAIS.PA_CODIGO, MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX
		


		exec Sp_GeneraTablaTemp 'NAFTA'


		INSERT INTO TempImportNAFTA(MA_CODIGO,SPI_CODIGO, PA_CLASE, NFT_CRITERIO, NFT_FABRICA, NFT_PERINI, NFT_PERFIN, NFT_NETCOST,
		NFT_CALIFICO, NFT_NOPARTE, NFT_NOPARTEAUX)
		SELECT    MAESTRO.MA_CODIGO, 22, PAIS.PA_CODIGO, (SELECT CB_KEYFIELD FROM COMBOBOXES WHERE CB_TABLA = 41 AND CB_FIELD = 'NFT_CRITERIO' AND CB_LOOKUPENG = max(Preference_Criterion)) AS CMP_CRITERIO,
		                        (SELECT CB_KEYFIELD FROM COMBOBOXES WHERE CB_TABLA = 41 AND CB_FIELD = 'NFT_FABRICA' AND 
		                        CB_LOOKUPENG = max(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Producer, 'NO1', 'NO (1)'), 'NO-1', 'NO (1)'), 'NO2', 
		                        'NO (2)'), 'NO-2', 'NO (2)'), 'NO3', 'NO (3)'), 'NO-3', 'NO (3)'))) AS CMP_FABRICA,
					'01/01/'+@ANIO, '12/31/'+@ANIO, (SELECT CB_KEYFIELD FROM COMBOBOXES
		                        WHERE CB_TABLA = 41 AND CB_FIELD = 'NFT_NETCOST' AND CB_LOOKUPENG = max(REPLACE(REPLACE(Net_Cost, 'NO', 'NON APPLICABLE'), 
		                        'NC', 'NET COST'))) AS CMP_NETCOST, 'S', MA_NOPARTE, MA_NOPARTEAUX
		FROM         temp_certDTS INNER JOIN
		                      MAESTRO ON rtrim(ltrim(temp_certDTS.Catalog_Number)) = rtrim(ltrim(replace(MAESTRO.MA_NOPARTE,'-',''))) LEFT OUTER JOIN
		                      PAIS ON temp_certDTS.Country_Main = PAIS.PA_ISO
		WHERE     (temp_certDTS.TIPO = 'PT') AND MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM NAFTA WHERE SPI_CODIGO=22 AND NFT_PERINI='01/01/'+@ANIO AND NFT_PERFIN='12/31/'+@ANIO)
		GROUP BY MAESTRO.MA_CODIGO, PAIS.PA_CODIGO, MA_NOPARTE, MA_NOPARTEAUX


		INSERT INTO NAFTA(NFT_CODIGO,MA_CODIGO,SPI_CODIGO ,PA_CLASE ,NFT_CRITERIO ,NFT_FABRICA ,NFT_PERINI ,NFT_PERFIN ,NFT_NETCOST ,
		NFT_OTRASINST, NFT_CALIFICO, NFT_NOPARTE, NFT_NOPARTEAUX)
		SELECT NFT_CODIGO,MA_CODIGO,SPI_CODIGO ,PA_CLASE ,NFT_CRITERIO ,NFT_FABRICA ,NFT_PERINI ,NFT_PERFIN ,NFT_NETCOST ,
		NFT_OTRASINST, NFT_CALIFICO, NFT_NOPARTE, NFT_NOPARTEAUX
		FROM TempImportNAFTA


		update consecutivo
		set cv_codigo =  isnull((select max(NFT_CODIGO) from NAFTA),0) + 1
		where cv_tipo = 'NFT'


end
	--actualiza la fraccion que tiene menos de 6 digitos
	UPDATE CERTORIGMPDET
	SET     CERTORIGMPDET.CMP_FRACCION= LEFT(ARANCEL.AR_FRACCION, 6) 
	FROM         CERTORIGMPDET INNER JOIN
	                      MAESTRO ON CERTORIGMPDET.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO AND LEFT(CERTORIGMPDET.CMP_FRACCION, 5) = LEFT(ARANCEL.AR_FRACCION, 5)
	WHERE     (LEN(CERTORIGMPDET.CMP_FRACCION) < 6)



	EXEC SP_ACTUALIZATASABAJAMA

GO
