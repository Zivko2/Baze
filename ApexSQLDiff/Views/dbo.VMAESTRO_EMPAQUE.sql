SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VMAESTRO_EMPAQUE
with encryption as
SELECT     dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_PESO_KG, 
                      dbo.MAESTRO.MA_CANTEMP, dbo.MAESTRO.MA_NOPARTEAUX, dbo.MAESTRO.TEM_CODIGO
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE     (dbo.MAESTRO.MA_EST_MAT = 'A') AND (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.CONFIGURATIPO.CFT_TIPO = 'E') AND 
                      (dbo.MAESTRO.MA_EMPFACT = 'S') AND (dbo.MAESTRO.MA_OCULTO = 'N')





































GO
