SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE dbo.SP_SETRANGOARA ( @RINI VARCHAR(20),  @RFIN VARCHAR(20), @CBARRA VARCHAR(20))    as

SET NOCOUNT ON 
BEGIN
     UPDATE ARANCEL
     SET RA_CODIGO = @CBARRA
     WHERE AR_FRACCION BETWEEN @RINI AND @RFIN;
END


































GO
