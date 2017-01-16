SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


































































CREATE VIEW dbo.VCONSULTA_FACTIMP
with encryption as
SELECT     dbo.FACTIMPDET.MA_CODIGO, dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.FI_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.TEMBARQUE.TQ_NOMBRE, 
                      SUM(ISNULL(dbo.FACTIMPDET.FID_CANT_ST, 0)) AS cantidad, dbo.MEDIDA.ME_CORTO, dbo.PAIS.PA_CORTO, dbo.ARANCEL.AR_FRACCION, 
                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_POR_DEF, dbo.MAESTRO.MA_NOPARTE, dbo.SPI.SPI_CLAVE, dbo.SECTOR.SE_CLAVE, 
                      dbo.FACTIMPDET.EQ_GEN
FROM         dbo.PAIS RIGHT OUTER JOIN
                      dbo.FACTIMPDET LEFT OUTER JOIN
                      dbo.SECTOR ON dbo.FACTIMPDET.FID_SEC_IMP = dbo.SECTOR.SE_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO ON 
                      dbo.PAIS.PA_CODIGO = dbo.FACTIMPDET.PA_CODIGO LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.FACTIMPDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO RIGHT OUTER JOIN
                      dbo.TEMBARQUE RIGHT OUTER JOIN
                      dbo.FACTIMP ON dbo.TEMBARQUE.TQ_CODIGO = dbo.FACTIMP.TQ_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTIMP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO ON 
                      dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
                      dbo.SPI ON dbo.FACTIMPDET.SPI_CODIGO = dbo.SPI.SPI_CODIGO
GROUP BY dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.FI_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.TEMBARQUE.TQ_NOMBRE, dbo.PAIS.PA_CORTO, 
                      dbo.MEDIDA.ME_CORTO, dbo.ARANCEL.AR_FRACCION, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.FID_DEF_TIP, 
                      dbo.FACTIMPDET.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.SPI.SPI_CLAVE, dbo.SECTOR.SE_CLAVE, dbo.FACTIMPDET.EQ_GEN



































































GO
