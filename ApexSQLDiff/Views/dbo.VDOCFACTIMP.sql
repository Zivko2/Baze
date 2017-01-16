SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














































CREATE VIEW dbo.VDOCFACTIMP
with encryption as
SELECT    dbo.FACTIMP.FI_CODIGO, dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.TQ_CODIGO, dbo.FACTIMP.TF_CODIGO, dbo.FACTIMP.FI_FECHA, 
                      dbo.FACTIMP.FI_FACTAGRU, dbo.TEMBARQUE.TQ_NOMBRE, dbo.TEMBARQUE.TQ_NAME, dbo.TFACTURA.TF_NOMBRE, dbo.TFACTURA.TF_NAME, 
                      InTradeGlobal.dbo.sysusrlst.sysusrlst_id
FROM         dbo.FACTIMP INNER JOIN
                      InTradeGlobal.dbo.sysusrlst ON dbo.FACTIMP.FI_FECHA >= GETDATE() - InTradeGlobal.dbo.sysusrlst.CF_ANIOSSYS * 365 LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTIMP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO LEFT OUTER JOIN
                      dbo.TEMBARQUE ON dbo.FACTIMP.TQ_CODIGO = dbo.TEMBARQUE.TQ_CODIGO
WHERE     (dbo.FACTIMP.FI_TIPO = 'F') and (dbo.FACTIMP.FI_CUENTADET>0) AND dbo.FACTIMP.FI_FOLIO IS NOT NULL AND dbo.FACTIMP.FI_FOLIO<>''






























































GO
