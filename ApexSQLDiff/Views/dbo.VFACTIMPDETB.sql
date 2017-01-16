SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VFACTIMPDETB
with encryption as
SELECT     dbo.FACTIMPDET.FI_CODIGO, dbo.FACTIMPDET.AR_IMPMX, SUM(dbo.FACTIMPDET.FID_CANT_ST * dbo.FACTIMPDET.EQ_GEN) AS FID_CANT_ST, 
                      SUM(dbo.FACTIMPDET.FID_COS_TOT) AS FID_COS_TOT, SUM(dbo.FACTIMPDET.FID_PES_BRU) AS FID_PES_BRU, 
                      SUM(dbo.FACTIMPDET.FID_COS_TOT) / SUM(dbo.FACTIMPDET.FID_CANT_ST) AS FID_COS_UNI, dbo.FACTIMPDET.FID_POR_DEF, 
                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.MA_GENERICO, dbo.FACTIMPDET.ME_GEN, dbo.FACTIMPDET.FID_SEC_IMP, 
                      SUM(dbo.FACTIMPDET.FID_PES_NET) AS FID_PES_NET, dbo.FACTIMPDET.MA_EMPAQUE, SUM(dbo.FACTIMPDET.FID_CANTEMP) AS FID_CANTEMP, 
                      dbo.VMAESTROCOST.TV_CODIGO, dbo.CLIENTE.VI_CODIGO, dbo.FACTIMPDET.EQ_GEN, dbo.FACTIMPDET.SPI_CODIGO, 
                      dbo.FACTIMPDET.FID_NOMBRE
FROM         dbo.VMAESTROCOST RIGHT OUTER JOIN
                      dbo.FACTIMPDET ON dbo.VMAESTROCOST.MA_CODIGO = dbo.FACTIMPDET.MA_CODIGO LEFT OUTER JOIN
                      dbo.CLIENTE RIGHT OUTER JOIN
                      dbo.FACTIMP ON dbo.CLIENTE.CL_CODIGO = dbo.FACTIMP.PR_CODIGO ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
GROUP BY dbo.FACTIMPDET.FI_CODIGO, dbo.FACTIMPDET.AR_IMPMX, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.FID_DEF_TIP, 
                      dbo.FACTIMPDET.MA_GENERICO, dbo.FACTIMPDET.ME_GEN, dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.MA_EMPAQUE, 
                      dbo.VMAESTROCOST.TV_CODIGO, dbo.CLIENTE.VI_CODIGO, dbo.FACTIMPDET.EQ_GEN, dbo.FACTIMPDET.SPI_CODIGO, 
                      dbo.FACTIMPDET.FID_NOMBRE





































GO
