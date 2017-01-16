SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_INSERTA_GENERICOARANCELALL]   as

SET NOCOUNT ON 
declare @ar_codigo int, @me_codigo int, @ar_fraccion varchar(20), @pa_codigo int, @ar_uso varchar(150),
@consecutivo int, @ma_codigo int, @me_corto varchar(5)

declare cur_insertgenerico cursor for
		select ar_codigo, me_codigo, ar_fraccion, pa_codigo, ar_uso 
		from arancel where pa_codigo=(select cf_pais_mx from configuracion) and
		ar_tiporeg='F'
	open cur_insertgenerico
		fetch next from cur_insertgenerico into @ar_codigo, @me_codigo, @ar_fraccion, @pa_codigo, @ar_uso
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

				select @me_corto=isnull(me_cortoe, me_corto) from medida where me_codigo=@me_codigo

				EXEC SP_GETCONSECUTIVO @TIPO='MA',@VALUE=@CONSECUTIVO OUTPUT
		

				if not exists(select * from maestro where ma_noparte='G'+replace(@ar_fraccion,'.', '')+@me_corto and ma_inv_gen='G')
					insert into maestro(ma_codigo, ma_noparte, ma_inv_gen, pa_origen, pa_procede, ti_codigo, ma_nombre, ma_name, me_com, ar_impmx,
					ar_expmx)
					values (@CONSECUTIVO, 'G'+replace(@ar_fraccion,'.', '')+@me_corto, 'G', @pa_codigo, @pa_codigo, 10, isnull(@ar_uso,''), isnull(@ar_uso,''), @me_codigo, @ar_codigo,
					@ar_codigo)	
		


		fetch next from cur_insertgenerico into @ar_codigo, @me_codigo, @ar_fraccion, @pa_codigo, @ar_uso
		END

	CLOSE cur_insertgenerico
	DEALLOCATE cur_insertgenerico



























GO
