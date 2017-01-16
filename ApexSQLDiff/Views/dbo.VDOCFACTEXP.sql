SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









































CREATE VIEW dbo.VDOCFACTEXP
with encryption as
SELECT     dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.TQ_CODIGO, dbo.FACTEXP.TF_CODIGO, dbo.FACTEXP.FE_FECHA, 
                      dbo.FACTEXP.FE_FACTAGRU, dbo.TEMBARQUE.TQ_NOMBRE, dbo.TEMBARQUE.TQ_NAME, dbo.TFACTURA.TF_NOMBRE, dbo.TFACTURA.TF_NAME, 
                      dbo.FACTEXP.CL_COMP, ISNULL(dbo.FACTEXP.MT_COMPANY1, 0) AS MT_COMPANY1, ISNULL(dbo.FACTEXP.CT_COMPANY1, 0) AS CT_COMPANY1, 
                      ISNULL(dbo.FACTEXP.PU_CARGA,0) AS PU_CARGA, ISNULL(dbo.FACTEXP.PU_DESTINO,0) AS PU_DESTINO, 
	        ISNULL(dbo.DIR_CLIENTE.PA_CODIGO,0) AS PA_CODIGO, ISNULL(dbo.FACTEXP.PU_ENTRADA,0) AS PU_ENTRADA, ISNULL(dbo.FACTEXP.US_CODIGO,0) AS US_CODIGO, 
                      InTradeGlobal.dbo.sysusrlst.sysusrlst_id
FROM         dbo.FACTEXP INNER JOIN
                      InTradeGlobal.dbo.sysusrlst ON dbo.FACTEXP.FE_FECHA >= GETDATE() - InTradeGlobal.dbo.sysusrlst.cf_aniossys * 365 LEFT OUTER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_EXP = dbo.DIR_CLIENTE.DI_INDICE LEFT OUTER JOIN
                      dbo.TEMBARQUE ON dbo.FACTEXP.TQ_CODIGO = dbo.TEMBARQUE.TQ_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTEXP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO
WHERE     (dbo.FACTEXP.FE_CUENTADET >0) AND dbo.FACTEXP.FE_FOLIO IS NOT NULL AND dbo.FACTEXP.FE_FOLIO <>''
and dbo.FACTEXP.tf_codigo not in (select tf_codigo from configuratfact where cff_tipo in('MN','EV', 'MA', 'PA', 'SE', 'SS', 'TS' ))



























































GO
