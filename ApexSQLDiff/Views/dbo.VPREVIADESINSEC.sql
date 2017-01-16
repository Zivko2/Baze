SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO










































CREATE VIEW dbo.VPREVIADESINSEC
with encryption as
SELECT     TOP 100 PERCENT dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.FI_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.FACTIMPDET.MA_CODIGO, 
                      dbo.FACTIMPDET.FID_NOPARTE, dbo.FACTIMPDET.FID_NOMBRE, dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.FID_CANT_ST, 
                      dbo.TIPO.TI_NOMBRE, dbo.CLIENTE.CL_RAZON
FROM         dbo.CLIENTE RIGHT OUTER JOIN
                      dbo.FACTIMP LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTIMP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO ON 
                      dbo.CLIENTE.CL_CODIGO = dbo.FACTIMP.PR_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTIMP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO LEFT OUTER JOIN
                      dbo.TIPO RIGHT OUTER JOIN
                      dbo.FACTIMPDET ON dbo.TIPO.TI_CODIGO = dbo.FACTIMPDET.TI_CODIGO ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE     (dbo.FACTIMPDET.FID_NOPARTE IS NOT NULL) AND (dbo.FACTIMP.FI_CANCELADO = 'N') AND (dbo.FACTIMPDET.FID_DEF_TIP = 'S') AND 
                      (dbo.FACTIMPDET.FID_SEC_IMP = 0 OR
                      dbo.FACTIMPDET.FID_SEC_IMP IS NULL) AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'ID' AND 
                      dbo.CONFIGURATFACT.CFF_TIPO <> 'TA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'IA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'RS')
ORDER BY dbo.FACTIMP.FI_FECHA, dbo.FACTIMP.FI_FOLIO



































































GO
