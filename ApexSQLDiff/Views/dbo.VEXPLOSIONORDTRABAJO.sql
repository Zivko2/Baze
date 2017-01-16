SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VEXPLOSIONORDTRABAJO
with encryption as
SELECT     dbo.ORDTRABAJODET.OT_CODIGO, dbo.TempImpOrdTrabajo.BST_PT, dbo.TempImpOrdTrabajo.BST_HIJO, dbo.TempImpOrdTrabajo.ME_CODIGO, 
                      dbo.TempImpOrdTrabajo.FACTCONV, dbo.TempImpOrdTrabajo.ME_GEN, 
                      SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.ORDTRABAJODET.OTD_SIZELOTE) AS CANTIDAD, 
                      dbo.TempImpOrdTrabajo.TI_CODIGO AS CFT_TIPO, dbo.MAESTRO.TI_CODIGO
FROM         dbo.MAESTRO RIGHT OUTER JOIN
                      dbo.TempImpOrdTrabajo ON dbo.MAESTRO.MA_CODIGO = dbo.TempImpOrdTrabajo.BST_HIJO RIGHT OUTER JOIN
                      dbo.ORDTRABAJODET ON dbo.TempImpOrdTrabajo.OTD_INDICED = dbo.ORDTRABAJODET.OTD_INDICED
WHERE     (dbo.TempImpOrdTrabajo.BST_DISCH = 'S') AND
((dbo.TempImpOrdTrabajo.TI_CODIGO <> 'S' AND dbo.TempImpOrdTrabajo.TI_CODIGO <> 'P' AND dbo.TempImpOrdTrabajo.MA_TIP_ENS<>'C') OR
(dbo.TempImpOrdTrabajo.TI_CODIGO = 'S' AND dbo.TempImpOrdTrabajo.MA_TIP_ENS='C'))
GROUP BY dbo.ORDTRABAJODET.OT_CODIGO, dbo.TempImpOrdTrabajo.BST_HIJO, dbo.TempImpOrdTrabajo.ME_CODIGO, dbo.TempImpOrdTrabajo.FACTCONV, 
                      dbo.TempImpOrdTrabajo.ME_GEN, dbo.TempImpOrdTrabajo.BST_PT, dbo.MAESTRO.TI_CODIGO, dbo.TempImpOrdTrabajo.TI_CODIGO


GO
