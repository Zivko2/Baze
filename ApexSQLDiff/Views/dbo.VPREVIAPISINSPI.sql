SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VPREVIAPISINSPI
with encryption as
SELECT     TOP 100 PERCENT dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_PATENTEFOLIO, dbo.PEDIMP.PI_FEC_ENT, 
                      dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.PI_TIP_CAM, dbo.CLAVEPED.CP_CLAVE, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, 
                      dbo.PEDIMPDET.PID_COS_UNI, dbo.PEDIMPDET.PID_CANT, dbo.PEDIMPDET.PID_INDICED, dbo.ARANCEL.AR_FRACCION, 
                      dbo.PEDIMPDET.SPI_CODIGO
FROM         dbo.ARANCEL RIGHT OUTER JOIN
                      dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO ON 
                      dbo.ARANCEL.AR_CODIGO = dbo.PEDIMPDET.AR_IMPMX RIGHT OUTER JOIN
                      dbo.AGENCIAPATENTE RIGHT OUTER JOIN
                      dbo.PEDIMP LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO ON dbo.AGENCIAPATENTE.AGT_CODIGO = dbo.PEDIMP.AGT_CODIGO ON 
                      dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R') AND (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND (dbo.CLAVEPED.CP_DESCARGABLE = 'S') AND 
                      (dbo.PEDIMPDET.PID_NOPARTE IS NOT NULL) AND (dbo.PEDIMPDET.PID_DEF_TIP = 'P') AND (dbo.PEDIMPDET.SPI_CODIGO = 0 OR
                      dbo.PEDIMPDET.SPI_CODIGO IS NULL) AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IA') AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IM') AND 
                      (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IB') AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IE') AND (NOT (dbo.CONFIGURATIPO.CFT_TIPO IN ('Q', 
                      'H'))) AND (dbo.PEDIMPDET.PID_IMPRIMIR = 'S')
ORDER BY dbo.PEDIMP.PI_FEC_ENT, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default




























































GO
