SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CALCULAINCREMENTASALIDA] (@FE_CODIGO INT, @USER INT)   as

DECLARE @TF_CODIGO SMALLINT , @TQ_CODIGO SMALLINT

	SELECT @TF_CODIGO=TF_CODIGO, @TQ_CODIGO=TQ_CODIGO FROM FACTEXP WHERE FE_CODIGO=@FE_CODIGO

	DELETE FROM FACTEXPINCREMENTA WHERE FE_CODIGO=@FE_CODIGO


	INSERT INTO FACTEXPINCREMENTA(FE_CODIGO, IC_CODIGO, FEI_VALOR)
	SELECT    @FE_CODIGO, IC_CODIGO, ISNULL((SELECT     SUM(FED_COS_TOT) 
	FROM         FACTEXPDET
	WHERE FE_CODIGO = @FE_CODIGO),0)*(IC_PORENTRADA/100)
	FROM         INCREMENTABLE
	GROUP BY IC_CODIGO, IC_PORENTRADA
	HAVING      (IC_PORENTRADA > 0)


	if exists(SELECT     IC_CODIGO
	FROM         INCREMENTABLEXDOC
	WHERE TF_CODIGO=@TF_CODIGO AND TQ_CODIGO=@TQ_CODIGO)
	begin

		INSERT INTO FACTEXPINCREMENTA(FE_CODIGO, IC_CODIGO, FEI_VALOR)
		SELECT    @FE_CODIGO, IC_CODIGO, ISNULL((SELECT     SUM(FED_COS_TOT) 
			FROM         FACTEXPDET
			WHERE FE_CODIGO = @FE_CODIGO),0)*(IC_PORCENTAJE/100)
		FROM         INCREMENTABLEXDOC
		WHERE TF_CODIGO=@TF_CODIGO AND TQ_CODIGO=@TQ_CODIGO
		GROUP BY IC_CODIGO, IC_PORCENTAJE
		HAVING      (IC_PORCENTAJE > 0)
	
	
	end


GO
