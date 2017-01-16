SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



/* esta desviacion todavia no incluye el campo de tipo de sustitucion*/
CREATE PROCEDURE [dbo].[SP_ExplosionaDesviacionFed] (@Fed_indiced int, @ExplosionParaDescargar char(1)='S')   as

declare @fe_fecha datetime, @canttotal decimal(38,6), @dev_codigo decimal(38,6), @dev_saldo decimal(38,6), @TotalaDesc decimal(38,6), @ma_codigoNvo int, @CANTDESCTOT decimal(38,6),
@CANTDESC decimal(38,6), @CONSECUTIVO INT, @ma_noparteorig varchar(30), @DEV_TIPOSUST char(1)

select @fe_fecha= fe_fecha from factexp where fe_codigo 
in (select fe_codigo from factexpdet where fed_indiced= @Fed_indiced)

/*
CB_FIELD	CB_KEYFIELD	CB_LOOKUP
DEV_TIPOSUST	A	PADRE E HIJO EMPIEZA CON
DEV_TIPOSUST	H	HIJO EMPIEZA CON
DEV_TIPOSUST	I	NO. PARTES IGUALES
DEV_TIPOSUST	P	PADRE EMPIEZA CON
*/

-- por periodo partes iguales
UPDATE    BOM_DESCTEMP
SET     BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
FROM         DESVIACION INNER JOIN
              MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE = DESVIACION.MA_NOPARTEORIG INNER JOIN
              BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
              FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
              FACTEXPDET.FED_NOPARTE = DESVIACION.MA_NOPARTEPADRE
WHERE     (BOM_DESCTEMP.FED_INDICED = @Fed_indiced) AND (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND (DESVIACION.DEV_FECHAFIN >= @fe_fecha)
and DESVIACION.DEV_CANTIDAD = 0 and DESVIACION.DEV_HABILITADO='S'
and isnull(DESVIACION.MA_NOPARTEPADRE,'')<>''  and DESVIACION.DEV_TIPOSUST='I'

-- por periodo padre empieza con
UPDATE    BOM_DESCTEMP
SET     BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
FROM         DESVIACION INNER JOIN
              MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE = DESVIACION.MA_NOPARTEORIG INNER JOIN
              BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
              FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
              FACTEXPDET.FED_NOPARTE LIKE DESVIACION.MA_NOPARTEPADRE+'%'
WHERE     (BOM_DESCTEMP.FED_INDICED = @Fed_indiced) AND (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND (DESVIACION.DEV_FECHAFIN >= @fe_fecha)
and DESVIACION.DEV_CANTIDAD = 0 and DESVIACION.DEV_HABILITADO='S'
and isnull(DESVIACION.MA_NOPARTEPADRE,'')<>''  and DESVIACION.DEV_TIPOSUST='P'

-- por periodo hijo empieza con
UPDATE    BOM_DESCTEMP
SET     BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
FROM         DESVIACION INNER JOIN
              MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE LIKE DESVIACION.MA_NOPARTEORIG+'%' INNER JOIN
              BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
              FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
              FACTEXPDET.FED_NOPARTE = DESVIACION.MA_NOPARTEPADRE
WHERE     (BOM_DESCTEMP.FED_INDICED = @Fed_indiced) AND (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND (DESVIACION.DEV_FECHAFIN >= @fe_fecha)
and DESVIACION.DEV_CANTIDAD = 0 and DESVIACION.DEV_HABILITADO='S'
and isnull(DESVIACION.MA_NOPARTEPADRE,'')<>''  and DESVIACION.DEV_TIPOSUST='H'

-- por periodo ambos empieza con
UPDATE    BOM_DESCTEMP
SET     BOM_DESCTEMP.BST_HIJO = DESVIACION.MA_CODIGONVO
FROM         DESVIACION INNER JOIN
              MAESTRO MAESTRO_1 ON MAESTRO_1.MA_NOPARTE LIKE DESVIACION.MA_NOPARTEORIG+'%' INNER JOIN
              BOM_DESCTEMP ON MAESTRO_1.MA_CODIGO = BOM_DESCTEMP.BST_HIJO INNER JOIN
              FACTEXPDET ON BOM_DESCTEMP.FED_INDICED = FACTEXPDET.FED_INDICED AND 
              FACTEXPDET.FED_NOPARTE LIKE DESVIACION.MA_NOPARTEPADRE+'%'
WHERE     (BOM_DESCTEMP.FED_INDICED = @Fed_indiced) AND (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND (DESVIACION.DEV_FECHAFIN >= @fe_fecha)
and DESVIACION.DEV_CANTIDAD = 0 and DESVIACION.DEV_HABILITADO='S'
and isnull(DESVIACION.MA_NOPARTEPADRE,'')<>''  and DESVIACION.DEV_TIPOSUST='A'


-- por cantidad y periodo
	if @ExplosionParaDescargar='S'
	begin
		DECLARE cur_Desviacion CURSOR FOR
			SELECT   DEV_CODIGO, DEV_SALDO, MA_NOPARTEORIG, MA_CODIGONVO, DEV_TIPOSUST
			FROM     DESVIACION 
			WHERE   (DEV_FECHAINI <= @fe_fecha) AND (DEV_FECHAFIN >= @fe_fecha) and
			MA_NOPARTEORIG IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO IN 
	                                        (SELECT BST_HIJO FROM BOM_DESCTEMP  inner join factexpdet on factexpdet.fed_indiced=BOM_DESCTEMP.fed_indiced
	                                        WHERE BOM_DESCTEMP.FED_INDICED = @Fed_indiced and factexpdet.FED_NOPARTE=MA_NOPARTEPADRE GROUP BY BST_HIJO))
			and MA_NOPARTEORIG <>MA_NOPARTENVO AND DEV_SALDO>0
			 and DEV_HABILITADO='S' and (DESVIACION.DEV_TIPOSUST='I' or DESVIACION.DEV_TIPOSUST='H')
			and isnull(DESVIACION.MA_NOPARTEPADRE,'')<>''
		open cur_Desviacion
			FETCH NEXT FROM cur_Desviacion INTO @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
	
				exec SP_ExplosionaDesviacionDetFed @Fed_indiced, @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
					
		
		
				FETCH NEXT FROM cur_Desviacion INTO @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
			
			END
			
			CLOSE cur_Desviacion
			DEALLOCATE cur_Desviacion
	
	
	
	
		-- por cantidad y periodo, padre empieza con
		DECLARE cur_DesviacionPadre CURSOR FOR
			SELECT   DEV_CODIGO, DEV_SALDO, MA_NOPARTEORIG, MA_CODIGONVO, DEV_TIPOSUST
			FROM     DESVIACION 
			WHERE   (DEV_FECHAINI <= @fe_fecha) AND (DEV_FECHAFIN >= @fe_fecha) and
			MA_NOPARTEORIG IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO IN 
	                                        (SELECT BST_HIJO FROM BOM_DESCTEMP  inner join factexpdet on factexpdet.fed_indiced=BOM_DESCTEMP.fed_indiced
	                                        WHERE BOM_DESCTEMP.FED_INDICED = @Fed_indiced and factexpdet.FED_NOPARTE like MA_NOPARTEPADRE+'%' GROUP BY BST_HIJO))
			and MA_NOPARTEORIG <>MA_NOPARTENVO AND DEV_SALDO>0
			 and DEV_HABILITADO='S' and (DESVIACION.DEV_TIPOSUST='P' or DESVIACION.DEV_TIPOSUST='A')
			and isnull(DESVIACION.MA_NOPARTEPADRE,'')<>''
		open cur_DesviacionPadre
			FETCH NEXT FROM cur_DesviacionPadre INTO @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
	
				exec SP_ExplosionaDesviacionDetFed @Fed_indiced, @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
	
						
		
		
				FETCH NEXT FROM cur_DesviacionPadre INTO @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
			
			END
			
			CLOSE cur_DesviacionPadre
			DEALLOCATE cur_DesviacionPadre

	end




/*===============================================================*/
-- por periodo sin padre
UPDATE    BOM_DESCTEMP
SET     BOM_DESCTEMP.BST_HIJO= DESVIACION.MA_CODIGONVO
FROM         BOM_DESCTEMP INNER JOIN
                      MAESTRO MAESTRO_1 INNER JOIN
                      DESVIACION ON MAESTRO_1.MA_NOPARTE = DESVIACION.MA_NOPARTEORIG ON 
                      BOM_DESCTEMP.BST_HIJO = MAESTRO_1.MA_CODIGO 
WHERE     (BOM_DESCTEMP.FED_INDICED = @Fed_indiced) AND (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND (DESVIACION.DEV_FECHAFIN >= @fe_fecha)
and DESVIACION.DEV_CANTIDAD = 0 and DESVIACION.DEV_HABILITADO='S'
and isnull(DESVIACION.MA_NOPARTEPADRE,'')='' and DESVIACION.DEV_TIPOSUST='I'

-- por periodo sin padre,  hiijo empieza con
UPDATE    BOM_DESCTEMP
SET     BOM_DESCTEMP.BST_HIJO= DESVIACION.MA_CODIGONVO
FROM         BOM_DESCTEMP INNER JOIN
                      MAESTRO MAESTRO_1 INNER JOIN
                      DESVIACION ON MAESTRO_1.MA_NOPARTE LIKE DESVIACION.MA_NOPARTEORIG+'%' ON 
                      BOM_DESCTEMP.BST_HIJO = MAESTRO_1.MA_CODIGO 
WHERE     (BOM_DESCTEMP.FED_INDICED = @Fed_indiced) AND (DESVIACION.DEV_FECHAINI <= @fe_fecha) AND (DESVIACION.DEV_FECHAFIN >= @fe_fecha)
and DESVIACION.DEV_CANTIDAD = 0 and DESVIACION.DEV_HABILITADO='S'
and isnull(DESVIACION.MA_NOPARTEPADRE,'')='' and DESVIACION.DEV_TIPOSUST='H'


-- por cantidad y periodo sin padre
	if @ExplosionParaDescargar='S'
	begin

		DECLARE cur_DesviacionSinPadre CURSOR FOR
			SELECT   DEV_CODIGO, DEV_SALDO, MA_NOPARTEORIG, MA_CODIGONVO, DEV_TIPOSUST
			FROM     DESVIACION 
			WHERE   (DEV_FECHAINI <= @fe_fecha) AND (DEV_FECHAFIN >= @fe_fecha) and
			MA_NOPARTEORIG IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO IN 
	                                        (SELECT BST_HIJO FROM BOM_DESCTEMP WHERE FED_INDICED = @Fed_indiced GROUP BY BST_HIJO))
			and MA_NOPARTEORIG <>MA_NOPARTENVO AND DEV_SALDO>0
			 and DEV_HABILITADO='S' and (DESVIACION.DEV_TIPOSUST='I' or DESVIACION.DEV_TIPOSUST='H')
			and isnull(DESVIACION.MA_NOPARTEPADRE,'')=''
		open cur_DesviacionSinPadre
			FETCH NEXT FROM cur_DesviacionSinPadre INTO @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
	
				exec SP_ExplosionaDesviacionDetFed @Fed_indiced, @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
	
						
		
		
			FETCH NEXT FROM cur_DesviacionSinPadre INTO @dev_codigo, @dev_saldo, @ma_noparteorig, @ma_codigoNvo, @DEV_TIPOSUST
			
			END
			
			CLOSE cur_DesviacionSinPadre
			DEALLOCATE cur_DesviacionSinPadre
	end
GO
