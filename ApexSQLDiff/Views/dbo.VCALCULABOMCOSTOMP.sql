SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























/*  la incorporacion se multiplica por el factconv para saber cuanto
se incorpora en um del grupo generico, esto por si se llega a dar el caso de que la um del no. de parte en el cat. maestro y en bom no es la misma, por lo tanto
no se tiene el costo unitario en la um que esta en el bom*/
CREATE VIEW dbo.VCALCULABOMCOSTOMP
with encryption as
SELECT     dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.MAESTRO.BST_TIPOCOSTO, 
                      round(SUM(dbo.VMAESTROCOST.MA_COSTO/isnull(dbo.MAESTRO.EQ_GEN,1)*isnull(dbo.BOM_STRUCT.FACTCONV,1) * dbo.BOM_STRUCT.BST_INCORPOR ),6) AS MA_COSTO, 
                      dbo.CONFIGURATIPO.CFT_TIPO
FROM         dbo.VMAESTROCOST RIGHT OUTER JOIN
                      dbo.BOM_STRUCT ON dbo.VMAESTROCOST.MA_CODIGO = dbo.BOM_STRUCT.BST_HIJO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE     ((dbo.CONFIGURATIPO.CFT_TIPO <> 'S' AND dbo.CONFIGURATIPO.CFT_TIPO <> 'P') OR dbo.BOM_STRUCT.BST_TIP_ENS='C')
and (getdate() between dbo.BOM_STRUCT.BST_PERINI and dbo.BOM_STRUCT.BST_PERFIN)
GROUP BY dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.MAESTRO.BST_TIPOCOSTO, dbo.CONFIGURATIPO.CFT_TIPO










GO
