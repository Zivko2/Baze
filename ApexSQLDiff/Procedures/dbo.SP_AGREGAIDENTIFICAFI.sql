SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE PROCEDURE [dbo].[SP_AGREGAIDENTIFICAFI]  (@fi_codigo int, @cl_codigo int)   as

SET NOCOUNT ON 

declare @CONSECUTIVO INT, @IDE_CODIGO INT, @IDED_CODIGO INT, @IDEC_DESC VARCHAR(40), @IDEC_DESC2 VARCHAR(40)



declare cur_identificaFi cursor for
	SELECT     IDE_CODIGO, IDED_CODIGO, IDEC_DESC, IDEC_DESC2
	FROM         IDENTIFICACLIENTE
	WHERE     (CL_CODIGO = @cl_codigo) AND (IDEC_MOVIMIENTO = 'E' OR
	                      IDEC_MOVIMIENTO = 'A') AND (IDEC_NIVEL = 'A' OR
	                      IDEC_NIVEL = 'G')

open cur_identificaFi


	FETCH NEXT FROM cur_identificaFi INTO @IDE_CODIGO, @IDED_CODIGO, @IDEC_DESC, @IDEC_DESC2

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		delete from FACTIMPIDENTIFICA where ide_codigo=@IDE_CODIGO and
				fi_codigo=@fi_codigo

		 EXEC SP_GETCONSECUTIVO @TIPO='FII', @VALUE=@CONSECUTIVO OUTPUT

		INSERT INTO FACTIMPIDENTIFICA(FII_CODIGO, FI_CODIGO, IDE_CODIGO, IDED_CODIGO, FII_DESC, FII_DESC2)
		VALUES (@CONSECUTIVO, @fi_codigo, @IDE_CODIGO, @IDED_CODIGO, @IDEC_DESC, @IDEC_DESC2)



	FETCH NEXT FROM cur_identificaFi INTO @IDE_CODIGO, @IDED_CODIGO, @IDEC_DESC, @IDEC_DESC2

END

CLOSE cur_identificaFi
DEALLOCATE cur_identificaFi






























GO
