SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW dbo.VBOM_STRUCTACTUAL
with encryption as
SELECT     BST_CODIGO, BSU_SUBENSAMBLE, BST_HIJO, BST_INCORPOR, BST_DISCH, dbo.MAESTRO.TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, 
                      ME_GEN, BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, BSU_NOPARTE, BST_NOPARTE, dbo.MAESTRO.PA_ORIGEN PA_CODIGO, BSU_NOPARTEAUX, 
                      BST_NOPARTEAUX
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO
WHERE     (GETDATE() between BST_PERINI AND BST_PERFIN)





































































GO
