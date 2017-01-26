SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_GETUMGENERICO (@GENID INTEGER,  @UMGEN INTEGER OUTPUT)   as

BEGIN
	SELECT @UMGEN = ME_COM
	FROM MAESTRO 
	WHERE MA_GENERICO =  @GENID

	IF @UMGEN = NULL 
		SET @UMGEN = 0
END



























GO
