SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VPEDIMPDETB
with encryption as
SELECT     PEDIMPDET.PI_CODIGO, MA_GENERICO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, SUM(PID_CAN_GEN) AS PID_CAN_GEN, SUM(PID_CAN_AR) 
                      AS PID_CAN_AR, PA_PROCEDE, SUM(PID_VAL_ADU) AS PID_VAL_ADU, 
                      SUM(PID_CTOT_DLS) AS PID_CTOT_DLS, PID_COS_UNIGEN=CASE WHEN  SUM(PID_CAN_GEN)>0 THEN SUM(dbo.PEDIMPDET.PID_CTOT_DLS * dbo.PEDIMP.PI_TIP_CAM) / SUM(PID_CAN_GEN) ELSE 0 END,
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_pr from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),9) AS ES_ORIGEN,
	 isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_cl from pedimp where pi_codigo=dbo.PEDIMPDET.PI_CODIGO )),7) AS ES_DESTINO, 
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_cl from pedimp where pi_codigo=dbo.PEDIMPDET.PI_CODIGO )),7) AS ES_COMPRADOR, 
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_pr from pedimp where pi_codigo=dbo.PEDIMPDET.PI_CODIGO )),9) AS ES_VENDEDOR
FROM         PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO=PEDIMP.PI_CODIGO
GROUP BY PEDIMPDET.PI_CODIGO, AR_IMPMX, ME_ARIMPMX, ME_GENERICO, PA_PROCEDE, MA_GENERICO






































































GO
