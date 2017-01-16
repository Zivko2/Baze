SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW dbo.VKARDESPEDTempMin
with encryption as
SELECT     KARDESPEDTemp.* 
FROM         KARDESPEDTemp left outer join maestro maestrog
	ON KARDESPEDTemp.MA_HIJO=MAESTROg.MA_CODIGO
WHERE    KARDESPEDTemp.kap_codigo in
	(SELECT min(KARDESPEDTempM.KAP_CODIGO)
	 FROM         KARDESPEDTemp KARDESPEDTempM LEFT OUTER JOIN MAESTRO 
		ON KARDESPEDTempM.MA_HIJO=MAESTRO.MA_CODIGO
	WHERE  MAESTRO.MA_GENERICO=MAESTROG.MA_GENERICO AND KARDESPEDTempM.kap_factrans = KARDESPEDTemp.kap_factrans and
		((KARDESPEDTempM.KAP_ESTATUS = 'P' OR
	                      KARDESPEDTempM.KAP_ESTATUS = 'N' ) AND (NOT (KARDESPEDTempM.KAP_INDICED_FACT IN
	                          (SELECT     KARDESPEDTemp1.kap_indiced_fact
	                            FROM          KARDESPEDTemp KARDESPEDTemp1
	                            WHERE      KARDESPEDTemp1.ma_hijo = KARDESPEDTempM.ma_hijo AND KARDESPEDTemp1.kap_estatus = 'D' AND KARDESPEDTemp1.kap_factrans = KARDESPEDTempM.kap_factrans)))
			and (KARDESPEDTempM.kap_padresust is null or KARDESPEDTempM.kap_padresust=0) and KARDESPEDTempM.kap_fiscomp='N')
		or ((KARDESPEDTempM.KAP_ESTATUS = 'P' OR
	                      KARDESPEDTempM.KAP_ESTATUS = 'N') AND (NOT (KARDESPEDTempM.KAP_INDICED_FACT IN
	                          (SELECT     KARDESPEDTemp2.kap_indiced_fact
	                            FROM          KARDESPEDTemp KARDESPEDTemp2
	                            WHERE      KARDESPEDTemp2.ma_hijo = KARDESPEDTempM.ma_hijo AND KARDESPEDTemp2.kap_estatus = 'D' AND KARDESPEDTemp2.kap_factrans = KARDESPEDTempM.kap_factrans)))
			and (KARDESPEDTempM.kap_padresust is not null and KARDESPEDTempM.kap_padresust>0) and KARDESPEDTempM.kap_fiscomp<>'N')
	GROUP BY MAESTRO.MA_GENERICO)






















GO
