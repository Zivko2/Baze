SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_CAPTURARAPIDAFACTIMP] (@Codigo int, @agrupacion char(1))   as

SET NOCOUNT ON 
DECLARE @CONSECUTIVO INTEGER, @NOPARTE varchar(30), @COSTO decimal(38,6), @CANTIDAD decimal(38,6), @PESO decimal(38,6), @ORIGEN INT, @TipoEmbarque INT, 
@TipoEntrada CHAR(1), @FID_indiced int, @CF_PESOS_IMP CHAR(1), @maximo int, @MA_CODIGO int


	IF (SELECT COUNT(*) FROM CAPTURARAPIDA WHERE codigofact=@Codigo and tipofact='I')>0
	BEGIN
	
		SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
		FROM         dbo.CONFIGURACION
	
	
	
		SET @TipoEntrada ='I'
		SELECT @TipoEmbarque =TQ_CODIGO FROM FACTIMP WHERE FI_CODIGO=@Codigo
		
		  DECLARE @ERRORES INT
		  SET @ERRORES  = 0
		
		/*===================================*/
				exec sp_droptable 'tempCapRapidamaestro'
				
				CREATE TABLE [dbo].[tempCapRapidamaestro] (
					[MA_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
					[MA_NOPARTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
					[MA_NOPARTEAUX] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
					[ME_COM] [int] NOT NULL ,
					[EQ_GEN] decimal(28,14) CONSTRAINT [DF_tempCapRapidamaestro_EQ_GEN] DEFAULT (1),
					[PA_ORIGEN] [int] NOT NULL ,
					[MA_PESO_KG] decimal(38,6) NULL ,
					[MA_PESO_LB] decimal(38,6) NULL ,
					CONSTRAINT [PK_tempCapRapidamaestro] PRIMARY KEY  CLUSTERED 
					(
						[MA_NOPARTE]
					)  ON [PRIMARY] 
				) ON [PRIMARY]
				
				--select @maximo=isnull(max(ma_codigo),0)+1 from maestro
				select @maximo=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'
				
				dbcc checkident (tempCapRapidamaestro, reseed, @maximo) WITH NO_INFOMSGS
				
				
					insert into tempCapRapidamaestro (ma_noparte,ma_noparteaux,ma_peso_kg, ma_peso_lb, me_com, pa_origen,
									  eq_gen)
					SELECT     CAPTURARAPIDA.NOPARTE, CAPTURARAPIDA.NOPARTEAUX, CAPTURARAPIDA.PESO, CAPTURARAPIDA.PESOLB, 
					                      MEDIDA.ME_CODIGO, ISNULL(CAPTURARAPIDA.ORIGEN,233), isnull(CAPTURARAPIDA.CANTIDADCOMERCIAL / ISNULL(CAPTURARAPIDA.CANTIDAD, 1),1)
					FROM         CAPTURARAPIDA LEFT OUTER JOIN
					                      MEDIDA ON CAPTURARAPIDA.MEDIDA = MEDIDA.ME_CORTO
					WHERE     (CAPTURARAPIDA.EXISTE = 'N')
		
		
		
					insert into maestro(ma_codigo, ma_noparte, ma_noparteaux, ma_nombre, ma_name, ma_inv_gen, ti_codigo, pa_procede,  pa_origen, ma_peso_kg, ma_peso_lb, me_com, eq_gen)
					select ma_codigo, ma_noparte, ma_noparteaux, 'temp', 'temp', 'I', 10, 233, pa_origen, ma_peso_kg, ma_peso_lb, me_com,  eq_gen 
					from tempCapRapidamaestro
		
		
					INSERT INTO MAESTROCOST(MA_CODIGO, TCO_CODIGO, TV_CODIGO, MA_COSTO, SPI_CODIGO, MA_PERINI, MA_PERFIN)
		
					SELECT     MAESTRO.MA_CODIGO, (SELECT TCO_COMPRA FROM dbo.CONFIGURACION), (SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'), CAPTURARAPIDA.COSTO,
					22, CONVERT(VARCHAR(11),GETDATE(),101), '01/01/9999'
					FROM         CAPTURARAPIDA INNER JOIN
					                      MAESTRO ON CAPTURARAPIDA.NOPARTE = MAESTRO.MA_NOPARTE AND 
					                      CAPTURARAPIDA.NOPARTEAUX = MAESTRO.MA_NOPARTEAUX LEFT OUTER JOIN
					                      MEDIDA ON CAPTURARAPIDA.MEDIDA = MEDIDA.ME_CORTO
					WHERE     (CAPTURARAPIDA.EXISTE = 'N')
		
			
				
				exec sp_droptable 'tempCapRapidamaestro'
				
				select @MA_CODIGO= max(MA_CODIGO) from MAESTRO

				if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@MA_CODIGO
				select @MA_CODIGO= isnull(max(MA_CODIGO),0) from MAESTROREFER

				
					update consecutivo
					set cv_codigo =  isnull(@MA_CODIGO,0) + 1
					where cv_tipo = 'MA'
		
		/*===================================*/
		
		
		UPDATE CAPTURARAPIDA
		SET EXISTE='S' WHERE codigofact=@Codigo and tipofact='I'
		
		
		ALTER TABLE FACTIMPDET DISABLE TRIGGER Update_FactImpDet
		
		-- se actualiza el costo en caso de que venga nulo o igual a cero
		UPDATE dbo.CAPTURARAPIDA
		SET     dbo.CAPTURARAPIDA.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
		FROM         dbo.CAPTURARAPIDA INNER JOIN
		                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
		WHERE dbo.CAPTURARAPIDA.COSTO=0 OR dbo.CAPTURARAPIDA.COSTO IS NULL
		AND codigofact=@Codigo and tipofact='I'
		
		-- se actualiza el peso en caso de que venga nulo o igual a cero
		UPDATE dbo.CAPTURARAPIDA
		SET  dbo.CAPTURARAPIDA.PESO = isnull(dbo.MAESTRO.MA_PESO_KG,0)
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
		WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
		               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
		                AND MA_EST_MAT = 'A' AND MA_NOPARTE=CAPTURARAPIDA.NOPARTE AND (PESO IS NULL OR PESO =0.0)
		AND codigofact=@Codigo and tipofact='I'
		
		UPDATE dbo.CAPTURARAPIDA
		SET  dbo.CAPTURARAPIDA.PESOLB = isnull(dbo.MAESTRO.MA_PESO_LB,0)
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
		WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
		               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
		                AND MA_EST_MAT = 'A' AND MA_NOPARTE=CAPTURARAPIDA.NOPARTE AND (PESO IS NULL OR PESOLB =0.0)
		AND codigofact=@Codigo and tipofact='I'
		
		--borra los errores generados en otras importaciones
		DELETE FROM IMPORTLOG WHERE IML_CBFORMA=21
		
		if (select count(*) from IMPORTLOG)=0
		DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS
		
		--borra los registros de la tabla que se hayan importado sin numero de parte
		delete from CAPTURARAPIDA where NOPARTE=''
		
		-- revisa si existen en el catalogo maestro
		if exists(SELECT dbo.CAPTURARAPIDA.NOPARTE
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE     (dbo.MAESTRO.MA_NOPARTE IS NULL) and codigofact=@Codigo and tipofact='I')
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURARAPIDA.NOPARTE +' POR QUE NO EXISTE EN EL CAT. MAESTRO', 21 
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE     (dbo.MAESTRO.MA_NOPARTE IS NULL)  and codigofact=@Codigo and tipofact='I' 
		
		-- revisa si existen obsoletos en el catalogo maestro
		if exists(SELECT dbo.CAPTURARAPIDA.NOPARTE
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') and codigofact=@Codigo and tipofact='I' )
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURARAPIDA.NOPARTE +' POR QUE ESTA OBSOLETO EN EL CAT. MAESTRO', 21
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') and codigofact=@Codigo and tipofact='I'  
		
		-- revisa si los tipos de material existen en la relacion tipo embarque - tipo material
			if exists (SELECT     dbo.CAPTURARAPIDA.NOPARTE
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
				WHERE     codigofact=@Codigo and tipofact='I'  and (NOT (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     ti_codigo
		                            FROM          reltembtipo
		                           WHERE      tq_codigo = @TipoEmbarque))))
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURARAPIDA.NOPARTE+' POR LA RELACION TIPO EMBARQUE-TIPO MATERIAL', 21
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
				WHERE codigofact=@Codigo and tipofact='I'  and (NOT (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
			'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURARAPIDA.NOPARTE +' POR QUE NO EXISTE EN EL CAT. MAESTRO' 
			not in (SELECT IML_MENSAJE FROM IMPORTLOG)
		
		
			if exists(SELECT     dbo.MAESTRO.MA_NOPARTE
			FROM         dbo.MAESTRO
			GROUP BY MA_NOPARTE
			HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN		
			                          (SELECT NOPARTE FROM CAPTURARAPIDA)))
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE + ' PORQUE ESTA REPETIDO EN EL CAT. MAESTRO', 21
			FROM         dbo.MAESTRO
			GROUP BY MA_NOPARTE
			HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
			                          (SELECT NOPARTE FROM CAPTURARAPIDA))
		
		
			if (select cf_permisoaviso from configuracion)='S'
			begin
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
				SELECT     'EL NO. PARTE: '+dbo.MAESTRO.MA_NOPARTE+' CON FRACCION '+ARANCEL.AR_FRACCION+' NO CUENTA CON PERMISO DE IMPORTACION', 21
				FROM         dbo.MAESTRO INNER JOIN
				             dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE LEFT OUTER JOIN ARANCEL ON
					dbo.MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
				WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND (dbo.MAESTRO.MA_CODIGO NOT IN
					(SELECT     dbo.MAESTROCATEG.MA_CODIGO
					FROM         dbo.MAESTROCATEG INNER JOIN
					                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
					                      dbo.IDENTIFICA INNER JOIN
					                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
					WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
				MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
				and codigofact=@Codigo and tipofact='I' 
				GROUP BY dbo.MAESTRO.MA_NOPARTE, ARANCEL.AR_FRACCION
		
			end
			else
			if (select cf_permisoaviso from configuracion)='X'
			begin
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
				SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + dbo.MAESTRO.MA_NOPARTE+' CON FRACCION '+ARANCEL.AR_FRACCION+' PORQUE NO CUENTA CON PERMISO SICEX', 21
				FROM         dbo.MAESTRO INNER JOIN
				             dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE  LEFT OUTER JOIN ARANCEL ON
					dbo.MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
				WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND (dbo.MAESTRO.MA_CODIGO NOT IN
					(SELECT     dbo.MAESTROCATEG.MA_CODIGO
					FROM         dbo.MAESTROCATEG INNER JOIN
					                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
					                      dbo.IDENTIFICA INNER JOIN
					                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
					WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
				MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
				and codigofact=@Codigo and tipofact='I' 
				GROUP BY dbo.MAESTRO.MA_NOPARTE, ARANCEL.AR_FRACCION
		
			end
		
			select @consecutivo=cv_codigo from consecutivo
			where cv_tipo = 'FID'
		
		
		
			if @agrupacion='N'
			begin
			-- insercion a la tabla factimpdet
				if (select cf_permisoaviso from configuracion)<>'X'
				BEGIN
					INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
				                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
				 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
								       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_ORD_COMP) 
				
				
					SELECT     TOP 100 PERCENT dbo.CAPTURARAPIDA.ORDEN+@consecutivo, @Codigo, dbo.CAPTURARAPIDA.NOPARTE, isnull(dbo.CAPTURARAPIDA.COSTO,0), 
					                      dbo.CAPTURARAPIDA.CANTIDAD, isnull(dbo.CAPTURARAPIDA.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
					                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(dbo.CAPTURARAPIDA.ORIGEN, 233), isnull(dbo.MAESTRO.MA_GENERICO,0), 
					                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378, 
					                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
					                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),MEDIDA.ME_CODIGO),
					                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD * dbo.CAPTURARAPIDA.COSTO,0),6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6),
						         isnull(dbo.CAPTURARAPIDA.CANTIDAD,0), isnull(VMAESTROCOST.TCO_CODIGO,0), dbo.CAPTURARAPIDA.ORDCOMPRA
					FROM         dbo.MAESTRO INNER JOIN
					                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE LEFT OUTER JOIN
					                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN MEDIDA ON 
							dbo.CAPTURARAPIDA.MEDIDACOMERCIAL=MEDIDA.ME_CORTO 
					WHERE     codigofact=@Codigo and tipofact='I' and (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
					                          (SELECT     TI_CODIGO
					                            FROM          RELTEMBTIPO
					                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
							dbo.CAPTURARAPIDA.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
									                          (SELECT NOPARTE FROM CAPTURARAPIDA))) 
					ORDER BY dbo.CAPTURARAPIDA.ORDEN
				END
				ELSE --(select cf_permisoaviso from configuracion)='X'
				BEGIN
					INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
				                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
				 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
								       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_ORD_COMP) 
				
					SELECT     TOP 100 PERCENT dbo.CAPTURARAPIDA.ORDEN+@consecutivo, @Codigo, dbo.CAPTURARAPIDA.NOPARTE, isnull(dbo.CAPTURARAPIDA.COSTO,0), 
					                      dbo.CAPTURARAPIDA.CANTIDAD, isnull(dbo.CAPTURARAPIDA.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
					                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(dbo.CAPTURARAPIDA.ORIGEN, 233), isnull(dbo.MAESTRO.MA_GENERICO,0), 
					                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378, 		
					                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
					                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),MEDIDA.ME_CODIGO),
					                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD * dbo.CAPTURARAPIDA.COSTO,0),6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6),
						         isnull(dbo.CAPTURARAPIDA.CANTIDAD,0), isnull(VMAESTROCOST.TCO_CODIGO,0), dbo.CAPTURARAPIDA.ORDCOMPRA
					FROM         dbo.MAESTRO INNER JOIN
					                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE LEFT OUTER JOIN
					                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN MEDIDA ON 
							dbo.CAPTURARAPIDA.MEDIDACOMERCIAL=MEDIDA.ME_CORTO 
					WHERE     codigofact=@Codigo and tipofact='I' and (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
					                          (SELECT     TI_CODIGO
					                            FROM          RELTEMBTIPO
					                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
							dbo.CAPTURARAPIDA.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
									                          (SELECT NOPARTE FROM CAPTURARAPIDA))) 
			
						AND dbo.MAESTRO.MA_CODIGO NOT IN
							(SELECT     dbo.MAESTRO.MA_CODIGO
							FROM         dbo.MAESTRO INNER JOIN
							             dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
							WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND dbo.MAESTRO.MA_GENERICO NOT IN
							          (SELECT     dbo.PERMISODET.MA_GENERICO
							FROM         dbo.IDENTIFICA INNER JOIN
							                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO RIGHT OUTER JOIN
							                      dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO
							WHERE     dbo.PERMISO.PE_APROBADO = 'S' AND dbo.IDENTIFICA.IDE_CLAVE = 'MQ')
							GROUP BY dbo.MAESTRO.MA_CODIGO)
					ORDER BY dbo.CAPTURARAPIDA.ORDEN
			
				END
			end
			else
			begin
		
				exec sp_CreaFactImpDetTemp
			-- insercion a la tabla factimpdet
				if (select cf_permisoaviso from configuracion)<>'X'
				BEGIN
					INSERT INTO FactImpDetTemp (FID_INDICEDANT, FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
				                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
				 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
								       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_ORD_COMP) 
				
				
					SELECT     TOP 100 PERCENT 0, @Codigo, dbo.CAPTURARAPIDA.NOPARTE, isnull(dbo.CAPTURARAPIDA.COSTO,0), 
					                      dbo.CAPTURARAPIDA.CANTIDAD, isnull(dbo.CAPTURARAPIDA.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
					                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(dbo.CAPTURARAPIDA.ORIGEN, 233), isnull(dbo.MAESTRO.MA_GENERICO,0), 
					                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378, 
					                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
					                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),MEDIDA.ME_CODIGO),
					                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD * dbo.CAPTURARAPIDA.COSTO,0),6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6),
						         isnull(dbo.CAPTURARAPIDA.CANTIDAD,0), isnull(VMAESTROCOST.TCO_CODIGO,0), dbo.CAPTURARAPIDA.ORDCOMPRA
					FROM         dbo.MAESTRO INNER JOIN
					                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE LEFT OUTER JOIN
					                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN MEDIDA ON 
							dbo.CAPTURARAPIDA.MEDIDACOMERCIAL=MEDIDA.ME_CORTO 
					WHERE     codigofact=@Codigo and tipofact='I' and (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
					                          (SELECT     TI_CODIGO
					                            FROM          RELTEMBTIPO
					                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
							dbo.CAPTURARAPIDA.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
									                          (SELECT NOPARTE FROM CAPTURARAPIDA))) 
					ORDER BY dbo.CAPTURARAPIDA.ORDEN
				END
				ELSE --(select cf_permisoaviso from configuracion)='X'
				BEGIN
					INSERT INTO FactImpDetTemp (FID_INDICEDANT, FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
				                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
				 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
								       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_ORD_COMP) 
				
					SELECT     TOP 100 PERCENT 0, @Codigo, dbo.CAPTURARAPIDA.NOPARTE, isnull(dbo.CAPTURARAPIDA.COSTO,0), 
					                      dbo.CAPTURARAPIDA.CANTIDAD, isnull(dbo.CAPTURARAPIDA.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
					                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(dbo.CAPTURARAPIDA.ORIGEN, 233), isnull(dbo.MAESTRO.MA_GENERICO,0), 
					                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378, 
					                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
					                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),MEDIDA.ME_CODIGO),
					                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD * dbo.CAPTURARAPIDA.COSTO,0),6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6), 
					                      round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0),6), round(dbo.CAPTURARAPIDA.CANTIDAD * isnull(dbo.CAPTURARAPIDA.PESO,0) * 2.20462442018378,6),
						         isnull(dbo.CAPTURARAPIDA.CANTIDAD,0), isnull(VMAESTROCOST.TCO_CODIGO,0), dbo.CAPTURARAPIDA.ORDCOMPRA
					FROM         dbo.MAESTRO INNER JOIN
					                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE LEFT OUTER JOIN
					                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN MEDIDA ON 
							dbo.CAPTURARAPIDA.MEDIDACOMERCIAL=MEDIDA.ME_CORTO 
					WHERE     codigofact=@Codigo and tipofact='I' and (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
					                          (SELECT     TI_CODIGO
					                            FROM          RELTEMBTIPO
					                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
							dbo.CAPTURARAPIDA.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
									                          (SELECT NOPARTE FROM CAPTURARAPIDA))) 
			
						AND dbo.MAESTRO.MA_CODIGO NOT IN
							(SELECT     dbo.MAESTRO.MA_CODIGO
							FROM         dbo.MAESTRO INNER JOIN
							             dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
							WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND dbo.MAESTRO.MA_GENERICO NOT IN
							          (SELECT     dbo.PERMISODET.MA_GENERICO
							FROM         dbo.IDENTIFICA INNER JOIN
							                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO RIGHT OUTER JOIN
							                      dbo.PERMISODET ON dbo.PERMISO.PE_CODIGO = dbo.PERMISODET.PE_CODIGO
							WHERE     dbo.PERMISO.PE_APROBADO = 'S' AND dbo.IDENTIFICA.IDE_CLAVE = 'MQ')
							GROUP BY dbo.MAESTRO.MA_CODIGO)
					ORDER BY dbo.CAPTURARAPIDA.ORDEN
					IF (@@ERROR <> 0 ) SET @ERRORES = 1
			
				END
		
		
				INSERT INTO FactImpDet (FID_INDICED, FI_CODIGO, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, 
				                      FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, OR_CODIGO, FID_ORD_COMP, ORD_INDICED, FID_NOORDEN, FID_OBSERVA, 
				                      FID_FEC_ENT, FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO, AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, 
				                      ME_CODIGO, MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PR_CODIGO, PL_FOLIO, PL_CODIGO, PLD_INDICED, CS_CODIGO, PE_CODIGO, EQ_GEN, 
				                      EQ_IMPMX, EQ_EXPFO, EQ_EXPFO2, TI_CODIGO, FID_RATEEXPFO, FID_RELEMP, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_LOTE, 
				                      FID_FAC_NUM, FID_FEC_ENV, FID_LISTA, FID_CON_CERTORIG, ME_GEN, FID_GENERA_EMP, FID_CANT_DESP, FID_FECHA_STRUCT, TCO_CODIGO, 
				                      FID_SALDO, FID_ENUSO, FID_NOPARTEAUX)
		
				SELECT     MIN(FID_INDICED), FI_CODIGO, FID_NOPARTE, MAX(FID_NOMBRE), MAX(FID_NAME), SUM(FID_CANT_ST), FID_COS_UNI, SUM(FID_COS_TOT), 
				                      FID_PES_UNI, SUM(FID_PES_NET), SUM(FID_PES_BRU), FID_PES_UNILB, SUM(FID_PES_NETLB), SUM(FID_PES_BRULB), MAX(OR_CODIGO), 
				                      MAX(FID_ORD_COMP), MAX(ORD_INDICED), MAX(FID_NOORDEN), MAX(FID_OBSERVA), MAX(FID_FEC_ENT), MAX(FID_NUM_ENT), 
				                      MAX(FID_SEC_IMP), MAX(FID_POR_DEF), MAX(FID_DEF_TIP), MAX(FID_ENVIO), MAX(AR_IMPMX), MAX(AR_EXPFO), MA_CODIGO, MAX(MV_CODIGO), 
				                      MAX(ME_CODIGO), MAX(MA_GENERICO), MAX(ME_ARIMPMX), PA_CODIGO, MAX(PR_CODIGO), MAX(PL_FOLIO), MAX(PL_CODIGO), 
				                      MAX(PLD_INDICED), MAX(CS_CODIGO), MAX(PE_CODIGO), MAX(EQ_GEN), MAX(EQ_IMPMX), MAX(EQ_EXPFO), MAX(EQ_EXPFO2), MAX(TI_CODIGO), 
				                      MAX(FID_RATEEXPFO), MAX(FID_RELEMP), MAX(SPI_CODIGO), MAX(MA_EMPAQUE), MAX(FID_CANTEMP), MAX(FID_LOTE), MAX(FID_FAC_NUM), 
				                      MAX(FID_FEC_ENV), MAX(FID_LISTA), MAX(FID_CON_CERTORIG), MAX(ME_GEN), MAX(FID_GENERA_EMP), MAX(FID_CANT_DESP), 
				                      MAX(FID_FECHA_STRUCT), MAX(TCO_CODIGO), SUM(FID_SALDO), MAX(FID_ENUSO), MAX(FID_NOPARTEAUX)
				FROM         FactImpDetTemp
				GROUP BY FI_CODIGO, FID_NOPARTE, FID_COS_UNI, FID_PES_UNI, FID_PES_UNILB, MA_CODIGO, PA_CODIGO
				ORDER BY MIN(FID_INDICED)
				IF (@@ERROR <> 0 ) SET @ERRORES = 1		
		
		
				IF @ERRORES = 0 
				exec sp_droptable 'FactImpDetTemp'
				
		
			end
		
			
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
		
		
		IF @ERRORES = 0 
		if exists (select * from CAPTURARAPIDA where codigofact=@Codigo and tipofact='I')
		delete from CAPTURARAPIDA where codigofact=@Codigo and tipofact='I'
	END
GO
