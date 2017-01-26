SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.SP_GetCodigoMexico   as
    DECLARE @outCodigoMexico Int

   SELECT @outCodigoMexico = CF_PAIS_MX FROM Configuracion
   IF (@outCodigoMexico >0)
      RETURN @outCodigoMexico
   ELSE
      RETURN 0




GO
