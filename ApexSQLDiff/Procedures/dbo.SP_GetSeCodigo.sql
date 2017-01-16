SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- </GI>


CREATE PROCEDURE dbo.SP_GetSeCodigo (@nMaCodigo Int, @outSeCodigo varchar(2) OUTPUT)   as
   SELECT @outSeCodigo = SE_CODIGO
  FROM MAESTRO
  WHERE (MA_CODIGO = @nMaCodigo)

  RETURN





GO
