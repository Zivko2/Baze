SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW dbo.V9801FECMIN
with encryption as
SELECT     MIN(dbo.FACTEXPENT.FEN_FEC_ENT) AS PI_FEC_ENT, dbo.FACTEXPDET.FE_CODIGO
FROM         dbo.FACTEXPENT INNER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXPENT.FED_INDICED = dbo.FACTEXPDET.FED_INDICED
GROUP BY dbo.FACTEXPDET.FE_CODIGO

GO
