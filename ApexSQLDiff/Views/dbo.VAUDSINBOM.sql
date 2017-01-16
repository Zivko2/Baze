SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE VIEW dbo.VAUDSINBOM
with encryption as
SELECT     dbo.MAESTRO.*, dbo.CONFIGURATIPO.CFT_TIPO AS CFT_TIPO
FROM         dbo.MAESTRO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
                      dbo.BOM_STRUCT ON dbo.MAESTRO.MA_CODIGO = dbo.BOM_STRUCT.BSU_SUBENSAMBLE
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR
                      dbo.CONFIGURATIPO.CFT_TIPO = 'S') AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE IS NULL) AND (dbo.MAESTRO.MA_INV_GEN = 'I')
























GO
