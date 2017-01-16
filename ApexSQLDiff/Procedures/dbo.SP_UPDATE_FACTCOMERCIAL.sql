SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_UPDATE_FACTCOMERCIAL(@CODIGO INTEGER)   as

SET NOCOUNT ON 
BEGIN
  -- El client dataset actualiza el codigo a -2 porque no tiene manera de saber cual numero le ser~ asignado al Entry Summary
  UPDATE COMMINV SET ET_CODIGO = @CODIGO WHERE ET_CODIGO = -2
END


GO
