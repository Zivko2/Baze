SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_GetKapTipoEnsPert (@nMaCodigo Int, @outTipoEns char(1) OUTPUT)   as
   SELECT @outTipoEns = CONFIGURATIPO.CFT_TIPO
  FROM MAESTRO INNER JOIN
      CONFIGURATIPO ON 
      MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
  WHERE (MAESTRO.MA_CODIGO = @nMaCodigo)

  RETURN



GO
