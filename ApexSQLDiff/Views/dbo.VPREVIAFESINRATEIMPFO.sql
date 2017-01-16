SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE VIEW dbo.VPREVIAFESINRATEIMPFO
with encryption as
SELECT     TOP 100 PERCENT dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.FACTEXPDET.FED_NOPARTE, 
                      dbo.FACTEXPDET.FED_NOMBRE, dbo.FACTEXPDET.FED_CANT, dbo.ARANCEL.AR_FRACCION, dbo.FACTEXPDET.FED_RATEIMPFO, 
                      dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_FOLIOPATENTE, dbo.PEDIMP.PI_FEC_PAG
FROM         dbo.PEDIMP LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
                      dbo.FACTEXP ON dbo.PEDIMP.PI_CODIGO = dbo.FACTEXP.PI_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.ARANCEL.AR_CODIGO = dbo.FACTEXPDET.AR_IMPFO ON 
                      dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTEXP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTEXP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO LEFT OUTER JOIN
	        dbo.CONFIGURATIPO ON dbo.CONFIGURATIPO.TI_CODIGO=dbo.FACTEXPDET.TI_CODIGO
WHERE     (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.FACTEXPDET.FED_RATEIMPFO = - 1) AND 
                      (dbo.PEDIMP.PI_MOVIMIENTO = 'S') AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'RS' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'EA' AND 
                      dbo.CONFIGURATFACT.CFF_TIPO <> 'PA') AND (dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S')
ORDER BY dbo.PEDIMP.PI_FEC_PAG, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_FOLIO, 
                      dbo.FACTEXPDET.FED_NOPARTE































































GO
