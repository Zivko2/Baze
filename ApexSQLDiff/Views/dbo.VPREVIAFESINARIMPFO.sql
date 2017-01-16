SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VPREVIAFESINARIMPFO
with encryption as
SELECT     TOP 100 PERCENT dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_FOLIOPATENTE, dbo.PEDIMP.PI_FEC_PAG, 
                      dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.FACTEXPDET.FED_NOPARTE, dbo.FACTEXPDET.FED_NOMBRE, 
                      dbo.FACTEXPDET.FED_CANT
FROM         dbo.AGENCIAPATENTE RIGHT OUTER JOIN
                      dbo.PEDIMP ON dbo.AGENCIAPATENTE.AGT_CODIGO = dbo.PEDIMP.AGT_CODIGO LEFT OUTER JOIN
                      dbo.FACTEXP ON dbo.PEDIMP.PI_CODIGO = dbo.FACTEXP.PI_CODIGO LEFT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTEXP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTEXP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO LEFT OUTER JOIN
	        dbo.CONFIGURATIPO ON dbo.CONFIGURATIPO.TI_CODIGO=dbo.FACTEXPDET.TI_CODIGO
WHERE     (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.FACTEXPDET.AR_IMPFO IS NULL OR
                      dbo.FACTEXPDET.AR_IMPFO = 0) AND (dbo.PEDIMP.PI_MOVIMIENTO = 'S') AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'RS' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'EA' AND 
                      dbo.CONFIGURATFACT.CFF_TIPO <> 'PA') AND (dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S')
ORDER BY dbo.PEDIMP.PI_FEC_PAG, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXPDET.FED_NOPARTE


































































GO
