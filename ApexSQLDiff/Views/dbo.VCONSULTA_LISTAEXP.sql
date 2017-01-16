SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


































































CREATE VIEW dbo.VCONSULTA_LISTAEXP
with encryption as
SELECT     dbo.LISTAEXPDET.MA_CODIGO, dbo.LISTAEXP.LE_FOLIO, dbo.LISTAEXP.LE_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.TEMBARQUE.TQ_NOMBRE, 
                      SUM(ISNULL(dbo.LISTAEXPDET.LED_CANT, 0)) AS cantidad, dbo.MEDIDA.ME_CORTO, dbo.PAIS.PA_CORTO, dbo.ARANCEL.AR_FRACCION, 
                      dbo.LISTAEXPDET.LED_DEF_TIP, dbo.LISTAEXPDET.LED_POR_DEF, dbo.MAESTRO.MA_NOPARTE, dbo.SECTOR.SE_CLAVE, 
                      dbo.LISTAEXPDET.EQ_GEN
FROM         dbo.PAIS RIGHT OUTER JOIN
                      dbo.LISTAEXPDET LEFT OUTER JOIN
                      dbo.SECTOR ON dbo.LISTAEXPDET.LED_SEC_IMP = dbo.SECTOR.SE_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.LISTAEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.LISTAEXPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO ON 
                      dbo.PAIS.PA_CODIGO = dbo.LISTAEXPDET.PA_CODIGO LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.LISTAEXPDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO RIGHT OUTER JOIN
                      dbo.TEMBARQUE RIGHT OUTER JOIN
                      dbo.LISTAEXP ON dbo.TEMBARQUE.TQ_CODIGO = dbo.LISTAEXP.TQ_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.LISTAEXP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO ON dbo.LISTAEXPDET.LE_CODIGO = dbo.LISTAEXP.LE_CODIGO
GROUP BY dbo.LISTAEXP.LE_FOLIO, dbo.LISTAEXP.LE_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.TEMBARQUE.TQ_NOMBRE, dbo.PAIS.PA_CORTO, 
                      dbo.MEDIDA.ME_CORTO, dbo.ARANCEL.AR_FRACCION, dbo.LISTAEXPDET.LED_POR_DEF, dbo.LISTAEXPDET.LED_DEF_TIP, 
                      dbo.LISTAEXPDET.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.SECTOR.SE_CLAVE, dbo.LISTAEXPDET.EQ_GEN


































































GO
