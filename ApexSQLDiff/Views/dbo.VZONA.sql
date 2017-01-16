SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VZONA
with encryption as
SELECT ZONA.ZO_CODIGO, ZONA.ZO_DESC, PAIS.PA_NOMBRE, 
    PAIS.PA_NAME
FROM ZONA, PAIS
WHERE ZONA.PA_CODIGO = PAIS.PA_CODIGO



GO
