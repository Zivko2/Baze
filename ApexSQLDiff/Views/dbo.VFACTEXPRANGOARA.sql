SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VFACTEXPRANGOARA
with encryption as
SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.AR_IMPFO, dbo.FACTEXP.FE_FACTAGRU
FROM         dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.AR_IMPFO, dbo.FACTEXP.FE_FACTAGRU






































GO
