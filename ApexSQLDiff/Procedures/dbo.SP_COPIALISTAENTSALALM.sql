SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_COPIALISTAENTSALALM (@end_indiced_origen INT,@en_codigo_destino INT,@end_indiced_destino INT)   as

SET NOCOUNT ON 
DECLARE @EN_codigo int, @ma_hijo int, @ENT_noparte varchar(30), @ENT_nombre varchar(150), @ENT_name varchar(150), @ENT_incorpor decimal(38,6), 
@ti_hijo int, @me_codigo int, @ma_generico int, @me_alm int, @ENT_incorgen decimal(38,6), @Factconv decimal(28,14), @EN_ENTSALALMLISTAdes char(1),@CONSECUTIVO INT

DECLARE cur_copiaretra CURSOR FOR
SELECT     MA_HIJO, ENT_NOPARTE, ENT_NOMBRE, ENT_NAME, ENT_INCORPOR, TI_HIJO, ME_CODIGO, me_alm, 
                      FACTCONV
FROM         ENTSALALMLISTA
WHERE     (END_INDICED = @end_indiced_origen)

open cur_copiaretra

fetch next from cur_copiaretra into  @ma_hijo, @ENT_noparte, @ENT_nombre, @ENT_name, @ENT_incorpor, @ti_hijo, @me_codigo, 
@me_alm, @factconv

WHILE (@@FETCH_STATUS = 0) 
BEGIN

		 EXEC SP_GETCONSECUTIVO @TIPO='ENT', @VALUE=@CONSECUTIVO OUTPUT
		INSERT INTO  ENTSALALMLISTA (ENT_INDICER, EN_CODIGO, END_INDICED, MA_HIJO, ENT_NOPARTE,
		 ENT_NOMBRE, ENT_NAME, ENT_INCORPOR, TI_HIJO, ME_CODIGO, me_alm,  
		FACTCONV)

		values 
		(@CONSECUTIVO, @en_codigo_destino, @end_indiced_destino, @ma_hijo, @ENT_noparte, @ENT_nombre, @ENT_name, 
		@ENT_incorpor, @ti_hijo, @me_codigo, @me_alm, @factconv)
		
			
fetch next from cur_copiaretra into  @ma_hijo, @ENT_noparte, @ENT_nombre, @ENT_name, @ENT_incorpor, @ti_hijo, @me_codigo, 
@me_alm, @factconv

END

CLOSE cur_copiaretra
DEALLOCATE cur_copiaretra
GO
