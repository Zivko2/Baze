SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[SP_HYSONFACTEXP]   as

SET NOCOUNT ON 
DECLARE @CONSECUTIVO INTEGER, @NOPARTE varchar(30), @COSTO decimal(38,6), @CANTIDAD decimal(38,6), @PESO decimal(38,6), @ORIGEN INT, @FECHA datetime, 
@fe_tipocambio decimal(38,6), @CL_MATRIZ int, @AG_MEX int, @AG_USA int, @CL_TRAFICO int,  @PU_CARGA int, @PU_SALIDA int, @PU_ENTRADA int,
@PU_DESTINO int, @di_matriz int, @di_trafico int, @di_empresa int, @MO_CODIGO int, @cfq_tipo varchar(5),
@FED_indiced int, @cf_pesos_exp CHAR(1), @Codigo int, @fe_folio varchar(25), @cliente varchar(10), @CL_DESTINO int, @DIRDESTINO int  



	delete from TempPckListExp_Hyson where NOPARTE=''

	select @cf_pesos_exp = cf_pesos_exp from configuracion 


	select @fe_folio=NoPacking, @cliente=cliente from TempPckListExp_Hyson



	delete from IMPORTLOG where IML_CBFORMA=-62

	if exists(SELECT dbo.TempPckListExp_Hyson.NOPARTE
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.TempPckListExp_Hyson ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.TempPckListExp_Hyson.NOPARTE+'-'+ISNULL(TempPckListExp_Hyson.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL)
	begin
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR LA FACTURA: ' +@fe_folio, -62

		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     '--------------------------------------------------------------------------------------- ' , -62

		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'EL NO. PARTE : ' +dbo.TempPckListExp_Hyson.NOPARTE +' CON EL AUX.: '+isnull(TempPckListExp_Hyson.NOPARTEAUX,'')+' NO EXISTE EN EL CAT. MAESTRO', -62
		FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
				where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
		                      dbo.TempPckListExp_Hyson ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.TempPckListExp_Hyson.NOPARTE+'-'+ISNULL(TempPckListExp_Hyson.NOPARTEAUX,'')
		WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL
	
	end
	else
	begin
		if not exists (select * from factexp where fe_folio =@fe_folio)
		begin
			SET @FECHA=(CONVERT(VARCHAR(10),GETDATE(),102))
		
			select @fe_tipocambio=tc_cant from tcambio where tc_fecha=@FECHA
	
			select @CL_DESTINO=cl_codigo from cliente where CL_CODEHTC=@cliente
	
			SELECT @CL_MATRIZ=CL_MATRIZ, @AG_MEX=AG_MEX, @AG_USA=AG_USA, @CL_TRAFICO=CL_TRAFICO,
			@PU_CARGA=PU_CARGAS, @PU_SALIDA=PU_SALIDAS, @PU_ENTRADA=PU_ENTRADAS, @PU_DESTINO=PU_DESTINOS,
			@MO_CODIGO =MO_CODIGO
			FROM CLIENTE WHERE CL_EMPRESA='S'
		
			select @di_matriz= di_indice from dir_cliente where cl_codigo=@cl_matriz and di_fiscal='S'
			select @DIRDESTINO= di_indice from dir_cliente where cl_codigo=@CL_DESTINO and di_fiscal='S'
			select @di_trafico= di_indice from dir_cliente where cl_codigo=@cl_trafico and di_fiscal='S'
			select @di_empresa= di_indice from dir_cliente where cl_codigo=1 and di_fiscal='S'
	
	
		
	
			EXEC SP_GETCONSECUTIVO @TIPO='FI',@VALUE=@Codigo OUTPUT
	
		
			if not exists (select * from factexp where fe_folio =@fe_folio)
		          INSERT INTO FACTEXP (FE_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_FOLIO, FE_TIPO, TF_CODIGO, TQ_CODIGO, 
				AG_MX, AG_US, CL_COMP, CL_DESTFIN, CL_DESTINI, CL_EXP, CL_IMP, CL_PROD, CL_VEND,
				DI_COMP, DI_DESTFIN, DI_DESTINI, DI_EXP, DI_IMP, DI_PROD,  DI_VEND, FE_PFINAL, FE_PINICIAL, 
				MO_CODIGO, PU_CARGA, PU_DESTINO, PU_ENTRADA, PU_SALIDA, CL_EXPFIN, DI_EXPFIN, AGT_CODIGO) 
	
		           SELECT @Codigo, @fecha, @fe_tipocambio, @fe_folio, 'F', 2, 12, 
				@AG_MEX, @AG_USA, @CL_DESTINO, @CL_DESTINO, @CL_DESTINO, @cl_trafico, @CL_DESTINO, @cl_trafico, @cl_trafico, 
				@DIRDESTINO, @DIRDESTINO, @DIRDESTINO, @di_trafico, @DIRDESTINO, @di_trafico, @di_trafico, @fecha, @fecha, 
				@MO_CODIGO, @PU_CARGA, @PU_DESTINO, @PU_ENTRADA, @PU_SALIDA,  @cl_trafico, @di_trafico,
				isnull((SELECT AGT_CODIGO FROM AGENCIAPATENTE WHERE AGT_DEFAULT = 'S' AND AG_CODIGO = @AG_MEX),0)
		end
		else
		begin
			if exists (select * from factexpdet where fe_codigo in (select fe_codigo from factexp where fe_folio =@fe_folio))
			delete from factexpdet where fe_codigo in (select fe_codigo from factexp where fe_folio =@fe_folio)
	
			select @Codigo=fe_codigo from factexp where fe_folio =@fe_folio
	
		end	
	
	
	
	
		-- se queda, si mas adelante se define un tipo difente
		select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=12
	
	
		UPDATE TempPckListExp_Hyson
		SET     TempPckListExp_Hyson.COSTO= ISNULL(VMAESTROCOST.MA_COSTO, 0)
		FROM         TempPckListExp_Hyson INNER JOIN MAESTRO ON TempPckListExp_Hyson.NOPARTE +'-'+IsNull(TempPckListExp_Hyson.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO
		WHERE VMAESTROCOST.SPI_CODIGO=22 AND (TempPckListExp_Hyson.COSTO=0 OR TempPckListExp_Hyson.COSTO IS NULL)
		and maestro.ma_inv_gen = 'I'
	
	
	
		UPDATE TempPckListExp_Hyson
		SET     TempPckListExp_Hyson.COSTO= 0
		WHERE TempPckListExp_Hyson.COSTO IS NULL 
	
	
	
		IF @cf_pesos_exp='K'
		BEGIN
			UPDATE TempPckListExp_Hyson
			SET  TempPckListExp_Hyson.PESO = isnull(MAESTRO.MA_PESO_KG,0)
			FROM         MAESTRO INNER JOIN
			                      TempPckListExp_Hyson ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = TempPckListExp_Hyson.NOPARTE+'-'+ isnull(TempPckListExp_Hyson.NOPARTEAUX,'')
			WHERE MAESTRO.MA_INV_GEN='I' AND
			               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =12  ) 
			                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) =TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
		
		END
		ELSE
		BEGIN
			UPDATE TempPckListExp_Hyson
			SET  TempPckListExp_Hyson.PESO = isnull(MAESTRO.MA_PESO_LB,0)
			FROM         MAESTRO INNER JOIN
			                      TempPckListExp_Hyson ON MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'')
			WHERE MAESTRO.MA_INV_GEN='I' AND
			               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =12  ) 
			                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))=TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
		END
	
	
	
	
	
		select @consecutivo=cv_codigo from consecutivo
		where cv_tipo = 'FED'
	
	
		IF @cf_pesos_exp='K'
		BEGIN
	
	
			INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
		                                                             FED_CANT,FED_PES_UNI,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
		                                                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
		 				        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
						        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
		 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
						FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNILB,
						FED_CANTEMP, MA_EMPAQUE, fed_SALDO,TCO_CODIGO, FED_NAFTA, CL_CODIGO,FED_PARTTYPE, SE_CODIGO, FED_NOPARTEAUX)	
		          SELECT @consecutivo+ORDEN, @Codigo, TempPckListExp_Hyson.NOPARTE, TempPckListExp_Hyson.COSTO,   TempPckListExp_Hyson.COSTO,  
		                TempPckListExp_Hyson.CANTIDAD, isnull(TempPckListExp_Hyson.PESO,0), 'MA_NOMBRE'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NOMBREDESP<>'' then MAESTRO.MA_NOMBREDESP else 'DESPERDICIO DE '+MAESTRO.MA_NOMBRE end) else MAESTRO.MA_NOMBRE end, 
				'MA_NAME'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NAMEDESP<>'' then MAESTRO.MA_NAMEDESP else 'SCRAP OF '+MAESTRO.MA_NAME end) else MAESTRO.MA_NAME end, 
				MAESTRO.MA_CODIGO, isnull(MAESTRO.TI_CODIGO,0), DBO.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, isnull(MAESTRO.MA_DEF_TIP,'G'), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.SPI_CODIGO,0)), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.PA_ORIGEN,0), 0,
				isnull(MAESTRO.AR_IMPMX,0), isnull(MAESTRO.MA_DISCHARGE, 'S'), 'MA_TIP_ENS'=CASE WHEN @cfq_tipo='T' THEN 'C'  ELSE (case when MAESTRO.MA_TIP_ENS='A' then 'F' else MAESTRO.MA_TIP_ENS end) END, 0, 1, 1,
				isnull(MAESTRO.MA_DEF_TIP,'G'), -1, isnull(MAESTRO.ME_COM,19), 0, 1,
				isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=MAESTRO.MA_GENERICO),19), 
				isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = MAESTRO.AR_EXPMX),0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			round(isnull(TempPckListExp_Hyson.COSTO*TempPckListExp_Hyson.CANTIDAD,0),6),
			round(isnull(TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO,0),6), 
			round(isnull(TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO * 2.20462442018378,0),6),
			round(isnull(TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO,0),6), 
			round(isnull(TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO * 2.20462442018378,0),6),
			round(isnull(TempPckListExp_Hyson.PESO*2.20462442018378,0),6), 
			'CANTEMP'=CASE WHEN MAESTRO.MA_CANTEMP>0 THEN CEILING(TempPckListExp_Hyson.CANTIDAD/MAESTRO.MA_CANTEMP) ELSE 0 END, 
			IsNull(MAESTRO.MA_EMPAQUE,0),TempPckListExp_Hyson.CANTIDAD, 
			'tco_codigo'=case when @cfq_tipo='D' and (select count(ma_codigo) from maestrocost where ma_codigo=MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
					then (select tco_desperdicio from configuracion) else (case when @cfq_tipo='T' AND (select CF_TCOCOMPRAIMP from configuracion)='S' then (select tco_compra from configuracion) else isnull(VMAESTROCOST.TCO_CODIGO,0) end) end, 
	
			'N',
			isnull(@CL_DESTINO,0),
			'FED_PARTTYPE'=CASE WHEN @cfq_tipo='D' THEN 'S' 	WHEN (@cfq_tipo<>'D' AND (MAESTRO.TI_CODIGO=14 OR MAESTRO.TI_CODIGO=16))
			THEN 'A'  WHEN (@cfq_tipo<>'D' AND MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16) THEN 'U' END,
			isnull(MAESTRO.SE_CODIGO,0), MAESTRO.MA_NOPARTEAUX
			FROM         TempPckListExp_Hyson LEFT OUTER JOIN
			                      MAESTRO ON TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
			                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
					      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
			WHERE     (NOT (TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'') NOT IN
			                          (SELECT     MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
			                            FROM          MAESTRO
			                            WHERE      MA_INV_GEN = 'I' AND TI_CODIGO IN
			                                                       (SELECT     TI_CODIGO
			                                                         FROM          RELTEMBTIPO
			                                                         WHERE      TQ_CODIGO = 12) AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) = NOPARTE+'-'+isnull(NOPARTEAUX,'')))) AND 
		
					TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
									FROM         MAESTRO
									where maestro.ma_inv_gen = 'I'
									  and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM TempPckListExp_Hyson)
									GROUP BY MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
									HAVING      (COUNT(MA_CODIGO) > 1))
			and maestro.ma_inv_gen = 'I'
		             ORDER BY ORDEN
		END
		ELSE
		BEGIN
			INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
		                                                             FED_CANT,FED_PES_UNILB,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
		                                                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
		 				        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
						        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
		 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
						FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNI,
						FED_CANTEMP, MA_EMPAQUE, fed_SALDO, TCO_CODIGO, FED_NAFTA, CL_CODIGO, FED_PARTTYPE, SE_CODIGO, FED_NOPARTEAUX)		
		          SELECT @consecutivo+ORDEN, @Codigo, TempPckListExp_Hyson.NOPARTE, TempPckListExp_Hyson.COSTO,   TempPckListExp_Hyson.COSTO,  
	                         TempPckListExp_Hyson.CANTIDAD, isnull(TempPckListExp_Hyson.PESO,0), 'MA_NOMBRE'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NOMBREDESP<>'' then MAESTRO.MA_NOMBREDESP else 'DESPERDICIO DE '+MAESTRO.MA_NOMBRE end) else MAESTRO.MA_NOMBRE end, 
				'MA_NAME'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NAMEDESP<>'' then MAESTRO.MA_NAMEDESP else 'SCRAP OF '+MAESTRO.MA_NAME end) else MAESTRO.MA_NAME end,
				MAESTRO.MA_CODIGO, isnull(MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, isnull(MAESTRO.MA_DEF_TIP,'G'), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.SPI_CODIGO,0)),
				 isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.PA_ORIGEN,0), 0,
				isnull(MAESTRO.AR_IMPMX,0), MAESTRO.MA_DISCHARGE, 'MA_TIP_ENS'=CASE WHEN @cfq_tipo='T' THEN 'C'  ELSE (case when MAESTRO.MA_TIP_ENS='A' then 'F' else MAESTRO.MA_TIP_ENS end) END, 0, 1, 1,
				isnull(MAESTRO.MA_DEF_TIP,'G'), -1, isnull(MAESTRO.ME_COM,19), 0, 1,
				isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=MAESTRO.MA_GENERICO),19), 
				isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = MAESTRO.AR_EXPMX),19), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			round(isnull(TempPckListExp_Hyson.COSTO*TempPckListExp_Hyson.CANTIDAD,0),6),
			round(isnull((TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO)/2.20462442018378,0),6), round(isnull(TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO,0),6),
				round(isnull((TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO)/2.20462442018378,0),6), round(isnull(TempPckListExp_Hyson.CANTIDAD* TempPckListExp_Hyson.PESO,0),6),
			round(isnull(TempPckListExp_Hyson.PESO/2.20462442018378,0),6), 'CANTEMP'=CASE WHEN MAESTRO.MA_CANTEMP>0 THEN CEILING(TempPckListExp_Hyson.CANTIDAD/MAESTRO.MA_CANTEMP) ELSE 0 END, IsNull(MAESTRO.MA_EMPAQUE,0),
			TempPckListExp_Hyson.CANTIDAD, 'tco_codigo'=case when @cfq_tipo='D' and (select count(ma_codigo) from maestrocost where ma_codigo=MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
				then (select tco_desperdicio from configuracion) else (case when @cfq_tipo='T' and MAESTRO.MA_TIP_ENS='A' AND (select CF_TCOCOMPRAIMP from configuracion)='S' then (select tco_compra from configuracion) else isnull(VMAESTROCOST.TCO_CODIGO,0) end) end, 
			'N',
			@CL_DESTINO,
			'FED_PARTTYPE'=CASE WHEN @cfq_tipo='D' THEN 'S' 	WHEN (@cfq_tipo<>'D' AND (MAESTRO.TI_CODIGO=14 OR MAESTRO.TI_CODIGO=16))
			THEN 'A'  WHEN (@cfq_tipo<>'D' AND MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16) THEN 'U' END, isnull(MAESTRO.SE_CODIGO,0), MAESTRO.MA_NOPARTEAUX
			FROM         TempPckListExp_Hyson LEFT OUTER JOIN
		                      MAESTRO ON TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
				      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
			WHERE     (NOT (TempPckListExp_Hyson.NOPARTE+'-'+Isnull(TempPckListExp_Hyson.NOPARTEAUX,'') NOT IN
			                          (SELECT     MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
			                            FROM          MAESTRO
			                            WHERE      MA_INV_GEN = 'I' AND TI_CODIGO IN
			                                                       (SELECT     TI_CODIGO
			                                                         FROM          RELTEMBTIPO
			                                                         WHERE      TQ_CODIGO = 12) AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = NOPARTE+'-'+isnull(NOPARTEAUX,'')))) AND 
		
					TempPckListExp_Hyson.NOPARTE+'-'+isnull(TempPckListExp_Hyson.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
									FROM         MAESTRO
									where maestro.ma_inv_gen = 'I'
	                						  and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM TempPckListExp_Hyson)
									GROUP BY MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
									HAVING      (COUNT(MA_CODIGO) > 1))
			and maestro.ma_inv_gen = 'I'
		             ORDER BY ORDEN
		END
	
	
		ALTER TABLE FACTEXPDET DISABLE TRIGGER Update_FactExpDet
	
			IF (SELECT CF_TCOCOMPRAIMP FROM CONFIGURACION)='S'
				UPDATE FACTEXPDET
				SET AR_IMPFO=(CASE when @cfq_tipo='D' then isnull(MAESTRO.AR_DESP,0) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.AR_IMPFO,0) else isnull(MAESTRO.AR_IMPFOUSA,0) end) 
					     else (CASE wheN FED_TIP_ENS ='C' then isnull(MAESTRO.AR_IMPFO,0) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.AR_IMPFOFIS,0) else isnull(MAESTRO.AR_IMPFO,0) end) end) end) end),
				EQ_IMPFO=(CASE when @cfq_tipo='D' then isnull(MAESTRO.EQ_DESP,1) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.EQ_IMPFO,1) else isnull(MAESTRO.EQ_IMPFOUSA,1) end) 
					     else (CASE wheN FED_TIP_ENS ='C' then isnull(MAESTRO.EQ_IMPFO,1) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.EQ_IMPFOFIS,1) else isnull(MAESTRO.EQ_IMPFO,1) end) end) end) end),
				AR_EXPMX=(CASE when @cfq_tipo='D' /*and @FE_DESTINO='N'*/ then isnull(MAESTRO.AR_DESPMX,0) else  (CASE when FED_TIP_ENS ='C' then isnull(MAESTRO.AR_EXPMX,0) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.AR_EXPMXFIS,0) else isnull(MAESTRO.AR_EXPMX,0) end) end) end), 
				EQ_EXPMX=(CASE when @cfq_tipo='D' /*and @FE_DESTINO='N'*/ then isnull(MAESTRO.EQ_DESPMX,1) else (CASE when FED_TIP_ENS ='C' then isnull(MAESTRO.EQ_EXPMX,1) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.EQ_EXPMXFIS,1) else isnull(MAESTRO.EQ_EXPMX,1) end) end) end),
				MA_GENERICO=(case when MA_TIP_ENS='A' and FED_TIP_ENS ='F' then isnull(ANEXO24.MA_GENERICOFIS,0) else isnull(MAESTRO.MA_GENERICO,0) end), 
				EQ_GEN=(case when MA_TIP_ENS='A' and FED_TIP_ENS ='F' then isnull(ANEXO24.EQ_GENERICOFIS,1) else isnull(MAESTRO.EQ_GEN,1) end)
				FROM FACTEXPDET 
				  LEFT OUTER JOIN MAESTRO 
				  ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN ANEXO24 
				  ON ANEXO24.MA_CODIGO = MAESTRO.MA_CODIGO 
				WHERE FACTEXPDET.FE_CODIGO=@Codigo
			ELSE
				UPDATE FACTEXPDET
				SET AR_IMPFO=(CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.AR_IMPFO,0) else isnull(dbo.MAESTRO.AR_IMPFOUSA,0) end) else isnull(dbo.MAESTRO.AR_IMPFO,0) end) end),
		  	            EQ_IMPFO=(CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.EQ_IMPFO,1) else isnull(dbo.MAESTRO.EQ_IMPFOUSA,1) end) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end) end), 
				    AR_EXPMX=(CASE when @cfq_tipo='D' /*and @FE_DESTINO='N'*/ then isnull(dbo.MAESTRO.AR_DESPMX,0) else isnull(dbo.MAESTRO.AR_EXPMX,0) end),
				    EQ_EXPMX=(CASE when @cfq_tipo='D' /*and @FE_DESTINO='N'*/ then isnull(dbo.MAESTRO.EQ_DESPMX,1) else isnull(dbo.MAESTRO.EQ_EXPMX,1) end),
				    MA_GENERICO=(isnull(dbo.MAESTRO.MA_GENERICO,0)), 
				    EQ_GEN=(isnull(dbo.MAESTRO.EQ_GEN,1))
				FROM FACTEXPDET 
				  LEFT OUTER JOIN MAESTRO 
				  ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN ANEXO24 
				  ON ANEXO24.MA_CODIGO = MAESTRO.MA_CODIGO 
				WHERE FACTEXPDET.FE_CODIGO=@Codigo
	
	
			
				UPDATE FACTEXPDET
				SET FED_NAFTA=dbo.GetNafta (@FECHA, FACTEXPDET.MA_CODIGO, FACTEXPDET.AR_IMPMX, FACTEXPDET.PA_CODIGO, FACTEXPDET.FED_DEF_TIP, FACTEXPDET.FED_TIP_ENS)
				FROM FACTEXPDET 
				WHERE FE_CODIGO=@Codigo
			
				UPDATE FACTEXPDET
				SET FED_RATEIMPFO=(CASE WHEN FED_NAFTA='S' THEN 0 ELSE dbo.GetAdvalorem(AR_IMPFO, 0, 'G', 0, 0) END)
				FROM FACTEXPDET 
				WHERE FE_CODIGO=@Codigo
			
			
				UPDATE FACTEXPDET
				SET FED_GRA_MP=isnull(MAESTROCOST.MA_GRAV_MP,0), 
				FED_GRA_MO=isnull(MAESTROCOST.MA_GRAV_MO,0), 
				FED_GRA_EMP=isnull(MAESTROCOST.MA_GRAV_EMP,0), 
				FED_GRA_ADD=isnull(MAESTROCOST.MA_GRAV_ADD,0), 
				FED_GRA_GI=isnull(MAESTROCOST.MA_GRAV_GI,0), 
				FED_GRA_GI_MX=isnull(MAESTROCOST.MA_GRAV_GI_MX,0), 
				FED_NG_MP=isnull(MAESTROCOST.MA_NG_MP,0), 
				FED_NG_EMP=isnull(MAESTROCOST.MA_NG_EMP,0), 
				FED_NG_ADD=isnull(MAESTROCOST.MA_NG_ADD,0), 
				FED_NG_USA=isnull(MAESTROCOST.MA_NG_USA,0)
				FROM FACTEXPDET 
				LEFT OUTER JOIN MAESTROCOST ON FACTEXPDET.MA_CODIGO = MAESTROCOST.MA_CODIGO 
				AND FACTEXPDET.TCO_CODIGO = MAESTROCOST.TCO_CODIGO 
				LEFT OUTER JOIN CONFIGURATIPO ON FACTEXPDET.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
				WHERE FE_CODIGO=@Codigo
				AND MAESTROCOST.MAC_CODIGO IN (SELECT MAX(M1.MAC_CODIGO) 
									FROM MAESTROCOST M1 
									WHERE M1.SPI_CODIGO = 22 AND M1.MA_PERINI <= GETDATE() AND M1.MA_PERFIN >= GETDATE() 
										AND M1.TCO_CODIGO = FACTEXPDET.TCO_CODIGO 
										AND M1.MA_CODIGO = FACTEXPDET.MA_CODIGO)
				and FACTEXPDET.tco_codigo in(SELECT TCO_CODIGO FROM TCOSTO WHERE TCO_TIPO IN ('P','N'))
			
			
			
				UPDATE FACTEXPDET
				set FED_COS_UNI=round(isnull(FED_GRA_MP+FED_GRA_MO+FED_GRA_EMP+ FED_GRA_ADD+
					FED_GRA_GI+ FED_GRA_GI_MX+ FED_NG_MP+ FED_NG_EMP+ FED_NG_ADD,0),6)
				FROM FACTEXPDET
				WHERE  FE_CODIGO=@Codigo
				and FACTEXPDET.tco_codigo in (select tco_manufactura from configuracion)
			
			
				UPDATE FACTEXPDET
				SET FED_COS_TOT=round(isnull(FED_COS_UNI*FED_CANT,0),6)
				WHERE  FE_CODIGO=@Codigo and FED_COS_TOT<>round(isnull(FED_COS_UNI*FED_CANT,0),6)
			
			
				UPDATE FACTEXPDET
				SET ME_AREXPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = FACTEXPDET.AR_EXPMX),19)
				WHERE FE_CODIGO=@Codigo
			
			
				  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) <> 'N'  
				  begin
					  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) = 'S' 
					  begin
						INSERT INTO FACTEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, FE_CODIGO, FED_INDICED)
						SELECT     CARGORELARANCEL.CAR_CODIGO, CARGODET.CARD_VALOR, CARGO.CAR_TIPO,  FACTEXPDET.FE_CODIGO, 
						                      FACTEXPDET.FED_INDICED
						FROM         FACTEXPDET INNER JOIN
						                      MAESTRO ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
						                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO INNER JOIN
						                      CARGORELARANCEL INNER JOIN
						                      CARGODET ON CARGORELARANCEL.CAR_CODIGO = CARGODET.CAR_CODIGO INNER JOIN
						                      CARGO ON CARGORELARANCEL.CAR_CODIGO = CARGO.CAR_CODIGO ON 
						                      FACTEXP.FE_FECHA >= CARGODET.CARD_FECHAINI AND FACTEXP.FE_FECHA <= CARGODET.CARD_FECHAFIN AND 
						                      FACTEXP.CL_DESTINI = CARGORELARANCEL.CL_CODIGO AND MAESTRO.AR_EXPMX = CARGORELARANCEL.AR_CODIGO
						WHERE FACTEXPDET.FE_CODIGO=@codigo
					  end
					  else
					  begin
						INSERT INTO FACTEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, FE_CODIGO, FED_INDICED)
						SELECT     CARGORELARANCEL.CAR_CODIGO, CARGODET.CARD_VALOR, CARGO.CAR_TIPO,  FACTEXPDET.FE_CODIGO, 
						                      FACTEXPDET.FED_INDICED
						FROM         FACTEXPDET INNER JOIN
						                      MAESTRO ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
						                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO INNER JOIN
						                      CARGORELARANCEL INNER JOIN
						                      CARGODET ON CARGORELARANCEL.CAR_CODIGO = CARGODET.CAR_CODIGO INNER JOIN
						                      CARGO ON CARGORELARANCEL.CAR_CODIGO = CARGO.CAR_CODIGO ON 
						                      FACTEXP.FE_FECHA >= CARGODET.CARD_FECHAINI AND FACTEXP.FE_FECHA <= CARGODET.CARD_FECHAFIN AND 
						                      FACTEXP.CL_DESTINI = CARGORELARANCEL.CL_CODIGO AND MAESTRO.LIN_CODIGO = CARGORELARANCEL.LIN_CODIGO
						WHERE FACTEXPDET.FE_CODIGO=@codigo
					  end
				end	
			
			
			
				update factexpdet	set ar_orig= case when fed_nafta='S' then
					 0 else ( case when isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0)=0 
					then  isnull((select AR_IMPFOUSA from maestro where maestro.ma_codigo=factexpdet.ma_codigo),0)  else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end) end
				where (ar_orig is null or ar_orig =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
				and fed_ng_usa>0 and fe_codigo=@Codigo
				
			
				update factexpdet
				set ar_ng_emp= case when fed_nafta='S' then
				 0 else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='3' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end
				where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
				and fed_ng_emp>0 and fe_codigo=@Codigo
			
			
				UPDATE FACTEXPDET
				SET     FACTEXPDET.FED_DESTNAFTA= CASE 
				when DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
				 when DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
				then 'N'  WHEN 	  DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
				then 'U' when 	  DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
				then 'A'  else 'F' end
				FROM         FACTEXPDET INNER JOIN
				                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN
				                      DIR_CLIENTE ON FACTEXP.DI_DESTFIN = DIR_CLIENTE.DI_INDICE
				where  FACTEXPDET.FE_CODIGO = @Codigo 
	
	
			exec SP_ACTUALIZAFED_FECHA_STRUCT @Codigo		
			
	
	
		ALTER TABLE FACTEXPDET ENABLE TRIGGER Update_FactExpDet
	
	
	
	
		select @FED_indiced= max(FED_indiced) from FACTEXPDET
	
		update consecutivo
		set cv_codigo =  isnull(@FED_indiced,0) + 1
		where cv_tipo = 'FED'
	
	
	
		update factexp
		set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
		where fe_codigo =@Codigo
	end
GO
