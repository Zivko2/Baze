SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VTODOSPT
with encryption as
SELECT     TOP 100 PERCENT dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX, dbo.MAESTRO.TI_CODIGO, dbo.TIPO.TI_NOMBRE, 
                      dbo.MAESTRO.MA_CODIGO
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.TIPO ON dbo.MAESTRO.TI_CODIGO = dbo.TIPO.TI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'S') OR
                      (dbo.CONFIGURATIPO.CFT_TIPO = 'P')
ORDER BY dbo.MAESTRO.MA_NOPARTE





































































GO
