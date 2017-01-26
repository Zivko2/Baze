SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE dbo.SP_EQMAESTRO ( @UMGEN INTEGER,  @UMNP INTEGER, @EQ decimal(38,6) OUTPUT)AS   
SET NOCOUNT ON 
BEGIN
	  SELECT @EQ = EQ_CANT
	  FROM EQUIVALE
	  WHERE ME_CODIGO1 = @UMNP 
	  AND   ME_CODIGO2 = @UMGEN
	  
	  IF(@EQ <=0)  OR (@EQ IS NULL)
	  BEGIN
		SET @EQ = 1 
	  END
END



























GO
