SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VPREVIAPESININFOPAGO
with encryption as
SELECT     TOP 100 PERCENT dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_FOLIOPATENTE, dbo.PEDIMP.PI_FEC_PAG, 
                      dbo.PEDIMP.PI_MOVIMIENTO, dbo.VPI_ESTATUS.CB_LOOKUP AS PI_ESTATUS, dbo.CLAVEPED.CP_CLAVE, dbo.PEDIMP.PI_FEC_ENT, 
                      dbo.PEDIMP.PI_FECHAPAGO, dbo.PEDIMP.PI_PORCENNAFTA, dbo.PEDIMP.PI_TIP_CAMPAGO, dbo.CONFIGURACLAVEPED.CCP_TIPO
FROM         dbo.PEDIMP LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.VPI_ESTATUS ON dbo.PEDIMP.PI_ESTATUS = dbo.VPI_ESTATUS.CB_KEYFIELD LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO
WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R')
GROUP BY dbo.PEDIMP.PI_MOVIMIENTO, dbo.VPI_ESTATUS.CB_LOOKUP, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default, dbo.CLAVEPED.CP_CLAVE, 
                      dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMP.PI_FECHAPAGO, dbo.PEDIMP.PI_PORCENNAFTA, dbo.PEDIMP.PI_TIP_CAMPAGO, 
                      dbo.CONFIGURACLAVEPED.CCP_TIPO
HAVING      (dbo.PEDIMP.PI_FECHAPAGO IS NULL) AND (dbo.PEDIMP.PI_MOVIMIENTO = 'S') AND (dbo.PEDIMP.PI_PORCENNAFTA IS NULL OR
                      dbo.PEDIMP.PI_PORCENNAFTA < 0 OR
                      dbo.PEDIMP.PI_TIP_CAMPAGO IS NULL OR
                      dbo.PEDIMP.PI_TIP_CAMPAGO < 8) AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IB' AND dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IR' AND 
                      dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IA' AND dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'ET' AND 
                      dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'EM' AND dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IE' AND dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'CN'
                   AND dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'RG')
ORDER BY dbo.PEDIMP.PI_FEC_PAG, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default


































































GO
