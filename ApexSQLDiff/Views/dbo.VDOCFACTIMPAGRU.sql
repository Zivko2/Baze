SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














































CREATE VIEW dbo.VDOCFACTIMPAGRU
with encryption as
SELECT     dbo.FACTIMPAGRU.FIA_CODIGO, dbo.FACTIMPAGRU.FIA_FOLIO, dbo.FACTIMPAGRU.TQ_CODIGO, dbo.FACTIMPAGRU.TF_CODIGO, 
                      dbo.FACTIMPAGRU.FIA_FECHA, dbo.FACTIMPAGRU.FIA_TIPO, dbo.TEMBARQUE.TQ_NAME, dbo.TEMBARQUE.TQ_NOMBRE, 
                      dbo.TFACTURA.TF_NOMBRE, dbo.TFACTURA.TF_NAME, InTradeGlobal.dbo.sysusrlst.sysusrlst_id
FROM         dbo.FACTIMPAGRU INNER JOIN
                      InTradeGlobal.dbo.sysusrlst ON dbo.FACTIMPAGRU.FIA_FECHA >= GETDATE() - InTradeGlobal.dbo.sysusrlst.CF_ANIOSSYS * 365 LEFT OUTER JOIN
                      dbo.TEMBARQUE ON dbo.FACTIMPAGRU.TQ_CODIGO = dbo.TEMBARQUE.TQ_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTIMPAGRU.TF_CODIGO = dbo.TFACTURA.TF_CODIGO
WHERE     (dbo.FACTIMPAGRU.FIA_TIPO = 'F') AND dbo.FACTIMPAGRU.FIA_CODIGO IN
(SELECT FI_FACTAGRU FROM FACTIMP WHERE FI_FACTAGRU<>-1 GROUP BY FI_FACTAGRU) AND dbo.FACTIMPAGRU.FIA_FOLIO IS NOT NULL
AND dbo.FACTIMPAGRU.FIA_FOLIO<>''






































































GO
