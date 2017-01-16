SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


































































CREATE VIEW dbo.VCONSULTA_LISTAIMP
with encryption as
SELECT     dbo.PCKLISTDET.MA_CODIGO, dbo.PCKLIST.PL_FOLIO, dbo.PCKLIST.PL_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.TEMBARQUE.TQ_NOMBRE, 
                      SUM(ISNULL(dbo.PCKLISTDET.PLD_CANT_ST, 0)) AS cantidad, dbo.MEDIDA.ME_CORTO, dbo.PAIS.PA_CORTO, dbo.ARANCEL.AR_FRACCION, 
                      dbo.PCKLISTDET.PLD_DEF_TIP, dbo.PCKLISTDET.PLD_POR_DEF, dbo.MAESTRO.MA_NOPARTE, dbo.SPI.SPI_CLAVE, dbo.SECTOR.SE_CLAVE, 
                      dbo.PCKLISTDET.EQ_GEN
FROM         dbo.PAIS RIGHT OUTER JOIN
                      dbo.PCKLISTDET LEFT OUTER JOIN
                      dbo.SECTOR ON dbo.PCKLISTDET.PLD_SEC_IMP = dbo.SECTOR.SE_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.PCKLISTDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.PCKLISTDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO ON 
                      dbo.PAIS.PA_CODIGO = dbo.PCKLISTDET.PA_CODIGO LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.PCKLISTDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO RIGHT OUTER JOIN
                      dbo.TEMBARQUE RIGHT OUTER JOIN
                      dbo.PCKLIST ON dbo.TEMBARQUE.TQ_CODIGO = dbo.PCKLIST.TQ_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.PCKLIST.TF_CODIGO = dbo.TFACTURA.TF_CODIGO ON 
                      dbo.PCKLISTDET.PL_CODIGO = dbo.PCKLIST.PL_CODIGO LEFT OUTER JOIN
                      dbo.SPI ON dbo.PCKLISTDET.SPI_CODIGO = dbo.SPI.SPI_CODIGO
GROUP BY dbo.PCKLIST.PL_FOLIO, dbo.PCKLIST.PL_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.TEMBARQUE.TQ_NOMBRE, dbo.PAIS.PA_CORTO, 
                      dbo.MEDIDA.ME_CORTO, dbo.ARANCEL.AR_FRACCION, dbo.PCKLISTDET.PLD_POR_DEF, dbo.PCKLISTDET.PLD_DEF_TIP, 
                      dbo.PCKLISTDET.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.SPI.SPI_CLAVE, dbo.SECTOR.SE_CLAVE, dbo.PCKLISTDET.EQ_GEN







































































GO
