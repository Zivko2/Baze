SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VPREVIAFESINDESCARGAR
with encryption as
SELECT     TOP 100 PERCENT dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_FOLIOPATENTE, dbo.PEDIMP.PI_FEC_PAG, 
                      dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.CLIENTE.CL_RAZON
FROM         dbo.TFACTURA RIGHT OUTER JOIN
                      dbo.CONFIGURATFACT RIGHT OUTER JOIN
                      dbo.FACTEXP LEFT OUTER JOIN
                      dbo.PEDIMP ON dbo.FACTEXP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
                      dbo.CLIENTE ON dbo.FACTEXP.CL_DESTINI = dbo.CLIENTE.CL_CODIGO ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO ON 
                      dbo.TFACTURA.TF_CODIGO = dbo.FACTEXP.TF_CODIGO LEFT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO
WHERE     (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.FACTEXP.PI_CODIGO <> - 1) AND 
                      (dbo.FACTEXP.FE_DESCARGADA = 'N') AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'RS') AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'EA') AND 
                      (dbo.CONFIGURATFACT.CFF_TIPO <> 'PA') AND (dbo.FACTEXP.FE_CODIGO IN
                          (SELECT     FE_CODIGO
                            FROM          FACTEXPDET
                            GROUP BY FE_CODIGO)) AND (dbo.CONFIGURATIPO.CFT_TIPO = 'P' OR
                      dbo.CONFIGURATIPO.CFT_TIPO = 'S')
GROUP BY dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default, dbo.PEDIMP.PI_FEC_PAG, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, 
                      dbo.TFACTURA.TF_NOMBRE, dbo.CLIENTE.CL_RAZON
ORDER BY dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default, dbo.PEDIMP.PI_FEC_PAG, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_FOLIO

























































GO
