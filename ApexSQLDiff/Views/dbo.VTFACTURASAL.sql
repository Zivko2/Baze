SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VTFACTURASAL
with encryption as
SELECT     *
FROM         dbo.TFACTURA
WHERE     (TF_CODIGO IN
                          (SELECT     tf_codigo
                            FROM          configuratfact
                            WHERE      cff_tipo IN ('EA', 'ED', 'ET', 'EV', 'MA', 'MN', 'PA', 'RS', 'SE', 'SS', 'TS', 'EF', 'RX'))) AND (TF_CODIGO > - 1)






































































GO
