SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_INSERTAGENERICOARANCEL] (@AR_CODIGO INT)   as

declare @me_codigo int, @ar_fraccion varchar(20), @ar_tiporeg char(1), @pa_codigo int, @ar_uso varchar(150),
@consecutivo int, @ma_codigo int, @me_corto varchar(5)



		select @me_codigo=me_codigo, @ar_fraccion=ar_fraccion, @ar_tiporeg=ar_tiporeg, @pa_codigo=pa_codigo, @ar_uso=ar_uso 
		from arancel where ar_codigo=@AR_CODIGO
		
		update arancel
		set me_codigo=36
		where me_codigo=0

			IF @AR_CODIGO<>0 AND @AR_CODIGO IS NOT NULL
			if (select cf_singenerico from configuracion)='S'
			begin
				select @me_corto=isnull(me_cortoe, me_corto) from medida where me_codigo=@me_codigo

				EXEC SP_GETCONSECUTIVO @TIPO='MA',@VALUE=@CONSECUTIVO OUTPUT
			
			--	SELECT @CONSECUTIVO=ISNULL(MAX(MA_CODIGO),0) FROM MAESTRO 
--				SET @CONSECUTIVO=@CONSECUTIVO+1
			
				if @ar_tiporeg='F' and @pa_codigo=(select cf_pais_mx from configuracion) and
				not exists(select * from maestro where ma_noparte='G'+replace(@ar_fraccion,'.', '')+@me_corto and ma_inv_gen='G')
					insert into maestro(ma_codigo, ma_noparte, ma_inv_gen, pa_origen, pa_procede, ti_codigo, ma_nombre, ma_name, me_com, ar_impmx,
					ar_expmx)
					values (	@CONSECUTIVO, 'G'+replace(@ar_fraccion,'.', '')+@me_corto, 'G', @pa_codigo, @pa_codigo, 10, isnull(@ar_uso,''), isnull(@ar_uso,''), @me_codigo, @ar_codigo,
					@ar_codigo)	
		
			end



























GO
