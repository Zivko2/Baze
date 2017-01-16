SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VMAESTRO_DETALLE
with encryption as
SELECT     dbo.MAESTRO.MA_CODIGO, MA_NOMBRE, MA_NAME, ME_COM, PA_ORIGEN, MA_GENERICO, AR_RETRA, AR_EXPFO, AR_IMPMX, TI_CODIGO, EQ_GEN, 
                      MA_DEF_TIP, MA_SEC_IMP, round(MA_PESO_KG,6) as MA_PESO_KG, round(MA_PESO_LB,6) as MA_PESO_LB, AR_DESP, MA_INV_GEN, MA_NOPARTE, EQ_IMPMX, EQ_EXPFO, 
                      AR_EXPMX, AR_IMPFO, MA_CANTEMP, EQ_DESP, EQ_RETRA, EQ_IMPFO, EQ_EXPFO2, 
                      EQ_EXPMX, MA_DISCHARGE, MA_EMPAQUE, MA_NOPARTEAUX, PA_PROCEDE, SPI_CODIGO, MA_EST_MAT, AR_IMPFOUSA, 
                      EQ_IMPFOUSA, MA_TIP_ENS, CS_CODIGO, SE_CODIGO, MA_FAMILIA, MA_SERVICIO, MA_ESTRUCTURA,
		ISNULL(ANX_CAS_NUM,'') AS ANX_CAS_NUM, maestroprohibido.MP_PROHIBIDO, maestro.MA_HOJASEGURIDAD
FROM         dbo.MAESTRO LEFT OUTER JOIN ANEXO24 ON dbo.MAESTRO.MA_CODIGO=ANEXO24.MA_CODIGO
			left outer join maestroprohibido on maestro.ma_codigo = maestroprohibido.ma_codigo 
			and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal
WHERE     (MA_OCULTO = 'N') AND (MA_ENUSO='S') and ma_inv_gen='I'
	and (maestroprohibido.MP_PROHIBIDO like case when (select cf_validaMaterialPeligroso from configuracion) = 'S' then 'N' else '%' end
	or maestroprohibido.MP_PROHIBIDO is null)




































































GO
