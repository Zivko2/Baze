SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.VFACTEXPPED
with encryption as
SELECT     dbo.KARDESPED.KAP_FACTRANS, dbo.KARDESPED.KAP_INDICED_FACT, dbo.PEDIMP.PI_FEC_ENT AS KAP_FECHAPED, dbo.PEDIMP.AGT_CODIGO, 
                      dbo.PEDIMPDET.PI_CODIGO AS KAP_PED_CONST, dbo.PEDIMP.AD_DES, dbo.KARDESPED.MA_HIJO, dbo.PEDIMPDET.ME_GENERICO AS ME_HIJO, 
                      SUM(dbo.KARDESPED.KAP_CANTDESC) AS KAP_CANTDESC, dbo.CLIENTE.CL_RFC, MIN(dbo.KARDESPED.KAP_CODIGO) AS FEP_INDICEP, 
                      FED.MA_CODIGO AS MA_FACT_TRANS, FE.FE_TIPO AS KAP_TIPO_FACTRANS, dbo.PEDIMP.PI_TIPO AS KAP_TIPO_PED, 
                      dbo.VPI_TIPO.CB_LOOKUP AS FEP_TIPO, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS [PATENTE-FOLIO], 
                      CASE MAX(CONFIGURACLAVEPED.CCP_TIPO) 
                      WHEN 'IT' THEN 'Temporal' WHEN 'IA' THEN 'Temporal' WHEN 'RE' THEN 'Temporal' WHEN 'IV' THEN 'Temporal' WHEN 'IR' THEN 'Temporal' WHEN 'CS'
                       THEN 'Temporal' WHEN 'ID' THEN 'Definitivo' END AS FED_TIP_PED
FROM         dbo.KARDESPED INNER JOIN
                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED INNER JOIN
                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO INNER JOIN
                      dbo.CLIENTE ON dbo.PEDIMP.PR_CODIGO = dbo.CLIENTE.CL_CODIGO INNER JOIN
                          (SELECT     FED.FED_INDICED, FED.MA_CODIGO
                            FROM          FACTEXPDET FED) FED ON FED.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT INNER JOIN
                          (SELECT     FE.FE_CODIGO, FE.FE_TIPO
                            FROM          FACTEXP FE) FE ON FE.FE_CODIGO = dbo.KARDESPED.KAP_FACTRANS INNER JOIN
                      dbo.VPI_TIPO ON dbo.VPI_TIPO.CB_KEYFIELD = dbo.PEDIMP.PI_TIPO INNER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
GROUP BY dbo.KARDESPED.KAP_FACTRANS, dbo.KARDESPED.KAP_INDICED_FACT, dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMP.AGT_CODIGO, 
                      dbo.PEDIMPDET.PI_CODIGO, dbo.PEDIMP.AD_DES, dbo.KARDESPED.MA_HIJO, dbo.PEDIMPDET.ME_GENERICO, dbo.CLIENTE.CL_RFC, 
                      FED.MA_CODIGO, FE.FE_TIPO, dbo.PEDIMP.PI_TIPO, dbo.VPI_TIPO.CB_LOOKUP, dbo.AGENCIAPATENTE.AGT_PATENTE, dbo.PEDIMP.PI_FOLIO

GO
