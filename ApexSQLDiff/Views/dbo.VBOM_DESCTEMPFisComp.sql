SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW dbo.VBOM_DESCTEMPFisComp
with encryption as
SELECT     FE_CODIGO, FED_INDICED, BST_HIJO, SUM(CANTDESC) AS CANTDESC, BST_TIPODESC, MAX(MA_TIP_ENS) AS MA_TIP_ENS,
                      'S' AS BST_DISCH, BST_PT
FROM         dbo.VBOM_DESCTEMP1
GROUP BY FE_CODIGO, FED_INDICED, BST_HIJO, BST_TIPODESC, MA_TIP_ENS, BST_PT



































































GO
