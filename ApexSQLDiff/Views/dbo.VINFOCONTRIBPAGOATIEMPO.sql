SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























































CREATE VIEW dbo.VINFOCONTRIBPAGOATIEMPO
with encryption as
SELECT     COUNT(dbo.FACTEXP.FE_CODIGO) AS [Cantidad Vencidas],
                      'Tipo Documento' = CASE FACTEXP.FE_TIPO WHEN 'F' THEN 'FACTURA EXPORTACION' WHEN 'V' THEN 'FACTURA VIRTUAL' END
FROM         dbo.FACTEXPDET RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO <> 'Q') AND (dbo.FACTEXP.FE_FECHA <= dbo.FACTEXP.FE_FECHA + 60)
GROUP BY dbo.FACTEXP.FE_TIPO
HAVING      (dbo.FACTEXP.FE_TIPO <> 'T')






































































GO
