SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















CREATE PROCEDURE [dbo].[SP_TempMaq100F]   as

SET NOCOUNT ON 
DECLARE @NOPARTE VARCHAR(50),@CANTIDAD decimal(38,6),@COSTO decimal(38,6),@PESO decimal(38,6),@CONSECUTIVOFE INTEGER, @CONSECUTIVOFED INTEGER,
@MA_GRAV_MP decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_GRAV_EMP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_GI decimal(38,6), 
@MA_GRAV_GI_MX decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_EMP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_USA decimal(38,6), 
@FED_indiced INT, @cf_pesos_exp CHAR(1), @CL_DESTINI INT, @cfq_tipo char(1), @FECHATEXT VARCHAR(11),
@fe_fecha datetime, @FE_DESTINO char(1), @AG_MEX INT,  @AG_USA INT, @CL_CODIGO int, @CL_MATRIZ int, 
@CL_TRAFICO int, @CT_CODIGO int, @MT_CODIGO int, @PU_CARGA int, @PU_DESTINO int, 
@PU_ENTRADA int, @PU_SALIDA int, @ZO_CODIGO int, @IT_CODIGO int, @MO_CODIGO int, 
@DIRPRINC int, @DIRMATRIZ int, @Tf_codigo int, @cp_codigo int, @Folio varchar(25), @Localizacion varchar(5),
@estatus char(1), @movimiento char(1), @DI_DESTFIN INT, @CL_DESTFIN INT, @CL_COMP INT, @DI_COMP INT

/*
INSERT INTO TempMaq100FSel(FacturaQ2C, FechaOrdCerrada, Localizacion) 
SELECT FacturaQ2C, FechaOrdCerrada, Localizacion 
FROM         TempMaq100F 
WHERE Sel='S'
GROUP BY FacturaQ2C, FechaOrdCerrada, Localizacion 
*/




	if (SELECT count(*) FROM TempMaq100FSel)>0
	begin


		ALTER TABLE FACTEXPDET DISABLE TRIGGER Update_FactExpDet
	
	
	         SELECT @AG_MEX=AG_MEX,  @AG_USA=AG_USA, @CL_CODIGO=CL_CODIGO, @CL_MATRIZ=CL_MATRIZ, @CL_TRAFICO=CL_TRAFICO, 
			@CT_CODIGO=CT_CODIGO, @MT_CODIGO=MT_CODIGO, @PU_CARGA=PU_CARGA, @PU_DESTINO=PU_DESTINO, 
			@PU_ENTRADA=PU_ENTRADA, @PU_SALIDA=PU_SALIDA, @ZO_CODIGO=ZO_CODIGO,
			@MO_CODIGO=MO_CODIGO, 
	 		@DIRPRINC=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_CODIGO),
			@DIRMATRIZ=(SELECT DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=CLIENTE.CL_MATRIZ)
		 FROM CLIENTE    WHERE CL_EMPRESA='S'



	
		SET @FECHATEXT = dbo.DateToText(GETDATE(),101)
	
	

		/*  ------------------- REVISIONES -----------------*/

			delete from TempMaq100F where NoCatalogo=''


			UPDATE dbo.TempMaq100F
			SET     dbo.TempMaq100F.CostoStd= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
			FROM         dbo.TempMaq100F INNER JOIN dbo.MAESTRO ON dbo.TempMaq100F.NoCatalogo = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
			                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
			WHERE dbo.VMAESTROCOST.SPI_CODIGO=22 AND (dbo.TempMaq100F.CostoStd=0 OR dbo.TempMaq100F.CostoStd IS NULL)


			UPDATE dbo.TempMaq100F
			SET     dbo.TempMaq100F.CostoStd= 0
			WHERE dbo.TempMaq100F.CostoStd IS NULL 
		

			
		
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
				SELECT     'No se puede importar La Factura: '+FacturaQ2C+' porque el No. Parte : ' +dbo.TempMaq100F.NoCatalogo +' porque no existe en el cat. maestro', -20
				FROM         dbo.MAESTRO RIGHT OUTER JOIN
				                      dbo.TempMaq100F ON dbo.MAESTRO.MA_NOPARTE = dbo.TempMaq100F.NoCatalogo
				WHERE     (dbo.MAESTRO.MA_NOPARTE IS NULL) and FacturaQ2C in (select FacturaQ2C from dbo.TempMaq100FSel)

/*

				SELECT     'No se puede importar La Factura: '+FacturaQ2C+' porque el No. Parte : ' +NoCatalogo +' no cuenta con costo unitario ', -20
				FROM TempMaq100F
				WHERE TempMaq100F.CostoStd= 0
			


				if (select cf_sicexexp from configuracion)='S'
				begin
					if (select cf_permisoaviso from configuracion)='S'
					begin
						INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
						SELECT     'No se puede importar La Factura: '+FacturaQ2C+' porque el No. Parte: '+dbo.MAESTRO.MA_NOPARTE+' no cuenta con permiso SICEX', -20
						FROM         dbo.MAESTRO INNER JOIN
						             dbo.TempMaq100F ON dbo.MAESTRO.MA_NOPARTE = dbo.TempMaq100F.NoCatalogo
						WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND dbo.MAESTRO.MA_CODIGO NOT IN
						(SELECT     dbo.MAESTROCATEG.MA_CODIGO
						FROM         dbo.MAESTROCATEG INNER JOIN
						                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
						                      dbo.IDENTIFICA INNER JOIN
						                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
						WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX')))
						GROUP BY dbo.MAESTRO.MA_NOPARTE, dbo.TempMaq100F.FacturaQ2C
					end
					else
					if (select cf_permisoaviso from configuracion)='X'
					begin
						INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
						SELECT     'No se puede importar La Factura: '+FacturaQ2C+' porque no se puede importar el No. Parte: ' + dbo.MAESTRO.MA_NOPARTE+' no cuenta con permiso SICEX', -20
						FROM         dbo.MAESTRO INNER JOIN
						             dbo.TempMaq100F ON dbo.MAESTRO.MA_NOPARTE = dbo.TempMaq100F.NoCatalogo
						WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND dbo.MAESTRO.MA_CODIGO NOT IN
						(SELECT     dbo.MAESTROCATEG.MA_CODIGO
						FROM         dbo.MAESTROCATEG INNER JOIN
						                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
						                      dbo.IDENTIFICA INNER JOIN
						                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
						WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX')))
						GROUP BY dbo.MAESTRO.MA_NOPARTE, dbo.TempMaq100F.FacturaQ2C
			
			
						DELETE FROM dbo.TempMaq100F
						WHERE dbo.TempMaq100F.NoCatalogo IN
							(SELECT     dbo.MAESTRO.MA_NOPARTE
							FROM         dbo.MAESTRO INNER JOIN
							             dbo.TempMaq100F ON dbo.MAESTRO.MA_NOPARTE = dbo.TempMaq100F.NoCatalogo
							WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND dbo.MAESTRO.MA_CODIGO NOT IN
								(SELECT     dbo.MAESTROCATEG.MA_CODIGO
								FROM         dbo.MAESTROCATEG INNER JOIN
								                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
								                      dbo.IDENTIFICA INNER JOIN
								                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
								WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX')))
						GROUP BY dbo.MAESTRO.MA_NOPARTE)
					end
			
				end
*/

		-- deselecciona las facturas con problemas
		
		UPDATE TempMaq100F
		Set Sel = 'N'
		where TempMaq100F.FacturaQ2C in 
		(select T1.FacturaQ2C FROM  TempMaq100F T1 CROSS JOIN
		                      IMPORTLOG
		WHERE     CHARINDEX(T1.FacturaQ2C, IMPORTLOG.IML_MENSAJE) > 0
		GROUP BY T1.FacturaQ2C)

		/* ---------------------------------------*/


			
		UPDATE dbo.MAESTRO
		SET MA_EST_MAT='A'
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      dbo.TempMaq100F ON dbo.MAESTRO.MA_NOPARTE = dbo.TempMaq100F.NoCatalogo
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') 
			
	
		
		DECLARE CUR_FACTURA CURSOR FOR
			SELECT     FacturaQ2C, Localizacion, Estatus, Movimiento
			FROM         TempMaq100FSel
			WHERE Estatus<>'C'
		OPEN CUR_FACTURA
				
		FETCH NEXT FROM CUR_FACTURA INTO @Folio, @Localizacion, @estatus, @movimiento
		
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			if not exists(select * from IMPORTLOG where charindex('No se puede importar La Factura: '+@Folio,IML_MENSAJE)>0 and IML_CBFORMA=-20) 
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			VALUES ('Fue Importada la Factura: '+@Folio, -20)
	

	 		SELECT @DI_DESTFIN=max(DI_INDICE) FROM DIR_CLIENTE WHERE DI_LOCPLANTA=@Localizacion
	 		SELECT @CL_DESTFIN=max(CL_CODIGO) FROM DIR_CLIENTE WHERE DI_INDICE=@DI_DESTFIN

			--1 CAMBIO DE REGIMEN (MERCADO NACIONAL)		
			--2 EXPORTACION DEFINITIVA	
			/*if @Localizacion ='099' or @Localizacion ='039' or @Localizacion ='0  ' or @Localizacion ='   ' 
		  		set @TF_CODIGO=1
			else	
				set @TF_CODIGO=2*/


			IF @Localizacion='099' or @Localizacion='039' or @Localizacion='SDS' or @Localizacion='0  '
			BEGIN
		  		set @TF_CODIGO=12
				select @cp_codigo=cp_codigo from claveped where cp_clave='V5'
				SELECT @IT_CODIGO=IT_CODIGO FROM INCOTERMS WHERE IT_CLAVE='EXW'

				SET @AG_MEX=9
				SELECT @AG_USA=10

				SET   @CL_COMP= @CL_MATRIZ 
				SET @DI_COMP=@DIRMATRIZ


			END
			ELSE
	 		IF (SELECT PA_CODIGO FROM DIR_CLIENTE WHERE DI_INDICE=@DI_DESTFIN)=154
			BEGIN
		  		set @TF_CODIGO=1
				select @cp_codigo=cp_codigo from claveped where cp_clave='CN'
				SELECT @IT_CODIGO=IT_CODIGO FROM INCOTERMS WHERE IT_CLAVE='FCA'


				SET @AG_MEX=2
				SELECT @AG_USA=10

				SET   @CL_COMP= @CL_MATRIZ 
				SET @DI_COMP=@DIRMATRIZ


			END
			ELSE
			BEGIN
				set @TF_CODIGO=2
				select @cp_codigo=cp_codigo from claveped where cp_clave='J1'
				SELECT @IT_CODIGO=IT_CODIGO FROM INCOTERMS WHERE IT_CLAVE='DAF'

				SET @AG_MEX=2
				SELECT @AG_USA=5

				SELECT   @CL_COMP= CL_COMP 
				FROM         CLIENTEENTIDADES
				WHERE     (OM_TIPO = 'S') AND (TF_CODIGO = 2)


				SELECT @DI_COMP=DI_INDICE FROM DIR_CLIENTE WHERE DI_FISCAL='S' AND CL_CODIGO=@CL_COMP

			END

		

		
			if @estatus='S' OR @estatus='N'
			begin
	
			          if @movimiento='R' -- reemplaza Factura
			         begin
			           delete from factexpdet where fe_codigo in (select fe_codigo from factexp where fe_folio=@Folio)	
  			           delete from factexpcont where fe_codigo in (select fe_codigo from factexp where fe_folio=@Folio)	
			        end	

				if @estatus='N'
				begin
				          EXEC SP_GETCONSECUTIVO @TIPO='FE',@VALUE=@CONSECUTIVOFE OUTPUT
			
				          INSERT INTO FACTEXP (FE_CODIGO, TF_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_FOLIO, FE_TIPO, TQ_CODIGO, 
						AG_MX, AG_US, CL_COMP, CL_DESTFIN, CL_DESTINI, CL_EXP, CL_IMP, CL_PROD, CL_VEND,
						CT_COMPANY1, DI_COMP, DI_DESTFIN, DI_DESTINI, DI_EXP, DI_IMP, DI_PROD,  DI_VEND, FE_PFINAL, FE_PINICIAL, IT_COMPANY1,
						MO_CODIGO, MT_COMPANY1, PU_CARGA, PU_DESTINO, PU_ENTRADA, PU_SALIDA, CL_EXPFIN, DI_EXPFIN, AGT_CODIGO, CP_CODIGO) 
			
		
				           SELECT @CONSECUTIVOFE, @TF_CODIGO, @FECHATEXT, dbo.ExchangeRate(@FECHATEXT), @Folio, 'FE_TIPO'=CASE WHEN @Localizacion='099' THEN 'V' ELSE 'F' END, 3, 
						@AG_MEX, @AG_USA, @CL_COMP, @CL_DESTFIN, @CL_DESTFIN, @CL_CODIGO, @CL_TRAFICO, @CL_CODIGO, @CL_CODIGO, 
						@CT_CODIGO, @DI_COMP, @DI_DESTFIN, @DI_DESTFIN, @DIRPRINC, @DIRPRINC, @DIRPRINC, @DIRPRINC, @FECHATEXT, @FECHATEXT, 
						@IT_CODIGO, @MO_CODIGO, @MT_CODIGO, @PU_CARGA, @PU_DESTINO, @PU_ENTRADA, @PU_SALIDA,  @CL_CODIGO, @DIRPRINC,
						isnull((SELECT AGT_CODIGO FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AG_CODIGO = @AG_MEX),0), @cp_codigo
				end
			end

			select @CONSECUTIVOFE=fe_codigo from factexp where fe_folio=@Folio
	
		
		
			SELECT @CL_DESTINI=CL_DESTINI, @fe_fecha=FE_FECHA, @FE_DESTINO=isnull(FE_DESTINO,'') FROM FACTEXP WHERE FE_CODIGO=@CONSECUTIVOFE
			
			
			select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=3
			
		

			UPDATE dbo.TempMaq100F
			SET     dbo.TempMaq100F.PesoKg= 0
			WHERE dbo.TempMaq100F.PesoKg IS NULL 

		
			UPDATE dbo.TempMaq100F
			SET  dbo.TempMaq100F.PesoKg = round(isnull(dbo.MAESTRO.MA_PESO_KG,0),6)
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.TempMaq100F ON dbo.MAESTRO.MA_NOPARTE = dbo.TempMaq100F.NoCatalogo
			WHERE MA_NOPARTE=TempMaq100F.NoCatalogo AND (PesoKg =0)
		
		
			
		
				select @CONSECUTIVOFED=cv_codigo from consecutivo
				where cv_tipo = 'FED'
			
		
				--PRINT @CONSECUTIVOFED
		
				INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
			                                                             FED_CANT,FED_PES_UNI,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
			                                                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
			 				        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
							        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
			 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
							FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNILB,
							FED_CANTEMP, MA_EMPAQUE, fed_SALDO,TCO_CODIGO, FED_NAFTA, CL_CODIGO,FED_PARTTYPE, SE_CODIGO, FED_NOORDEN, LE_FOLIO, FED_FECHA_STRUCT)	

			          SELECT @CONSECUTIVOFED+Codigo, @CONSECUTIVOFE, dbo.TempMaq100F.NoCatalogo, dbo.TempMaq100F.CostoStd,   dbo.TempMaq100F.CostoStd,  
			                dbo.TempMaq100F.CANTIDAD, isnull(dbo.TempMaq100F.PesoKg,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.PA_ORIGEN,0), 
					isnull(dbo.MAESTRO.MA_GENERICO,0), isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.MA_DISCHARGE, 'S'), 'MA_TIP_ENS'=CASE WHEN @cfq_tipo='T' THEN 'C'  ELSE (case when dbo.MAESTRO.MA_TIP_ENS='A' then 'F' else dbo.MAESTRO.MA_TIP_ENS end) END,
		 			'AR_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.AR_IMPFO,0) else isnull(dbo.MAESTRO.AR_IMPFOUSA,0) end) else isnull(dbo.MAESTRO.AR_IMPFO,0) end) end,
		  	                'EQ_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.EQ_IMPFO,1) else isnull(dbo.MAESTRO.EQ_IMPFOUSA,1) end) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end) end, 
					isnull(dbo.MAESTRO.EQ_GEN,1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), -1, isnull(dbo.MAESTRO.ME_COM,19), 
					'AR_EXPMX'=CASE when @cfq_tipo='D' and @FE_DESTINO='N' then isnull(dbo.MAESTRO.AR_DESPMX,0) else  isnull(dbo.MAESTRO.AR_EXPMX,0) end, 'EQ_EXPMX'=CASE when @cfq_tipo='D' and @FE_DESTINO='N' then isnull(dbo.MAESTRO.EQ_DESPMX,1) else isnull(dbo.MAESTRO.EQ_EXPMX,1) end, isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=dbo.MAESTRO.MA_GENERICO),19), 	
					isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_EXPMX),0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
				round(isnull(dbo.TempMaq100F.CostoStd*dbo.TempMaq100F.CANTIDAD,0),6),
				round(isnull(dbo.TempMaq100F.CANTIDAD* dbo.TempMaq100F.PesoKg,0),6), 
				round(isnull(dbo.TempMaq100F.CANTIDAD* dbo.TempMaq100F.PesoKg * 2.20462442018378,0),6),
				round(isnull(dbo.TempMaq100F.CANTIDAD* dbo.TempMaq100F.PesoKg,0),6), 
				round(isnull(dbo.TempMaq100F.CANTIDAD* dbo.TempMaq100F.PesoKg * 2.20462442018378,0),6),
				round(isnull(dbo.TempMaq100F.PesoKg*2.20462442018378,0),6), 
				'CANTEMP'=CASE WHEN dbo.MAESTRO.MA_CANTEMP>0 THEN CEILING(dbo.TempMaq100F.CANTIDAD/dbo.MAESTRO.MA_CANTEMP) ELSE 0 END, 
				IsNull(dbo.MAESTRO.MA_EMPAQUE,0),dbo.TempMaq100F.CANTIDAD, 
				'tco_codigo'=case when @cfq_tipo='D' and (select count(ma_codigo) from maestrocost where ma_codigo=dbo.MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
						then (select tco_desperdicio from configuracion) else (case when @cfq_tipo='T' AND (select CF_TCOCOMPRAIMP from configuracion)='S' then (select tco_compra from configuracion) else isnull(dbo.VMAESTROCOST.TCO_CODIGO,0) end) end, 
				'N',
				isnull(@CL_DESTINI,0),
				'FED_PARTTYPE'=CASE WHEN @cfq_tipo='D' THEN 'S' 	WHEN (@cfq_tipo<>'D' AND (dbo.MAESTRO.TI_CODIGO=14 OR dbo.MAESTRO.TI_CODIGO=16))
				THEN 'A'  WHEN (@cfq_tipo<>'D' AND dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16) THEN 'U' END,
				isnull(dbo.MAESTRO.SE_CODIGO,0), dbo.TempMaq100F.NoOrden, @Folio, @FE_FECHA
				FROM         dbo.TempMaq100F LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.TempMaq100F.NoCatalogo = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
				                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
						      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE dbo.TempMaq100F.FacturaQ2C = @Folio   
				AND dbo.TempMaq100F.NoCatalogo NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
								                          (SELECT NoCatalogo FROM TempMaq100F)))
					and dbo.TempMaq100F.FacturaQ2C in 
						(SELECT     FacturaQ2C
						FROM         TempMaq100FSel WHERE ESTATUS ='N' OR ESTATUS ='S')
					and 'No se puede importar La Factura: '+dbo.TempMaq100F.FacturaQ2C+' porque el No. Parte : ' +dbo.TempMaq100F.NoCatalogo +' porque no existe en el cat. maestro' not in
				(select IML_MENSAJE from IMPORTLOG where IML_CBFORMA=-20)



			             ORDER BY Codigo
		
			
				UPDATE FACTEXPDET
				SET FED_NAFTA=dbo.GetNafta (@fe_fecha, FACTEXPDET.MA_CODIGO, FACTEXPDET.AR_IMPMX, FACTEXPDET.PA_CODIGO, FACTEXPDET.FED_DEF_TIP, FACTEXPDET.FED_TIP_ENS)
				FROM FACTEXPDET 
				WHERE FE_CODIGO=@CONSECUTIVOFE
			
				UPDATE FACTEXPDET
				SET FED_RATEIMPFO=(CASE WHEN FED_NAFTA='S' THEN 0 ELSE dbo.GetAdvalorem(AR_IMPFO, 0, 'G', 0, 0) END)
				FROM FACTEXPDET 
				WHERE FE_CODIGO=@CONSECUTIVOFE
			
		
				UPDATE FACTEXPDET
				SET FED_GRA_MP=isnull(dbo.MAESTROCOST.MA_GRAV_MP,0), 
				FED_GRA_MO=isnull(dbo.MAESTROCOST.MA_GRAV_MO,0), 
				FED_GRA_EMP=isnull(dbo.MAESTROCOST.MA_GRAV_EMP,0), 
				FED_GRA_ADD=isnull(dbo.MAESTROCOST.MA_GRAV_ADD,0), 
				FED_GRA_GI=isnull(dbo.MAESTROCOST.MA_GRAV_GI,0), 
				FED_GRA_GI_MX=isnull(dbo.MAESTROCOST.MA_GRAV_GI_MX,0), 
				FED_NG_MP=isnull(dbo.MAESTROCOST.MA_NG_MP,0), 
				FED_NG_EMP=isnull(dbo.MAESTROCOST.MA_NG_EMP,0), 
				FED_NG_ADD=isnull(dbo.MAESTROCOST.MA_NG_ADD,0), 
				FED_NG_USA=isnull(dbo.MAESTROCOST.MA_NG_USA,0)
				FROM FACTEXPDET 
				LEFT OUTER JOIN dbo.MAESTROCOST ON FACTEXPDET.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO 
				AND FACTEXPDET.TCO_CODIGO = dbo.MAESTROCOST.TCO_CODIGO 
				LEFT OUTER JOIN dbo.CONFIGURATIPO ON FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE FE_CODIGO=@CONSECUTIVOFE
				AND dbo.MAESTROCOST.MAC_CODIGO IN (SELECT MAX(M1.MAC_CODIGO) 
									FROM MAESTROCOST M1 
									WHERE M1.SPI_CODIGO = 22 AND M1.MA_PERINI <= GETDATE() AND M1.MA_PERFIN >= GETDATE() 
										AND M1.TCO_CODIGO = FACTEXPDET.TCO_CODIGO 
										AND M1.MA_CODIGO = FACTEXPDET.MA_CODIGO)
				and FACTEXPDET.tco_codigo in (select tco_manufactura from configuracion)
			
		
		
				UPDATE FACTEXPDET
				set FED_COS_UNI=round(isnull(FED_GRA_MP+FED_GRA_MO+FED_GRA_EMP+ FED_GRA_ADD+
					FED_GRA_GI+ FED_GRA_GI_MX+ FED_NG_MP+ FED_NG_EMP+ FED_NG_ADD,0),6)
				FROM FACTEXPDET
				WHERE  FE_CODIGO=@CONSECUTIVOFE
				and FACTEXPDET.tco_codigo in (select tco_manufactura from configuracion)
			
			
				UPDATE FACTEXPDET
				SET FED_COS_TOT=round(isnull(FED_COS_UNI*FED_CANT,0),6)
				WHERE  FE_CODIGO=@CONSECUTIVOFE and FED_COS_TOT<>round(isnull(FED_COS_UNI*FED_CANT,0),6)
			
			
				UPDATE FACTEXPDET
				SET ME_AREXPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = FACTEXPDET.AR_EXPMX),19)
				WHERE FE_CODIGO=@CONSECUTIVOFE
		
		
				  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) <> 'N'  
				  begin
					  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) = 'S' 
					  begin
						INSERT INTO FACTEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, FE_CODIGO, FED_INDICED)
						SELECT     dbo.CARGORELARANCEL.CAR_CODIGO, dbo.CARGODET.CARD_VALOR, dbo.CARGO.CAR_TIPO,  dbo.FACTEXPDET.FE_CODIGO, 
						                      dbo.FACTEXPDET.FED_INDICED
						FROM         dbo.FACTEXPDET INNER JOIN
						                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
						                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
						                      dbo.CARGORELARANCEL INNER JOIN
						                      dbo.CARGODET ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGODET.CAR_CODIGO INNER JOIN
						                      dbo.CARGO ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGO.CAR_CODIGO ON 
						                      dbo.FACTEXP.FE_FECHA >= dbo.CARGODET.CARD_FECHAINI AND dbo.FACTEXP.FE_FECHA <= dbo.CARGODET.CARD_FECHAFIN AND 
						                      dbo.FACTEXP.CL_DESTINI = dbo.CARGORELARANCEL.CL_CODIGO AND dbo.MAESTRO.AR_EXPMX = dbo.CARGORELARANCEL.AR_CODIGO
						WHERE dbo.FACTEXPDET.FE_CODIGO=@CONSECUTIVOFE
					  end
					  else
					  begin
						INSERT INTO FACTEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, FE_CODIGO, FED_INDICED)
						SELECT     dbo.CARGORELARANCEL.CAR_CODIGO, dbo.CARGODET.CARD_VALOR, dbo.CARGO.CAR_TIPO,  dbo.FACTEXPDET.FE_CODIGO, 			
						                      dbo.FACTEXPDET.FED_INDICED
						FROM         dbo.FACTEXPDET INNER JOIN
						                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
						                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
						                      dbo.CARGORELARANCEL INNER JOIN
						                      dbo.CARGODET ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGODET.CAR_CODIGO INNER JOIN
						                      dbo.CARGO ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGO.CAR_CODIGO ON 
						                      dbo.FACTEXP.FE_FECHA >= dbo.CARGODET.CARD_FECHAINI AND dbo.FACTEXP.FE_FECHA <= dbo.CARGODET.CARD_FECHAFIN AND 
						                      dbo.FACTEXP.CL_DESTINI = dbo.CARGORELARANCEL.CL_CODIGO AND dbo.MAESTRO.LIN_CODIGO = dbo.CARGORELARANCEL.LIN_CODIGO
						WHERE dbo.FACTEXPDET.FE_CODIGO=@CONSECUTIVOFE
					  end
				end	
			
				
			
				update factexpdet				set ar_orig= case when fed_nafta='S' then
					 0 else ( case when isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0)=0 
					then  isnull((select AR_IMPFOUSA from maestro where maestro.ma_codigo=factexpdet.ma_codigo),0)  else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end) end
				where (ar_orig is null or ar_orig =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
				and fed_ng_usa>0 and fe_codigo=@CONSECUTIVOFE
				
			
				update factexpdet
				set ar_ng_emp= case when fed_nafta='S' then
				 0 else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='3' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end
				where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
				and fed_ng_emp>0 and fe_codigo=@CONSECUTIVOFE
		
		
				UPDATE dbo.FACTEXPDET
				SET     dbo.FACTEXPDET.FED_DESTNAFTA= CASE 
				when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
				 when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
				then 'N'  WHEN 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
				then 'U' when 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
				then 'A'  else 'F' end
				FROM         dbo.FACTEXPDET INNER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
				                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE
				where  dbo.FACTEXPDET.FE_CODIGO = @CONSECUTIVOFE 
			
			
			
				select @FED_indiced= max(FED_indiced) from FACTEXPDET
				
					update consecutivo
					set cv_codigo =  isnull(@FED_indiced,0) + 1
					where cv_tipo = 'FED'
			
		
		
			--	exec SP_ACTUALIZAFED_FECHA_STRUCT @CONSECUTIVOFE
			
				update factexp
				set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
				where fe_codigo =@CONSECUTIVOFE
		
		
			FETCH NEXT FROM CUR_FACTURA INTO @Folio, @Localizacion, @estatus, @movimiento
		
		END
		
		CLOSE CUR_FACTURA
		DEALLOCATE CUR_FACTURA

		ALTER TABLE FACTEXPDET ENABLE TRIGGER Update_FactExpDet
		
	end
	else
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		values('No existen facturas seleccionas para su importacion', -20)

	exec sp_droptable 'TempMaq100FSel'
	CREATE TABLE [dbo].[TempMaq100FSel] (
		[FechaOrdCerrada] [datetime] NULL ,
		[FacturaQ2C] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Localizacion] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Estatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[Movimiento] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	) ON [PRIMARY]

GO
