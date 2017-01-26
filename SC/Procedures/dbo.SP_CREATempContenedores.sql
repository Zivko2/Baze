SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CREATempContenedores] (@FIEG_CODIGO INT, @MOVIMIENTO CHAR(1), @USUARIO INT)   as

declare @USUARIO1 varchar(50), @FIEG_CODIGO1 varchar(50)

	select @USUARIO1=convert(varchar(50),@USUARIO), @FIEG_CODIGO1=convert(varchar(50),@FIEG_CODIGO)

	IF @MOVIMIENTO='E'
	BEGIN
		exec('exec sp_droptable ''TempFigCONTENEDORES'+@USUARIO1+'''')

		exec('Create table TempFigCONTENEDORES'+@USUARIO1+' 
		(Consecutivo int IDENTITY (1, 1) NOT NULL , 
		FI_CONT_REG varchar(20))')

		

		exec('INSERT INTO TempFigCONTENEDORES'+@USUARIO1+'(FI_CONT_REG)
		SELECT     FI_CONT_REG
		FROM         FACTIMP
		WHERE     (FIG_CODIGO = '+@FIEG_CODIGO1+') AND (FI_CONT_REG IS NOT NULL AND FI_CONT_REG <> '''')
		GROUP BY FI_CONT_REG')
	END
	ELSE
	BEGIN


		exec('exec sp_droptable ''TempFegCONTENEDORES'+@USUARIO1+'''')

		exec('Create table TempFegCONTENEDORES'+@USUARIO1+' 
		(Consecutivo int IDENTITY (1, 1) NOT NULL , 
		FE_CONT1_REG varchar(20))')

		

		exec('INSERT INTO TempFegCONTENEDORES'+@USUARIO1+'(FE_CONT1_REG)
		SELECT     FE_CONT1_REG
		FROM         FACTEXP
		WHERE     (FEG_CODIGO = '+@FIEG_CODIGO1+') AND (FE_CONT1_REG IS NOT NULL AND FE_CONT1_REG <> '''')
		GROUP BY FE_CONT1_REG')
	END
GO
