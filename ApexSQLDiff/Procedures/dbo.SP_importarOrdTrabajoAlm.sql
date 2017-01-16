SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_importarOrdTrabajoAlm] (@EN_CODIGO int, @OT_CODIGO int)   as

SET NOCOUNT ON 
declare @CONSECUTIVO2 int, @MA_CODIGO int, @OTD_NOPARTE varchar(30), @OTD_NOMBRE varchar(150), @ma_name varchar(150),
 @OTD_SIZELOTE decimal(38,6), @ma_costo decimal(38,6), @ME_CODIGO int, @ME_ALM int, @OTD_OBSERVA varchar(1100), @EQ_ALM decimal(28,14),
 @OTD_FECHA_STRUCT datetime, @OTD_TIPODESCARGA char(1), @OTD_INDICED int, @MA_EMPAQUE int, @OTD_SIZELOTEEMP decimal(38,6),
@end_indiced int, @alm_destino int, @alm_origen int, @tm_tipo char(1), @CONSECUTIVO3 int, @ma_marca varchar(35), @ma_modelo varchar(35), 
@NOSERIE varchar(35), @enc_indicec int, @OT_folio varchar(25), @TI_CODIGO INT, @en_fecha datetime, @SALDO decimal(38,6), @CFM_TIPO VARCHAR(5),
@saldoalm decimal(38,6)
/*
select @OT_folio=OT_folio from ORDTRABAJO where OT_codigo=@OT_CODIGO
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
			SELECT     OTD_INDICED, MA_CODIGO, OTD_NOPARTE, OTD_NOMBRE, OTD_SIZELOTE/(SELECT EQ_GEN FROM MAESTRO WHERE MA_CODIGO=dbo.ORDTRABAJODET.MA_CODIGO), ME_CODIGO, OTD_OBSERVA, 
	                        convert(varchar(10), getdate(),101), 'N',   (select TI_CODIGO
				from maestro where ma_codigo=dbo.ORDTRABAJODET.MA_CODIGO)
			FROM         dbo.ORDTRABAJODET
			where OT_CODIGO=@OT_CODIGO and end_indiced=-1
		end
		else
		begin
			declare cur_entsalproduccion cursor for
			SELECT     OTD_INDICED, MA_CODIGO, OTD_NOPARTE, OTD_NOMBRE, OTD_SIZELOTE/(SELECT EQ_GEN FROM MAESTRO WHERE MA_CODIGO=dbo.ORDTRABAJODET.MA_CODIGO), ME_CODIGO, OTD_OBSERVA, 
	                        convert(varchar(10), getdate(),101), 'N',   (select TI_CODIGO
				from maestro where ma_codigo=dbo.ORDTRABAJODET.MA_CODIGO)
			FROM         dbo.ORDTRABAJODET
			where OT_CODIGO=@OT_CODIGO
		end
			open cur_entsalproduccion
			FETCH NEXT FROM cur_entsalproduccion INTO @OTD_INDICED, @MA_CODIGO, @OTD_NOPARTE, @OTD_NOMBRE, @OTD_SIZELOTE, @ME_CODIGO, 
					@OTD_OBSERVA, @OTD_FECHA_STRUCT, @OTD_TIPODESCARGA, @TI_CODIGO
		
			WHILE (@@FETCH_STATUS = 0) 
			begin
				SELECT     @SALDO=SUM(dbo.ENTSALALMSALDO.END_SALDOALM)
				FROM         dbo.ENTSALALMDET INNER JOIN
				                      dbo.ENTSALALM ON dbo.ENTSALALMDET.EN_CODIGO = dbo.ENTSALALM.EN_CODIGO INNER JOIN
				                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
				WHERE     (dbo.ENTSALALM.EN_FECHA<=@en_fecha)
				AND dbo.ENTSALALM.ALM_DESTINO=@alm_origen AND  (dbo.ENTSALALMDET.MA_CODIGO = @MA_CODIGO)
				GROUP BY dbo.ENTSALALMDET.MA_CODIGO

				if @CFM_TIPO<>'PR' and @saldo<@OTD_SIZELOTE
				set @OTD_SIZELOTE=@saldo
				
				SELECT @CONSECUTIVO2=ISNULL(MAX(END_INDICED),0) FROM ENTSALALMDET
				SET @CONSECUTIVO2=@CONSECUTIVO2+1
		
				select @ma_name=ma_name, @EQ_ALM=eq_alm, @me_alm=me_alm
				from maestro where ma_codigo=@MA_CODIGO
		
		
				select @ma_costo=ma_costo from vmaestrocost where ma_codigo=@MA_CODIGO

				if @tm_tipo <>'S'
				set @saldoalm=@OTD_SIZELOTE
				else
				set @saldoalm=0
		
				INSERT INTO ENTSALALMDET (END_INDICED, EN_CODIGO, MA_CODIGO, END_NOPARTE, END_NOMBRE, END_NAME, END_CANT, END_COS_UNI, 
				END_COS_TOT, END_CAN_ALM, ME_CODIGO, ME_ALM, END_OBSERVA, EQ_ALM, END_FECHA_STRUCT, END_TIPODESCARGA,
				END_NOORDEN, TI_CODIGO)
		
				values (@CONSECUTIVO2, @EN_CODIGO, @MA_CODIGO, @OTD_NOPARTE, @OTD_NOMBRE, @ma_name, @OTD_SIZELOTE/@EQ_ALM, isnull(@ma_costo,0),
				isnull(@ma_costo,0)*@OTD_SIZELOTE, @OTD_SIZELOTE, @ME_CODIGO, @ME_ALM, @OTD_OBSERVA, @EQ_ALM, @OTD_FECHA_STRUCT, 
				'N', @OT_folio, @TI_CODIGO)
				
				IF @CFM_TIPO<>'SA'
				update ORDTRABAJODET
				set END_INDICED=@CONSECUTIVO2
				where OTD_INDICED=@OTD_INDICED	 
		
			FETCH NEXT FROM cur_entsalproduccion INTO @OTD_INDICED, @MA_CODIGO, @OTD_NOPARTE, @OTD_NOMBRE, @OTD_SIZELOTE, @ME_CODIGO, 
					@OTD_OBSERVA, @OTD_FECHA_STRUCT, @OTD_TIPODESCARGA, @TI_CODIGO				
			end
		CLOSE cur_entsalproduccion
		DEALLOCATE cur_entsalproduccion
	end
	else
	begin
		print 'explosiona el detalle de produccion'
		if exists (select * from BOM_DESCTEMP where fe_codigo=@OT_CODIGO)
		delete from BOM_DESCTEMP where fe_codigo=@OT_CODIGO
		declare cur_entsalproduccionPt cursor for
		SELECT     OTD_INDICED, MA_CODIGO, convert(varchar(10), getdate(),101), OTD_SIZELOTE
		FROM         dbo.ORDTRABAJODET
		where OT_CODIGO=@OT_CODIGO and end_indiced=-1
		open cur_entsalproduccionPt
		FETCH NEXT FROM cur_entsalproduccionPt INTO @OTD_INDICED, @MA_CODIGO, @OTD_FECHA_STRUCT, @OTD_SIZELOTE
	
		WHILE (@@FETCH_STATUS = 0) 
		begin
			exec SP_FILL_BOM_DESCTEMP  @OTD_INDICED, @MA_CODIGO, @OTD_FECHA_STRUCT, @OTD_SIZELOTE, @OT_CODIGO

		FETCH NEXT FROM cur_entsalproduccionPt INTO @OTD_INDICED, @MA_CODIGO, @OTD_FECHA_STRUCT, @OTD_SIZELOTE
		end
		CLOSE cur_entsalproduccionPt
		DEALLOCATE cur_entsalproduccionPt
		--print 'insercion de lo explosionado a la tabla ENTSALALMDET'
		if exists (select * from BOM_DESCTEMP WHERE FE_CODIGO=@OT_CODIGO)
		declare cur_importamp cursor for
		SELECT BST_HIJO, BST_INCORPOR* FED_CANT*FACTCONV , ME_CODIGO
		FROM BOM_DESCTEMP 
		WHERE FE_CODIGO=@OT_CODIGO and BST_HIJO is not null
		open cur_importamp
		FETCH NEXT FROM cur_importamp INTO @MA_CODIGO, @OTD_SIZELOTE, @ME_CODIGO
		WHILE (@@FETCH_STATUS = 0) 
		begin

				SELECT     @SALDO=SUM(dbo.ENTSALALMSALDO.END_SALDOALM)
				FROM         dbo.ENTSALALMDET INNER JOIN
				                      dbo.ENTSALALM ON dbo.ENTSALALMDET.EN_CODIGO = dbo.ENTSALALM.EN_CODIGO INNER JOIN
				                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
				WHERE     (dbo.ENTSALALM.EN_FECHA<=@en_fecha)
				AND dbo.ENTSALALM.ALM_DESTINO=@alm_origen AND  (dbo.ENTSALALMDET.MA_CODIGO = @MA_CODIGO)
				GROUP BY dbo.ENTSALALMDET.MA_CODIGO
				if @saldo<@OTD_SIZELOTE
				set @OTD_SIZELOTE=@saldo
				--print @OTD_SIZELOTE
				SELECT @CONSECUTIVO2=ISNULL(MAX(END_INDICED),0) FROM ENTSALALMDET
				SET @CONSECUTIVO2=@CONSECUTIVO2+1
				if @OTD_SIZELOTE>0
				begin
					select @ma_name=ma_name, @EQ_ALM=eq_alm, @OTD_noparte=ma_noparte,
					@OTD_nombre=ma_nombre, @ti_codigo=ti_codigo, @me_alm=me_alm
					from maestro where ma_codigo=@MA_CODIGO
					
					select @ma_costo=ma_costo from vmaestrocost where ma_codigo=@MA_CODIGO
					if @tm_tipo <>'S'
					set @saldoalm = @OTD_SIZELOTE
					else
					set @saldoalm = 0
					INSERT INTO ENTSALALMDET (END_INDICED, EN_CODIGO, MA_CODIGO, END_NOPARTE, END_NOMBRE, END_NAME, END_CANT, END_COS_UNI, 
					END_COS_TOT, END_CAN_ALM, ME_CODIGO, ME_ALM, EQ_ALM, END_NOORDEN, TI_CODIGO, END_TIPODESCARGA)
	
				
					values ( @CONSECUTIVO2, @EN_CODIGO, @MA_CODIGO, @OTD_NOPARTE, @OTD_NOMBRE, @ma_name, @OTD_SIZELOTE/@EQ_ALM, isnull(@ma_costo,0),
					isnull(@ma_costo,0)*@OTD_SIZELOTE, @OTD_SIZELOTE, @ME_CODIGO, @me_alm, @EQ_ALM, @OT_folio, @ti_codigo, 'N')
				end
		FETCH NEXT FROM cur_importamp INTO @MA_CODIGO, @OTD_SIZELOTE, @ME_CODIGO
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
