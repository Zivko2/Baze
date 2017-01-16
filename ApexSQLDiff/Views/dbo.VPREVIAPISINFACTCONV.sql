SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VPREVIAPISINFACTCONV
with encryption as
SELECT     TOP 100 PERCENT dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_PATENTEFOLIO, dbo.PEDIMP.PI_FEC_ENT, 
                      dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.PI_TIP_CAM, dbo.CLAVEPED.CP_CLAVE, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, 
                      dbo.PEDIMPDET.PID_COS_UNI, dbo.PEDIMPDET.PID_CANT, dbo.PEDIMPDET.PID_INDICED, dbo.ARANCEL.AR_FRACCION, dbo.MEDIDA.ME_CORTO, 
                      MEDIDA_1.ME_CORTO AS ME_GEN, dbo.PEDIMPDET.EQ_GENERICO
FROM         dbo.ARANCEL RIGHT OUTER JOIN
                      dbo.MEDIDA MEDIDA_1 RIGHT OUTER JOIN
                      dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO ON 
                      MEDIDA_1.ME_CODIGO = dbo.PEDIMPDET.ME_GENERICO LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.PEDIMPDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO ON 
                      dbo.ARANCEL.AR_CODIGO = dbo.PEDIMPDET.AR_IMPMX RIGHT OUTER JOIN
                      dbo.PEDIMP LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R') AND (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND (dbo.CLAVEPED.CP_DESCARGABLE = 'S') AND 
                      (dbo.PEDIMPDET.PID_NOPARTE IS NOT NULL) AND (dbo.PEDIMPDET.ME_CODIGO <> dbo.PEDIMPDET.ME_GENERICO) AND 
                      (dbo.PEDIMPDET.EQ_GENERICO = 1) AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IA') AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IM') AND 
                      (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IB') AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IE') AND (NOT (dbo.CONFIGURATIPO.CFT_TIPO IN ('Q', 
                      'H'))) AND (dbo.PEDIMPDET.PID_IMPRIMIR = 'S')
	and convert(varchar(10),dbo.PEDIMPDET.ME_CODIGO)+convert(varchar(10),dbo.PEDIMPDET.ME_GENERICO) not in 
	(SELECT convert(varchar(10),dbo.EQUIVALE.ME_CODIGO1)+convert(varchar(10),dbo.EQUIVALE.ME_CODIGO2) FROM dbo.EQUIVALE WHERE dbo.EQUIVALE.EQ_CANT=1)
ORDER BY dbo.PEDIMP.PI_FEC_ENT, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default
UNION
SELECT     TOP 100 PERCENT dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS PI_PATENTEFOLIO, dbo.PEDIMP.PI_FEC_ENT, 
                      dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.PI_TIP_CAM, dbo.CLAVEPED.CP_CLAVE, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, 
                      dbo.PEDIMPDET.PID_COS_UNI, dbo.PEDIMPDET.PID_CANT, dbo.PEDIMPDET.PID_INDICED, dbo.ARANCEL.AR_FRACCION, dbo.MEDIDA.ME_CORTO, 
                      MEDIDA_1.ME_CORTO AS ME_GEN, dbo.PEDIMPDET.EQ_GENERICO
FROM         dbo.ARANCEL RIGHT OUTER JOIN
                      dbo.MEDIDA MEDIDA_1 RIGHT OUTER JOIN
                      dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO ON 
                      MEDIDA_1.ME_CODIGO = dbo.PEDIMPDET.ME_GENERICO LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.PEDIMPDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO ON 
                      dbo.ARANCEL.AR_CODIGO = dbo.PEDIMPDET.AR_IMPMX RIGHT OUTER JOIN
                      dbo.PEDIMP LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R') AND (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND (dbo.CLAVEPED.CP_DESCARGABLE = 'S') AND 
                      (dbo.PEDIMPDET.PID_NOPARTE IS NOT NULL) AND (dbo.PEDIMPDET.ME_CODIGO = dbo.PEDIMPDET.ME_GENERICO) AND 
                      (dbo.PEDIMPDET.EQ_GENERICO <> 1) AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IA') AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IM') AND 
                      (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IB') AND (dbo.CONFIGURACLAVEPED.CCP_TIPO <> 'IE') AND (NOT (dbo.CONFIGURATIPO.CFT_TIPO IN ('Q', 
                      'H'))) AND (dbo.PEDIMPDET.PID_IMPRIMIR = 'S')
	and convert(varchar(10),dbo.PEDIMPDET.ME_CODIGO)+convert(varchar(10),dbo.PEDIMPDET.ME_GENERICO) not in 
	(SELECT convert(varchar(10),dbo.EQUIVALE.ME_CODIGO1)+convert(varchar(10),dbo.EQUIVALE.ME_CODIGO2) FROM dbo.EQUIVALE WHERE dbo.EQUIVALE.EQ_CANT=1)
ORDER BY dbo.PEDIMP.PI_FEC_ENT, dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default






































GO
