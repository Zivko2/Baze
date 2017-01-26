SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_HYSONFACTIMP]   as

SET NOCOUNT ON 
DECLARE @CONSECUTIVO INTEGER, @NOPARTE varchar(30), @COSTO decimal(38,6), @CANTIDAD decimal(38,6), @PESO decimal(38,6), @ORIGEN INT, @FECHA datetime, 
@fi_tipocambio decimal(38,6), @CL_MATRIZ int, @AG_MEX int, @AG_USA int, @CL_TRAFICO int,  @PU_CARGA int, @PU_SALIDA int, @PU_ENTRADA int,
@PU_DESTINO int, @di_matriz int, @di_trafico int, @di_empresa int, 
@FID_indiced int, @CF_PESOS_IMP CHAR(1), @Codigo int, @fi_folio varchar(25), @proveedor varchar(10), @pr_codigo int, @di_provee int  


	--borra los registros de la tabla que se hayan importado sin numero de parte
	delete from TempPckListImp_Hyson where NOPARTE=''


	SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
	FROM         dbo.CONFIGURACION


	select @fi_folio=NoPacking, @proveedor=proveedor from TempPckListImp_Hyson



	delete from IMPORTLOG where IML_CBFORMA=-44

	if exists(SELECT dbo.TempPckListImp_Hyson.NOPARTE
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.TempPckListImp_Hyson ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL)
	begin
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR LA FACTURA: ' +@fi_folio, -44

		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     '--------------------------------------------------------------------------------------- ', -44

		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'EL NO. PARTE : ' +dbo.TempPckListImp_Hyson.NOPARTE +' CON EL AUX.: '+isnull(TempPckListImp_Hyson.NOPARTEAUX,'')+' NO EXISTE EN EL CAT. MAESTRO', -44
		FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
				where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
		                      dbo.TempPckListImp_Hyson ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'')
		WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL
	
	end
	else
	begin

		if not exists (select * from factimp where fi_folio =@fi_folio)
		begin
			SET @FECHA=(CONVERT(VARCHAR(10),GETDATE(),102))
		
			select @fi_tipocambio=tc_cant from tcambio where tc_fecha=@FECHA
	
			select @pr_codigo=cl_codigo from cliente where CL_CODEHTC=@proveedor
	
			SELECT @CL_MATRIZ=CL_MATRIZ, @AG_MEX=AG_MEX, @AG_USA=AG_USA, @CL_TRAFICO=CL_TRAFICO,
			@PU_CARGA=PU_CARGA, @PU_SALIDA=PU_SALIDA, @PU_ENTRADA=PU_ENTRADA, @PU_DESTINO=PU_DESTINO 
			FROM CLIENTE WHERE CL_EMPRESA='S'
		
			select @di_matriz= di_indice from dir_cliente where cl_codigo=@cl_matriz and di_fiscal='S'
			select @di_provee= di_indice from dir_cliente where cl_codigo=@pr_codigo and di_fiscal='S'
			select @di_trafico= di_indice from dir_cliente where cl_codigo=@cl_trafico and di_fiscal='S'
			select @di_empresa= di_indice from dir_cliente where cl_codigo=1 and di_fiscal='S'
	
	
		
	
			EXEC SP_GETCONSECUTIVO @TIPO='FI',@VALUE=@Codigo OUTPUT
	
		
			if not exists (select * from factimp where fi_folio =@fi_folio)
			INSERT INTO FACTIMP(FI_CODIGO, FI_FOLIO, FI_FECHA, TF_CODIGO, TQ_CODIGO, FI_PINICIAL, FI_PFINAL,
			AG_MEX, AG_USA, PR_CODIGO, DI_PROVEE, CL_PROD, DI_PROD, CL_DESTFIN, DI_DESTFIN,
			CL_COMP, DI_COMP, CL_VEND, DI_VEND, CL_EXP, DI_EXP, CL_IMP, DI_IMP, FI_TIPO, CL_DESTINT, DI_DESTINT, fi_tipocambio)
		
			VALUES (@Codigo, @fi_folio, @fecha, 5, 12, @fecha, @fecha,
			@ag_mex, @ag_usa, @pr_codigo, @di_provee, @pr_codigo, @di_provee, 1, @di_empresa,
			1, @di_empresa, @cl_matriz, @di_matriz, @cl_matriz, @di_matriz, @cl_trafico, @di_trafico, 'F', 1, @di_empresa, @fi_tipocambio)
		end
		else
		begin
			if exists (select * from factimpdet where fi_codigo in (select fi_codigo from factimp where fi_folio =@fi_folio))
			delete from factimpdet where fi_codigo in (select fi_codigo from factimp where fi_folio =@fi_folio)
	
			select @Codigo=fi_codigo from factimp where fi_folio =@fi_folio
	
		end	


		-- se actualiza el costo en caso de que venga nulo o igual a cero pero solo de los comprados-fisicos
		UPDATE dbo.TempPckListImp_Hyson
		SET     dbo.TempPckListImp_Hyson.COSTO= ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)
		FROM         dbo.TempPckListImp_Hyson INNER JOIN
		                      dbo.MAESTRO ON dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      dbo.MAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO
		WHERE dbo.MAESTROCOST.SPI_CODIGO=22 AND dbo.MAESTROCOST.MA_PERINI<=getdate() AND dbo.MAESTROCOST.MA_PERFIN>=getdate()
		AND dbo.MAESTROCOST.TCO_CODIGO IN (select TCO_COMPRA from configuracion) AND
		(dbo.TempPckListImp_Hyson.COSTO=0 OR dbo.TempPckListImp_Hyson.COSTO IS NULL)
		AND dbo.MAESTRO.MA_TIP_ENS='A'
		and maestro.ma_inv_gen = 'I'
		
		
		-- se actualiza el costo en caso de que venga nulo o igual a cero
		UPDATE dbo.TempPckListImp_Hyson
		SET     dbo.TempPckListImp_Hyson.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
		FROM         dbo.TempPckListImp_Hyson INNER JOIN
		                      dbo.MAESTRO ON dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
		WHERE dbo.VMAESTROCOST.SPI_CODIGO=22 AND
		(dbo.TempPckListImp_Hyson.COSTO=0 OR dbo.TempPckListImp_Hyson.COSTO IS NULL)
		 and maestro.ma_inv_gen = 'I'
		
		
		UPDATE dbo.TempPckListImp_Hyson
		SET     dbo.TempPckListImp_Hyson.COSTO= 0
		WHERE dbo.TempPckListImp_Hyson.COSTO IS NULL
		
		
		-- se actualiza el peso en caso de que venga nulo o igual a cero
		IF @CF_PESOS_IMP='K'
			UPDATE dbo.TempPckListImp_Hyson
			SET  dbo.TempPckListImp_Hyson.PESO = isnull(dbo.MAESTRO.MA_PESO_KG,0)
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.TempPckListImp_Hyson ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'')
			WHERE dbo.MAESTRO.MA_INV_GEN='I' 
				AND MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))=TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
		ELSE
			UPDATE dbo.TempPckListImp_Hyson
			SET  dbo.TempPckListImp_Hyson.PESO = isnull(dbo.MAESTRO.MA_PESO_LB,0)
			FROM         dbo.MAESTRO INNER JOIN
			                      dbo.TempPckListImp_Hyson ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'')
			WHERE dbo.MAESTRO.MA_INV_GEN='I' 
			        AND MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))=TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
	
	
	
		
		
		select @consecutivo=cv_codigo from consecutivo
		where cv_tipo = 'FID'
		
		-- insercion a la tabla factimpdet
		IF @CF_PESOS_IMP='K'
		BEGIN
				INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
			                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
			 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
							       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_NOPARTEAUX) 
			
				SELECT     TOP 100 PERCENT dbo.TempPckListImp_Hyson.ORDEN+@consecutivo, @Codigo, max(dbo.TempPckListImp_Hyson.NOPARTE), isnull(max(dbo.TempPckListImp_Hyson.COSTO),0), 
				                      SUM(dbo.TempPckListImp_Hyson.CANTIDAD), isnull(max(dbo.TempPckListImp_Hyson.PESO),0), max(dbo.MAESTRO.MA_NOMBRE), max(dbo.MAESTRO.MA_NAME), 
				                      dbo.MAESTRO.MA_CODIGO, isnull(max(dbo.MAESTRO.TI_CODIGO),10), dbo.GetAdvalorem(max(dbo.MAESTRO.AR_IMPMX), max(dbo.MAESTRO.PA_ORIGEN), isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), isnull(max(dbo.MAESTRO.SPI_CODIGO),0)),
							isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), 
				                      ISNULL(max(dbo.MAESTRO.SPI_CODIGO), 0), max(dbo.MAESTRO.PA_ORIGEN), max(isnull(dbo.MAESTRO.MA_GENERICO,0)), 
				                      ISNULL(max(dbo.MAESTRO.AR_IMPMX), 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(max(dbo.TempPckListImp_Hyson.PESO),0) * 2.20462442018378, 
				                      ISNULL(max(dbo.MAESTRO.EQ_IMPMX), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO2), 1), ISNULL(max(dbo.MAESTRO.EQ_GEN), 1), isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), 
				                      isnull(max(dbo.MAESTRO.ME_COM),19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO), max(dbo.MAESTRO.ME_COM)),
				                      @PR_CODIGO, round(isnull(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * max(dbo.TempPckListImp_Hyson.COSTO),0),6), 
				                      round(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0),6), round(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0) * 2.20462442018378,6), 
				                      round(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0),6), round(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0) * 2.20462442018378,6),
					         isnull(sum(dbo.TempPckListImp_Hyson.CANTIDAD),0), 'TCO_CODIGO'=case when max(dbo.MAESTRO.MA_TIP_ENS)='A' THEN  (select TCO_COMPRA from configuracion) ELSE isnull(max(VMAESTROCOST.TCO_CODIGO),0) END, MAESTRO.MA_NOPARTEAUX
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.TempPckListImp_Hyson ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') LEFT OUTER JOIN
						VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO 
				WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND
						dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,'')))
									FROM         MAESTRO
									where maestro.ma_inv_gen = 'I'
								          and MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM TempPckListImp_Hyson)		
									GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))
									HAVING      (COUNT(MA_CODIGO) > 1)) 
				GROUP BY dbo.TempPckListImp_Hyson.ORDEN, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, MAESTRO.MA_NOPARTEAUX
				ORDER BY dbo.TempPckListImp_Hyson.ORDEN
			
		END
		ELSE
		BEGIN
				INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNILB,FID_NOMBRE,FID_NAME,MA_CODIGO,
			                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
			 				       AR_EXPFO,FID_PES_UNI,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
							       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_NOPARTEAUX) 
		
				SELECT     TOP 100 PERCENT dbo.TempPckListImp_Hyson.ORDEN+@consecutivo, @Codigo, max(dbo.TempPckListImp_Hyson.NOPARTE), max(dbo.TempPckListImp_Hyson.COSTO), 
				                      sum(dbo.TempPckListImp_Hyson.CANTIDAD), isnull(max(dbo.TempPckListImp_Hyson.PESO),0), max(dbo.MAESTRO.MA_NOMBRE), max(dbo.MAESTRO.MA_NAME), 
				                      dbo.MAESTRO.MA_CODIGO, isnull(max(dbo.MAESTRO.TI_CODIGO),10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, max(dbo.MAESTRO.PA_ORIGEN), isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), isnull(max(dbo.MAESTRO.SPI_CODIGO),0)),
							 isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), 
				                      ISNULL(max(dbo.MAESTRO.SPI_CODIGO), 0), max(dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_GENERICO,0), 
				                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(max(dbo.TempPckListImp_Hyson.PESO),0) / 2.20462442018378, 
				                      ISNULL(max(dbo.MAESTRO.EQ_IMPMX), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO2), 1), ISNULL(max(dbo.MAESTRO.EQ_GEN), 1),  isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), 
				                      isnull(max(dbo.MAESTRO.ME_COM),19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),max(dbo.MAESTRO.ME_COM)),
				                      isnull((SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo),0), round(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.COSTO),0),6), 
				                      round((sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0))/2.20462442018378,6), round(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0),6), 
				                      round((sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0))/2.20462442018378,6), round(sum(dbo.TempPckListImp_Hyson.CANTIDAD) * isnull(max(dbo.TempPckListImp_Hyson.PESO),0),6),
						sum(dbo.TempPckListImp_Hyson.CANTIDAD), 'TCO_CODIGO'=case when max(dbo.MAESTRO.MA_TIP_ENS)='A' THEN  (select TCO_COMPRA from configuracion) ELSE isnull(max(VMAESTROCOST.TCO_CODIGO),0) END, MAESTRO.MA_NOPARTEAUX
				FROM         dbo.MAESTRO INNER JOIN
				                      dbo.TempPckListImp_Hyson ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') LEFT OUTER JOIN
						VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO 
				WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND	
						dbo.TempPckListImp_Hyson.NOPARTE+'-'+ISNULL(TempPckListImp_Hyson.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,'')))
									FROM         MAESTRO
									where maestro.ma_inv_gen = 'I'
		                					  and MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM TempPckListImp_Hyson)
									GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))
									HAVING      (COUNT(MA_CODIGO) > 1))
				GROUP BY dbo.TempPckListImp_Hyson.ORDEN, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, MAESTRO.MA_NOPARTEAUX
				ORDER BY dbo.TempPckListImp_Hyson.ORDEN
		
		
		
			
			
		
		END
	
	
		update factimp
		set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
		where fi_codigo =@Codigo
	
	
		ALTER TABLE FACTIMPDET DISABLE TRIGGER Update_FactImpDet
	
			update factimpdet
			set eq_gen=fid_pes_uni
			where me_gen=36 and fi_codigo=@Codigo
			update factimpdet
			set eq_impmx=fid_pes_uni
			where me_arimpmx=36 and fi_codigo=@Codigo
	
	
		ALTER TABLE FACTIMPDET ENABLE TRIGGER Update_FactImpDet
	
	
		select @FID_indiced= max(FID_indiced) from FACTIMPDET
	
		update consecutivo
		set cv_codigo =  isnull(@FID_indiced,0) + 1
		where cv_tipo = 'FID'
	end
GO
