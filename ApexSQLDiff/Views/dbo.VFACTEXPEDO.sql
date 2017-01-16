SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE VIEW dbo.VFACTEXPEDO
with encryption as
SELECT     dbo.FACTEXP.FE_CODIGO, dbo.CAMION.ES_CODIGO AS ES_CAMION, dbo.ESTADO.ES_CORTO AS ES_CORTOCAMION, 
                      ESTADO_1.ES_CODIGO AS ES_CAJA, ESTADO_1.ES_CORTO AS ES_CORTOCAJA
FROM         dbo.ANEXO24 LEFT OUTER JOIN
                      dbo.ESTADO ESTADO_1 ON dbo.ANEXO24.ES_CODIGO = ESTADO_1.ES_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.ANEXO24.MA_CODIGO = dbo.FACTEXP.CJ_COMPANY1 LEFT OUTER JOIN
                      dbo.ESTADO RIGHT OUTER JOIN
                      dbo.CAMION ON dbo.ESTADO.ES_CODIGO = dbo.CAMION.ES_CODIGO ON dbo.FACTEXP.CA_COMPANY1 = dbo.CAMION.CA_CODIGO

































GO
