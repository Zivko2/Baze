SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VARANCELEXP
with encryption as
SELECT     dbo.ARANCEL.AR_CODIGO, dbo.ARANCEL.AR_OFICIAL, dbo.ARANCEL.AR_FRACCION, dbo.MEDIDA.ME_CORTO, 
                      MEDIDA_1.ME_CORTO AS ME_CORTO2
FROM         dbo.MEDIDA MEDIDA_1 RIGHT OUTER JOIN
                      dbo.ARANCEL ON MEDIDA_1.ME_CODIGO = dbo.ARANCEL.ME_CODIGO2 LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.ARANCEL.ME_CODIGO = dbo.MEDIDA.ME_CODIGO
WHERE     (dbo.ARANCEL.PA_CODIGO <>
                          (SELECT     CF_PAIS_MX
                            FROM          CONFIGURACION)) AND (dbo.ARANCEL.AR_TIPOREG <> 'C')

and dbo.ARANCEL.AR_TIPO = 'E'



GO
