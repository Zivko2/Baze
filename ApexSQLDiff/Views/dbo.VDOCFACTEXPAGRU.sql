SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









































CREATE VIEW dbo.VDOCFACTEXPAGRU
with encryption as
SELECT     dbo.FACTEXPAGRU.FEA_CODIGO, dbo.FACTEXPAGRU.FEA_FOLIO, dbo.FACTEXPAGRU.TQ_CODIGO, dbo.FACTEXPAGRU.TF_CODIGO, 
                      dbo.FACTEXPAGRU.FEA_FECHA, dbo.FACTEXPAGRU.FEA_TIPO, dbo.TEMBARQUE.TQ_NAME, dbo.TEMBARQUE.TQ_NOMBRE, 
                      dbo.TFACTURA.TF_NOMBRE, dbo.TFACTURA.TF_NAME, ISNULL(dbo.FACTEXPAGRU.MT_COMPANY1, 0) AS MT_COMPANY1, 
                      ISNULL(dbo.FACTEXPAGRU.PU_ENTRADA,0) AS PU_ENTRADA, ISNULL(dbo.FACTEXPAGRU.PU_CARGA,0) AS PU_CARGA, 
	         ISNULL(dbo.FACTEXPAGRU.PU_DESTINO,0) AS PU_DESTINO, ISNULL(dbo.DIR_CLIENTE.PA_CODIGO,0) AS PA_CODIGO, 
                      ISNULL(dbo.FACTEXPAGRU.CT_COMPANY1, 0) AS CT_COMPANY1, ISNULL(dbo.FACTEXPAGRU.US_CODIGO, 0) AS US_CODIGO, 
                      InTradeGlobal.dbo.sysusrlst.sysusrlst_id
FROM         dbo.FACTEXPAGRU INNER JOIN
                      InTradeGlobal.dbo.sysusrlst ON dbo.FACTEXPAGRU.FEA_FECHA >= GETDATE() - InTradeGlobal.dbo.sysusrlst.cf_aniossys * 365 LEFT OUTER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXPAGRU.DI_EXP = dbo.DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTEXPAGRU.TF_CODIGO = dbo.TFACTURA.TF_CODIGO LEFT OUTER JOIN
                      dbo.TEMBARQUE ON dbo.FACTEXPAGRU.TQ_CODIGO = dbo.TEMBARQUE.TQ_CODIGO
WHERE     (dbo.FACTEXPAGRU.FEA_TIPO = 'F') AND dbo.FACTEXPAGRU.FEA_CODIGO IN
(SELECT FE_FACTAGRU FROM FACTEXP WHERE FE_FACTAGRU<>-1 GROUP BY FE_FACTAGRU) 
AND dbo.FACTEXPAGRU.FEA_FOLIO<>''
and dbo.FACTEXPAGRU.tf_codigo not in (select tf_codigo from configuratfact where cff_tipo in('MN','EV', 'MA', 'PA', 'SE', 'SS', 'TS' ))























































GO
