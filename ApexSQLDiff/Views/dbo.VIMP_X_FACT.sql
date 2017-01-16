SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


































































CREATE VIEW dbo.VIMP_X_FACT
with encryption as
SELECT     dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.TQ_CODIGO, dbo.FACTIMP.FI_TIPOCAMBIO, dbo.FACTIMP.FI_ESTATUS, dbo.FACTIMP.TF_CODIGO, 
                      dbo.FACTIMP.FI_FECHA, dbo.VPEDIMP.PI_CODIGO, dbo.FACTIMP.FI_CODIGO, dbo.FACTIMP.FC_CODIGO, dbo.FACTIMP.FI_NO_SEM, 
                      dbo.FACTIMP.AG_MEX, dbo.FACTIMP.AG_USA, dbo.FACTIMP.PR_CODIGO, dbo.FACTIMP.DI_PROVEE, dbo.FACTIMP.CL_PROD, dbo.FACTIMP.DI_PROD, 
                      dbo.FACTIMP.CL_DESTINT, dbo.FACTIMP.DI_DESTINT, dbo.FACTIMP.CL_DESTFIN, dbo.FACTIMP.DI_DESTFIN, dbo.FACTIMP.CL_COMP, 
                      dbo.FACTIMP.DI_COMP, dbo.FACTIMP.CL_VEND, dbo.FACTIMP.DI_VEND, dbo.FACTIMP.CL_EXP, dbo.FACTIMP.DI_EXP, dbo.FACTIMP.CL_IMP, 
                      dbo.FACTIMP.DI_IMP, dbo.FACTIMP.FI_TOTALB, dbo.FACTIMP.FI_TIPO AS PIA_TI_FACT_CONST
FROM         dbo.VPEDIMP RIGHT OUTER JOIN
                      dbo.FACTIMP ON dbo.VPEDIMP.PI_CODIGO = dbo.FACTIMP.PI_CODIGO
WHERE     (dbo.FACTIMP.FI_TIPO = 'F')





































































GO
