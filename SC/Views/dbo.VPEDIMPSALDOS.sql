SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE VIEW dbo.VPEDIMPSALDOS
AS
SELECT     KAP_SALDO_PED, KAP_INDICED_PED
FROM         dbo.KARDESPED
WHERE     (KAP_CODIGO IN
                          (SELECT     MAX(kardesped1.kap_codigo)
                            FROM          kardesped kardesped1
                            GROUP BY kardesped1.KAP_INDICED_PED))






















GO
