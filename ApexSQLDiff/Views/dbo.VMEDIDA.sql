SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.VMEDIDA
with encryption as
SELECT     TOP 100 PERCENT dbo.MEDIDA.ME_CODIGO, dbo.MEDIDA.ME_CORTO, dbo.MEDIDA.ME_CORTOE, dbo.MEDIDA.ME_CLA_PED, 
                      dbo.MEDIDA.ME_CLA_ISO, dbo.MEDIDA.ME_CLA_SCHEDB, dbo.MEDIDA.ME_NOMBRE, dbo.MEDIDA.ME_NAME, 
                      MAX(dbo.MEDIDAMRP.ME_TEXTOMRP) as ME_TEXTOMRP
FROM         dbo.MEDIDA LEFT OUTER JOIN
                      dbo.MEDIDAMRP ON dbo.MEDIDA.ME_CODIGO = dbo.MEDIDAMRP.ME_INTRADE
GROUP BY dbo.MEDIDA.ME_CODIGO, dbo.MEDIDA.ME_CORTO, dbo.MEDIDA.ME_CORTOE, dbo.MEDIDA.ME_CLA_PED, 
                      dbo.MEDIDA.ME_CLA_ISO, dbo.MEDIDA.ME_CLA_SCHEDB, dbo.MEDIDA.ME_NOMBRE, dbo.MEDIDA.ME_NAME
ORDER BY dbo.MEDIDA.ME_CORTO












































GO
