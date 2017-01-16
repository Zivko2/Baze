SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VMAESTROCOSTPT
with encryption as
SELECT     dbo.MAESTROCOST.TCO_CODIGO, dbo.MAESTROCOST.MA_CODIGO, dbo.MAESTROCOST.MA_GRAV_MP, dbo.MAESTROCOST.MA_GRAV_ADD, 
                      dbo.MAESTROCOST.MA_GRAV_EMP, dbo.MAESTROCOST.MA_GRAV_GI, dbo.MAESTROCOST.MA_GRAV_GI_MX, dbo.MAESTROCOST.MA_GRAV_MO, 
                      dbo.MAESTROCOST.MA_NG_MP, dbo.MAESTROCOST.MA_NG_ADD, dbo.MAESTROCOST.MA_NG_EMP, dbo.MAESTROCOST.MA_COSTO, 
                      dbo.MAESTROCOST.MA_GRAVA_VA, dbo.MAESTROCOST.MA_NG_USA, dbo.MAESTROCOST.MA_NG_MX, dbo.MAESTROCOST.TV_CODIGO
FROM         dbo.CONFIGURATIPO RIGHT OUTER JOIN
                      dbo.MAESTRO ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.MAESTRO.TI_CODIGO RIGHT OUTER JOIN
                      dbo.MAESTROCOST INNER JOIN
                      dbo.CONFIGURACION ON dbo.MAESTROCOST.TCO_CODIGO = dbo.CONFIGURACION.TCO_MANUFACTURA ON 
                      dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'P') OR
                      (dbo.CONFIGURATIPO.CFT_TIPO = 'S') AND dbo.MAESTRO.MA_TIP_ENS<>'C'
AND dbo.MAESTROCOST.MA_PERINI <= GETDATE() AND dbo.MAESTROCOST.MA_PERFIN >= GETDATE()












































GO
