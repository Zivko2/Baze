SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_COPIALISTARETRABAJO (@fed_indiced_origen INT,@fe_codigo_destino INT,@fed_indiced_destino INT,@tipo char(1))   as

SET NOCOUNT ON 
DECLARE @fetr_codigo int, @tipo_factrans char(1), @ma_hijo int, @re_noparte varchar(30), @re_nombre varchar(150), @re_name varchar(150), @re_incorpor decimal(38,6), 
@ti_hijo int, @me_codigo int, @ma_generico int, @me_gen int, @re_incorgen decimal(38,6), @Factconv decimal(28,14), @fetr_retrabajodes char(1),@CONSECUTIVO INT, 
@fetr_nafta char(1), @pa_origen int


DECLARE cur_copiaretra CURSOR FOR

SELECT     MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR, TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, 
                      RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN
FROM         RETRABAJO
WHERE     (FETR_INDICED = @fed_indiced_origen)


open cur_copiaretra


fetch next from cur_copiaretra into  @ma_hijo, @re_noparte, @re_nombre, @re_name, @re_incorpor, @ti_hijo, @me_codigo, @ma_generico,
@me_gen, @re_incorgen, @factconv, @fetr_retrabajodes, @fetr_nafta, @pa_origen


WHILE (@@FETCH_STATUS = 0) 
BEGIN

	--SELECT @tipo_factrans= FE_TIPO FROM FACTEXP WHERE FE_CODIGO=@fe_codigo_destino
	SELECT @tipo_factrans=@tipo

		 EXEC SP_GETCONSECUTIVO @TIPO='RE',@VALUE=@CONSECUTIVO OUTPUT

		INSERT INTO  RETRABAJO (RE_INDICER,TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE,
		 RE_NOMBRE, RE_NAME, RE_INCORPOR, TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, 
		FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)


		values 
		(@CONSECUTIVO,@tipo_factrans, @fe_codigo_destino,@fed_indiced_destino, @ma_hijo, @re_noparte, @re_nombre, @re_name, 
		@re_incorpor, @ti_hijo, @me_codigo, @ma_generico, @me_gen, @re_incorgen, @factconv, @fetr_retrabajodes, @fetr_nafta, @pa_origen)
		
			

fetch next from cur_copiaretra into  @ma_hijo, @re_noparte, @re_nombre, @re_name, @re_incorpor, @ti_hijo, @me_codigo, @ma_generico,
@me_gen, @re_incorgen, @factconv, @fetr_retrabajodes, @fetr_nafta, @pa_origen


END


CLOSE cur_copiaretra
DEALLOCATE cur_copiaretra



GO
