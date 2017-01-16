SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VEXP_X_FACT
with encryption as
SELECT     dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.TF_CODIGO, dbo.FACTEXP.TQ_CODIGO, 
                      dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FED_NOPARTE, dbo.FACTEXPDET.FED_NOMBRE, dbo.FACTEXPDET.FED_NAME, 
                      dbo.FACTEXPDET.FED_CANT, dbo.FACTEXPDET.FED_COS_UNI, dbo.FACTEXPCONT.FEC_MARCA, dbo.FACTEXPCONT.FEC_MODELO, 
                      dbo.FACTEXPCONT.FEC_SERIE, dbo.FACTEXPDET.TI_CODIGO, dbo.FACTEXPDET.EQ_GEN, dbo.FACTEXPDET.MA_GENERICO, 
                      dbo.FACTEXPDET.ME_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXP.FE_TIPOCAMBIO, dbo.FACTEXP.FE_ESTATUS, 
                      dbo.FACTEXP.FE_TOTALB, dbo.FACTEXPDET.FED_GRA_MP + dbo.FACTEXPDET.FED_GRA_ADD AS TEX_MAT_GRAV, 
                      dbo.FACTEXPDET.FED_NG_MP + dbo.FACTEXPDET.FED_NG_ADD AS TEX_MAT_NG, 
                      dbo.FACTEXPDET.FED_NG_EMP, dbo.FACTEXPDET.FED_GRA_EMP, dbo.DIR_CLIENTE.PA_CODIGO AS PA_DESTINO, 
                      dbo.FACTEXPDET.PA_CODIGO AS PA_ORIGEN, dbo.FACTEXP.CL_DESTFIN, dbo.FACTEXPDET.FED_PES_BRU, dbo.FACTEXPDET.FED_ORD_COMP, 
                      dbo.FACTEXPDET.FED_NOORDEN, dbo.FACTEXP.FE_FEC_ENV, dbo.FACTEXP.DI_DESTFIN, dbo.FACTEXP.CL_PROD, 
                      dbo.FACTEXP.FE_TIPO AS EXA_TI_FACT_TRANSFER
FROM         dbo.FACTEXPDET RIGHT OUTER JOIN
                      dbo.FACTEXP LEFT OUTER JOIN
                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE ON 
                      dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
                      dbo.FACTEXPCONT ON dbo.FACTEXPDET.FED_INDICED = dbo.FACTEXPCONT.FED_INDICED
WHERE     (dbo.FACTEXP.FE_TIPO = 'F')







































































GO
