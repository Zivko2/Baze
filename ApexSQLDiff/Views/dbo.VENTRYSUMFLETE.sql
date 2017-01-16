SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VENTRYSUMFLETE
with encryption as
SELECT     ET_CODIGO, ISNULL
                          ((SELECT     SUM(FACTEXPINCREMENTA1.FEI_VALOR*FE_TIPOCAMBIOUSD)
FROM         dbo.FACTEXPINCREMENTA FACTEXPINCREMENTA1 INNER JOIN
                      dbo.INCREMENTABLE ON FACTEXPINCREMENTA1.IC_CODIGO = dbo.INCREMENTABLE.IC_CODIGO INNER JOIN
                      dbo.FACTEXP ON FACTEXPINCREMENTA1.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
WHERE     (dbo.INCREMENTABLE.IC_PEDIMENTO = 'F') AND (dbo.FACTEXP.ET_CODIGO = dbo.ENTRYSUM.ET_CODIGO)), 0) AS flete
FROM         dbo.ENTRYSUM
































GO
