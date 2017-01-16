SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.VPEDIDOIVA
with encryption as
SELECT     SUM(ISNULL(PDC_CONTRIBTOTUS, 0)) AS PDC_CONTRIBTOTUS, PD_CODIGO
FROM         dbo.PEDIDOCONTRIBUCION
WHERE     (CON_CODIGO in(select con_codigo from contribucion where con_clave='3'))
GROUP BY PD_CODIGO


GO
