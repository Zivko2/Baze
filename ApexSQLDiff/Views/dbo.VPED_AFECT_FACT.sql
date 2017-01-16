SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE VIEW dbo.VPED_AFECT_FACT
with encryption as
SELECT     dbo.KARDESPED.KAP_FACTRANS, dbo.FACTEXP.PI_CODIGO AS KAP_PED_CONST, dbo.PEDIMP.PI_TIPO AS KAP_TIPO_PED, 
                      dbo.AGENCIA.AG_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS KPN_PED_CONS, dbo.PEDIMP.PI_FEC_PAG AS KPN_PED_CONST_FECHA, 
                      dbo.ADUANA.AD_CLAVE collate database_default + '-' + dbo.ADUANA.AD_SECCION collate database_default AS AD_SEC_CONST, dbo.FACTEXPDET.FED_NOPARTE AS KPN_FNOPARTE, 
                      dbo.FACTEXPDET.FED_NOMBRE AS KPN_FNOMBRE, dbo.FACTEXPDET.FED_NAME AS KPN_FNAME, dbo.KARDESPED.KAP_CANTDESC, 
                      dbo.ARANCEL.AR_FRACCION, dbo.MAESTRO.ME_COM AS ME_FCORTO, dbo.FACTEXP.FE_TIPO AS KAP_TIPO_FACTRANS
FROM         dbo.MAESTRO RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.MAESTRO.MA_CODIGO = dbo.FACTEXPDET.MA_CODIGO FULL OUTER JOIN
                      dbo.ADUANA RIGHT OUTER JOIN
                      dbo.KARDESPED LEFT OUTER JOIN
                      dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.ARANCEL INNER JOIN
                      dbo.AGENCIA ON dbo.ARANCEL.PA_CODIGO = dbo.AGENCIA.PA_CODIGO RIGHT OUTER JOIN
                      dbo.PEDIMP LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO ON 
                      dbo.AGENCIA.AG_CODIGO = dbo.AGENCIAPATENTE.AG_CODIGO ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO ON 
                      dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO ON dbo.ADUANA.AD_CODIGO = dbo.PEDIMP.AD_DES ON 
                      dbo.FACTEXPDET.FED_INDICED = dbo.KARDESPED.KAP_INDICED_FACT AND dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
WHERE     (dbo.FACTEXP.FE_TIPO = 'F')






GO
