SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_CAPTURAXORDCOMPFACTIMP] (@Codigo int)   as

SET NOCOUNT ON 
DECLARE @CONSECUTIVO INTEGER, @NOPARTE varchar(30), @COSTO decimal(38,6), @CANTIDAD decimal(38,6), @PESO decimal(38,6), @ORIGEN INT, @TipoEmbarque INT, 
@TipoEntrada CHAR(1), @FID_indiced int, @CF_PESOS_IMP CHAR(1), @maximo int, @MA_CODIGO int, @fi_codigo varchar(50), @FI_TIPO CHAR(1)



	IF (SELECT COUNT(*) FROM CAPTURAXORDCOMP WHERE codigofact=@Codigo and tipofact='I')>0
	BEGIN

			SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
			FROM         dbo.CONFIGURACION
		
		
		
		SET @TipoEntrada ='I'
		SELECT @TipoEmbarque =TQ_CODIGO, @fi_codigo=convert(varchar(50),FI_CODIGO), @FI_TIPO=FI_TIPO FROM FACTIMP WHERE FI_CODIGO=@Codigo
		
		  DECLARE @ERRORES INT
		  SET @ERRORES  = 0
		
		ALTER TABLE FACTIMPDET DISABLE TRIGGER Update_FactImpDet
		
		
		
		--borra los errores generados en otras importaciones
		DELETE FROM IMPORTLOG WHERE IML_CBFORMA=-3
		
		if (select count(*) from IMPORTLOG)=0
		DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS
		
		--borra los registros de la tabla que se hayan importado sin numero de parte
		delete from CAPTURAXORDCOMP where NOPARTE=''
		
		-- se actualiza el costo en caso de que venga nulo o igual a cero
		UPDATE dbo.CAPTURAXORDCOMP
		SET     dbo.CAPTURAXORDCOMP.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
		FROM         dbo.CAPTURAXORDCOMP INNER JOIN
		                      dbo.MAESTRO ON dbo.CAPTURAXORDCOMP.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
		WHERE dbo.CAPTURAXORDCOMP.COSTO=0 OR dbo.CAPTURAXORDCOMP.COSTO IS NULL
		AND codigofact=@Codigo and tipofact='I'
		
		-- revisa si existen en el catalogo maestro
		if exists(SELECT dbo.CAPTURAXORDCOMP.NOPARTE
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE
			WHERE     (dbo.MAESTRO.MA_NOPARTE IS NULL) and codigofact=@Codigo and tipofact='I')
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURAXORDCOMP.NOPARTE +' POR QUE NO EXISTE EN EL CAT. MAESTRO', -3 
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE
			WHERE     (dbo.MAESTRO.MA_NOPARTE IS NULL)  and codigofact=@Codigo and tipofact='I' 
		
		-- revisa si existen obsoletos en el catalogo maestro
		if exists(SELECT dbo.CAPTURAXORDCOMP.NOPARTE
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE
			WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') and codigofact=@Codigo and tipofact='I' )
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURAXORDCOMP.NOPARTE +' POR QUE ESTA OBSOLETO EN EL CAT. MAESTRO', -3
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE
			WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') and codigofact=@Codigo and tipofact='I'  
		
		-- revisa si los tipos de material existen en la relacion tipo embarque - tipo material
			if exists (SELECT     dbo.CAPTURAXORDCOMP.NOPARTE
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE
				WHERE     codigofact=@Codigo and tipofact='I'  and (NOT (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     ti_codigo
		                            FROM          reltembtipo
		                           WHERE      tq_codigo = @TipoEmbarque))))
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURAXORDCOMP.NOPARTE+' POR LA RELACION TIPO EMBARQUE-TIPO MATERIAL', -3
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE
				WHERE codigofact=@Codigo and tipofact='I'  and (NOT (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
			'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURAXORDCOMP.NOPARTE +' POR QUE NO EXISTE EN EL CAT. MAESTRO' 
			not in (SELECT IML_MENSAJE FROM IMPORTLOG)
		
		
			if exists(SELECT     dbo.MAESTRO.MA_NOPARTE
			FROM         dbo.MAESTRO
			GROUP BY MA_NOPARTE
			HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN		
			                          (SELECT NOPARTE FROM CAPTURAXORDCOMP)))
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE + ' PORQUE ESTA REPETIDO EN EL CAT. MAESTRO', -3
			FROM         dbo.MAESTRO
			GROUP BY MA_NOPARTE
			HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
			                          (SELECT NOPARTE FROM CAPTURAXORDCOMP))
		
		
			if (select cf_permisoaviso from configuracion)='S'
			begin
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
				SELECT     'EL NO. PARTE: '+dbo.MAESTRO.MA_NOPARTE+' CON FRACCION '+ARANCEL.AR_FRACCION+' NO CUENTA CON PERMISO DE IMPORTACION', -3
				FROM         dbo.MAESTRO INNER JOIN
				             dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE LEFT OUTER JOIN ARANCEL ON
					dbo.MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
				WHERE     codigofact=@Codigo and dbo.MAESTRO.MA_INV_GEN = 'I' AND (dbo.MAESTRO.MA_CODIGO NOT IN
					(SELECT     dbo.MAESTROCATEG.MA_CODIGO
					FROM         dbo.MAESTROCATEG INNER JOIN
					                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
					                      dbo.IDENTIFICA INNER JOIN
					                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
					WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
				MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
				GROUP BY dbo.MAESTRO.MA_NOPARTE, ARANCEL.AR_FRACCION
		
			end
			else
			if (select cf_permisoaviso from configuracion)='X'
			begin
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
				SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + dbo.MAESTRO.MA_NOPARTE+' CON FRACCION '+ARANCEL.AR_FRACCION+' PORQUE NO CUENTA CON PERMISO SICEX', -3
				FROM         dbo.MAESTRO INNER JOIN
				             dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE  LEFT OUTER JOIN ARANCEL ON
					dbo.MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
				WHERE     codigofact=@Codigo and dbo.MAESTRO.MA_INV_GEN = 'I' AND (dbo.MAESTRO.MA_CODIGO NOT IN
					(SELECT     dbo.MAESTROCATEG.MA_CODIGO
					FROM         dbo.MAESTROCATEG INNER JOIN
					                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
					                      dbo.IDENTIFICA INNER JOIN
					                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
					WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
				MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
				GROUP BY dbo.MAESTRO.MA_NOPARTE, ARANCEL.AR_FRACCION
		
			end
		
			select @consecutivo=cv_codigo from consecutivo
			where cv_tipo = 'FID'
		
		
		
		

		
				exec Sp_GeneraTablaTemp 'FactImpDet'

		
		
			-- insercion a la tabla factimpdet
				if (select cf_permisoaviso from configuracion)<>'X'
				BEGIN
					INSERT INTO TempImportFACTIMPDET (FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
				                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
				 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
								       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_NUM_ENT, FID_ORD_COMP) 		
				
				
					SELECT     TOP 100 PERCENT @Codigo, dbo.CAPTURAXORDCOMP.NOPARTE, isnull(dbo.CAPTURAXORDCOMP.COSTO,0), 
					                      dbo.CAPTURAXORDCOMP.CANTIDAD, isnull(dbo.MAESTRO.MA_PESO_KG,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
					                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(dbo.MAESTRO.PA_ORIGEN, 233), isnull(dbo.MAESTRO.MA_GENERICO,0), 		
					                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.MAESTRO.MA_PESO_KG,0) * 2.20462442018378, 
					                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
					                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),MEDIDA.ME_CODIGO),
					                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(dbo.CAPTURAXORDCOMP.CANTIDAD * dbo.CAPTURAXORDCOMP.COSTO,0),6), 
					                      round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0),6), round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0) * 2.20462442018378,6), 
					                      round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0),6), round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0) * 2.20462442018378,6),
						         isnull(dbo.CAPTURAXORDCOMP.CANTIDAD,0), isnull(VMAESTROCOST.TCO_CODIGO,0), NUM_ENT, ORD_COMP
					FROM         dbo.MAESTRO INNER JOIN
					                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE LEFT OUTER JOIN
					                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN MEDIDA ON 
							dbo.MAESTRO.ME_COM=MEDIDA.ME_CODIGO 
					WHERE     codigofact=@Codigo and tipofact='I' and (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
					                          (SELECT     TI_CODIGO
					                            FROM          RELTEMBTIPO
					                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
							dbo.CAPTURAXORDCOMP.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
									                          (SELECT NOPARTE FROM CAPTURAXORDCOMP))) 
					ORDER BY dbo.CAPTURAXORDCOMP.CODIGO
				END
				ELSE --(select cf_permisoaviso from configuracion)='X'
				BEGIN
					INSERT INTO TempImportFACTIMPDET (FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
				                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
				 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
								       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_NUM_ENT, FID_ORD_COMP) 
				
					SELECT     TOP 100 PERCENT @Codigo, dbo.CAPTURAXORDCOMP.NOPARTE, isnull(dbo.CAPTURAXORDCOMP.COSTO,0), 
					                      dbo.CAPTURAXORDCOMP.CANTIDAD, isnull(dbo.MAESTRO.MA_PESO_KG,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
					                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(dbo.MAESTRO.PA_ORIGEN, 233), isnull(dbo.MAESTRO.MA_GENERICO,0), 
					                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.MAESTRO.MA_PESO_KG,0) * 2.20462442018378, 
					                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
					                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),MEDIDA.ME_CODIGO),
					                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(dbo.CAPTURAXORDCOMP.CANTIDAD * dbo.CAPTURAXORDCOMP.COSTO,0),6), 
					                      round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0),6), round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0) * 2.20462442018378,6), 
					                      round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0),6), round(dbo.CAPTURAXORDCOMP.CANTIDAD * isnull(dbo.MAESTRO.MA_PESO_KG,0) * 2.20462442018378,6),
						         isnull(dbo.CAPTURAXORDCOMP.CANTIDAD,0), isnull(VMAESTROCOST.TCO_CODIGO,0), NUM_ENT, ORD_COMP
					FROM         dbo.MAESTRO INNER JOIN
					                      dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE LEFT OUTER JOIN
					                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN MEDIDA ON 
							dbo.MAESTRO.ME_COM=MEDIDA.ME_CODIGO
					WHERE     codigofact=@Codigo and tipofact='I' and (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
					                          (SELECT     TI_CODIGO
					                            FROM          RELTEMBTIPO
					                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
							dbo.CAPTURAXORDCOMP.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
									                          (SELECT NOPARTE FROM CAPTURAXORDCOMP))) 
			
						AND dbo.MAESTRO.MA_CODIGO NOT IN
							(SELECT     dbo.MAESTRO.MA_CODIGO
							FROM         dbo.MAESTRO INNER JOIN
							             dbo.CAPTURAXORDCOMP ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURAXORDCOMP.NOPARTE
							WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND dbo.MAESTRO.MA_GENERICO NOT IN
							          (SELECT     dbo.PERMISODET.MA_GENERICO
							FROM         dbo.IDENTIFICA INNER JOIN
							                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO RIGHT OUTER JOIN
							                      dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO
							WHERE     dbo.PERMISO.PE_APROBADO = 'S' AND dbo.IDENTIFICA.IDE_CLAVE = 'MQ')
							GROUP BY dbo.MAESTRO.MA_CODIGO)
					ORDER BY dbo.CAPTURAXORDCOMP.CODIGO
			
				END
		
		
				INSERT INTO FactImpDet (FID_INDICED, FI_CODIGO, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, 
				                      FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, OR_CODIGO, FID_ORD_COMP, ORD_INDICED, FID_OBSERVA, 
				                      FID_FEC_ENT, FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO, AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, 
				                      ME_CODIGO, MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PR_CODIGO, PL_FOLIO, PL_CODIGO, PLD_INDICED, CS_CODIGO, PE_CODIGO, EQ_GEN, 
				                      EQ_IMPMX, EQ_EXPFO, EQ_EXPFO2, TI_CODIGO, FID_RATEEXPFO, FID_RELEMP, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_LOTE, 
				                      FID_FAC_NUM, FID_FEC_ENV, FID_LISTA, FID_CON_CERTORIG, ME_GEN, FID_GENERA_EMP, FID_CANT_DESP, FID_FECHA_STRUCT, TCO_CODIGO, 
				                      FID_SALDO, FID_ENUSO, FID_NOPARTEAUX)
		
				SELECT     TOP 100 PERCENT FID_INDICED, FI_CODIGO, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, 
				                      FID_PES_NET, FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, OR_CODIGO, FID_ORD_COMP, ORD_INDICED, FID_OBSERVA, 
				                      FID_FEC_ENT, FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO, AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, 
				                      ME_CODIGO, MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PR_CODIGO, PL_FOLIO, PL_CODIGO, PLD_INDICED, CS_CODIGO, PE_CODIGO, EQ_GEN, 
				                      EQ_IMPMX, EQ_EXPFO, EQ_EXPFO2, TI_CODIGO, FID_RATEEXPFO, FID_RELEMP, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_LOTE, 
				                      FID_FAC_NUM, FID_FEC_ENV, FID_LISTA, FID_CON_CERTORIG, ME_GEN, FID_GENERA_EMP, FID_CANT_DESP, FID_FECHA_STRUCT, TCO_CODIGO, 
				                      FID_SALDO, FID_ENUSO, FID_NOPARTEAUX
				FROM         dbo.TempImportFACTIMPDET
				ORDER BY FID_INDICED
					IF (@@ERROR <> 0 ) SET @ERRORES = 1
		
		
				IF @FI_TIPO='V'
					UPDATE TempOrdCompCerradas
					SET     SaldoQty = QTY_RECVD - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
										       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO='V'
							                                                AND FACTIMPDET.FID_ORD_COMP = TempOrdCompCerradas.ORDER_NUMBER and FACTIMPDET.FID_NOPARTE = TempOrdCompCerradas.ITEM_NUMBER),0)
					WHERE SaldoQty <> QTY_RECVD - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
										       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO='V' 
		                                                                       AND FACTIMPDET.FID_ORD_COMP = TempOrdCompCerradas.ORDER_NUMBER and FACTIMPDET.FID_NOPARTE = TempOrdCompCerradas.ITEM_NUMBER),0)
					AND ORDER_NUMBER IN (SELECT FID_ORD_COMP FROM TempImportFACTIMPDET where fid_noparte = ITEM_NUMBER)
		
				ELSE
					UPDATE TempOrdCompAbiertas
					SET     SaldoQty = OutstdQty - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
										       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO<>'V' 
										       AND FACTIMPDET.FID_ORD_COMP = TempOrdCompAbiertas.ContractNbr and FACTIMPDET.FID_NOPARTE = TempOrdCompAbiertas.itemNbr),0)
					WHERE SaldoQty <> OutstdQty - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET INNER JOIN FACTIMP ON
										       FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO WHERE FI_TIPO<>'V' 
			                                                             AND FACTIMPDET.FID_ORD_COMP = TempOrdCompAbiertas.ContractNbr and FACTIMPDET.FID_NOPARTE = TempOrdCompAbiertas.itemNbr),0)
					AND ContractNbr IN (SELECT FID_ORD_COMP FROM TempImportFACTIMPDET where fid_noparte = itemNbr)
		
				IF @ERRORES = 0 
				exec sp_droptable 'TempImportFACTIMPDET'
				
			
			update factimp
			set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
			where fi_codigo =@Codigo
		
			EXEC SP_INSERTPERMISODET @Codigo
		
			-- cambia el tipo de tasa en base a la configuracion
			if (select CF_ACTTASA from configuracion)='S'
			INSERT INTO IMPORTLOG (IML_MENSAJE) 
			SELECT     'PARA ACTUALIZAR A LA TASA MAS BAJA DEBERA DE EJECUTAR EN PROCESO MANUALMENTE POR MEDIO DE INFORANEXA'
			--	EXEC SP_ACTUALIZATASABAJAFACTIMP  @codigo 
		
			EXEC sp_actualizaReferencia @Codigo
		
		select @FID_indiced= max(FID_indiced) from FACTIMPDET
		
			update consecutivo
			set cv_codigo =  isnull(@FID_indiced,0) + 1
			where cv_tipo = 'FID'
		
		ALTER TABLE FACTIMPDET ENABLE TRIGGER Update_FactImpDet
	END
GO
