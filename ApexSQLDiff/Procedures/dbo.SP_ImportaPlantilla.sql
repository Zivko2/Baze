SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ImportaPlantilla]   as


declare @PXP_PLANTILLA varchar(100), @platilla varchar(100), @Consecutivo int

set @platilla=(SELECT PXP_PLANTILLA FROM TempPlantillaExp)

-- insercion de la tabla PlantillaExp


	if exists (select * from PlantillaExp where PXP_PLANTILLA=@platilla)
	begin
		if exists (select * from PlantillaExp where PXP_PLANTILLA like @platilla+'_%' and PXP_PLANTILLA not like @platilla+' _%')
		begin
	               SET @PXP_PLANTILLA= @platilla+'_'+convert(varchar(50),(SELECT max(REPLACE(RIGHT(PXP_PLANTILLA, 2), '_', ''))+1  FROM PlantillaExp where PXP_PLANTILLA like @platilla+'_%' and PXP_PLANTILLA not like @platilla+' _%'))
		end
		else
		       SET @PXP_PLANTILLA= @platilla+'_1'
	end
	else
	begin
		SET @PXP_PLANTILLA= @platilla
	
	end



	select @Consecutivo=IsNull(max(pxp_codigo),0)+1 from PlantillaExp

	INSERT INTO PlantillaExp(PXP_CODIGO, PXP_PLANTILLA, CR_CODIGO, IMT_CODIGO, PXP_FIJO_DELIM, PXP_TITULOS, PXP_SEPARACAMPO, PXP_OTROSEPARACAMPO, 
	                      PXP_TEXTQUAL, PXP_CHRRELLENO, PXP_ORDENFECHA, PXP_SEPARAFECHA, PXP_CUATROCIFRAS, PXP_MESCONLETRAS, PXP_SEPARAHORA, 
	                      PXP_SEPARADECIMAL, PXP_NOMBREARCHIVO, PXP_MULTFILE, PXP_TRANSKEYS, PXP_CONTENIDOTRIGGER, PXP_GENERATABLAS, 
				PXP_ORDENARCHIVOXSEC, PXP_NOMBRE_RPT, PXP_TABLA_RPT, PXP_CAMPO_RPT, PXP_CAMPONOMBRE_PDF)
	
	SELECT     @Consecutivo, @PXP_PLANTILLA, CR_CODIGO, IMT_CODIGO, PXP_FIJO_DELIM, PXP_TITULOS, PXP_SEPARACAMPO, ISNULL(PXP_OTROSEPARACAMPO,''), 
	                      PXP_TEXTQUAL, ISNULL(PXP_CHRRELLENO,' '), PXP_ORDENFECHA, PXP_SEPARAFECHA, PXP_CUATROCIFRAS, PXP_MESCONLETRAS, PXP_SEPARAHORA, 
	                      PXP_SEPARADECIMAL, replace(PXP_NOMBREARCHIVO,'~',CHAR(13)+CHAR(10)), PXP_MULTFILE, PXP_TRANSKEYS, PXP_CONTENIDOTRIGGER, PXP_GENERATABLAS, 
			PXP_ORDENARCHIVOXSEC, PXP_NOMBRE_RPT, PXP_TABLA_RPT, PXP_CAMPO_RPT, PXP_CAMPONOMBRE_PDF 
	FROM         TempPlantillaExp


	


--insercion en la tabla PlntExpDet
	delete from PlntExpDet where PXP_CODIGO =@Consecutivo

	INSERT INTO PlntExpDet(PXP_CODIGO, PXT_TBLNAME, PXT_SELECTED)
	SELECT     @Consecutivo, PXT_TBLNAME, PXT_SELECTED
	FROM         TempPlntExpDet



--insercion en la tabla PlntExpSecc
	delete from PlntExpSecc where pxp_codigo =@Consecutivo

	INSERT INTO PlntExpSecc(PXS_CODIGO, PXP_CODIGO, PXS_SECCION, PXS_ORDENSECCION, PXS_AGRUPACION, PXS_QUERY, PXS_PARAMTEXT,PXS_PARAMTEXT2, PXS_FILTRO, 
              PXS_ESPRINCIPAL, PXS_PADRE, PXS_FILTROFORMULA, PXS_OMITIRSININFO,PXS_REPETIRSECCION, PXS_OMITIRTRANSSININFO, PXS_QUERYORDERBY)

	SELECT PXS_CODIGONVO, @Consecutivo, PXS_SECCION, PXS_ORDENSECCION, PXS_AGRUPACION, PXS_QUERY, ISNULL(replace(PXS_PARAMTEXT,'~',CHAR(13)+CHAR(10)),''), ISNULL(replace(PXS_PARAMTEXT2,'~',CHAR(13)+CHAR(10)),''), IsNull(replace(PXS_FILTRO,'~',CHAR(13)+CHAR(10)),''),
              ISNULL(PXS_ESPRINCIPAL,'N'), isnull((SELECT TempPlntExpSecc1.PXS_CODIGONVO FROM TempPlntExpSecc as TempPlntExpSecc1 WHERE TempPlntExpSecc1.PXS_CODIGO=TempPlntExpSecc.PXS_PADRE),0), IsNull(replace(PXS_FILTROFORMULA,'~',CHAR(13)+CHAR(10)),''), ISNULL(PXS_OMITIRSININFO,'N'), ISNULL(PXS_REPETIRSECCION,'N'),
	isnull(PXS_OMITIRTRANSSININFO,'N'), PXS_QUERYORDERBY

	FROM TempPlntExpSecc




	EXEC SP_CAMBIAFILTROFORMULA

	
--insercion en la tabla busquedamascara
if exists (select * from tempbusquedamascara where BUM_TEXTOMOSTRAR not in (select BUM_TEXTOMOSTRAR from busquedamascara))
begin
	INSERT INTO BUSQUEDAMASCARA( BUM_TEXTOMOSTRAR, BUM_TIPO, BUM_DECIMAL, BUM_REDONDEO, BUM_SEPARAMIL, 
	                      BUM_SIMADICIONA, BUM_SIMPOSICION, BUM_NEGATIVO, BUM_DATEORDER, BUM_MESFORMAT, BUM_DIAFORMAT, 
	                      BUM_ANIOFORMAT, BUM_DATESEPARA, BUM_MASCARATEXT)
	
	SELECT     dbo.TempBUSQUEDAMASCARA.BUM_TEXTOMOSTRAR, dbo.TempBUSQUEDAMASCARA.BUM_TIPO, 
	                      dbo.TempBUSQUEDAMASCARA.BUM_DECIMAL, dbo.TempBUSQUEDAMASCARA.BUM_REDONDEO, dbo.TempBUSQUEDAMASCARA.BUM_SEPARAMIL, 
	                      dbo.TempBUSQUEDAMASCARA.BUM_SIMADICIONA, dbo.TempBUSQUEDAMASCARA.BUM_SIMPOSICION, 
	                      dbo.TempBUSQUEDAMASCARA.BUM_NEGATIVO, dbo.TempBUSQUEDAMASCARA.BUM_DATEORDER, 
	                      dbo.TempBUSQUEDAMASCARA.BUM_MESFORMAT, dbo.TempBUSQUEDAMASCARA.BUM_DIAFORMAT, 
	                      dbo.TempBUSQUEDAMASCARA.BUM_ANIOFORMAT, dbo.TempBUSQUEDAMASCARA.BUM_DATESEPARA, 
	                      dbo.TempBUSQUEDAMASCARA.BUM_MASCARATEXT
	FROM         dbo.TempBUSQUEDAMASCARA LEFT OUTER JOIN
	                      dbo.BUSQUEDAMASCARA ON dbo.TempBUSQUEDAMASCARA.BUM_TEXTOMOSTRAR = dbo.BUSQUEDAMASCARA.BUM_TEXTOMOSTRAR
	WHERE     (dbo.BUSQUEDAMASCARA.BUM_TEXTOMOSTRAR IS NULL)

end

UPDATE dbo.TempPlntExpFormula
SET     dbo.TempPlntExpFormula.BUM_CODIGO= dbo.BUSQUEDAMASCARA.BUM_CODIGO
FROM         dbo.TempBUSQUEDAMASCARA INNER JOIN
                      dbo.BUSQUEDAMASCARA ON dbo.TempBUSQUEDAMASCARA.BUM_TEXTOMOSTRAR = dbo.BUSQUEDAMASCARA.BUM_TEXTOMOSTRAR INNER JOIN
                      dbo.TempPlntExpFormula ON dbo.TempBUSQUEDAMASCARA.BUM_CODIGO = dbo.TempPlntExpFormula.BUM_CODIGO


--insercion en la tabla PlntExpFormula
	delete from PlntExpFormula where pxs_codigo in (select PXS_CODIGONVO from TempPlntExpSecc)

	INSERT INTO PlntExpFormula(PXF_CODIGO, PXS_CODIGO, PXF_FORMULANAME, PXF_FORMULASTRING, 
			PXF_DATATYPE, PXF_VERIFICADA, BUM_CODIGO)
	
	SELECT     TempPlntExpFormula.PXF_CODIGONVO, TempPlntExpSecc.PXS_CODIGONVO, TempPlntExpFormula.PXF_FORMULANAME, 
	                      replace(TempPlntExpFormula.PXF_FORMULASTRING,'~',CHAR(13)+CHAR(10)), TempPlntExpFormula.PXF_DATATYPE, TempPlntExpFormula.PXF_VERIFICADA, 
	                      TempPlntExpFormula.BUM_CODIGO
	FROM         TempPlntExpFormula INNER JOIN
	                      TempPlntExpSecc ON TempPlntExpFormula.PXS_CODIGO = TempPlntExpSecc.PXS_CODIGO





--insercion en la tabla PlntExpSeccDet
	delete from PlntExpSeccDet where pxs_codigo in (select PXS_CODIGONVO from TempPlntExpSecc)

	INSERT INTO PlntExpSeccDet (PXD_CODIGO, PXS_CODIGO, PXD_MOSTRAR, PXD_TIPOCOL, PXD_TABLA, IMF_CODIGO, PXF_CODIGO, PXD_DETALLE, PXD_OBLIGATORIO, 
	                      PXD_SIZE, PXD_AGRUPACION, PXD_CASONULO, PXD_VALOROMISION, PXD_ORDENCOL, PXD_PROCSOLO, PXD_IDENTSECCION, PXD_ININEWROW,PXD_ACUMULATOTALES, PXD_QUERY)
	
	SELECT     dbo.TempPlntExpSeccDet.PXD_CODIGONVO, dbo.TempPlntExpSecc.PXS_CODIGONVO, dbo.TempPlntExpSeccDet.PXD_MOSTRAR, 
	                      dbo.TempPlntExpSeccDet.PXD_TIPOCOL, isnull(dbo.TempPlntExpSeccDet.PXD_TABLA,''), dbo.TempPlntExpSeccDet.IMF_CODIGO, 
	                      dbo.TempPlntExpFormula.PXF_CODIGONVO, dbo.TempPlntExpSeccDet.PXD_DETALLE, dbo.TempPlntExpSeccDet.PXD_OBLIGATORIO, 
	                      dbo.TempPlntExpSeccDet.PXD_SIZE, dbo.TempPlntExpSeccDet.PXD_AGRUPACION, dbo.TempPlntExpSeccDet.PXD_CASONULO, 
	                      dbo.TempPlntExpSeccDet.PXD_VALOROMISION, dbo.TempPlntExpSeccDet.PXD_ORDENCOL, dbo.TempPlntExpSeccDet.PXD_PROCSOLO,
		        dbo.TempPlntExpSeccDet.PXD_IDENTSECCION, dbo.TempPlntExpSeccDet.PXD_ININEWROW,dbo.TempPlntExpSeccDet.PXD_ACUMULATOTALES,
		        dbo.TempPlntExpSeccDet.PXD_QUERY
	FROM         dbo.TempPlntExpSeccDet INNER JOIN
	                      dbo.TempPlntExpSecc ON dbo.TempPlntExpSeccDet.PXS_CODIGO = dbo.TempPlntExpSecc.PXS_CODIGO INNER JOIN
	                      dbo.TempPlntExpFormula ON dbo.TempPlntExpSeccDet.PXF_CODIGO = dbo.TempPlntExpFormula.PXF_CODIGO

--insercion en la tabla PlntExpSeccFiltro
	delete from PlntExpSeccFiltro where pxs_codigo in (select PXS_CODIGONVO from TempPlntExpSecc)

	INSERT INTO PlntExpSeccFiltro(PXSF_CODIGO, PXS_CODIGO, PXSF_CAMPO1, PXSF_CAMPO2, PXSF_OPERADOR, PXSF_IGUAL, PXSF_MIN,
		 PXSF_MAX, PXSF_NULL)
	
	SELECT     TempPlntExpSeccFiltro.PXSF_CODIGONVO, TempPlntExpSecc.PXS_CODIGONVO, TempPlntExpSeccFiltro.PXSF_CAMPO1, 
	                      TempPlntExpSeccFiltro.PXSF_CAMPO2, TempPlntExpSeccFiltro.PXSF_OPERADOR, TempPlntExpSeccFiltro.PXSF_IGUAL, 
	                      TempPlntExpSeccFiltro.PXSF_MIN, TempPlntExpSeccFiltro.PXSF_MAX, TempPlntExpSeccFiltro.PXSF_NULL                
	FROM         TempPlntExpSeccFiltro INNER JOIN
	                      TempPlntExpSecc ON TempPlntExpSeccFiltro.PXS_CODIGO = TempPlntExpSecc.PXS_CODIGO

--insercion en la tabla PlntExpSeccFiltro_IN
	delete from PlntExpSeccFiltro_IN where PXSF_CODIGO in (select PXSF_CODIGONVO from TempPlntExpSeccFiltro)

	INSERT INTO PlntExpSeccFiltro_IN (PXSF_CODIGO, PXSF_ELEMENTO)
	
	SELECT     TempPlntExpSeccFiltro.PXSF_CODIGONVO, TempPlntExpSeccFiltro_IN.PXSF_ELEMENTO
	FROM         TempPlntExpSeccFiltro_IN INNER JOIN
	                      TempPlntExpSeccFiltro ON TempPlntExpSeccFiltro_IN.PXSF_CODIGO = TempPlntExpSeccFiltro.PXSF_CODIGO

--insercion en la tabla PlntExpSeccPrm
	delete from PlntExpSeccPrm where pxs_codigo in (select PXS_CODIGONVO from TempPlntExpSecc)

	INSERT INTO PlntExpSeccPrm (PXM_CODIGO, PXS_CODIGO, PXM_ORDEN, IMF_CODIGO, PXM_LABELPARAMETRO, PXM_OPERADOR, PXM_DISPLAYFIELDS, 
	                      PXM_TIPOPARAM,PXM_PROCSOLO)
	
	SELECT     TempPlntExpSeccPrm.PXM_CODIGONVO, TempPlntExpSecc.PXS_CODIGONVO, TempPlntExpSeccPrm.PXM_ORDEN, TempPlntExpSeccPrm.IMF_CODIGO, 
	                      TempPlntExpSeccPrm.PXM_LABELPARAMETRO, TempPlntExpSeccPrm.PXM_OPERADOR, TempPlntExpSeccPrm.PXM_DISPLAYFIELDS, 
	                      TempPlntExpSeccPrm.PXM_TIPOPARAM,TempPlntExpSeccPrm.PXM_PROCSOLO
	FROM         TempPlntExpSeccPrm INNER JOIN
	                      TempPlntExpSecc ON TempPlntExpSeccPrm.PXS_CODIGO = TempPlntExpSecc.PXS_CODIGO

--insercion en la tabla PlntExpSeccFiltroFormula
	delete from PlntExpSeccFiltroFormula where pxs_codigo in (select PXS_CODIGONVO from TempPlntExpSecc)

	INSERT INTO PlntExpSeccFiltroFormula (PXFF_CODIGO, PXS_CODIGO, PXFF_FORMULA, PXFF_OPERADOR, PXFF_IGUAL, PXFF_MIN, PXFF_MAX, PXFF_NULL)
	SELECT     PXFF_CODIGONVO, PXS_CODIGONVO, PXFF_FORMULA, PXFF_OPERADOR, PXFF_IGUAL, PXFF_MIN, PXFF_MAX, PXFF_NULL
	FROM         TempPlntExpSeccFiltroFormula INNER JOIN
	                      TempPlntExpSecc ON TempPlntExpSeccFiltroFormula.PXS_CODIGO = TempPlntExpSecc.PXS_CODIGO

--insercion en la tabla PlntExpSeccFiltroFormula_IN
	delete from PlntExpSeccFiltroFormula_IN where pxff_codigo in (select PXFF_CODIGO from PlntExpSeccFiltroFormula where pxs_codigo in (select PXS_CODIGONVO from TempPlntExpSecc))

	INSERT INTO PlntExpSeccFiltroFormula_IN (PXFF_CODIGO, PXFF_ELEMENTO)
	SELECT     TempPlntExpSeccFiltroFormula.PXFF_CODIGONVO, TempPlntExpSeccFiltroFormula_IN.PXFF_ELEMENTO
	FROM         TempPlntExpSeccFiltroFormula_IN INNER JOIN
	                      TempPlntExpSeccFiltroFormula ON TempPlntExpSeccFiltroFormula_IN.PXFF_CODIGO = TempPlntExpSeccFiltroFormula.PXFF_CODIGO



exec sp_droptable 'TempPlantillaExp'
exec sp_droptable 'TempPlntExpSecc'
exec sp_droptable 'TempPlntExpDet'
exec sp_droptable 'TempBUSQUEDAMASCARA'
exec sp_droptable 'TempPlntExpFormula'
exec sp_droptable 'TempPlntExpSeccDet'
exec sp_droptable 'TempPlntExpSeccFiltro'
exec sp_droptable 'TempPlntExpSeccFiltro_IN'
exec sp_droptable 'TempPlntExpSeccPrm'
exec sp_droptable 'TempPlntExpSeccFiltroFormula'
exec sp_droptable 'TempPlntExpSeccFiltroFormula_IN'

---------------------------------- actualiza consecutivos -----------------------------------------
UPDATE CONSECUTIVO
SET     CV_CODIGO=isnull((select max(pxp_codigo)+1 from PlantillaExp),0)
WHERE     (CV_TIPO = 'PXP')


UPDATE CONSECUTIVO
SET     CV_CODIGO=isnull((select max(pxs_codigo)+1 from PlntExpSecc),0)
WHERE     (CV_TIPO = 'PXS')


UPDATE CONSECUTIVO
SET     CV_CODIGO=isnull((select max(pxf_codigo)+1 from PlntExpFormula),0)
WHERE     (CV_TIPO = 'PXF')


UPDATE CONSECUTIVO
SET     CV_CODIGO=isnull((select max(pxd_codigo)+1 from PlntExpSeccDet),0)
WHERE     (CV_TIPO = 'PXD')


UPDATE CONSECUTIVO
SET     CV_CODIGO=isnull((select max(pxsf_codigo)+1 from PlntExpSeccFiltro),0)
WHERE     (CV_TIPO = 'PXSF')

UPDATE CONSECUTIVO
SET     CV_CODIGO=isnull((select max(pxm_codigo)+1 from PlntExpSeccPrm),0)
WHERE     (CV_TIPO = 'PXM')


UPDATE CONSECUTIVO
SET     CV_CODIGO=isnull((select max(pxff_codigo)+1 from PlntExpSeccFiltroFormula),0)
WHERE     (CV_TIPO = 'PXFF')


exec SP_ACTUALIZACONSECUTIVO




GO
