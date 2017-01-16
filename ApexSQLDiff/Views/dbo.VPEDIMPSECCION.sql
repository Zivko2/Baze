SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VPEDIMPSECCION
with encryption as
SELECT     PI_CODIGO,
                          (SELECT     COUNT(*)
                            FROM          PEDIMPCTRANSPOR
                            WHERE      pi_codigo = pedimp.pi_codigo) AS CTRANSPORT,
                          (SELECT     COUNT(*)
                            FROM          PEDIMPGUIA
                            WHERE      pi_codigo = pedimp.pi_codigo) AS GUIA,
                          (SELECT     COUNT(*)
                            FROM          PEDIMPCAJA
                            WHERE      pi_codigo = pedimp.pi_codigo) AS CAJA,
                          (SELECT     COUNT(*)
                            FROM          PEDIMPIDENTIFICA
                            WHERE      pi_codigo = pedimp.pi_codigo) AS IDENTIFICA,
                          (SELECT     COUNT(*)
                            FROM          PEDIMPPAGOVIRT
                            WHERE      pi_codigo = pedimp.pi_codigo) AS PAGOVIRTUAL,
                          (SELECT     COUNT(*)
                            FROM          PEDIMPCUENTA
                            WHERE      pi_codigo = pedimp.pi_codigo) AS CUENTA
FROM         dbo.PEDIMP




GO
