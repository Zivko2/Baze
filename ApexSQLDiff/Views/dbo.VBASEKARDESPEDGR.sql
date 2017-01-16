SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE VIEW dbo.VBASEKARDESPEDGR
with encryption as
SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.MA_GENERICO, SUM(dbo.FACTEXPDET.FED_CANT) AS FED_CANT, 
                      dbo.MAESTRO.MA_NOPARTE AS FED_NOPARTE, dbo.MAESTRO.MA_NOMBRE AS FED_NOMBRE, dbo.MAESTRO.MA_NAME AS FED_NAME, 
                      SUM(dbo.FACTEXPDET.FED_GRA_MP + dbo.FACTEXPDET.FED_GRA_EMP + dbo.FACTEXPDET.FED_GRA_ADD + dbo.FACTEXPDET.FED_GRA_MO + dbo.FACTEXPDET.FED_GRA_GI_MX)
                       AS FED_COS_GRAVUNI
FROM         dbo.FACTEXPDET LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.MA_GENERICO, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
                      dbo.MAESTRO.MA_NOPARTE




































GO
