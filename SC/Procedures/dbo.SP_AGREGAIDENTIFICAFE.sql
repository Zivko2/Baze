SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE PROCEDURE [dbo].[SP_AGREGAIDENTIFICAFE]  (@fe_codigo int, @cl_codigo int)   as

SET NOCOUNT ON 

declare @CONSECUTIVO INT, @IDE_CODIGO INT, @IDED_CODIGO INT, @IDEC_DESC VARCHAR(40), @IDEC_DESC2 VARCHAR(40)



declare cur_identificaFe cursor for
	SELECT     IDE_CODIGO, IDED_CODIGO, IDEC_DESC, IDEC_DESC2
	FROM         IDENTIFICACLIENTE
	WHERE     (CL_CODIGO = @cl_codigo) AND (IDEC_MOVIMIENTO = 'S' OR
	                      IDEC_MOVIMIENTO = 'A') AND (IDEC_NIVEL = 'A' OR
	                      IDEC_NIVEL = 'G')

open cur_identificaFe


	FETCH NEXT FROM cur_identificaFe INTO @IDE_CODIGO, @IDED_CODIGO, @IDEC_DESC, @IDEC_DESC2

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		delete from FACTEXPIDENTIFICA where ide_codigo=@IDE_CODIGO and
				FE_codigo=@FE_codigo 

		 EXEC SP_GETCONSECUTIVO @TIPO='FEI', @VALUE=@CONSECUTIVO OUTPUT

		INSERT INTO FACTEXPIDENTIFICA(FEI_CODIGO, FE_CODIGO, IDE_CODIGO, IDED_CODIGO, FEI_DESC, FEI_DESC2)
		VALUES (@CONSECUTIVO, @FE_codigo, @IDE_CODIGO, @IDED_CODIGO, @IDEC_DESC, @IDEC_DESC2)



	FETCH NEXT FROM cur_identificaFe INTO @IDE_CODIGO, @IDED_CODIGO, @IDEC_DESC, @IDEC_DESC2

END

CLOSE cur_identificaFe
DEALLOCATE cur_identificaFe






























GO
