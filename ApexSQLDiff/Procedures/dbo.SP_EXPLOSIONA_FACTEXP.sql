SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_EXPLOSIONA_FACTEXP] (@tipofactura char(1), @FE_CODIGO int)   as

SET NOCOUNT ON 
DECLARE @FE_CODIGOA int

	if @tipofactura='I'
	begin

			EXEC SP_DescExplosionFactExp @FE_CODIGO, 1
	end
	if @tipofactura='A'
	begin
	
		declare cur_factexp cursor static for
			SELECT FE_CODIGO FROM FACTEXP WHERE FE_FACTAGRU=@FE_CODIGO
		open  cur_factexp
		
		
			FETCH NEXT FROM  cur_factexp INTO @FE_CODIGOA
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

				EXEC SP_DescExplosionFactExp @FE_CODIGOA, 1
		
			FETCH NEXT FROM  cur_factexp INTO @FE_CODIGOA
		
		END
		
		CLOSE  cur_factexp
		DEALLOCATE  cur_factexp
	end


GO
