SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













CREATE PROCEDURE [dbo].[SP_TempImportLst]   as

SET NOCOUNT ON 
DECLARE @AG_MEX INT,  @AG_USA INT, @CL_CODIGO int, @CL_MATRIZ int,
@CL_TRAFICO int, @CT_CODIGO int, @MT_CODIGO int, @PU_CARGA int, @PU_DESTINO int, 
@PU_ENTRADA int, @PU_SALIDA int, @ZO_CODIGO int, @IT_ENTRADA int, @MO_CODIGO int, 
@DIRPRINC int, @DIRMATRIZ int, @TF_CODIGO int, @cp_codigo int, @Folio varchar(25),
@estatus char(1), @movimiento char(1), @CantBultos decimal(38,6), @FI_TIPO CHAR(1), @TQ_CODIGO INT, @CONSECUTIVOFI INT,
@FECHATEXT VARCHAR(11), @FI_FECHA datetime, @cfq_tipo char(1), @CONSECUTIVOFID INT, @FID_INDICED INT



	-- actualiza costo
	UPDATE TempImportLst
	SET     TempImportLst.CostoUnitUSD= ISNULL(VMAESTROCOST.MA_COSTO, 0)
	FROM         TempImportLst INNER JOIN MAESTRO ON TempImportLst.NoParte = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
	                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO
	WHERE VMAESTROCOST.SPI_CODIGO=22 AND (TempImportLst.CostoUnitUSD=0 OR TempImportLst.CostoUnitUSD IS NULL)


	UPDATE TempImportLst
	SET     TempImportLst.CostoUnitUSD= 0
	WHERE TempImportLst.CostoUnitUSD IS NULL 

	-- actualiza pais
	-- los nulos
	UPDATE TempImportLst	
	SET     TempImportLst.Pais= PAIS.PA_CORTO
	FROM         TempImportLst INNER JOIN
	                      MAESTRO ON TempImportLst.NoParte = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
	                      PAIS ON MAESTRO.PA_ORIGEN = PAIS.PA_CODIGO
	WHERE     (TempImportLst.Pais IS NULL OR
	                      rtrim(ltrim(TempImportLst.Pais)) = '')



	-- los que no coinciden en la clave
	UPDATE TempImportLst	
	SET     TempImportLst.Pais= PAIS.PA_CORTO
	FROM         TempImportLst INNER JOIN
	                      PAIS ON TempImportLst.Pais = PAIS.PA_ISO
	WHERE     TempImportLst.Pais not in (select PA_CORTO from PAIS)





	if (SELECT count(*) FROM TempImportLstSel)>0
	begin


		ALTER TABLE FACTIMPDET DISABLE TRIGGER Update_FACTIMPDET
	
	
	         SELECT @AG_MEX=AG_MEX,  @AG_USA=AG_USA, @CL_CODIGO=CL_CODIGO, @CL_MATRIZ=CL_MATRIZ, @CL_TRAFICO=CL_TRAFICO, 
			@CT_CODIGO=CT_CODIGO, @MT_CODIGO=MT_CODIGO, @PU_CARGA=PU_CARGA, @PU_DESTINO=PU_DESTINO, 
			@PU_ENTRADA=PU_ENTRADA, @PU_SALIDA=PU_SALIDA, @ZO_CODIGO=ZO_CODIGO,
			@IT_ENTRADA= IT_ENTRADA, @MO_CODIGO=MO_CODIGO, 
	 		@DIRPRINC=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_CODIGO),
			@DIRMATRIZ=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_MATRIZ)
		 FROM CLIENTE    WHERE CL_EMPRESA='S'
	
		SET @FECHATEXT = dbo.DateToText(GETDATE(),101)
	
	

		/*  ------------------- REVISIONES -----------------*/

			delete from TempImportLst where NoParte=''



		
		
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
				SELECT     'No se puede importar La Factura: '+Folio+' porque el No. Parte : ' +TempImportLst.NoParte +' porque no existe en el cat. maestro', -21
				FROM         MAESTRO RIGHT OUTER JOIN
				                      TempImportLst ON MAESTRO.MA_NOPARTE = TempImportLst.NoParte
				WHERE     (MAESTRO.MA_NOPARTE IS NULL) 

/*

				SELECT     'No se puede importar La Factura: '+Folio+' porque el No. Parte : ' +NoParte +' no cuenta con costo unitario ', -21
				FROM TempImportLst
				WHERE TempImportLst.CostoUnitUSD= 0

*/

				/*


				if (select cf_permisoaviso from configuracion)='S'
				begin
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					SELECT     'EL NO. PARTE: '+MAESTRO.MA_NOPARTE+' CON FRACCION '+ARANCEL.AR_FRACCION+' NO CUENTA CON PERMISO DE IMPORTACION', -21
					FROM         MAESTRO INNER JOIN
					             TempImportLst ON MAESTRO.MA_NOPARTE = TempImportLst.NOPARTE LEFT OUTER JOIN ARANCEL ON
						MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
					WHERE     MAESTRO.MA_INV_GEN = 'I' AND (MAESTRO.MA_CODIGO NOT IN
						(SELECT     MAESTROCATEG.MA_CODIGO
						FROM         MAESTROCATEG INNER JOIN
						                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
						                      IDENTIFICA INNER JOIN
						                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
						WHERE     (PERMISO.PE_APROBADO = 'S') AND (IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
					MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
					GROUP BY MAESTRO.MA_NOPARTE, ARANCEL.AR_FRACCION
				end
				else
				if (select cf_permisoaviso from configuracion)='X'
				begin
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MAESTRO.MA_NOPARTE+' CON FRACCION '+ARANCEL.AR_FRACCION+' PORQUE NO CUENTA CON PERMISO SICEX', -21
					FROM         MAESTRO INNER JOIN
					             TempImportLst ON MAESTRO.MA_NOPARTE = TempImportLst.NOPARTE  LEFT OUTER JOIN ARANCEL ON
						MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
					WHERE     MAESTRO.MA_INV_GEN = 'I' AND (MAESTRO.MA_CODIGO NOT IN
						(SELECT     MAESTROCATEG.MA_CODIGO
						FROM         MAESTROCATEG INNER JOIN
						                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
						                      IDENTIFICA INNER JOIN
						                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
						WHERE     (PERMISO.PE_APROBADO = 'S') AND (IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
					MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
					GROUP BY MAESTRO.MA_NOPARTE, ARANCEL.AR_FRACCION
			
			
					DELETE FROM TempImportLst
					WHERE TempImportLst.NOPARTE IN (SELECT MAESTRO.MA_NOPARTE
					FROM         MAESTRO INNER JOIN
					             TempImportLst ON MAESTRO.MA_NOPARTE = TempImportLst.NOPARTE
					WHERE     MAESTRO.MA_INV_GEN = 'I' AND (MAESTRO.MA_CODIGO NOT IN
						(SELECT     MAESTROCATEG.MA_CODIGO
						FROM         MAESTROCATEG INNER JOIN
						                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
						                      IDENTIFICA INNER JOIN
						                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
						WHERE     (PERMISO.PE_APROBADO = 'S') AND (IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
						MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
					GROUP BY MAESTRO.MA_NOPARTE)
			
				end*/
			
			

		-- deselecciona las facturas con problemas
		
		UPDATE TempImportLst
		Set Sel = 'N'
		where TempImportLst.Folio in 
		(select T1.Folio FROM  TempImportLst T1 CROSS JOIN
		                      IMPORTLOG
		WHERE     CHARINDEX(T1.Folio, IMPORTLOG.IML_MENSAJE) > 0
		GROUP BY T1.Folio)

		/* ---------------------------------------*/


			
		UPDATE MAESTRO
		SET MA_EST_MAT='A'
		FROM         MAESTRO RIGHT OUTER JOIN
		                      TempImportLst ON MAESTRO.MA_NOPARTE = TempImportLst.NoParte
		WHERE     (MAESTRO.MA_EST_MAT <>'A') 
			
	
		
		DECLARE CUR_FACTURA CURSOR FOR
			SELECT     Folio, Estatus, Movimiento, (select max(TempImportLst.CantBultos) from TempImportLst where TempImportLst.Folio=TempImportLstSel.Folio)
			FROM         TempImportLstSel
			WHERE Estatus<>'C'
		OPEN CUR_FACTURA
				
		FETCH NEXT FROM CUR_FACTURA INTO @Folio, @estatus, @movimiento, @CantBultos
		
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			if not exists(select * from IMPORTLOG where charindex('No se puede importar La Factura: '+@Folio,IML_MENSAJE)>0 and IML_CBFORMA=-21) 
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			Values('Fue Importada la Factura: '+@Folio, -21)
	
			IF EXISTS(SELECT * FROM TempImportLst WHERE  Folio=@Folio and TipoMcia='MAQ.')
			BEGIN
				IF (SELECT max(TipoImportacion) FROM TempImportLst WHERE Folio=@Folio)='TEMP'
				BEGIN
			  		set @FI_TIPO='F'
			  		set @TF_CODIGO=10 --IMPORTACION TEMPORAL DE ACTIVO FIJO
			  		set @TQ_CODIGO=13 -- TODO TIPO EQUIPO
					select @cp_codigo=cp_codigo from claveped where cp_clave='H3'
				END
				ELSE
				BEGIN
			  		set @FI_TIPO='V'
			  		set @TF_CODIGO=20 -- IMPORTACION VIRTUAL DE ACTIVO FIJO
			  		set @TQ_CODIGO=13
					select @cp_codigo=cp_codigo from claveped where cp_clave='V1'

				END
			END
			ELSE
			BEGIN

				IF (SELECT max(TipoImportacion) FROM TempImportLst WHERE Folio=@Folio)='TEMP'
				BEGIN
			  		set @FI_TIPO='F'
			  		set @TF_CODIGO=5
			  		set @TQ_CODIGO=12
					select @cp_codigo=cp_codigo from claveped where cp_clave='H2'
				END
				ELSE
				BEGIN
			  		set @FI_TIPO='V'
			  		set @TF_CODIGO=11
			  		set @TQ_CODIGO=12
					select @cp_codigo=cp_codigo from claveped where cp_clave='V1'

				END


			END

--			PRINT @estatus
--			PRINT @movimiento

			if @estatus='S' or @estatus='N'
			begin
	
			          if @movimiento='R' -- reemplaza Factura
			         begin
			           delete from FACTIMPDET where FI_codigo in (select FI_codigo from FACTIMP where FI_folio=@Folio)	
  			           delete from FACTIMPcont where FI_codigo in (select FI_codigo from FACTIMP where FI_folio=@Folio)	
			        end	

				if @estatus='N'
				begin
				          EXEC SP_GETCONSECUTIVO @TIPO='FI',@VALUE=@CONSECUTIVOFI OUTPUT
		
	
			
				          INSERT INTO FACTIMP (FI_CODIGO,TF_CODIGO ,FI_FECHA ,FI_TIPOCAMBIO ,FI_FOLIO ,FI_TIPO ,TQ_CODIGO, AG_MEX , AG_USA, 
						CL_COMP, CL_DESTFIN ,CL_DESTINT ,CL_EXP ,CL_IMP ,CL_PROD ,CL_VEND ,
						CT_CODIGO, DI_COMP, DI_DESTFIN ,DI_DESTINT ,DI_EXP ,DI_IMP ,DI_PROD ,DI_PROVEE ,DI_VEND ,FI_PFINAL ,FI_PINICIAL ,IT_CODIGO,
						MO_CODIGO, MT_CODIGO, PR_CODIGO, PU_CARGA, PU_DESTINO, PU_ENTRADA, PU_SALIDA, AGT_CODIGO, CP_CODIGO, FI_TOTALB) 
	
				           SELECT @CONSECUTIVOFI, @TF_CODIGO, @FECHATEXT, dbo.ExchangeRate(@FECHATEXT), @Folio, @FI_TIPO, @TQ_CODIGO, 
						@AG_MEX, @AG_USA, @CL_MATRIZ, @CL_CODIGO, @CL_CODIGO, @CL_MATRIZ, @CL_CODIGO, @CL_MATRIZ, @CL_MATRIZ, 
						@CT_CODIGO, @DIRPRINC, @DIRPRINC, @DIRPRINC, @DIRMATRIZ, @DIRPRINC, @DIRMATRIZ, @DIRMATRIZ, @DIRMATRIZ, @FECHATEXT, @FECHATEXT, 
						@IT_ENTRADA, @MO_CODIGO, @MT_CODIGO, @CL_MATRIZ, @PU_CARGA, @PU_DESTINO, @PU_ENTRADA, @PU_SALIDA,  
						isnull((SELECT AGT_CODIGO FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AG_CODIGO = @AG_MEX),0), @cp_codigo, @CantBultos
	
	
				end


			end

				select @CONSECUTIVOFI=FI_codigo from FACTIMP where FI_folio=@Folio
		
		
				select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=@TQ_CODIGO

		

			UPDATE TempImportLst
			SET     TempImportLst.PesoLb= 0
			WHERE TempImportLst.PesoLb IS NULL 

/*
		
			UPDATE TempImportLst
			SET  TempImportLst.PesoLb = ROUND(PesoTotalLbs/Cantidad,6)
		*/
		
			UPDATE TempImportLst
			SET  TempImportLst.PesoLb = isnull(MAESTRO.MA_PESO_LB,0)
			FROM         MAESTRO INNER JOIN
			                      TempImportLst ON MAESTRO.MA_NOPARTE = TempImportLst.NoParte
			WHERE MA_NOPARTE=TempImportLst.NoParte AND (PesoLb =0)
		
		
			
		
				select @CONSECUTIVOFID=cv_codigo from consecutivo
				where cv_tipo = 'FID'
		

			INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNILB,FID_NOMBRE,FID_NAME,MA_CODIGO,
		                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
		 				       AR_EXPFO,FID_PES_UNI,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
						       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_OBSERVA) 
	
			SELECT     TOP 100 PERCENT dbo.TempImportLst.Codigo+@CONSECUTIVOFID, @CONSECUTIVOFI, max(dbo.TempImportLst.NOPARTE), max(dbo.TempImportLst.CostoUnitUSD), 
			                      sum(dbo.TempImportLst.CANTIDAD), isnull(max(dbo.TempImportLst.PesoLb),0), max(dbo.MAESTRO.MA_NOMBRE), max(dbo.MAESTRO.MA_NAME), 
			                      dbo.MAESTRO.MA_CODIGO, isnull(max(dbo.MAESTRO.TI_CODIGO),10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(max(PAISISO.PA_CODIGO), max(dbo.PAIS.PA_CODIGO)), max(dbo.MAESTRO.PA_ORIGEN)), isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), isnull(max(dbo.MAESTRO.SPI_CODIGO),0)),
						 isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), 
			                      ISNULL(max(dbo.MAESTRO.SPI_CODIGO), 0), ISNULL(isnull(max(PAISISO.PA_CODIGO), max(dbo.PAIS.PA_CODIGO)), max(dbo.MAESTRO.PA_ORIGEN)), isnull(dbo.MAESTRO.MA_GENERICO,0), 
			                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(max(dbo.TempImportLst.PesoLb),0) / 2.20462442018378, 
			                      ISNULL(max(dbo.MAESTRO.EQ_IMPMX), 1), max(ISNULL(dbo.MAESTRO.EQ_EXPFO, 1)), max(ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1)), max(ISNULL(dbo.MAESTRO.EQ_GEN, 1)),  isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), 
			                      isnull(max(dbo.MAESTRO.ME_COM),19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),max(dbo.MAESTRO.ME_COM)),
			                      isnull((SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @CONSECUTIVOFI),0), round(sum(dbo.TempImportLst.CANTIDAD) * isnull(max(dbo.TempImportLst.CostoUnitUSD),0),6), 
			                      round((sum(dbo.TempImportLst.CANTIDAD) * isnull(max(dbo.TempImportLst.PesoLb),0))/2.20462442018378,6), round(sum(dbo.TempImportLst.CANTIDAD) * isnull(max(dbo.TempImportLst.PesoLb),0),6), 
			                      round((sum(dbo.TempImportLst.CANTIDAD) * isnull(max(dbo.TempImportLst.PesoLb),0))/2.20462442018378,6), round(sum(dbo.TempImportLst.CANTIDAD) * isnull(max(dbo.TempImportLst.PesoLb),0),6),
					sum(dbo.TempImportLst.CANTIDAD), 'TCO_CODIGO'=case when max(dbo.MAESTRO.MA_TIP_ENS)='A' THEN  (select TCO_COMPRA from configuracion) ELSE isnull(max(VMAESTROCOST.TCO_CODIGO),0) END, dbo.TempImportLst.OBSERVACIONES
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.TempImportLst ON dbo.MAESTRO.MA_NOPARTE = dbo.TempImportLst.NOPARTE LEFT OUTER JOIN
			                      dbo.PAIS ON dbo.TempImportLst.Pais = dbo.PAIS.PA_CORTO  LEFT OUTER JOIN
					VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
			                      dbo.PAIS PAISISO ON dbo.TempImportLst.Pais = PAISISO.PA_ISO
			WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
			                          (SELECT     TI_CODIGO
			                            FROM          RELTEMBTIPO
			                            WHERE      TQ_CODIGO = @TQ_CODIGO)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
		
					dbo.TempImportLst.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
								FROM         dbo.MAESTRO
								GROUP BY MA_NOPARTE
								HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
							                          (SELECT NOPARTE FROM TempImportLst)))
					and TempImportLst.Folio in 
						(SELECT     Folio
						FROM         TempImportLstSel
						WHERE     Sel = 'S')
	
			GROUP BY dbo.TempImportLst.Codigo, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO,  dbo.TempImportLst.OBSERVACIONES
			ORDER BY dbo.TempImportLst.Codigo
		
			
			
			update factimp
			set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
			where fi_codigo =@CONSECUTIVOFI
		
		/*
			update factimpdet
			set eq_gen=fid_pes_uni
			where me_gen=36 and fi_codigo=@CONSECUTIVOFI
			update factimpdet
			set eq_impmx=fid_pes_uni
			where me_arimpmx=36 and fi_codigo=@CONSECUTIVOFI
		*/
		
	
			if (SELECT CF_VALIDAPERMISOS FROM CONFIGURACION)='I'
			EXEC SP_INSERTPERMISODET @CONSECUTIVOFI
		
			-- cambia el tipo de tasa en base a la configuracion
			/*if (select CF_ACTTASA from configuracion)='S'
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'PARA ACTUALIZAR A LA TASA MAS BAJA DEBERA DE EJECUTAR EN PROCESO MANUALMENTE POR MEDIO DE INFORANEXA', -21*/



			if (SELECT CF_TASABAJAFIIMPORTA FROM CONFIGURACION)='S'
			EXEC SP_ACTUALIZATASABAJAFACTIMP @CONSECUTIVOFI


			if (select cf_selpaisimp from configuracion)='S'
			EXEC SP_ACTUALIZAIMPEXCELPROVEE @CONSECUTIVOFI, 'F'

		
			EXEC sp_actualizaReferencia @CONSECUTIVOFI
			
					
			
			select @FID_INDICED= max(FID_INDICED) from FACTIMPDET
			
				update consecutivo
				set cv_codigo =  isnull(@FID_indiced,0) + 1
				where cv_tipo = 'FID'
			
		
		
		
			FETCH NEXT FROM CUR_FACTURA INTO @Folio, @estatus, @movimiento, @CantBultos
		
		END
		
		CLOSE CUR_FACTURA
		DEALLOCATE CUR_FACTURA

		ALTER TABLE FACTIMPDET ENABLE TRIGGER Update_FACTIMPDET
		
	end
	else
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		values('No existen facturas seleccionas para su importacion', -21)

	exec sp_droptable 'TempImportLstSel'
	CREATE TABLE [dbo].[TempImportLstSel] (
		[Fecha] [datetime] NULL ,
		[Folio] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Estatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Movimiento] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	) ON [PRIMARY]

GO
