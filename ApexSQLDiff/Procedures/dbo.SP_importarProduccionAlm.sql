SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_importarProduccionAlm] (@EN_CODIGO int, @PRO_CODIGO int)   as

SET NOCOUNT ON 
declare @CONSECUTIVO2 int, @MA_CODIGO int, @PROD_NOPARTE varchar(30), @PROD_NOMBRE varchar(150), @ma_name varchar(150),
 @PROD_CANT decimal(38,6), @ma_costo decimal(38,6), @ME_CODIGO int, @ma_generico int, @me_gen int, @PROD_OBSERVA varchar(1100), @EQ_ALM decimal(28,14),
 @PROD_FECHA_STRUCT datetime, @PROD_TIPODESCARGA char(1), @PROD_INDICED int, @MA_EMPAQUE int, @PROD_CANTEMP decimal(38,6),
@end_indiced int, @alm_destino int, @alm_origen int, @tm_tipo char(1), @CONSECUTIVO3 int, @ma_marca varchar(35), @ma_modelo varchar(35), 
@NOSERIE varchar(35), @enc_indicec int, @pro_folio varchar(25), @TI_CODIGO INT, @en_fecha datetime, @SALDO decimal(38,6), @CFM_TIPO VARCHAR(5),
@saldoalm decimal(38,6)
/*
select @pro_folio=pro_folio from produc where pro_codigo=@PRO_CODIGO
SELECT     @alm_destino=isnull(ALM_DESTINO,0), @alm_origen=isnull(ALM_ORIGEN,0), @tm_tipo=TM_TIPO
FROM         TMOVIMIENTO 
WHERE     TM_CODIGO in (select tm_codigo from entsalalm where en_codigo=@EN_CODIGO)

SELECT     @CFM_TIPO= dbo.CONFIGURATMOVIMIENTO.CFM_TIPO
FROM         dbo.ENTSALALM LEFT OUTER JOIN
                      dbo.CONFIGURATMOVIMIENTO ON dbo.ENTSALALM.TM_CODIGO = dbo.CONFIGURATMOVIMIENTO.TM_CODIGO
WHERE dbo.ENTSALALM.EN_CODIGO=@EN_CODIGO
select @en_fecha=en_fecha from entsalalm where en_codigo=@EN_CODIGO
	if (SELECT  CF_DESCMOVALM FROM dbo.CONFIGURACION)='P' AND @CFM_TIPO<>'PR'--salida a produccion
	begin
		IF @CFM_TIPO<>'SA'
		begin
			declare cur_entsalproduccion cursor for
			SELECT     PROD_INDICED, MA_CODIGO, PROD_NOPARTE, PROD_NOMBRE, PROD_CANT/(SELECT EQ_GEN FROM MAESTRO WHERE MA_CODIGO=dbo.PRODUCDET.MA_CODIGO), ME_CODIGO, PROD_OBSERVA, 
			                      PROD_FECHA_STRUCT, isnull(PROD_TIPODESCARGA,'N'), MA_EMPAQUE, isnull(PROD_CANTEMP,0), (select TI_CODIGO
				from maestro where ma_codigo=dbo.PRODUCDET.MA_CODIGO)
			FROM         dbo.PRODUCDET
			where PRO_CODIGO=@PRO_CODIGO and end_indiced=-1
		end
		else
		begin
			declare cur_entsalproduccion cursor for
			SELECT     PROD_INDICED, MA_CODIGO, PROD_NOPARTE, PROD_NOMBRE, PROD_CANT/(SELECT EQ_GEN FROM MAESTRO WHERE MA_CODIGO=dbo.PRODUCDET.MA_CODIGO), ME_CODIGO, PROD_OBSERVA, 
			                      PROD_FECHA_STRUCT, isnull(PROD_TIPODESCARGA,'N'), MA_EMPAQUE, isnull(PROD_CANTEMP,0), (select TI_CODIGO
				from maestro where ma_codigo=dbo.PRODUCDET.MA_CODIGO)
			FROM         dbo.PRODUCDET
			where PRO_CODIGO=@PRO_CODIGO
		end
			open cur_entsalproduccion
			FETCH NEXT FROM cur_entsalproduccion INTO @PROD_INDICED, @MA_CODIGO, @PROD_NOPARTE, @PROD_NOMBRE, @PROD_CANT, @ME_CODIGO, 
					@PROD_OBSERVA, @PROD_FECHA_STRUCT, @PROD_TIPODESCARGA, @MA_EMPAQUE, @PROD_CANTEMP, @TI_CODIGO
		
			WHILE (@@FETCH_STATUS = 0) 
			begin

				SELECT     @SALDO=SUM(dbo.ENTSALALMSALDO.END_SALDOALM)
				FROM         dbo.ENTSALALMDET INNER JOIN
				                      dbo.ENTSALALM ON dbo.ENTSALALMDET.EN_CODIGO = dbo.ENTSALALM.EN_CODIGO INNER JOIN
				                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
				WHERE     (dbo.ENTSALALM.EN_FECHA<=@en_fecha)
				AND dbo.ENTSALALM.ALM_DESTINO=@alm_origen AND  (dbo.ENTSALALMDET.MA_CODIGO = @MA_CODIGO)
				GROUP BY dbo.ENTSALALMDET.MA_CODIGO
				if @CFM_TIPO<>'PR' and @saldo<@PROD_CANT
				set @PROD_CANT=@saldo
				
				SELECT @CONSECUTIVO2=ISNULL(MAX(END_INDICED),0) FROM ENTSALALMDET
				SET @CONSECUTIVO2=@CONSECUTIVO2+1
		
				select @ma_name=ma_name, @EQ_ALM=eq_gen, @ma_generico=ma_generico
				from maestro where ma_codigo=@MA_CODIGO
		
				select @me_gen=me_com from maestro where ma_codigo=@ma_generico
		
				select @ma_costo=ma_costo from vmaestrocost where ma_codigo=@MA_CODIGO
				if @tm_tipo <>'S'
				set @saldoalm=@PROD_CANT
				else
				set @saldoalm=0
		
				INSERT INTO ENTSALALMDET (END_INDICED, EN_CODIGO, MA_CODIGO, END_NOPARTE, END_NOMBRE, END_NAME, END_CANT, END_COS_UNI, 
				END_COS_TOT, END_CAN_ALM, ME_CODIGO, ME_ALM, END_OBSERVA, EQ_ALM, END_FECHA_STRUCT, END_TIPODESCARGA,
				MA_EMPAQUE, END_CANTEMP, END_NOORDEN, TI_CODIGO)
		
				values (@CONSECUTIVO2, @EN_CODIGO, @MA_CODIGO, @PROD_NOPARTE, @PROD_NOMBRE, @ma_name, @PROD_CANT/@EQ_ALM, isnull(@ma_costo,0),
				isnull(@ma_costo,0)*@PROD_CANT, @PROD_CANT, @ME_CODIGO, @me_gen, @PROD_OBSERVA, @EQ_ALM, @PROD_FECHA_STRUCT, 
				'N', @MA_EMPAQUE, @PROD_CANTEMP, @pro_folio, @TI_CODIGO)
				
				IF @CFM_TIPO<>'SA'
				update PRODUCDET
				set END_INDICED=@CONSECUTIVO2
				where PROD_INDICED=@PROD_INDICED	 
		
		
			FETCH NEXT FROM cur_entsalproduccion INTO @PROD_INDICED, @MA_CODIGO, @PROD_NOPARTE, @PROD_NOMBRE, @PROD_CANT, @ME_CODIGO, 
					@PROD_OBSERVA, @PROD_FECHA_STRUCT, @PROD_TIPODESCARGA, @MA_EMPAQUE, @PROD_CANTEMP, @TI_CODIGO
			end
		CLOSE cur_entsalproduccion
		DEALLOCATE cur_entsalproduccion
	end
	else
	begin
		--explosiona el detalle de produccion
		if exists (select * from BOM_DESCTEMP where fe_codigo=@PRO_CODIGO)
		delete from BOM_DESCTEMP where fe_codigo=@PRO_CODIGO
		declare cur_entsalproduccionPt cursor for
		SELECT     PROD_INDICED, MA_CODIGO, PROD_FECHA_STRUCT, PROD_CANT
		FROM         dbo.PRODUCDET
		where PRO_CODIGO=@PRO_CODIGO and end_indiced=-1
		open cur_entsalproduccionPt
		FETCH NEXT FROM cur_entsalproduccionPt INTO @PROD_INDICED, @MA_CODIGO, @PROD_FECHA_STRUCT, @PROD_CANT
	
		WHILE (@@FETCH_STATUS = 0) 
		begin
			exec SP_FILL_BOM_DESCTEMP  @PROD_INDICED, @MA_CODIGO, @PROD_FECHA_STRUCT, @PROD_CANT, @PRO_CODIGO

		FETCH NEXT FROM cur_entsalproduccionPt INTO @PROD_INDICED, @MA_CODIGO, @PROD_FECHA_STRUCT, @PROD_CANT
		end
		CLOSE cur_entsalproduccionPt
		DEALLOCATE cur_entsalproduccionPt
		-- insercion de lo explosionado a la tabla ENTSALALMDET
		if exists (select * from BOM_DESCTEMP WHERE FE_CODIGO=@PRO_CODIGO)
		declare cur_importamp cursor for
		SELECT BST_HIJO, BST_INCORPOR* FED_CANT*FACTCONV , ME_CODIGO
		FROM BOM_DESCTEMP 
		WHERE FE_CODIGO=@PRO_CODIGO and BST_HIJO is not null
		open cur_importamp
		FETCH NEXT FROM cur_importamp INTO @MA_CODIGO, @PROD_CANT, @ME_CODIGO
		WHILE (@@FETCH_STATUS = 0) 
		begin
				SELECT     @SALDO=SUM(dbo.ENTSALALMSALDO.END_SALDOALM)
				FROM         dbo.ENTSALALMDET INNER JOIN
				                      dbo.ENTSALALM ON dbo.ENTSALALMDET.EN_CODIGO = dbo.ENTSALALM.EN_CODIGO INNER JOIN
				                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
				WHERE     (dbo.ENTSALALM.EN_FECHA<=@en_fecha)
				AND dbo.ENTSALALM.ALM_DESTINO=@alm_origen AND  (dbo.ENTSALALMDET.MA_CODIGO = @MA_CODIGO)
				GROUP BY dbo.ENTSALALMDET.MA_CODIGO

				if @saldo<@PROD_CANT
				set @PROD_CANT=@saldo

				SELECT @CONSECUTIVO2=ISNULL(MAX(END_INDICED),0) FROM ENTSALALMDET
				SET @CONSECUTIVO2=@CONSECUTIVO2+1
				if @PROD_CANT>0
				begin
					select @ma_name=ma_name, @EQ_ALM=eq_gen, @ma_generico=ma_generico, @prod_noparte=ma_noparte,
					@prod_nombre=ma_nombre, @ti_codigo=ti_codigo
					from maestro where ma_codigo=@MA_CODIGO
			
					select @me_gen=me_com from maestro where ma_codigo=@ma_generico
			
					select @ma_costo=ma_costo from vmaestrocost where ma_codigo=@MA_CODIGO

					if @tm_tipo <>'S'
					set @saldoalm=@PROD_CANT
					else
					set @saldoalm=0
					INSERT INTO ENTSALALMDET (END_INDICED, EN_CODIGO, MA_CODIGO, END_NOPARTE, END_NOMBRE, END_NAME, END_CANT, END_COS_UNI, 
					END_COS_TOT, END_CAN_ALM, ME_CODIGO, ME_ALM, EQ_ALM, END_NOORDEN, TI_CODIGO, END_TIPODESCARGA)
	
				
					values ( @CONSECUTIVO2, @EN_CODIGO, @MA_CODIGO, @PROD_NOPARTE, @PROD_NOMBRE, @ma_name, @PROD_CANT/@EQ_ALM, isnull(@ma_costo,0),
					isnull(@ma_costo,0)*@PROD_CANT, @PROD_CANT, @ME_CODIGO, @me_gen, @EQ_ALM, @pro_folio, @ti_codigo, 'N')
				end
		FETCH NEXT FROM cur_importamp INTO @MA_CODIGO, @PROD_CANT, @ME_CODIGO
		end
		CLOSE cur_importamp
		DEALLOCATE cur_importamp
	end
	select @en_codigo= max(en_codigo) from entsalalm
	update consecutivo
	set cv_codigo =  isnull(@en_codigo,0) + 1
	where cv_tipo = 'EN'
	select @end_indiced= max(end_indiced) from entsalalmdet
	update consecutivo
	set cv_codigo =  isnull(@end_indiced,0) + 1
	where cv_tipo = 'END'
	select @enc_indicec= max(enc_indicec) from entsalalmcont
	update consecutivo
	set cv_codigo =  isnull(@enc_indicec,0) + 1
	where cv_tipo = 'ENC'

*/
GO
