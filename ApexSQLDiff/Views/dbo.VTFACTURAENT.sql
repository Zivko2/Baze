SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.VTFACTURAENT
with encryption as
SELECT     *
FROM         dbo.TFACTURA
WHERE     (TF_CODIGO IN
                          (SELECT     tf_codigo
                            FROM          configuratfact
                            WHERE      cff_tipo IN ('ES', 'IA', 'ID', 'IT', 'IV', 'SA', 'TA', 'RS', 'TE', 'IF')))





































































GO
