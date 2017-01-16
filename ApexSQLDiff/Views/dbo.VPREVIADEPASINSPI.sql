SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VPREVIADEPASINSPI
with encryption as
SELECT     TOP 100 PERCENT dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.FI_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.FACTIMPDET.MA_CODIGO, 
                      dbo.FACTIMPDET.FID_NOPARTE, dbo.FACTIMPDET.FID_NOMBRE, dbo.FACTIMPDET.SPI_CODIGO, dbo.FACTIMPDET.FID_CANT_ST, 
                      dbo.TIPO.TI_NOMBRE, dbo.CLIENTE.CL_RAZON, dbo.PAIS.PA_CORTO, dbo.SPI.SPI_CLAVE
FROM         dbo.TFACTURA RIGHT OUTER JOIN
                      dbo.CLIENTE RIGHT OUTER JOIN
                      dbo.FACTIMP LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTIMP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO ON 
                      dbo.CLIENTE.CL_CODIGO = dbo.FACTIMP.PR_CODIGO ON dbo.TFACTURA.TF_CODIGO = dbo.FACTIMP.TF_CODIGO LEFT OUTER JOIN
                      dbo.PAIS RIGHT OUTER JOIN
                      dbo.SPI RIGHT OUTER JOIN
                      dbo.FACTIMPDET ON dbo.SPI.SPI_CODIGO = dbo.FACTIMPDET.SPI_CODIGO ON 
                      dbo.PAIS.PA_CODIGO = dbo.FACTIMPDET.PA_CODIGO LEFT OUTER JOIN
                      dbo.TIPO ON dbo.FACTIMPDET.TI_CODIGO = dbo.TIPO.TI_CODIGO ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
WHERE     (dbo.FACTIMPDET.FID_NOPARTE IS NOT NULL) AND (dbo.FACTIMP.FI_CANCELADO = 'N') AND (dbo.FACTIMPDET.SPI_CODIGO <> 0) AND 
                      (dbo.FACTIMPDET.SPI_CODIGO IS NOT NULL) AND (dbo.FACTIMPDET.FID_DEF_TIP = 'P') AND (dbo.PAIS.SPI_CODIGO = 0 OR
                      dbo.PAIS.SPI_CODIGO IS NULL) AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'ID' AND 
                      dbo.CONFIGURATFACT.CFF_TIPO <> 'TA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'IA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'RS')
ORDER BY dbo.FACTIMP.FI_FECHA, dbo.FACTIMP.FI_FOLIO

































































GO
