SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























































CREATE VIEW dbo.VCONSULTA_PEDIMP
with encryption as
SELECT     dbo.PEDIMPDET.MA_CODIGO, dbo.VPEDIMP.PI_FOLIO, dbo.VPEDIMP.PI_FEC_PAG, SUM(ISNULL(dbo.PEDIMPDET.PID_CANT, 0)) AS cantidad, 
                      dbo.MEDIDA.ME_CORTO, dbo.PAIS.PA_CORTO, dbo.ARANCEL.AR_FRACCION, dbo.PEDIMPDET.PID_DEF_TIP, dbo.PEDIMPDET.PID_POR_DEF, 
                      dbo.MAESTRO.MA_NOPARTE, dbo.SPI.SPI_CLAVE, dbo.SECTOR.SE_CLAVE, dbo.PEDIMPDET.EQ_GENERICO, dbo.CLAVEPED.CP_CLAVE
FROM         dbo.ARANCEL RIGHT OUTER JOIN
                      dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.PAIS ON dbo.PEDIMPDET.PA_ORIGEN = dbo.PAIS.PA_CODIGO LEFT OUTER JOIN
                      dbo.SECTOR ON dbo.PEDIMPDET.PID_SEC_IMP = dbo.SECTOR.SE_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO ON 
                      dbo.ARANCEL.AR_CODIGO = dbo.PEDIMPDET.AR_IMPMX LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.PEDIMPDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO RIGHT OUTER JOIN
                      dbo.VPEDIMP LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.VPEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO ON 
                      dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.SPI ON dbo.PEDIMPDET.SPI_CODIGO = dbo.SPI.SPI_CODIGO
GROUP BY dbo.VPEDIMP.PI_FOLIO, dbo.VPEDIMP.PI_FEC_PAG, dbo.PAIS.PA_CORTO, dbo.MEDIDA.ME_CORTO, dbo.ARANCEL.AR_FRACCION, 
                      dbo.PEDIMPDET.PID_POR_DEF, dbo.PEDIMPDET.PID_DEF_TIP, dbo.PEDIMPDET.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.SPI.SPI_CLAVE, 
                      dbo.SECTOR.SE_CLAVE, dbo.PEDIMPDET.EQ_GENERICO, dbo.CLAVEPED.CP_CLAVE




































































GO
