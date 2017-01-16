SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE PROCEDURE [dbo].[SP_SELEQUIPO] (@FE_CODIGO INT, @PID_INDICED INT, @CANT decimal(38,6), @PIC_INDICEC INT, @CONSECUTIVO INT, @RETRABAJO CHAR(1)='N')   as

SET NOCOUNT ON 
declare @MA_CODIGO INT, @PID_NOPARTE VARCHAR(30), @PID_NOMBRE VARCHAR(150), @PID_NAME VARCHAR(150), 
	@PID_COS_UNI decimal(38,6), @PID_PES_UNI decimal(38,6), @ME_CODIGO INT,  @MA_GENERICO INT, @ME_GENERICO INT, @EQ_GENERICO decimal(28,14),
	@TI_CODIGO INT, @PA_ORIGEN INT, @MA_TIP_ENS CHAR(1), @AR_IMPFO INT, @AR_EXPMX INT, @EQ_IMPFO decimal(28,14), @EQ_EXPMX decimal(28,14),
	@FED_INDICED INT, @pic_marca varchar(30), @pic_modelo varchar(30), @pic_serie varchar(30), @fec_indicec int, @consecutivo2 int, @pic_noactivo varchar(50),
	@FE_FECHA VARCHAR(11), @PID_DEF_TIP CHAR(1), @PID_POR_DEF decimal(38,6), @EsRegularizacion char(1), @SPI_CODIGO int, @PID_SEC_IMP int, @cfq_tipo char(1),
	@TipoEmbarque INT, @FE_DESTINO CHAR(1), @PID_SECUENCIA INT, @FE_CODIGOB INT, @PID_PES_UNILB decimal(38,6)

declare @fe_tipo char(1)
--declare @fed_indiced int
declare @re_incorporgen [decimal](38, 6)
declare @fetr_nafta varchar(1)

/* cuando es material vencido el parametro @FE_CODIGO=fe_codigo
 cuando es importcaion a la pestaña de retrabajo el parametro @FE_CODIGO=fed_indiced*/

	IF @RETRABAJO='S'
		SELECT @FE_CODIGOB=FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=@FE_CODIGO
	else
		SET @FE_CODIGOB=@FE_CODIGO


	SELECT @FE_FECHA=CONVERT(VARCHAR(11),FE_FECHA,101), @TipoEmbarque =TQ_CODIGO, @FE_DESTINO=FE_DESTINO FROM FACTEXP WHERE FE_CODIGO=@FE_CODIGOB

	set @EsRegularizacion='N'

	if (select tf_codigo from factexp where fe_codigo=@FE_CODIGOB)= (select tf_codigo from tfactura where tf_nombre='REGULARIZACION (MATERIAL VENCIDO)')
	set @EsRegularizacion='S'


	select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=@TipoEmbarque


IF @RETRABAJO='S'
begin
		if @CANT >0  and not exists (select * from retrabajo where re_indicer=@consecutivo)
		begin
			declare cur_pedimpdet cursor for
			SELECT     dbo.PEDIMPDET.PID_INDICED, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, isnull(dbo.PEDIMPDET.PID_NOMBRE,''), 
		                      isnull(dbo.PEDIMPDET.PID_NAME,''), isnull(dbo.PEDIMPDET.PID_COS_UNI,0), isnull(dbo.PEDIMPDET.ME_CODIGO,0), 
		                      isnull(dbo.PEDIMPDET.MA_GENERICO,0), isnull(dbo.PEDIMPDET.ME_GENERICO,0), isnull(dbo.PEDIMPDET.EQ_GENERICO,1), isnull(dbo.PEDIMPDET.TI_CODIGO,1), 
		                      isnull(dbo.PEDIMPDET.PA_ORIGEN,0), dbo.MAESTRO.MA_TIP_ENS, isnull(dbo.MAESTRO.AR_IMPFO,0), isnull(dbo.MAESTRO.AR_EXPMX,0), isnull(dbo.MAESTRO.EQ_IMPFO,1), 
		                      isnull(dbo.MAESTRO.EQ_EXPMX,1), isnull(dbo.PEDIMPDET.PID_DEF_TIP,'G'), isnull(dbo.PEDIMPDET.PID_POR_DEF,-1), isnull(dbo.PEDIMPDET.SPI_CODIGO,0), isnull(PID_SEC_IMP,0),
					dbo.PEDIMPDET.PID_SECUENCIA, isnull(dbo.PEDIMPDET.PID_PES_UNIKG,0) as PID_PES_UNIKG
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			where dbo.PEDIMPDET.pid_indiced =@pid_indiced
			open cur_pedimpdet
		
			FETCH NEXT FROM cur_pedimpdet INTO @PID_INDICED, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, 
		                    @PID_NAME, @PID_COS_UNI, @ME_CODIGO, 
		                      @MA_GENERICO, @ME_GENERICO, @EQ_GENERICO, @TI_CODIGO, 
		                      @PA_ORIGEN, @MA_TIP_ENS, @AR_IMPFO, @AR_EXPMX, @EQ_IMPFO, 
		                      @EQ_EXPMX, @PID_DEF_TIP, @PID_POR_DEF, @SPI_CODIGO, @PID_SEC_IMP, @PID_SECUENCIA, @PID_PES_UNI
		
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				select @PID_PES_UNILB=@PID_PES_UNI*2.2046
		
				if @PID_PES_UNI is null 
				set @PID_PES_UNI=0
		
		
				if @EsRegularizacion='S'
				begin
					select @PID_POR_DEF=ar_advdef from arancel where ar_codigo=@AR_EXPMX
				
					set @PID_DEF_TIP='G'
					set @SPI_CODIGO = 0
					set @PID_SEC_IMP=0
				end
		
		


						set @fe_tipo = (select max(fe_tipo) from factexp inner join factexpdet on factexp.fe_codigo = factexpdet.fe_codigo where factexpdet.fed_indiced = @FE_CODIGO )
						set @re_incorporgen = (@CANT *@EQ_GENERICO)
						set @fetr_nafta = dbo.GetNafta (@fe_fecha, @MA_CODIGO, @AR_IMPFO, @PA_ORIGEN,  @PID_DEF_TIP, @MA_TIP_ENS)
						
						--Antes de Insertar a la tabla de RETRABAJO debe verificar que no exista otro registro en esa factura con el mismo No.Parte
						if not exists(select * from retrabajo where tipo_factrans = @fe_tipo and fetr_codigo = @FE_CODIGOB 
						and fetr_indiced = @FE_CODIGO and ma_hijo = @MA_CODIGO and pid_indiced = @PID_INDICED)
						begin	

							--inserta a la tabla de RETRABAJO el detalle seleccionado por el cliente de la lista de Material Importado
							insert into retrabajo(  re_indicer,tipo_factrans,fetr_codigo, fetr_indiced, ma_hijo, re_noparte,
										re_incorpor, ti_hijo, me_codigo, me_gen, re_incorporgen,factconv,
										fetr_retrabajodes, ade_codigo,fetr_nafta,pa_origen, fetr_recuperado, pid_indiced,re_nombre, re_name, ma_generico)
							values (@CONSECUTIVO,@fe_tipo, @FE_CODIGOB, @FE_CODIGO, @MA_CODIGO, @PID_NOPARTE, 
								@CANT, @TI_CODIGO, @ME_CODIGO, @ME_GENERICO, @re_incorporgen, @EQ_GENERICO,
								'N', NULL, @fetr_nafta, @PA_ORIGEN, 'N',@PID_INDICED,  @PID_NOMBRE, @PID_NAME, @MA_GENERICO)
							
					
							--Debe actualizar el codigo de la tabla de RETRABAJO
								/*
								select @re_indicer= max(re_indicer) from retrabajo

								update consecutivo
								set cv_codigo =  isnull(@re_indicer,0) + 1
								where cv_tipo = 'RE' and cv_tabla = 'retrabajo'
								*/
								

							update pidescarga
							set pid_saldogen = pid_saldogen - (@CANT*@EQ_GENERICO)
							where pid_indiced=@pid_indiced
					
			
						end
						else
						begin
							--Debe de mandar el registro al log para que el cliente este enterado de que no se pudo asignar ese registro ya que estaba repetido en la pestaña de RETRABAJO
							insert into importlog (	iml_mensaje, iml_cbforma, iml_referencia)
							--values ('No se pudo importar el No.Parte '+@PID_NOPARTE+ ' ya que no se puede repetir en un mismo detalle de Factura', 308, @MA_CODIGO)
							values ('No es posible seleccionar el No.Parte '+@PID_NOPARTE+ ' debido a que no se puede seleccionar dos veces del mismo detalle del Ped. Importación', 308, @MA_CODIGO)
						end
			
			FETCH NEXT FROM cur_pedimpdet INTO @PID_INDICED, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, 
		             	       @PID_NAME, @PID_COS_UNI, @ME_CODIGO, 
		                      @MA_GENERICO, @ME_GENERICO, @EQ_GENERICO, @TI_CODIGO, 
		                      @PA_ORIGEN, @MA_TIP_ENS, @AR_IMPFO, @AR_EXPMX, @EQ_IMPFO, 
		                      @EQ_EXPMX, @PID_DEF_TIP, @PID_POR_DEF, @SPI_CODIGO, @PID_SEC_IMP, @PID_SECUENCIA, @PID_PES_UNI
		
			end
			close cur_pedimpdet
			deallocate cur_pedimpdet
		
		
		end

end 
else
begin
		if @CANT >0  and not exists (select * from factexpdet where fed_indiced=@consecutivo)
		begin
			declare cur_pedimpdet cursor for
			SELECT     dbo.PEDIMPDET.PID_INDICED, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, isnull(dbo.PEDIMPDET.PID_NOMBRE,''), 
		                      isnull(dbo.PEDIMPDET.PID_NAME,''), isnull(dbo.PEDIMPDET.PID_COS_UNI,0), isnull(dbo.PEDIMPDET.ME_CODIGO,0), 
		                      isnull(dbo.PEDIMPDET.MA_GENERICO,0), isnull(dbo.PEDIMPDET.ME_GENERICO,0), isnull(dbo.PEDIMPDET.EQ_GENERICO,1), isnull(dbo.PEDIMPDET.TI_CODIGO,1), 
		                      isnull(dbo.PEDIMPDET.PA_ORIGEN,0), dbo.MAESTRO.MA_TIP_ENS, isnull(dbo.MAESTRO.AR_IMPFO,0), isnull(dbo.MAESTRO.AR_EXPMX,0), isnull(dbo.MAESTRO.EQ_IMPFO,1), 
		                      isnull(dbo.MAESTRO.EQ_EXPMX,1), isnull(dbo.PEDIMPDET.PID_DEF_TIP,'G'), isnull(dbo.PEDIMPDET.PID_POR_DEF,-1), isnull(dbo.PEDIMPDET.SPI_CODIGO,0), isnull(PID_SEC_IMP,0),
					dbo.PEDIMPDET.PID_SECUENCIA, isnull(dbo.PEDIMPDET.PID_PES_UNIKG,0) as PID_PES_UNIKG
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			where dbo.PEDIMPDET.pid_indiced =@pid_indiced
			open cur_pedimpdet
		
			FETCH NEXT FROM cur_pedimpdet INTO @PID_INDICED, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, 
		                    @PID_NAME, @PID_COS_UNI, @ME_CODIGO, 
		                      @MA_GENERICO, @ME_GENERICO, @EQ_GENERICO, @TI_CODIGO, 
		                      @PA_ORIGEN, @MA_TIP_ENS, @AR_IMPFO, @AR_EXPMX, @EQ_IMPFO, 
		                      @EQ_EXPMX, @PID_DEF_TIP, @PID_POR_DEF, @SPI_CODIGO, @PID_SEC_IMP, @PID_SECUENCIA, @PID_PES_UNI
		
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				select @PID_PES_UNILB=@PID_PES_UNI*2.2046
		
				if @PID_PES_UNI is null 
				set @PID_PES_UNI=0
		
		
				if @EsRegularizacion='S'
				begin
					select @PID_POR_DEF=ar_advdef from arancel where ar_codigo=@AR_EXPMX
				
					set @PID_DEF_TIP='G'
					set @SPI_CODIGO = 0
					set @PID_SEC_IMP=0
				end
		
		
		
						/* es igual acero porque se repite el stored por cada contendo, en el primero manda la cantidad y en los sig. cero */
		
						insert into factexpdet (FE_CODIGO, FED_INDICED, MA_CODIGO, FED_NOPARTE, FED_NOMBRE, FED_NAME, FED_COS_UNI, FED_PES_UNI, FED_PES_UNILB, ME_CODIGO, 
				             		       MA_GENERICO, ME_GENERICO, EQ_GEN, TI_CODIGO, PA_CODIGO, FED_TIP_ENS, AR_IMPFO, AR_EXPMX, EQ_IMPFO, 
				             		         EQ_EXPMX, PID_INDICED, FED_CANT, FED_FECHA_STRUCT, FED_DEF_TIP, FED_POR_DEF, SPI_CODIGO, FED_SEC_IMP, FED_SECF4)
				
						VALUES (@FE_CODIGOB, @CONSECUTIVO, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, 
				             		       @PID_NAME, @PID_COS_UNI, @PID_PES_UNI, @PID_PES_UNILB, @ME_CODIGO, 
					                      @MA_GENERICO, @ME_GENERICO, @EQ_GENERICO, @TI_CODIGO, 
				             		         @PA_ORIGEN, @MA_TIP_ENS, @AR_IMPFO, @AR_EXPMX, @EQ_IMPFO, 
					                      @EQ_EXPMX, @PID_INDICED, @CANT, @FE_FECHA, @PID_DEF_TIP, @PID_POR_DEF, @SPI_CODIGO, @PID_SEC_IMP, @PID_SECUENCIA)
		
		
				
						update pidescarga
						set pid_saldogen = pid_saldogen - (@CANT*@EQ_GENERICO)
						where pid_indiced=@pid_indiced
				
		
						IF (SELECT CF_TCOCOMPRAIMP FROM CONFIGURACION)='S'
							UPDATE FACTEXPDET
							SET AR_IMPFO=(CASE when @cfq_tipo='D' then isnull(MAESTRO.AR_DESP,0) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and @PA_ORIGEN=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.AR_IMPFO,0) else isnull(MAESTRO.AR_IMPFOUSA,0) end) 
								     else (CASE wheN FED_TIP_ENS ='C' then isnull(MAESTRO.AR_IMPFO,0) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.AR_IMPFOFIS,0) else isnull(MAESTRO.AR_IMPFO,0) end) end) end) end),
							EQ_IMPFO=(CASE when @cfq_tipo='D' then isnull(MAESTRO.EQ_DESP,1) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and @PA_ORIGEN=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.EQ_IMPFO,1) else isnull(MAESTRO.EQ_IMPFOUSA,1) end)
								     else (CASE wheN FED_TIP_ENS ='C' then isnull(MAESTRO.EQ_IMPFO,1) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.EQ_IMPFOFIS,1) else isnull(MAESTRO.EQ_IMPFO,1) end) end) end) end)
							FROM FACTEXPDET 
							  LEFT OUTER JOIN MAESTRO 
							  ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN ANEXO24 
							  ON ANEXO24.MA_CODIGO = MAESTRO.MA_CODIGO 
							WHERE FACTEXPDET.FED_INDICED=@CONSECUTIVO
						ELSE
							UPDATE FACTEXPDET
							SET AR_IMPFO=(CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and @PA_ORIGEN=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.AR_IMPFO,0) else isnull(dbo.MAESTRO.AR_IMPFOUSA,0) end) else isnull(dbo.MAESTRO.AR_IMPFO,0) end) end),
					  	            EQ_IMPFO=(CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and @PA_ORIGEN=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.EQ_IMPFO,1) else isnull(dbo.MAESTRO.EQ_IMPFOUSA,1) end) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end) end)
							FROM FACTEXPDET 
							  LEFT OUTER JOIN MAESTRO 
							  ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO
							WHERE FACTEXPDET.FED_INDICED=@CONSECUTIVO
							
		
		
						IF @cfq_tipo='D' AND @FE_DESTINO='N'
						UPDATE FACTEXPDET
						SET AR_EXPMX=isnull(dbo.MAESTRO.AR_DESPMX,0),
						    EQ_EXPMX=isnull(dbo.MAESTRO.EQ_DESPMX,1)
						FROM FACTEXPDET 
						  LEFT OUTER JOIN MAESTRO 
						  ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO 
						WHERE FACTEXPDET.FED_INDICED=@CONSECUTIVO
					
		
					
						update factexpdet	
						set ar_orig= case when fed_nafta='S' then
							 0 else ( case when isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0)=0 
							then  isnull((select AR_IMPFOUSA from maestro where maestro.ma_codigo=factexpdet.ma_codigo),0)  else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end) end
						where (ar_orig is null or ar_orig =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
						and fed_ng_usa>0 and FED_INDICED=@CONSECUTIVO
						
					
						update factexpdet
						set ar_ng_emp= case when fed_nafta='S' then
						 0 else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='3' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end
						where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
						and fed_ng_emp>0 and FED_INDICED=@CONSECUTIVO
					
					
					
						UPDATE FACTEXPDET
						SET FED_NAFTA=dbo.GetNafta (@fe_fecha, FACTEXPDET.MA_CODIGO, FACTEXPDET.AR_IMPMX, FACTEXPDET.PA_CODIGO, FACTEXPDET.FED_DEF_TIP, FACTEXPDET.FED_TIP_ENS)
						FROM FACTEXPDET 
						WHERE FED_INDICED=@CONSECUTIVO
					
						UPDATE FACTEXPDET
						SET FED_RATEIMPFO=(CASE WHEN FED_NAFTA='S' THEN 0 ELSE dbo.GetAdvalorem(AR_IMPFO, 0, 'G', 0, 0) END)
						FROM FACTEXPDET 
						WHERE FED_INDICED=@CONSECUTIVO
					
					
					
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
						where  FACTEXPDET.FED_INDICED=@CONSECUTIVO
				
				
			
			FETCH NEXT FROM cur_pedimpdet INTO @PID_INDICED, @MA_CODIGO, @PID_NOPARTE, @PID_NOMBRE, 
		             	       @PID_NAME, @PID_COS_UNI, @ME_CODIGO, 
		                      @MA_GENERICO, @ME_GENERICO, @EQ_GENERICO, @TI_CODIGO, 
		                      @PA_ORIGEN, @MA_TIP_ENS, @AR_IMPFO, @AR_EXPMX, @EQ_IMPFO, 
		                      @EQ_EXPMX, @PID_DEF_TIP, @PID_POR_DEF, @SPI_CODIGO, @PID_SEC_IMP, @PID_SECUENCIA, @PID_PES_UNI
		
			end
			close cur_pedimpdet
			deallocate cur_pedimpdet
		
			IF @RETRABAJO<>'S'
			UPDATE factexpdet
			SET FED_COS_TOT=ROUND(FED_COS_UNI*FED_CANT,6)
			WHERE FE_CODIGO=@FE_CODIGOB
		
		
			UPDATE factexpdet
			SET FED_PES_NET=ROUND(FED_PES_UNI*FED_CANT,6), FED_PES_NETLB=ROUND(FED_PES_UNILB*FED_CANT,6)
			WHERE FE_CODIGO=@FE_CODIGOB
		
		
			UPDATE factexpdet
			SET FED_PES_BRU=ROUND(FED_PES_UNI*FED_CANT,6), FED_PES_BRULB=ROUND(FED_PES_UNILB*FED_CANT,6)
			WHERE FE_CODIGO=@FE_CODIGOB AND ISNULL(FED_CANTEMP,0)=0
		
		end
end


if @RETRABAJO<>'S' AND @PIC_INDICEC <>0   /* es cero cuando no existen contenidos seleccionados */
begin
		declare cur_pedimpcont cursor for
		select pic_marca, pic_modelo, pic_serie, pic_noactivo
		from pedimpcont where pic_indicec=@PIC_INDICEC
		
		open cur_pedimpcont
		fetch next from cur_pedimpcont into @pic_marca, @pic_modelo, @pic_serie, @pic_noactivo

		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			SELECT @CONSECUTIVO2=ISNULL(MAX(FEC_INDICEC),0) FROM FACTEXPCONT
	
			SET @CONSECUTIVO2=@CONSECUTIVO2+1

			insert into factexpcont (fe_codigo, fed_indiced, fec_indicec, fec_marca, fec_modelo, fec_serie, pic_indicec, fec_descargado, fec_noactivo)
			values (@FE_CODIGOB, @CONSECUTIVO, @CONSECUTIVO2, @pic_marca, @pic_modelo, @pic_serie, @pic_indicec, 'S', @pic_noactivo)


			UPDATE PEDIMPCONT
			SET PIC_USO_DESCARGA ='S'
			WHERE PIC_INDICEC =@PIC_INDICEC

			fetch next from cur_pedimpcont into @pic_marca, @pic_modelo, @pic_serie, @pic_noactivo

		END	
	close cur_pedimpcont
	deallocate cur_pedimpcont

end


--Yolanda Avila
--2010-01-20
--Cuando es "Retrabajo" el tipo de descarga el valor de PIC_INDICEC es CERO
if @RETRABAJO<>'S'
begin
		select @fec_indicec= max(fec_indicec) from factexpcont

		update consecutivo
		set cv_codigo =  isnull(@fec_indicec,0) + 1
		where cv_tipo = 'FEC'

end
GO
