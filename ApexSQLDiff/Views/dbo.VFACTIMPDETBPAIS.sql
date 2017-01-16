SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VFACTIMPDETBPAIS
with encryption as
SELECT     dbo.FACTIMPDET.PA_CODIGO, dbo.FACTIMPDET.FI_CODIGO, dbo.FACTIMPDET.AR_IMPMX, COUNT(*) AS COUNTPAIS, 
                      dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.SPI_CODIGO, 
                      dbo.PAIS.PA_SAAIM3, dbo.FACTIMPDET.FID_NOMBRE, round(SUM(dbo.FACTIMPDET.FID_CANT_ST* dbo.FACTIMPDET.EQ_GEN),6) AS FID_CAN_GEN
FROM         dbo.FACTIMPDET LEFT OUTER JOIN
                      dbo.PAIS ON dbo.FACTIMPDET.PA_CODIGO = dbo.PAIS.PA_CODIGO
GROUP BY dbo.FACTIMPDET.PA_CODIGO, dbo.FACTIMPDET.FI_CODIGO, dbo.FACTIMPDET.AR_IMPMX, dbo.FACTIMPDET.FID_POR_DEF, 
                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_SEC_IMP, dbo.FACTIMPDET.SPI_CODIGO, dbo.PAIS.PA_SAAIM3, dbo.FACTIMPDET.FID_NOMBRE






































































GO
