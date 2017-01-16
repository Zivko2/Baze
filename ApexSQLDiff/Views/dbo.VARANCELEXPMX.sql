SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























CREATE VIEW dbo.VARANCELEXPMX
with encryption as
SELECT     dbo.ARANCEL.AR_CODIGO, dbo.ARANCEL.AR_OFICIAL, dbo.ARANCEL.AR_FRACCION, dbo.MEDIDA.ME_CORTO, dbo.MEDIDA.ME_CODIGO
FROM         dbo.ARANCEL LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.ARANCEL.ME_CODIGO = dbo.MEDIDA.ME_CODIGO
WHERE     (dbo.ARANCEL.PA_CODIGO = (SELECT     CF_PAIS_MX
                            FROM          CONFIGURACION)) AND (dbo.ARANCEL.AR_TIPOREG<>'C')































GO
