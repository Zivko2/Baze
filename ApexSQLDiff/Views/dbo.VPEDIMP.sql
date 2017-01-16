SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VPEDIMP
with encryption as
SELECT     dbo.PEDIMP.PI_CODIGO, dbo.PEDIMP.PI_FOLIO, dbo.PEDIMP.FC_CODIGO, dbo.PEDIMP.PI_MOVIMIENTO, dbo.PEDIMP.PI_TIPO, 
                      dbo.PEDIMP.CP_CODIGO, dbo.PEDIMP.CP_RECTIFICA, dbo.PEDIMP.REG_CODIGO, dbo.PEDIMP.PI_TIP_CAM, dbo.PEDIMP.PI_FMON_EXT, 
                      dbo.PEDIMP.MT_CODIGO, dbo.VPEDIMPVALORES.PI_PESO, dbo.PEDIMP.PI_FRAN_INT, dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.AD_DES, 
                      dbo.PEDIMP.AD_ORI, dbo.PEDIMP.PI_FEC_ENT, dbo.PEDIMP.PI_REEXPED, dbo.PEDIMP.PI_TRANSIT, dbo.PEDIMP.PI_IN_DIR, 
                      dbo.PEDIMP.CL_CODIGO, dbo.PEDIMP.DI_CL, dbo.PEDIMP.PR_CODIGO, dbo.PEDIMP.DI_PR, dbo.PEDIMP.PI_BULTO, 
                      dbo.VPEDIMPVALORES.PI_VALOR_ME, dbo.VPEDIMPVALORES.PI_VALOR_FACT, dbo.VPEDIMPVALORES.PI_VALOR_ADU, dbo.PEDIMP.PI_FT_ADU, 
                      dbo.PEDIMP.PI_TOTAL, dbo.PEDIMP.PI_FIRMA, dbo.AGENCIAPATENTE.AG_CODIGO, dbo.PEDIMP.AGT_CODIGO, dbo.PEDIMP.PI_OBSERVA, 
                      dbo.PEDIMP.PI_RECTIFICA, dbo.PEDIMP.PI_SEM, 0 AS PI_TRANSP, dbo.PEDIMP.PI_ANEXOL, dbo.PEDIMP.US_CODIGO, 
                      dbo.PEDIMP.PI_ESTATUS, dbo.PEDIMP.PI_ACTIVO_DESCARGA, dbo.PEDIMP.PI_AFECTADO, dbo.PEDIMP.PI_FECHAINI, dbo.PEDIMP.PI_FECHAFIN, 
                      dbo.PEDIMP.PI_OBSERVA_RECTIFICA, dbo.PEDIMP.PI_CONSOLIDA, dbo.PEDIMP.PI_FEC_CAMREG, dbo.PEDIMP.ZO_CODIGO, 
                      dbo.PEDIMP.MT_SALIDA, dbo.PEDIMP.MT_ARRIBO, dbo.PEDIMP.MT_ABANDONA, dbo.PEDIMP.TTA_CODIGO, dbo.PEDIMP.PI_FOLIOPAGO, 
                      dbo.PEDIMP.PI_CHEQUEPAGO, dbo.PEDIMP.PI_COMPLEMEN, dbo.PEDIMP.PI_FECHAPAGO, dbo.PEDIMP.PI_TIP_CAMPAGO, 
                      dbo.PEDIMP.PI_IMPORTECONTR, dbo.PEDIMP.PI_IMPORTERECARGOS, dbo.PEDIMP.PI_PORCENNAFTA, dbo.PEDIMP.PI_FEC_ACT_TIEMPO, 
                      CASE WHEN dbo.PEDIMP.PI_TIPO IN ('C', 'A') THEN isnull(dbo.AGENCIAPATENTE.AGT_PATENTE, '') collate database_default 
                      + '-' + dbo.PEDIMP.PI_FOLIO collate database_default ELSE dbo.PEDIMP.PI_FOLIO collate database_default END AS [PATENTE-FOLIO], dbo.PEDIMP.PI_ADVMNIMPUSA, 
                      CASE WHEN dbo.PEDIMP.PI_TIPO IN ('C', 'A') THEN isnull(dbo.AGENCIAPATENTE.AGT_PATENTE, '') collate database_default 
                      + '-' + dbo.PEDIMP.PI_FOLIO collate database_default ELSE dbo.PEDIMP.PI_FOLIO collate database_default END AS PATENTE_FOLIO, dbo.PEDIMP.PI_CUENTADET, dbo.PEDIMP.PI_ADVMNIMPMEX, 
                      dbo.PEDIMP.PI_EXCENCION, dbo.PEDIMP.PI_IMPORTECONTRSINRECARGOS, dbo.PEDIMP.PI_DEDUCIBLE, dbo.PEDIMP.PI_IMPORTECONTRUSD, 
                      dbo.PEDIMP.PI_LIGACORRECTA, dbo.PEDIMP.PI_DESP_EQUIPO, dbo.PEDIMP.PI_CODIGO AS PI_CODIGOGUIA, 
                      dbo.PEDIMP.PI_CODIGO AS PI_CODIGOCTRANS, dbo.PEDIMP.PI_CODIGO AS PI_CODIGOCAJA, dbo.PEDIMP.PI_CODIGO AS PI_CODIGOINCREMENTA, 
                      dbo.PEDIMP.PI_PAGADO, dbo.PEDIMP.PI_PEDVIRTUAL
FROM         dbo.PEDIMP LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN
                      dbo.VPEDIMPVALORES ON dbo.PEDIMP.PI_CODIGO = dbo.VPEDIMPVALORES.PI_CODIGO
WHERE     (dbo.PEDIMP.PI_MOVIMIENTO = 'E')

GO
