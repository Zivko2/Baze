SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VPREVIAEXSINESTRUCT
with encryption as
SELECT     dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.VFE_ESTATUS.CB_LOOKUP, 
                      dbo.FACTEXPDET.FED_FECHA_STRUCT, dbo.FACTEXPDET.FED_INDICED, dbo.VFED_TIP_ENS.CB_LOOKUP AS FED_TIP_ENS, 
                      dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FED_NOPARTE
FROM         dbo.VFED_TIP_ENS RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.VFED_TIP_ENS.CB_KEYFIELD = dbo.FACTEXPDET.FED_TIP_ENS LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXP LEFT OUTER JOIN
                      dbo.VFE_ESTATUS ON dbo.FACTEXP.FE_ESTATUS = dbo.VFE_ESTATUS.CB_KEYFIELD LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTEXP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.FACTEXPDET.MA_CODIGO NOT IN
                          (SELECT     BSU_SUBENSAMBLE
                            FROM          BOM_STRUCT
                            WHERE      BST_PERINI <= dbo.FACTEXPDET.FED_FECHA_STRUCT AND BST_PERFIN >= dbo.FACTEXPDET.FED_FECHA_STRUCT)) AND 
                      (dbo.FACTEXPDET.FED_RETRABAJO = 'N' OR
                      dbo.FACTEXPDET.FED_RETRABAJO = 'A') OR
                      (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N' OR
                      dbo.FACTEXPDET.FED_RETRABAJO = 'A') AND (dbo.FACTEXPDET.FED_TIP_ENS IS NULL)























































GO
