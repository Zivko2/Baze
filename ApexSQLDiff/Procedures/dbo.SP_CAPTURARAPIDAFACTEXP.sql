SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CAPTURARAPIDAFACTEXP] (@Codigo int, @agrupacion char(1))   as

SET NOCOUNT ON 
DECLARE @NOPARTE VARCHAR(50),@CANTIDAD decimal(38,6),@COSTO decimal(38,6),@PESO decimal(38,6),@CONSECUTIVO INTEGER,
@MA_GRAV_MP decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_GRAV_EMP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_GI decimal(38,6), 
@MA_GRAV_GI_MX decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_EMP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_USA decimal(38,6), 
@FED_indiced INT, @cf_pesos_exp CHAR(1), @TipoEntrada char,@TipoEmbarque int, @CL_DESTINI INT, @cfq_tipo char(1), @fe_fecha datetime



DELETE FROM IMPORTLOG WHERE IML_CBFORMA=-20


	IF (SELECT COUNT(*) FROM CAPTURARAPIDA WHERE codigofact=@Codigo and tipofact='X')>0
	BEGIN

			ALTER TABLE FACTEXPDET DISABLE TRIGGER Update_FactExpDet
		
			select @cf_pesos_exp = cf_pesos_exp from configuracion 
		
		DELETE FROM CAPTURARAPIDA WHERE NOPARTE='-1'
		
		
		  DECLARE @ERRORES INT
		  SET @ERRORES  = 0
		
		SET @TipoEntrada ='I'
		SELECT @TipoEmbarque =TQ_CODIGO, @CL_DESTINI=CL_DESTINI, @fe_fecha=fe_fecha FROM FACTEXP WHERE FE_CODIGO=@Codigo
		
		
		select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=@TipoEmbarque
		
		if (select cf_tipocosto from configuracion)='N'
		begin
			UPDATE dbo.CAPTURARAPIDA
			SET     dbo.CAPTURARAPIDA.COSTO= round(ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0),6)
			FROM         dbo.CAPTURARAPIDA INNER JOIN
			                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
			                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
			WHERE dbo.CAPTURARAPIDA.COSTO=0 OR dbo.CAPTURARAPIDA.COSTO IS NULL
		
			UPDATE dbo.CAPTURARAPIDA
			SET     dbo.CAPTURARAPIDA.COSTO= round(ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0),6)
			FROM         dbo.CAPTURARAPIDA INNER JOIN
			                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
			                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
			WHERE dbo.MAESTRO.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P', 'S'))
		
		end
		else
		begin
			if @cfq_tipo='D'
			begin
				UPDATE dbo.CAPTURARAPIDA
				SET     dbo.CAPTURARAPIDA.COSTO= ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)
				FROM         dbo.CAPTURARAPIDA INNER JOIN
				                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
				                      dbo.MAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO
				WHERE (dbo.CAPTURARAPIDA.COSTO=0 OR dbo.CAPTURARAPIDA.COSTO IS NULL)
				AND dbo.MAESTROCOST.TCO_CODIGO IN (SELECT TCO_DESPERDICIO FROM CONFIGURACION)
				AND ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)>0
		
		
				-- si no encuentra tipo de costo de desperdicio asigna el de manufactura o compra
				UPDATE dbo.CAPTURARAPIDA
				SET     dbo.CAPTURARAPIDA.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
				FROM         dbo.CAPTURARAPIDA INNER JOIN
				                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
				                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
				WHERE dbo.CAPTURARAPIDA.COSTO=0 OR dbo.CAPTURARAPIDA.COSTO IS NULL
			end
			else
			begin
				UPDATE dbo.CAPTURARAPIDA
				SET     dbo.CAPTURARAPIDA.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
				FROM         dbo.CAPTURARAPIDA INNER JOIN
				                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
				                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
				WHERE dbo.CAPTURARAPIDA.COSTO=0 OR dbo.CAPTURARAPIDA.COSTO IS NULL
		
			end
		end
		
		
		
		
		IF @cf_pesos_exp='K'
		BEGIN
			UPDATE dbo.CAPTURARAPIDA
			SET  dbo.CAPTURARAPIDA.PESO = isnull(dbo.MAESTRO.MA_PESO_KG,0)
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
			               dbo.MAESTRO.TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
			                AND MA_EST_MAT = 'A' AND MA_NOPARTE=CAPTURARAPIDA.NOPARTE AND (PESO IS NULL OR PESO =0.0)
		END
		ELSE
		BEGIN
			UPDATE dbo.CAPTURARAPIDA
			SET  dbo.CAPTURARAPIDA.PESO = isnull(dbo.MAESTRO.MA_PESO_LB,0)
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
			               dbo.MAESTRO.TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
			                AND MA_EST_MAT = 'A' AND MA_NOPARTE=CAPTURARAPIDA.NOPARTE AND (PESO IS NULL OR PESO =0.0)
		END
		

		
		delete from CAPTURARAPIDA where NOPARTE=''
		
		if exists(SELECT dbo.CAPTURARAPIDA.NOPARTE
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE     (dbo.MAESTRO.MA_NOPARTE IS NULL))
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURARAPIDA.NOPARTE +' POR QUE NO EXISTE EN EL CAT. MAESTRO', -20 
			FROM         dbo.MAESTRO RIGHT OUTER JOIN
			                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
			WHERE     (dbo.MAESTRO.MA_NOPARTE IS NULL) and codigofact=@Codigo and tipofact='X'
		
		
		
		
			if exists (SELECT     dbo.CAPTURARAPIDA.NOPARTE
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
				WHERE     codigofact=@Codigo and tipofact='X' and (NOT (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     ti_codigo
		                            FROM          reltembtipo
		                           WHERE      tq_codigo = @TipoEmbarque))))
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURARAPIDA.NOPARTE+' POR LA RELACION TIPO EMBARQUE-TIPO MATERIAL', -20
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.CAPTURARAPIDA ON dbo.MAESTRO.MA_NOPARTE = dbo.CAPTURARAPIDA.NOPARTE
				WHERE     codigofact=@Codigo and tipofact='X' and (NOT (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
			'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.CAPTURARAPIDA.NOPARTE +' POR QUE NO EXISTE EN EL CAT. MAESTRO' 
			not in (SELECT IML_MENSAJE FROM IMPORTLOG)
		
		
			if exists(SELECT     dbo.MAESTRO.MA_NOPARTE
			FROM         dbo.MAESTRO
			GROUP BY MA_NOPARTE
			HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
			                          (SELECT NOPARTE FROM CAPTURARAPIDA)))
		
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE + ' PORQUE ESTA REPETIDO EN EL CAT. MAESTRO', -20 
			FROM         dbo.MAESTRO
			GROUP BY MA_NOPARTE
			HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
			                          (SELECT NOPARTE FROM CAPTURARAPIDA))
		
		
			select @consecutivo=cv_codigo from consecutivo
			where cv_tipo = 'FED'
		
		
			if @agrupacion='N'
			begin
		
				INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
				                             FED_CANT,FED_PES_UNI,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
				                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
						        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
						        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
			 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
							FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNILB,
							FED_CANTEMP, MA_EMPAQUE, fed_SALDO,TCO_CODIGO, FED_NAFTA, CL_CODIGO, FED_ORD_COMP)	
			          SELECT @consecutivo+ORDEN, @Codigo, dbo.CAPTURARAPIDA.NOPARTE, dbo.CAPTURARAPIDA.COSTO, dbo.CAPTURARAPIDA.COSTO,
			                         dbo.CAPTURARAPIDA.CANTIDAD, isnull(dbo.CAPTURARAPIDA.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)),
					isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), 
					isnull(dbo.MAESTRO.MA_GENERICO,0), isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.MA_DISCHARGE, 'S'), 'MA_TIP_ENS'=CASE WHEN dbo.MAESTRO.MA_TIP_ENS='A' THEN 'F' WHEN @cfq_tipo='T' THEN 'C'  ELSE dbo.MAESTRO.MA_TIP_ENS END, 'AR_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else isnull(dbo.MAESTRO.AR_IMPFO,0) end,
			               'EQ_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end, isnull(CAPTURARAPIDA.CANTIDADCOMERCIAL / ISNULL(CAPTURARAPIDA.CANTIDAD, 1),1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 'MA_RATEIMPFO'=CASE WHEN isnull((SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),'N')='S' 
					THEN 0 ELSE dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPFO, 0, 'G', 0, 0) END, isnull(dbo.MAESTRO.ME_COM,19), 
					isnull(dbo.MAESTRO.AR_EXPMX,0), isnull(dbo.MAESTRO.EQ_EXPMX,1), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=dbo.MAESTRO.MA_GENERICO),19), 
					isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_EXPMX),0), 
					'MA_GRAV_MP'=CASE when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_MP,0) else 0 end, 
					'MA_GRAV_MO'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_MO,0) else 0 end, 
					'MA_GRAV_EMP'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_EMP,0) else 0 end, 
					'MA_GRAV_ADD'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_ADD,0) else 0 end, 
					'MA_GRAV_GI'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_GI,0) else 0 end, 
					'MA_GRAV_GI_MX'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_GI_MX,0) else 0 end, 
					'MA_NG_MP'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_MP,0) else 0 end, 
					'MA_NG_EMP'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_EMP,0) else 0 end, 
					'MA_NG_ADD'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_ADD,0) else 0 end, 
					'MA_NG_USA'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_USA,0) else 0 end, 
					round(isnull(dbo.CAPTURARAPIDA.COSTO*dbo.CAPTURARAPIDA.CANTIDAD,0),6),
					round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO,0),6), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO * 2.20462442018378,0),6),
						round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO,0),6), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO * 2.20462442018378,0),6),
					round(isnull(dbo.CAPTURARAPIDA.PESO*2.20462442018378,0),6), 'CANTEMP'=CASE WHEN dbo.MAESTRO.MA_CANTEMP>0 THEN CEILING(dbo.CAPTURARAPIDA.CANTIDAD/dbo.MAESTRO.MA_CANTEMP) ELSE 0 END, IsNull(dbo.MAESTRO.MA_EMPAQUE,0),
					dbo.CAPTURARAPIDA.CANTIDAD, 'tco_codigo'=case when @cfq_tipo='D' then (select tco_desperdicio from configuracion) else isnull(dbo.VMAESTROCOST.TCO_CODIGO,0) end, 
					isnull((SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),'N'),
					isnull(@CL_DESTINI,0), dbo.CAPTURARAPIDA.ORDCOMPRA
				FROM         dbo.CAPTURARAPIDA LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
				                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
						      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE    codigofact=@Codigo and tipofact='X' and (NOT (dbo.CAPTURARAPIDA.NOPARTE NOT IN
				                          (SELECT     MA_NOPARTE
				                            FROM          MAESTRO
				                            WHERE      MA_INV_GEN = @TipoEntrada AND MAESTRO.TI_CODIGO IN
				                                                       (SELECT     TI_CODIGO
				                                                         FROM          RELTEMBTIPO	
				                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE = NOPARTE))) AND 
			
						dbo.CAPTURARAPIDA.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
								                          (SELECT NOPARTE FROM CAPTURARAPIDA)))
			            ORDER BY ORDEN
		
			
				update factexpdet
				set ar_orig= isnull((select max(ar_codigo) from bom_arancel where ma_codigo=factexpdet.ma_codigo and ba_tipocosto='2'),0)
				where (ar_orig is null or ar_orig =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
				and fe_codigo=@Codigo
				
			
				update factexpdet
				set ar_ng_emp= isnull((select max(ar_codigo) from bom_arancel where ma_codigo=factexpdet.ma_codigo and ba_tipocosto='3'),0)
				where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
				and fe_codigo=@Codigo
			end
			else
			begin
		
				exec sp_CreaFactExpDetTemp
		
				INSERT INTO FactExpDetTemp (FED_INDICEDANT,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
				                             FED_CANT,FED_PES_UNI,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
				                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
						        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
						        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
			 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
							FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNILB,
							FED_CANTEMP, MA_EMPAQUE, fed_SALDO,TCO_CODIGO, FED_NAFTA, CL_CODIGO, FED_ORD_COMP)	
			          SELECT 0, @Codigo, dbo.CAPTURARAPIDA.NOPARTE, dbo.CAPTURARAPIDA.COSTO, dbo.CAPTURARAPIDA.COSTO,
			                         dbo.CAPTURARAPIDA.CANTIDAD, isnull(dbo.CAPTURARAPIDA.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
					dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.CAPTURARAPIDA.ORIGEN,dbo.MAESTRO.PA_ORIGEN), 
					isnull(dbo.MAESTRO.MA_GENERICO,0), isnull(dbo.MAESTRO.AR_IMPMX,0), isnull(dbo.MAESTRO.MA_DISCHARGE, 'S'), 'MA_TIP_ENS'=CASE WHEN dbo.MAESTRO.MA_TIP_ENS='A' THEN 'F' WHEN @cfq_tipo='T' THEN 'C'  ELSE dbo.MAESTRO.MA_TIP_ENS END, 'AR_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else isnull(dbo.MAESTRO.AR_IMPFO,0) end,
			               'EQ_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end, isnull(CAPTURARAPIDA.CANTIDADCOMERCIAL / ISNULL(CAPTURARAPIDA.CANTIDAD, 1),1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 'MA_RATEIMPFO'=CASE WHEN isnull((SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),'N')='S' THEN 0 ELSE dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPFO, 0, 'G', 0, 0) END, isnull(dbo.MAESTRO.ME_COM,19), 
					isnull(dbo.MAESTRO.AR_EXPMX,0), isnull(dbo.MAESTRO.EQ_EXPMX,1), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=dbo.MAESTRO.MA_GENERICO),19), 
					isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_EXPMX),0), 
					'MA_GRAV_MP'=CASE when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_MP,0) else 0 end, 
					'MA_GRAV_MO'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_MO,0) else 0 end, 
					'MA_GRAV_EMP'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_EMP,0) else 0 end, 
					'MA_GRAV_ADD'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_ADD,0) else 0 end, 
					'MA_GRAV_GI'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_GI,0) else 0 end, 
					'MA_GRAV_GI_MX'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_GRAV_GI_MX,0) else 0 end, 
					'MA_NG_MP'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_MP,0) else 0 end, 
					'MA_NG_EMP'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_EMP,0) else 0 end, 
					'MA_NG_ADD'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_ADD,0) else 0 end, 
					'MA_NG_USA'=case when @cfq_tipo='N' and dbo.CONFIGURATIPO.CFT_TIPO in ('P', 'S') then isnull(dbo.VMAESTROCOST.MA_NG_USA,0) else 0 end, 
					round(isnull(dbo.CAPTURARAPIDA.COSTO*dbo.CAPTURARAPIDA.CANTIDAD,0),6),
					round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO,0),6), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO * 2.20462442018378,0),6),
						round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO,0),6), round(isnull(dbo.CAPTURARAPIDA.CANTIDAD* dbo.CAPTURARAPIDA.PESO * 2.20462442018378,0),6),
					round(isnull(dbo.CAPTURARAPIDA.PESO*2.20462442018378,0),6), 'CANTEMP'=CASE WHEN dbo.MAESTRO.MA_CANTEMP>0 THEN CEILING(dbo.CAPTURARAPIDA.CANTIDAD/dbo.MAESTRO.MA_CANTEMP) ELSE 0 END, IsNull(dbo.MAESTRO.MA_EMPAQUE,0),
					dbo.CAPTURARAPIDA.CANTIDAD, 'tco_codigo'=case when @cfq_tipo='D' then (select tco_desperdicio from configuracion) else isnull(dbo.VMAESTROCOST.TCO_CODIGO,0) end, 
					isnull((SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),'N'),
					isnull(@CL_DESTINI,0), dbo.CAPTURARAPIDA.ORDCOMPRA
				FROM         dbo.CAPTURARAPIDA LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.CAPTURARAPIDA.NOPARTE = dbo.MAESTRO.MA_NOPARTE LEFT OUTER JOIN
				                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
						      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
				WHERE codigofact=@Codigo and tipofact='X' and  (NOT (dbo.CAPTURARAPIDA.NOPARTE NOT IN
				                          (SELECT     MA_NOPARTE
				                            FROM          MAESTRO
				                            WHERE      MA_INV_GEN = @TipoEntrada AND TI_CODIGO IN
				                                                       (SELECT     TI_CODIGO
				                                                         FROM          RELTEMBTIPO	
				                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE = NOPARTE))) AND 
			
						dbo.CAPTURARAPIDA.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
										FROM         dbo.MAESTRO
										GROUP BY MA_NOPARTE
										HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
								                          (SELECT NOPARTE FROM CAPTURARAPIDA)))
			            ORDER BY ORDEN
		
			
				update FactExpDetTemp
				set ar_orig= isnull((select max(ar_codigo) from bom_arancel where ma_codigo=FactExpDetTemp.ma_codigo and ba_tipocosto='2'),0)
				where (ar_orig is null or ar_orig =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
				and fe_codigo=@Codigo
				
			
				update FactExpDetTemp
				set ar_ng_emp= isnull((select max(ar_codigo) from bom_arancel where ma_codigo=FactExpDetTemp.ma_codigo and ba_tipocosto='3'),0)
				where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
				and fe_codigo=@Codigo
		
		
				INSERT INTO FACTEXPDET(FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, FED_NAME, ME_CODIGO, FED_CANT, 
				                      FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
				                      FED_NG_USA, FED_COS_UNI, FED_COS_TOT, FED_PES_UNI, FED_PES_NET, FED_PES_BRU, FED_PES_UNILB, 
				                      FED_PES_NETLB, FED_PES_BRULB, FED_SEC_IMP, FED_DEF_TIP, FED_POR_DEF, AR_IMPMX, AR_EXPMX, 
				                      AR_IMPFO, MA_GENERICO, PA_CODIGO, EQ_GEN, EQ_IMPFO, EQ_EXPMX, TI_CODIGO, FED_RATEEXPMX, 
				                      FED_RATEIMPFO, FED_FECHA_STRUCT, FED_DISCHARGE, SPI_CODIGO, FED_SALDO, FED_COS_UNI_CO, 
				                      FED_GRA_MAT_CO, FED_EMP_CO, FED_NG_MAT_CO, FED_VA_CO, FED_CANTGEN, MO_CODIGO, 
				                      FED_DESCARGADO, FED_PARTTYPE, ME_GENERICO, FED_TIP_ENS, PID_INDICED, MA_NOPARTECL, 
				                      ME_AREXPMX, FED_NAFTA, TCO_CODIGO, PI_ORIGENKITPADRE, CS_CODIGO, SE_CODIGO, 
				                      FED_SALDOTRANS, FED_USOTRANS, FED_USOSALDO, CL_CODIGO, MA_STRUCT, FED_DESTNAFTA, 
				                      AR_ORIG, AR_NG_EMP, FED_NOPARTEAUX, FED_ORD_COMP)
		
				SELECT     MIN(FED_INDICED), FE_CODIGO, MA_CODIGO, MAX(FED_NOMBRE), FED_NOPARTE, MAX(FED_NAME), MAX(ME_CODIGO), SUM(FED_CANT), 
				                      FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
				                      FED_NG_USA, FED_COS_UNI, SUM(FED_COS_TOT), FED_PES_UNI, SUM(FED_PES_NET), SUM(FED_PES_BRU), FED_PES_UNILB, 
				                      SUM(FED_PES_NETLB), SUM(FED_PES_BRULB), MAX(FED_SEC_IMP), MAX(FED_DEF_TIP), MAX(FED_POR_DEF), MAX(AR_IMPMX), MAX(AR_EXPMX), 
				                      MAX(AR_IMPFO), MAX(MA_GENERICO), PA_CODIGO, MAX(EQ_GEN), MAX(EQ_IMPFO), MAX(EQ_EXPMX), MAX(TI_CODIGO), MAX(FED_RATEEXPMX), 
				                      MAX(FED_RATEIMPFO), MAX(FED_FECHA_STRUCT), MAX(FED_DISCHARGE), MAX(SPI_CODIGO), MAX(FED_SALDO), MAX(FED_COS_UNI_CO), 
				                      MAX(FED_GRA_MAT_CO), MAX(FED_EMP_CO), MAX(FED_NG_MAT_CO), MAX(FED_VA_CO), MAX(FED_CANTGEN), MAX(MO_CODIGO), 
				                      MAX(FED_DESCARGADO), MAX(FED_PARTTYPE), MAX(ME_GENERICO), MAX(FED_TIP_ENS), MAX(PID_INDICED), MAX(MA_NOPARTECL), 
				                      MAX(ME_AREXPMX), MAX(FED_NAFTA), MAX(TCO_CODIGO), MAX(PI_ORIGENKITPADRE), MAX(CS_CODIGO), MAX(SE_CODIGO), 
				                      MAX(FED_SALDOTRANS), MAX(FED_USOTRANS), MAX(FED_USOSALDO), MAX(CL_CODIGO), MAX(MA_STRUCT), MAX(FED_DESTNAFTA), 
				                      MAX(AR_ORIG), MAX(AR_NG_EMP), MAX(FED_NOPARTEAUX), FED_ORD_COMP
				FROM         FactExpDetTemp
				GROUP BY FE_CODIGO, MA_CODIGO, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, 
				                      FED_NG_EMP, FED_NG_ADD, FED_NG_USA, FED_COS_UNI, FED_PES_UNI, FED_PES_UNILB, FED_NOPARTE, PA_CODIGO, FED_ORD_COMP
				ORDER BY MIN(FED_INDICED)
		
				IF (@@ERROR <> 0 ) SET @ERRORES = 1		
		
				IF @ERRORES = 0 
				exec sp_droptable 'FactExpDetTemp'
			end


			-- Permite Exportar sin Estructura de producto 
			if (select CF_EXPSINBOM from configuracion)='N'
			begin
				if (@cfq_tipo<>'D') or (@cfq_tipo='D' and (select CF_VERIFICABOMDESPERDICIO from configuracion)='S')
				begin
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + FACTEXPDET.FED_NOPARTE+' CON EL AUX.: '+isnull(FACTEXPDET.FED_NOPARTEAUX,'')+' PORQUE NO CUENTA CON ESTRUCTURA(BOM)', -20
					FROM        FACTEXPDET 
					WHERE FACTEXPDET.FE_CODIGO=@Codigo and (FED_TIP_ENS='F' OR FED_TIP_ENS='E') AND MA_CODIGO NOT IN
						(select bsu_subensamble from bom_struct where bst_perini<=@fe_fecha and bst_perfin>=@fe_fecha group by bsu_subensamble)
					GROUP BY FACTEXPDET.FED_NOPARTE, FACTEXPDET.FED_NOPARTEAUX
			
			
					DELETE FROM FACTEXPDET 
					WHERE FACTEXPDET.FE_CODIGO=@Codigo and (FED_TIP_ENS='F' OR FED_TIP_ENS='E') AND MA_CODIGO NOT IN
						(select bsu_subensamble from bom_struct where bst_perini<=@fe_fecha and bst_perfin>=@fe_fecha group by bsu_subensamble)
				end
			end

		
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
					WHERE dbo.FACTEXPDET.FE_CODIGO=@codigo
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
					WHERE dbo.FACTEXPDET.FE_CODIGO=@codigo
				  end
			end	
		
		
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
			where  dbo.FACTEXPDET.FE_CODIGO = @Codigo 
		
		
			IF @cfq_tipo is null
			SELECT     ' LA IMPORTACION NO SE HIZO CORRECTAMENTE DEBIDO A LA CONFIGURACION DEL TIPO DE EMBARQUE'
		
		
		select @FED_indiced= max(FED_indiced) from FACTEXPDET
		
			update consecutivo
			set cv_codigo =  isnull(@FED_indiced,0) + 1
			where cv_tipo = 'FED'
		
		
			exec SP_ACTUALIZAFED_FECHA_STRUCT @Codigo
		
			update factexp
			set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
			where fe_codigo =@Codigo
		
			ALTER TABLE FACTEXPDET ENABLE TRIGGER Update_FactExpDet
		
		IF @ERRORES = 0 
		if exists (select * from CAPTURARAPIDA where codigofact=@Codigo and tipofact='X')
		delete from CAPTURARAPIDA where codigofact=@Codigo and tipofact='X'
	END

GO
