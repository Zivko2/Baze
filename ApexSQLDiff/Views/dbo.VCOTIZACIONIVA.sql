SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.VCOTIZACIONIVA
with encryption as
SELECT     SUM(ISNULL(COTC_CONTRIBTOTUS, 0)) AS ORC_CONTRIBTOTUS, COT_CODIGO
FROM         dbo.COTIZACIONCONTRIBUCION
WHERE     (CON_CODIGO in(select con_codigo from contribucion where con_clave='3'))
GROUP BY COT_CODIGO


GO
