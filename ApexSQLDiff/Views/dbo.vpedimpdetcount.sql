SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















































CREATE VIEW dbo.vpedimpdetcount
with encryption as
SELECT     COUNT(*) AS [count], dbo.FACTIMP.PI_CODIGO
FROM         dbo.FACTIMP LEFT OUTER JOIN
                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
GROUP BY dbo.FACTIMPDET.MA_CODIGO, dbo.FACTIMPDET.FID_NOPARTE, dbo.FACTIMPDET.FID_COS_UNI, dbo.FACTIMPDET.FID_PES_UNI, 
                      dbo.FACTIMPDET.ME_CODIGO, dbo.FACTIMPDET.MA_GENERICO, dbo.FACTIMPDET.EQ_GEN, dbo.FACTIMPDET.EQ_IMPMX, 
                      dbo.FACTIMPDET.AR_IMPMX, dbo.FACTIMPDET.AR_EXPFO, dbo.FACTIMPDET.FID_RATEEXPFO, dbo.FACTIMPDET.FID_SEC_IMP, 
                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.TI_CODIGO, dbo.FACTIMPDET.PA_CODIGO, 
                      dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, dbo.FACTIMPDET.ME_GEN, dbo.FACTIMPDET.ME_ARIMPMX, 
                      dbo.FACTIMPDET.PR_CODIGO, ISNULL(dbo.FACTIMPDET.CS_CODIGO, 8), dbo.FACTIMPDET.FID_PADREKITINSERT, 
                      dbo.FACTIMPDET.FID_FECHA_STRUCT, dbo.FACTIMP.PI_CODIGO


































































GO
