SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE dbo.SP_GetTipoOperacion (@strVal varchar(2))   as
    SELECT     CP_CLAVE, 'D' AS TipoOperacion
   FROM         dbo.CLAVEPED
   WHERE     (CP_NOMBRE LIKE '%DEFINITIV%') AND CP_CLAVE = @strVal
   union
   SELECT     CP_CLAVE, 'V' AS TipoOperacion
   FROM         dbo.CLAVEPED
   WHERE     ((CP_NOMBRE NOT LIKE '%DEFINITIV%') AND (CP_NOMBRE LIKE '%VIRTUAL%')) AND CP_CLAVE = @strVal
   union
   SELECT     CP_CLAVE, 'C' AS TipoOperacion
   FROM         dbo.CLAVEPED
   WHERE     (((not (CP_NOMBRE NOT LIKE '%DEFINITIV%') AND (CP_NOMBRE LIKE '%VIRTUAL%')) or not (CP_NOMBRE LIKE '%DEFINITIV%')) and (CP_CLAVE <> 'CT')) AND CP_CLAVE = @strVal
RETURN



GO
