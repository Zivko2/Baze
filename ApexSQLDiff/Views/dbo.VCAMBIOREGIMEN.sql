SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VCAMBIOREGIMEN
with encryption as
SELECT     dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.TF_CODIGO, dbo.FACTEXP.TQ_CODIGO, dbo.FACTEXP.FE_FECHA, 
                      dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS [PATENTE-FOLIO], dbo.FACTEXP.PI_CODIGO, dbo.FACTEXP.FE_TIPO,
                   dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PATENTE_FOLIO
FROM         dbo.FACTEXP LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE RIGHT OUTER JOIN
                      dbo.PEDIMP ON dbo.AGENCIAPATENTE.AGT_CODIGO = dbo.PEDIMP.AGT_CODIGO ON dbo.FACTEXP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTEXP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO LEFT OUTER JOIN
                      dbo.FACTCONS ON dbo.FACTEXP.FC_CODIGO = dbo.FACTCONS.FC_CODIGO
WHERE     (dbo.CONFIGURATFACT.CFF_TIPO = 'MA' OR
                      dbo.CONFIGURATFACT.CFF_TIPO = 'MN') AND (dbo.FACTEXP.FE_CUENTADET > 0) AND (dbo.FACTEXP.FE_DESCARGADA = 'S') AND 
                      (dbo.FACTEXP.FE_FECHADESCARGA IS NOT NULL)






































GO
