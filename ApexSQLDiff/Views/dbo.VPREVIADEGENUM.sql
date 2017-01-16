SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE VIEW dbo.VPREVIADEGENUM
with encryption as
SELECT     TOP 100 PERCENT dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.FI_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.FACTIMPDET.MA_CODIGO, 
                      dbo.FACTIMPDET.FID_NOPARTE, dbo.FACTIMPDET.FID_NOMBRE, dbo.FACTIMPDET.FID_CANT_ST, dbo.TIPO.TI_NOMBRE, dbo.CLIENTE.CL_RAZON, 
                      dbo.MAESTRO.MA_NOPARTE AS MA_NOPARTEGEN
FROM         dbo.TFACTURA RIGHT OUTER JOIN
                      dbo.FACTIMP LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTIMP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO ON 
                      dbo.TFACTURA.TF_CODIGO = dbo.FACTIMP.TF_CODIGO LEFT OUTER JOIN
                      dbo.CLIENTE ON dbo.FACTIMP.PR_CODIGO = dbo.CLIENTE.CL_CODIGO LEFT OUTER JOIN
                      dbo.TIPO RIGHT OUTER JOIN
                      dbo.MAESTRO RIGHT OUTER JOIN
                      dbo.FACTIMPDET ON dbo.MAESTRO.MA_CODIGO = dbo.FACTIMPDET.MA_GENERICO ON dbo.TIPO.TI_CODIGO = dbo.FACTIMPDET.TI_CODIGO ON 
                      dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE     (dbo.FACTIMPDET.FID_NOPARTE IS NOT NULL) AND (dbo.FACTIMP.FI_CANCELADO = 'N') AND (dbo.FACTIMPDET.ME_GEN = 0 OR
                      dbo.FACTIMPDET.ME_GEN IS NULL) AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'ID' AND 
                      dbo.CONFIGURATFACT.CFF_TIPO <> 'TA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'IA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'RS')
ORDER BY dbo.FACTIMP.FI_FECHA, dbo.FACTIMP.FI_FOLIO


































GO
