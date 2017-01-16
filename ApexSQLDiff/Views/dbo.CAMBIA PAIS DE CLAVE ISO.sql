SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.[CAMBIA PAIS DE CLAVE ISO]
AS
SELECT     dbo.PAIS.PA_CORTO, dbo.PAISharvard.PA_CODIGO, dbo.PAIS.PA_CODIGO AS Expr1, dbo.PAISharvard.PA_CORTO AS Expr2, dbo.PAIS.PA_ISO, 
                      dbo.PAISharvard.PA_ISO AS Expr3
FROM         dbo.PAIS INNER JOIN
                      dbo.PAISharvard ON dbo.PAIS.PA_CODIGO = dbo.PAISharvard.PA_CODIGO AND dbo.PAIS.PA_ISO <> dbo.PAISharvard.PA_ISO
GO
