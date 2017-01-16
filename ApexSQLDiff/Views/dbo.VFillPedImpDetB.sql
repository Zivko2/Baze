SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.VFillPedImpDetB
with encryption as
SELECT     TOP 100 PERCENT dbo.PEDIMPDET.PI_CODIGO, dbo.PEDIMPDET.PID_INDICED, 0 AS MA_GENERICO, ISNULL(dbo.PEDIMPDET.AR_IMPMX, 0) AS AR_IMPMX, 
                      ISNULL(dbo.PEDIMPDET.ME_ARIMPMX, 36) AS ME_ARIMPMX, ISNULL(dbo.PEDIMPDET.ME_GENERICO, 19) AS ME_GENERICO, 
                      dbo.PEDIMPDET.PID_CAN_GEN AS PID_CAN_GEN, dbo.PEDIMPDET.PID_CAN_AR AS PID_CAN_AR, dbo.PEDIMPDET.PA_PROCEDE, 
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_pr from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),9) AS ES_ORIGEN,
	 isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_cl from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),7) AS ES_DESTINO, 
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_cl from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),7) AS ES_COMPRADOR, 
	isnull((select max(es_codigo) from dir_cliente where di_indice in (select di_pr from pedimp where pi_codigo=dbo.PEDIMP.PI_CODIGO )),9) AS ES_VENDEDOR,
                      ROUND(dbo.PEDIMPDET.PID_CTOT_DLS, 2) AS PID_CTOT_DLS, ROUND(dbo.PEDIMPDET.PID_CTOT_MN, 6) AS PID_CTOT_MN, 
	         ISNULL(dbo.PEDIMPDET.AR_EXPFO, 0) AS AR_EXPFO, 
                      'PID_RATEEXPFO'=case when dbo.PEDIMP.PI_MOVIMIENTO='S' then ISNULL(dbo.PEDIMPDET.PID_RATEEXPFO, 0) else 0 end, ISNULL(dbo.PEDIMPDET.PID_COS_UNIMATGRA, 0) 
                      + ISNULL(dbo.PEDIMPDET.PID_COS_UNIVA/dbo.PEDIMP.PI_TIP_CAM, 0) AS PIB_COS_UNIGRA, ISNULL(dbo.PEDIMPDET.PID_COS_UNIVA, 0) AS PID_COS_UNIVA, 
                      ISNULL(dbo.PEDIMPDET.EQ_EXPFO, 1) AS EQ_EXPFO, dbo.PEDIMPDET.PID_CANT, ISNULL(dbo.PEDIMPDET.PID_POR_DEF, - 1) AS PID_POR_DEF, 
                      dbo.PEDIMPDET.PA_ORIGEN, dbo.PEDIMPDET.PID_NOMBRE,  dbo.ARANCEL.AR_FRACCION, isnull(dbo.PEDIMPDET.PID_COS_UNIGEN,0) AS PID_COS_UNIGEN,
		 'PIB_DESTNAFTA'=case when dbo.PEDIMP.PI_MOVIMIENTO='S' then (case when isnull(dbo.PEDIMPDET.PID_REGIONFIN, 'F')='N' or isnull(dbo.PEDIMPDET.PID_REGIONFIN, 'F')='M'
		then (case when dbo.PEDIMPDET.PID_DEF_TIP<>'S' and dbo.MAESTRO.MA_SERVICIO<>'S'
		then 'S' else 'N' end) else 'N' end) else (case when isnull(dbo.PEDIMPDET.PID_DEF_TIP, 'G')='P' then 'S'else 'N' end) end, 
		'PID_PAGACONTRIB'=case when dbo.PEDIMP.PI_MOVIMIENTO='S' then 'S' else dbo.PEDIMPDET.PID_PAGACONTRIB end, dbo.PEDIMPDET.PID_SECUENCIA,
		dbo.PEDIMPDET.PID_SEC_IMP, dbo.PEDIMPDET.PID_DEF_TIP, dbo.PEDIMPDET.SPI_CODIGO, dbo.PEDIMPDET.PID_CODIGOFACT, dbo.PAIS.PA_SAAIM3,
		dbo.MEDIDA.ME_CLA_PED, 'IDENTIFICADOR'=CASE WHEN dbo.PEDIMPDET.PID_DEF_TIP='P' THEN 'TL' WHEN dbo.PEDIMPDET.PID_DEF_TIP='S' THEN 'PS' ELSE '' END,
		dbo.PEDIMPDET.PID_CTOT_MN-( PID_COS_UNIVA*PID_CAN_GEN) AS PID_VAL_RET, PID_GENERA_EMPDET as PIB_GENERA_EMPDET, ISNULL(PID_SERVICIO,'N') AS PID_SERVICIO
FROM         dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.MEDIDA ON dbo.PEDIMPDET.ME_GENERICO = dbo.MEDIDA.ME_CODIGO LEFT OUTER JOIN
                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.PEDIMPDET.AR_IMPMX = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
                      dbo.PAIS ON dbo.PEDIMPDET.PA_ORIGEN = dbo.PAIS.PA_CODIGO LEFT OUTER JOIN
                     dbo.MAESTRO ON  dbo.PEDIMPDET.MA_CODIGO=dbo.MAESTRO.MA_CODIGO
WHERE     (dbo.PEDIMPDET.PID_IMPRIMIR = 'S') AND dbo.PEDIMPDET.PI_CODIGO=07525 
ORDER BY dbo.ARANCEL.AR_FRACCION, dbo.PEDIMPDET.AR_IMPMX, dbo.PEDIMPDET.MA_GENERICO
GO
