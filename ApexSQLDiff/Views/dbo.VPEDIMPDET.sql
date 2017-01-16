SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


















CREATE VIEW dbo.VPEDIMPDET
with encryption as
SELECT     dbo.PEDIMPDET.PI_CODIGO, dbo.PEDIMPDET.PID_INDICED, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, 
                      dbo.PEDIMPDET.PID_NOMBRE, dbo.PEDIMPDET.PID_NAME, dbo.PEDIMPDET.PID_COS_UNI, dbo.PEDIMPDET.PID_COS_UNIADU, 
                      dbo.PEDIMPDET.PID_COS_UNIGEN, dbo.PEDIMPDET.PID_COS_UNIVA, dbo.PEDIMPDET.PID_COS_UNIMATGRA, dbo.PEDIMPDET.PID_CANT, 
                      dbo.PEDIMPDET.PID_CAN_AR, dbo.PEDIMPDET.PID_CAN_GEN, dbo.PEDIMPDET.PID_CTOT_DLS * dbo.PEDIMP.PI_TIP_CAM  AS PID_VAL_FAC, dbo.PEDIMPDET.PID_VAL_ADU, 
                      dbo.PEDIMPDET.PID_CTOT_DLS, dbo.PEDIMPDET.ME_CODIGO, dbo.PEDIMPDET.ME_GENERICO, dbo.PEDIMPDET.PID_OBSERVA, dbo.PEDIMPDET.MA_GENERICO, 
                      dbo.PEDIMPDET.EQ_GENERICO, dbo.PEDIMPDET.EQ_IMPMX, dbo.PEDIMPDET.AR_IMPMX, dbo.PEDIMPDET.ME_ARIMPMX, 
                      dbo.PEDIMPDET.AR_EXPFO, dbo.PEDIMPDET.PID_RATEEXPFO, dbo.PEDIMPDET.PID_SEC_IMP, dbo.PEDIMPDET.PID_DEF_TIP, 
                      dbo.PEDIMPDET.PID_POR_DEF, dbo.PEDIMPDET.CS_CODIGO, dbo.PIDescarga.PID_SALDOGEN, 
                      dbo.PEDIMPDET.PID_KIT_POR, dbo.PEDIMPDET.TI_CODIGO, dbo.PEDIMPDET.PA_ORIGEN, dbo.PEDIMPDET.PA_PROCEDE, 
                      dbo.PEDIMPDET.SPI_CODIGO, dbo.PEDIMPDET.PR_CODIGO, 
                      dbo.PEDIMPDET.PID_IMPRIMIR, dbo.PEDIMPDET.PID_GENERA_EMP, 
	         dbo.PEDIMPDET.PID_CANT_DESP, dbo.PEDIMPDET.EQ_EXPFO, dbo.PEDIMPDET.PIB_INDICEB, 
                      dbo.PEDIMPDET.PID_DESCARGABLE, dbo.PEDIMPDET.PID_MA_CODIGOPADREKIT, dbo.PEDIMPDET.TCO_CODIGO, dbo.PEDIMPDET.SE_CODIGO, 
                      dbo.PIDescarga.PID_FECHAVENCE, dbo.PEDIMPDET.PID_REGIONFIN,
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_pr from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),9) AS ES_ORIGEN,
	 isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_cl from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),7) AS ES_DESTINO, 
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_cl from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),7) AS ES_COMPRADOR, 
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_pr from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),9) AS ES_VENDEDOR
FROM         dbo.PEDIMP INNER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN 
	        dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED=dbo.PIDescarga.PID_INDICED
WHERE     (dbo.PEDIMP.PI_MOVIMIENTO = 'E')









































































GO
