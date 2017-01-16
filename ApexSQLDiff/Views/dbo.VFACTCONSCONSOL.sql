SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VFACTCONSCONSOL
with encryption as
SELECT     dbo.FACTCONS.FC_CODIGO, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.FACTCONS.FC_FOLIO collate database_default AS agencia_folio, dbo.FACTCONS.FC_TIPO, 
                      dbo.FACTCONS.CP_CODIGO, dbo.FACTCONS.FC_SEM, dbo.FACTCONS.FC_INI, dbo.FACTCONS.FC_FIN, dbo.FACTCONS.FC_ACUSEDERECIBO, 
                      dbo.AGENCIAPATENTE.AG_CODIGO, dbo.FACTCONS.FC_FECHA, dbo.FACTCONS.FC_CONSOLIDA, dbo.FACTCONS.FC_DTA1_CANT, 
                      dbo.FACTCONS.FC_ADV_CANT, dbo.FACTCONS.FC_TIP_CAM, dbo.FACTCONS.FC_TOTAL, dbo.FACTCONS.AD_DES, dbo.FACTCONS.REG_CODIGO, 
                      dbo.FACTCONS.US_CODIGO, dbo.FACTCONS.CL_CODIGO
FROM         dbo.FACTCONS LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.FACTCONS.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO
WHERE     (dbo.FACTCONS.FC_TIPO = 'S') OR
                      (dbo.FACTCONS.FC_TIPO = 'A')  AND (dbo.FACTCONS.FC_CONSOLIDA = 'S')





































































GO
