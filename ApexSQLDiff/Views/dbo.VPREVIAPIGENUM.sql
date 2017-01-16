SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VPREVIAPIGENUM
with encryption as
SELECT     TOP 100 PERCENT dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_PATENTEFOLIO, dbo.PEDIMP.PI_FEC_ENT, 
                      dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.PI_TIP_CAM, dbo.CLAVEPED.CP_CLAVE, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, 
                      dbo.PEDIMPDET.PID_COS_UNI, dbo.PEDIMPDET.PID_CANT, dbo.PEDIMPDET.PID_INDICED, dbo.ARANCEL.AR_FRACCION, 
                      dbo.MAESTRO.MA_NOPARTE AS MA_NOPARTEGEN, CONFIGURACLAVEPED_1.CCP_TIPO
FROM         dbo.CLAVEPED RIGHT OUTER JOIN
                      dbo.PEDIMP LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED CONFIGURACLAVEPED_1 ON dbo.PEDIMP.CP_RECTIFICA = CONFIGURACLAVEPED_1.CP_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED CONFIGURACLAVEPED_2 ON dbo.PEDIMP.CP_CODIGO = CONFIGURACLAVEPED_2.CP_CODIGO ON 
                      dbo.CLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
                      dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.PEDIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO
WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R') AND (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND (dbo.CLAVEPED.CP_DESCARGABLE = 'S') AND 
                      (dbo.PEDIMPDET.PID_NOPARTE IS NOT NULL) AND (dbo.PEDIMPDET.ME_GENERICO = 0 OR
                      dbo.PEDIMPDET.ME_GENERICO IS NULL) AND (CONFIGURACLAVEPED_2.CCP_TIPO <> 'IA') AND 
                      (CONFIGURACLAVEPED_2.CCP_TIPO <> 'IM') AND (CONFIGURACLAVEPED_2.CCP_TIPO <> 'IB') AND (CONFIGURACLAVEPED_2.CCP_TIPO <> 'IE') 
ORDER BY dbo.PEDIMP.PI_FEC_ENT, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default


































































GO
