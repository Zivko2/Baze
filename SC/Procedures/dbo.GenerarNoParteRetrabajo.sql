SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GenerarNoParteRetrabajo] (@MA_CODIGO INT, @CONSECUTIVO INT output)   as

declare @AUX varchar(10), @CONSECUTIVOAUX int

select @AUX = ma_noparteaux from maestro where ma_noparteaux like 'RT_%'
if (@AUX is null) or (@AUX = '')
	Set @AUX = 'RT_1'
else
	begin
		select @CONSECUTIVOAUX = max(convert(int,replace(ma_noparteaux,'RT_',''))) from maestro 
		where ma_noparteaux like '%RT_%'
		set @AUX = 'RT_'+Convert(varchar(100),@CONSECUTIVOAUX+1)
	end
	
EXEC SP_GETCONSECUTIVO @TIPO='MA', @VALUE=@CONSECUTIVO OUTPUT
Insert Into maestro (ma_codigo, TI_CODIGO, MA_INV_GEN, MA_NOMBRE, MA_NAME, MA_NOPARTE, MA_NOPARTEAUX, MA_TIP_ENS, ME_COM, PA_ORIGEN, PA_PROCEDE, MA_OCULTO)
select @CONSECUTIVO, 
	   (select ti_codigo from maestro where ma_codigo = @ma_codigo) ti_codigo, 
	   'I', '.','.',(select ma_noparte from maestro where ma_codigo = @ma_codigo),@AUX, 'F',
	   (select me_codigo from medida where me_corto = 'EA'), 
	   (select pa_codigo from pais where pa_corto = 'UNKN'), 
	   (select pa_codigo from pais where pa_corto = 'UNKN'), 'S'


exec DatosOriginalesNoParteRetrabajo @MA_CODIGO, @CONSECUTIVO


GO
