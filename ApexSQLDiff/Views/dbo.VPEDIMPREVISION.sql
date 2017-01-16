SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW dbo.VPEDIMPREVISION
with encryption as
SELECT     dbo.AGENCIAPATENTE.AGT_PATENTE collate database_default + '-' + dbo.PEDIMP.PI_FOLIO collate database_default AS FOLIOPED, dbo.CLAVEPED.CP_CLAVE, dbo.PEDIMP.PI_FEC_ENT, 
                      dbo.PEDIMPDET.ME_CODIGO, dbo.PEDIMPDET.PID_INDICED, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, 
                      dbo.PEDIMPDET.PA_ORIGEN, dbo.PAIS.PA_CORTO, dbo.PEDIMPDET.MA_GENERICO, dbo.PEDIMPDET.ME_GENERICO, dbo.MAESTRO.MA_NOPARTE, 
                      dbo.PEDIMPDET.EQ_GENERICO, dbo.PEDIMPDET.AR_IMPMX, dbo.PEDIMPDET.ME_ARIMPMX, ARANCEL_2.AR_FRACCION, 
                      dbo.PEDIMPDET.EQ_IMPMX, dbo.PEDIMPDET.PID_DEF_TIP, dbo.PEDIMPDET.PID_POR_DEF, dbo.PEDIMPDET.PID_SEC_IMP, SECTOR_2.SE_CLAVE, 
                      dbo.PEDIMPDET.SPI_CODIGO, dbo.SPI.SPI_CLAVE, dbo.PEDIMPDET.AR_EXPFO, ARANCEL_1.AR_FRACCION AS AR_FRACCIONEXPFO, 
                      dbo.PEDIMPDET.PID_RATEEXPFO, dbo.PEDIMPDET.SE_CODIGO, SECTOR_1.SE_CLAVE AS SE_CLAVEPT, dbo.PEDIMP.PI_MOVIMIENTO, 
                      dbo.PEDIMPDET.PID_COS_UNI, dbo.PEDIMPDET.PID_CANT, dbo.MEDIDA.ME_CORTO, dbo.PEDIMP.CP_RECTIFICA, dbo.PEDIMPDET.PID_PAGACONTRIB,
                      CLAVEPED_1.CP_CLAVE AS CP_CLAVER1, dbo.PEDIMP.CP_CODIGO, dbo.PEDIMPDET.PID_NOMBRE, dbo.PEDIMP.PI_ESTATUS, 
                      dbo.PIDescarga.PID_SALDOGEN, dbo.PIDescarga.pid_fechavence, dbo.PEDIMPDET.PID_CAN_GEN, dbo.PEDIMPDET.PID_VAL_ADU, TI_NOMBRE
FROM         dbo.PAIS RIGHT OUTER JOIN
                      dbo.PIDescarga RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.PIDescarga.PID_INDICED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.PEDIMPDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO LEFT OUTER JOIN
                      dbo.SECTOR SECTOR_1 ON dbo.PEDIMPDET.SE_CODIGO = SECTOR_1.SE_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ARANCEL_1 ON dbo.PEDIMPDET.AR_EXPFO = ARANCEL_1.AR_CODIGO LEFT OUTER JOIN
                      dbo.SPI ON dbo.PEDIMPDET.SPI_CODIGO = dbo.SPI.SPI_CODIGO LEFT OUTER JOIN
                      dbo.SECTOR SECTOR_2 ON dbo.PEDIMPDET.PID_SEC_IMP = SECTOR_2.SE_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ARANCEL_2 ON dbo.PEDIMPDET.AR_IMPMX = ARANCEL_2.AR_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO ON 
                      dbo.PAIS.PA_CODIGO = dbo.PEDIMPDET.PA_ORIGEN RIGHT OUTER JOIN
                      dbo.CLAVEPED RIGHT OUTER JOIN
                      dbo.CLAVEPED CLAVEPED_1 RIGHT OUTER JOIN
                      dbo.PEDIMP ON CLAVEPED_1.CP_CODIGO = dbo.PEDIMP.CP_RECTIFICA ON dbo.CLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO ON 
                      dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.AGENCIAPATENTE ON dbo.PEDIMP.AGT_CODIGO = dbo.AGENCIAPATENTE.AGT_CODIGO LEFT OUTER JOIN dbo.TIPO ON
                      dbo.PEDIMPDET.TI_CODIGO = dbo.TIPO.TI_CODIGO
WHERE     (dbo.PEDIMP.PI_ESTATUS <> 'R') AND ((dbo.PEDIMP.PI_MOVIMIENTO='E' AND dbo.CLAVEPED.CP_DESCARGABLE = 'S') OR dbo.PEDIMP.PI_MOVIMIENTO='S' )
	AND dbo.PEDIMP.CP_CODIGO NOT IN (SELECT CP_CODIGO FROM CONFIGURACLAVEPED WHERE CCP_TIPO='OC') and dbo.PEDIMPDET.PID_IMPRIMIR='S'

GO
